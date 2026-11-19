import 'dart:convert';

import '../../core/canonical_json.dart';
import '../../core/date_only.dart';

/// Identificador do arquivo de backup do Planner.
const backupFormatName = 'stick2planner-backup';

/// Versão do layout do arquivo. Mudanças incompatíveis exigem incremento.
const backupFormatVersion = 1;

/// Versões de esquema local cujos backups podem ser importados.
const supportedBackupSchemaVersions = <int>{4, 5, 6, 7, 8, 9, 10, 11, 12, 13};

/// Falhas previstas ao ler, validar ou aplicar um backup.
enum BackupErrorCode {
  invalidJson,
  invalidFormat,
  unsupportedFormatVersion,
  unsupportedSchemaVersion,
  checksumMismatch,
  invalidData,
  ioError,
}

final class BackupException implements Exception {
  const BackupException(this.code, [this.detail]);

  final BackupErrorCode code;
  final String? detail;

  @override
  String toString() =>
      'BackupException(${code.name}${detail == null ? '' : ': $detail'})';
}

final class BackupCounts {
  const BackupCounts({
    required this.postIts,
    required this.notes,
    required this.noteLines,
    required this.history,
    required this.settings,
    this.tags = 0,
    this.routines = 0,
  });

  final int postIts;
  final int notes;
  final int noteLines;
  final int history;
  final int settings;
  final int tags;
  final int routines;

  Map<String, Object?> toJson() => {
    'postIts': postIts,
    'notes': notes,
    'noteLines': noteLines,
    'history': history,
    'settings': settings,
    'tags': tags,
    'routines': routines,
  };

  static BackupCounts fromJson(Object? value) {
    final map = _asMap(value, 'counts');
    return BackupCounts(
      postIts: _asInt(map['postIts'], 'counts.postIts'),
      notes: _asInt(map['notes'], 'counts.notes'),
      noteLines: _asInt(map['noteLines'], 'counts.noteLines'),
      history: _asInt(map['history'], 'counts.history'),
      settings: _asInt(map['settings'], 'counts.settings'),
      tags: map['tags'] == null ? 0 : _asInt(map['tags'], 'counts.tags'),
      routines: map['routines'] == null
          ? 0
          : _asInt(map['routines'], 'counts.routines'),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BackupCounts &&
      other.postIts == postIts &&
      other.notes == notes &&
      other.noteLines == noteLines &&
      other.history == history &&
      other.settings == settings &&
      other.tags == tags &&
      other.routines == routines;

  @override
  int get hashCode =>
      Object.hash(postIts, notes, noteLines, history, settings, tags, routines);
}

/// Documento de backup já validado.
final class BackupDocument {
  BackupDocument({
    required this.schemaVersion,
    required this.appVersion,
    required this.exportedAt,
    required this.data,
    this.deviceId,
  }) : counts = _countsOf(data),
       checksum = 'sha256:${canonicalSha256(data)}';

  final int schemaVersion;
  final String appVersion;
  final DateTime exportedAt;
  final String? deviceId;
  final Map<String, Object?> data;
  final BackupCounts counts;
  final String checksum;

  /// Nome sugerido, estável e ordenável.
  String get suggestedFileName {
    final utc = exportedAt.toUtc();
    final stamp =
        '${utc.year.toString().padLeft(4, '0')}'
        '${utc.month.toString().padLeft(2, '0')}'
        '${utc.day.toString().padLeft(2, '0')}-'
        '${utc.hour.toString().padLeft(2, '0')}'
        '${utc.minute.toString().padLeft(2, '0')}'
        '${utc.second.toString().padLeft(2, '0')}';
    return 'stick2planner-$stamp.s2p.json';
  }

  Map<String, Object?> toJson() => {
    'format': backupFormatName,
    'formatVersion': backupFormatVersion,
    'appVersion': appVersion,
    'schemaVersion': schemaVersion,
    'exportedAt': exportedAt.toUtc().toIso8601String(),
    'deviceId': deviceId,
    'counts': counts.toJson(),
    'checksum': checksum,
    'data': data,
  };

  String toJsonString() => const JsonEncoder.withIndent('  ').convert(toJson());

  /// Lê e valida o arquivo sem tocar no banco.
  static BackupDocument parse(String raw) {
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException catch (error) {
      throw BackupException(BackupErrorCode.invalidJson, error.message);
    }

    final root = _asMap(decoded, 'backup');
    if (root['format'] != backupFormatName) {
      throw const BackupException(BackupErrorCode.invalidFormat);
    }

    final formatVersion = _asInt(root['formatVersion'], 'formatVersion');
    if (formatVersion != backupFormatVersion) {
      throw BackupException(
        BackupErrorCode.unsupportedFormatVersion,
        'formatVersion=$formatVersion',
      );
    }

    final schemaVersion = _asInt(root['schemaVersion'], 'schemaVersion');
    if (!supportedBackupSchemaVersions.contains(schemaVersion)) {
      throw BackupException(
        BackupErrorCode.unsupportedSchemaVersion,
        'schemaVersion=$schemaVersion',
      );
    }

    final data = _asMap(root['data'], 'data');
    final expectedChecksum = 'sha256:${canonicalSha256(data)}';
    if (root['checksum'] != expectedChecksum) {
      throw const BackupException(BackupErrorCode.checksumMismatch);
    }

    final counts = BackupCounts.fromJson(root['counts']);
    final activeCounts = _countsOf(data);
    if (counts != activeCounts && counts != _rawCountsOf(data)) {
      throw const BackupException(
        BackupErrorCode.invalidData,
        'contagens divergem do conteúdo',
      );
    }

    final exportedAtRaw = root['exportedAt'];
    if (exportedAtRaw is! String) {
      throw const BackupException(
        BackupErrorCode.invalidData,
        'exportedAt ausente',
      );
    }
    final exportedAt = DateTime.tryParse(exportedAtRaw);
    if (exportedAt == null) {
      throw const BackupException(
        BackupErrorCode.invalidData,
        'exportedAt inválido',
      );
    }

    final appVersion = root['appVersion'];
    if (appVersion is! String || appVersion.isEmpty) {
      throw const BackupException(
        BackupErrorCode.invalidData,
        'appVersion ausente',
      );
    }

    final deviceId = root['deviceId'];
    if (deviceId != null && deviceId is! String) {
      throw const BackupException(
        BackupErrorCode.invalidData,
        'deviceId inválido',
      );
    }

    _validateStructure(data);

    return BackupDocument(
      schemaVersion: schemaVersion,
      appVersion: appVersion,
      exportedAt: exportedAt,
      deviceId: deviceId as String?,
      data: data,
    );
  }

  static BackupCounts _countsOf(Map<String, Object?> data) {
    final postIts = _asList(data['postIts'], 'data.postIts');
    final notes = _asList(data['notes'], 'data.notes');
    final activePostItIds = <String>{};
    for (final entry in postIts) {
      final row = _asMap(entry, 'data.postIts[]');
      if (row['deletedAt'] == null) {
        activePostItIds.add(_asString(row['id'], 'postIts.id'));
      }
    }
    final activeNoteIds = <String>{};
    for (final entry in notes) {
      final row = _asMap(entry, 'data.notes[]');
      if (row['deletedAt'] == null) {
        activeNoteIds.add(_asString(row['id'], 'notes.id'));
      }
    }
    return BackupCounts(
      postIts: activePostItIds.length,
      notes: activeNoteIds.length,
      noteLines: _asList(data['noteLines'], 'data.noteLines').where((entry) {
        final row = _asMap(entry, 'data.noteLines[]');
        return activeNoteIds.contains(row['noteId']);
      }).length,
      history: _asList(data['history'], 'data.history').where((entry) {
        final row = _asMap(entry, 'data.history[]');
        return activePostItIds.contains(row['postItId']);
      }).length,
      settings: _asList(data['settings'], 'data.settings').length,
      tags: _tags(data).where((entry) {
        final row = _asMap(entry, 'data.tags[]');
        return row['deletedAt'] == null;
      }).length,
      routines: _routines(data).length,
    );
  }

  static List<Object?> _tags(Map<String, Object?> data) =>
      data['tags'] is List ? data['tags'] as List : const [];

  static List<Object?> _routines(Map<String, Object?> data) =>
      data['routines'] is List ? data['routines'] as List : const [];

  static BackupCounts _rawCountsOf(Map<String, Object?> data) => BackupCounts(
    postIts: _asList(data['postIts'], 'data.postIts').length,
    notes: _asList(data['notes'], 'data.notes').length,
    noteLines: _asList(data['noteLines'], 'data.noteLines').length,
    history: _asList(data['history'], 'data.history').length,
    settings: _asList(data['settings'], 'data.settings').length,
    tags: _tags(data).length,
    routines: _routines(data).length,
  );

  static void _validateStructure(Map<String, Object?> data) {
    final notes = _asList(data['notes'], 'data.notes');
    final noteIds = <String>{};
    for (final entry in notes) {
      final row = _asMap(entry, 'data.notes[]');
      final id = _asString(row['id'], 'notes.id');
      if (!noteIds.add(id)) {
        throw BackupException(
          BackupErrorCode.invalidData,
          'nota duplicada $id',
        );
      }
      _asString(row['title'], 'notes.title');
      _asString(row['type'], 'notes.type');
      _requiredTimestamp(row['createdAt'], 'notes.createdAt');
      _requiredTimestamp(row['updatedAt'], 'notes.updatedAt');
      _optionalTimestamp(row['deletedAt'], 'notes.deletedAt');
      final markdown = row['markdown'];
      if (markdown != null && markdown is! String) {
        throw const BackupException(
          BackupErrorCode.invalidData,
          'notes.markdown inválido',
        );
      }
    }

    final lines = _asList(data['noteLines'], 'data.noteLines');
    final lineIds = <String>{};
    for (final entry in lines) {
      final row = _asMap(entry, 'data.noteLines[]');
      final id = _asString(row['id'], 'noteLines.id');
      if (!lineIds.add(id)) {
        throw BackupException(
          BackupErrorCode.invalidData,
          'linha duplicada $id',
        );
      }
      final noteId = _asString(row['noteId'], 'noteLines.noteId');
      if (!noteIds.contains(noteId)) {
        throw BackupException(
          BackupErrorCode.invalidData,
          'linha $id aponta para nota ausente $noteId',
        );
      }
      _asInt(row['position'], 'noteLines.position');
      _asString(row['content'], 'noteLines.content');
      _asBool(row['isChecked'], 'noteLines.isChecked');
    }

    final postIts = _asList(data['postIts'], 'data.postIts');
    final postItIds = <String>{};
    for (final entry in postIts) {
      final row = _asMap(entry, 'data.postIts[]');
      final id = _asString(row['id'], 'postIts.id');
      if (!postItIds.add(id)) {
        throw BackupException(
          BackupErrorCode.invalidData,
          'post-it duplicado $id',
        );
      }
      _asString(row['title'], 'postIts.title');
      _asString(row['type'], 'postIts.type');
      _asString(row['status'], 'postIts.status');
      _asBool(row['isHighlight'], 'postIts.isHighlight');
      _asInt(row['sortOrder'], 'postIts.sortOrder');
      _requiredTimestamp(row['createdAt'], 'postIts.createdAt');
      _requiredTimestamp(row['updatedAt'], 'postIts.updatedAt');
      _optionalTimestamp(row['deletedAt'], 'postIts.deletedAt');
      _optionalTimestamp(row['lastRolloverAt'], 'postIts.lastRolloverAt');
      for (final key in const ['details', 'noteExcerpt', 'sourceNoteId']) {
        final value = row[key];
        if (value != null && value is! String) {
          throw BackupException(
            BackupErrorCode.invalidData,
            'postIts.$key inválido',
          );
        }
      }
      for (final key in const ['startDate', 'endDate']) {
        final value = row[key];
        if (value != null && value is! String) {
          throw BackupException(
            BackupErrorCode.invalidData,
            'postIts.$key inválido',
          );
        }
      }
      final recurrence = row['recurrence'];
      if (recurrence != null && recurrence is! String) {
        throw const BackupException(
          BackupErrorCode.invalidData,
          'postIts.recurrence inválido',
        );
      }
      final recurrenceInterval = row['recurrenceInterval'];
      if (recurrenceInterval != null && recurrenceInterval is! int) {
        throw const BackupException(
          BackupErrorCode.invalidData,
          'postIts.recurrenceInterval inválido',
        );
      }
      final seriesId = row['seriesId'];
      if (seriesId != null && (seriesId is! String || seriesId.isEmpty)) {
        throw const BackupException(
          BackupErrorCode.invalidData,
          'postIts.seriesId inválido',
        );
      }
      final timeMinutes = row['timeMinutes'];
      if (timeMinutes != null &&
          (timeMinutes is! int || timeMinutes < 0 || timeMinutes >= 1440)) {
        throw const BackupException(
          BackupErrorCode.invalidData,
          'postIts.timeMinutes inválido',
        );
      }
      final tagIds = row['tagIds'];
      if (tagIds != null &&
          (tagIds is! List || tagIds.any((value) => value is! String))) {
        throw const BackupException(
          BackupErrorCode.invalidData,
          'postIts.tagIds inválido',
        );
      }
      final reminderMinutes = row['reminderMinutes'];
      if (reminderMinutes != null &&
          (reminderMinutes is! int ||
              reminderMinutes < 0 ||
              reminderMinutes > 7 * 24 * 60)) {
        throw const BackupException(
          BackupErrorCode.invalidData,
          'postIts.reminderMinutes inválido',
        );
      }
      final noteId = row['noteId'];
      if (noteId != null) {
        if (noteId is! String || !noteIds.contains(noteId)) {
          throw const BackupException(
            BackupErrorCode.invalidData,
            'postIt aponta para nota ausente',
          );
        }
      }
    }

    final tags = _tags(data);
    final tagIds = <String>{};
    for (final entry in tags) {
      final row = _asMap(entry, 'data.tags[]');
      final id = _asString(row['id'], 'tags.id');
      if (!tagIds.add(id)) {
        throw BackupException(BackupErrorCode.invalidData, 'tag duplicada $id');
      }
      _asString(row['name'], 'tags.name');
      _asString(row['tone'], 'tags.tone');
      _requiredTimestamp(row['createdAt'], 'tags.createdAt');
      _requiredTimestamp(row['updatedAt'], 'tags.updatedAt');
      _optionalTimestamp(row['deletedAt'], 'tags.deletedAt');
    }

    final routines = _routines(data);
    final routineIds = <String>{};
    final itemIds = <String>{};
    final sectionIds = <String>{};
    final intervalIds = <String>{};
    for (final entry in routines) {
      final row = _asMap(entry, 'data.routines[]');
      final id = _asString(row['id'], 'routines.id');
      if (!routineIds.add(id)) {
        throw BackupException(
          BackupErrorCode.invalidData,
          'rotina duplicada $id',
        );
      }
      _asString(row['name'], 'routines.name');
      final mode = _asString(row['mode'], 'routines.mode');
      if (mode != 'simple' && mode != 'complete') {
        throw BackupException(
          BackupErrorCode.invalidData,
          'routines.mode inválido',
        );
      }
      final weekdays = _asList(row['weekdays'], 'routines.weekdays');
      final seenWeekdays = <int>{};
      for (final weekday in weekdays) {
        if (weekday is! int || weekday < 1 || weekday > 7) {
          throw const BackupException(
            BackupErrorCode.invalidData,
            'routines.weekdays inválido',
          );
        }
        if (!seenWeekdays.add(weekday)) {
          throw const BackupException(
            BackupErrorCode.invalidData,
            'routines.weekdays duplicado',
          );
        }
      }
      _requiredTimestamp(row['createdAt'], 'routines.createdAt');
      _requiredTimestamp(row['updatedAt'], 'routines.updatedAt');

      final items = row['items'] == null
          ? const <Object?>[]
          : _asList(row['items'], 'routines.items');
      for (final itemEntry in items) {
        final item = _asMap(itemEntry, 'routines.items[]');
        final itemId = _asString(item['id'], 'routines.items.id');
        if (!itemIds.add(itemId)) {
          throw BackupException(
            BackupErrorCode.invalidData,
            'atividade duplicada $itemId',
          );
        }
        _asString(item['title'], 'routines.items.title');
        _optionalString(item['details'], 'routines.items.details');
        _asInt(item['position'], 'routines.items.position');
        _dates(item['completedDates'], 'routines.items.completedDates');
      }

      final sections = row['sections'] == null
          ? const <Object?>[]
          : _asList(row['sections'], 'routines.sections');
      for (final sectionEntry in sections) {
        final section = _asMap(sectionEntry, 'routines.sections[]');
        final sectionId = _asString(section['id'], 'routines.sections.id');
        if (!sectionIds.add(sectionId)) {
          throw BackupException(
            BackupErrorCode.invalidData,
            'card duplicado $sectionId',
          );
        }
        _asString(section['title'], 'routines.sections.title');
        _asInt(section['position'], 'routines.sections.position');
        final start = _optionalMinutes(
          section['startMinutes'],
          'routines.sections.startMinutes',
        );
        final end = _optionalMinutes(
          section['endMinutes'],
          'routines.sections.endMinutes',
        );
        if ((start == null) != (end == null)) {
          throw const BackupException(
            BackupErrorCode.invalidData,
            'card com apenas um horário',
          );
        }
        if (start != null && end != null && end <= start) {
          throw const BackupException(
            BackupErrorCode.invalidData,
            'fim do card anterior ao início',
          );
        }
        final intervals = section['intervals'] == null
            ? const <Object?>[]
            : _asList(section['intervals'], 'routines.sections.intervals');
        var expectedStart = start;
        for (final intervalEntry in intervals) {
          final interval = _asMap(
            intervalEntry,
            'routines.sections.intervals[]',
          );
          final intervalId = _asString(interval['id'], 'routines.intervals.id');
          if (!intervalIds.add(intervalId)) {
            throw BackupException(
              BackupErrorCode.invalidData,
              'intervalo duplicado $intervalId',
            );
          }
          final intervalStart = _asInt(
            interval['startMinutes'],
            'routines.intervals.startMinutes',
          );
          final intervalEnd = _asInt(
            interval['endMinutes'],
            'routines.intervals.endMinutes',
          );
          if (intervalStart < 0 ||
              intervalEnd > 1440 ||
              intervalStart >= intervalEnd) {
            throw const BackupException(
              BackupErrorCode.invalidData,
              'intervalo com horário inválido',
            );
          }
          if (start != null &&
              end != null &&
              (intervalStart < start || intervalEnd > end)) {
            throw const BackupException(
              BackupErrorCode.invalidData,
              'intervalo fora dos limites do card',
            );
          }
          if (expectedStart != null && intervalStart != expectedStart) {
            throw const BackupException(
              BackupErrorCode.invalidData,
              'intervalos descontínuos',
            );
          }
          expectedStart = intervalEnd;
          _asInt(interval['position'], 'routines.intervals.position');
          _optionalString(interval['title'], 'routines.intervals.title');
          _optionalString(interval['details'], 'routines.intervals.details');
          _dates(
            interval['completedDates'],
            'routines.intervals.completedDates',
          );
        }
        if (start != null && end != null) {
          if (intervals.isEmpty || expectedStart != end) {
            throw const BackupException(
              BackupErrorCode.invalidData,
              'card configurado sem intervalos completos',
            );
          }
        }
      }
    }

    final history = _asList(data['history'], 'data.history');
    final historyIds = <String>{};
    for (final entry in history) {
      final row = _asMap(entry, 'data.history[]');
      final id = _asString(row['id'], 'history.id');
      if (!historyIds.add(id)) {
        throw BackupException(
          BackupErrorCode.invalidData,
          'histórico duplicado $id',
        );
      }
      final postItId = _asString(row['postItId'], 'history.postItId');
      if (!postItIds.contains(postItId)) {
        throw BackupException(
          BackupErrorCode.invalidData,
          'histórico $id aponta para post-it ausente',
        );
      }
      _asString(row['action'], 'history.action');
      _requiredTimestamp(row['createdAt'], 'history.createdAt');
      for (final key in const ['fromValue', 'toValue']) {
        final value = row[key];
        if (value != null && value is! String) {
          throw BackupException(
            BackupErrorCode.invalidData,
            'history.$key inválido',
          );
        }
      }
    }

    final settings = _asList(data['settings'], 'data.settings');
    final settingKeys = <String>{};
    for (final entry in settings) {
      final row = _asMap(entry, 'data.settings[]');
      final key = _asString(row['key'], 'settings.key');
      if (!settingKeys.add(key)) {
        throw BackupException(
          BackupErrorCode.invalidData,
          'preferência duplicada $key',
        );
      }
      _asString(row['value'], 'settings.value');
    }
  }
}

Map<String, Object?> _asMap(Object? value, String field) {
  if (value is Map<String, Object?>) return value;
  if (value is Map) {
    final result = <String, Object?>{};
    for (final entry in value.entries) {
      final key = entry.key;
      if (key is! String) {
        throw BackupException(
          BackupErrorCode.invalidData,
          '$field tem chave não textual',
        );
      }
      result[key] = entry.value;
    }
    return result;
  }
  throw BackupException(BackupErrorCode.invalidData, '$field não é objeto');
}

List<Object?> _asList(Object? value, String field) {
  if (value is List) return value;
  throw BackupException(BackupErrorCode.invalidData, '$field não é lista');
}

String _asString(Object? value, String field) {
  if (value is String) return value;
  throw BackupException(BackupErrorCode.invalidData, '$field não é texto');
}

int _asInt(Object? value, String field) {
  if (value is int) return value;
  if (value is double && value == value.roundToDouble()) {
    return value.toInt();
  }
  throw BackupException(BackupErrorCode.invalidData, '$field não é inteiro');
}

bool _asBool(Object? value, String field) {
  if (value is bool) return value;
  throw BackupException(BackupErrorCode.invalidData, '$field não é booleano');
}

int _requiredTimestamp(Object? value, String field) {
  final text = _asString(value, field);
  final parsed = DateTime.tryParse(text);
  if (parsed == null) {
    throw BackupException(BackupErrorCode.invalidData, '$field inválido');
  }
  return parsed.toUtc().millisecondsSinceEpoch;
}

void _optionalTimestamp(Object? value, String field) {
  if (value == null) return;
  _requiredTimestamp(value, field);
}

String? _optionalString(Object? value, String field) {
  if (value == null) return null;
  return _asString(value, field);
}

int? _optionalMinutes(Object? value, String field) {
  if (value == null) return null;
  final minutes = _asInt(value, field);
  if (minutes < 0 || minutes > 1440) {
    throw BackupException(BackupErrorCode.invalidData, '$field inválido');
  }
  return minutes;
}

List<String> _dates(Object? value, String field) {
  if (value == null) return const [];
  final entries = _asList(value, field);
  final dates = <String>[];
  for (final entry in entries) {
    final text = _asString(entry, field);
    try {
      DateOnly.parse(text);
    } on FormatException {
      throw BackupException(BackupErrorCode.invalidData, '$field inválido');
    }
    dates.add(text);
  }
  return dates;
}
