import '../../core/canonical_json.dart';

/// Sentinela para chaves ausentes durante a mesclagem.
const _Absent _absent = _Absent();

/// Sentinela para alterações incompatíveis dos dois lados.
const _Conflict _conflict = _Conflict();

/// Mescla três versões de um payload `routine` usando IDs estáveis.
///
/// Retorna `null` quando os dois lados alteraram o mesmo campo ou o mesmo
/// elemento de formas diferentes. Nesse caso o fluxo normal de conflito/cópia
/// continua valendo, sem descartar dados silenciosamente.
Map<String, Object?>? mergeRoutinePayloads({
  required Map<String, Object?> base,
  required Map<String, Object?> local,
  required Map<String, Object?> server,
}) {
  final result = _mergeValue(base, local, server);
  if (identical(result, _conflict) || result is! Map) return null;
  final merged = Map<String, Object?>.from(result);

  final localTime = DateTime.tryParse((local['updatedAt'] as String?) ?? '');
  final serverTime = DateTime.tryParse((server['updatedAt'] as String?) ?? '');
  final latest = switch ((localTime, serverTime)) {
    (final DateTime a, final DateTime b) => a.isAfter(b) ? a : b,
    (final DateTime a, null) => a,
    (null, final DateTime b) => b,
    _ => null,
  };
  if (latest != null) {
    merged['updatedAt'] = latest.toUtc().toIso8601String();
  }

  _normalizeRoutine(merged);
  return merged;
}

Object? _mergeValue(Object? base, Object? local, Object? server) {
  if (_same(local, server)) return local;
  if (_same(local, base)) return server;
  if (_same(server, base)) return local;

  if (local is Map && server is Map) {
    return _mergeMaps(base, local, server);
  }
  if (local is List && server is List) {
    return _mergeLists(base, local, server);
  }
  return _conflict;
}

Object? _mergeMaps(
  Object? base,
  Map<Object?, Object?> local,
  Map<Object?, Object?> server,
) {
  final baseMap = base is Map ? base : const <Object?, Object?>{};
  final keys = <Object?>{...baseMap.keys, ...local.keys, ...server.keys};
  final result = <String, Object?>{};
  for (final key in keys) {
    if (key == 'updatedAt') continue;
    final baseValue = baseMap.containsKey(key) ? baseMap[key] : _absent;
    final localValue = local.containsKey(key) ? local[key] : _absent;
    final serverValue = server.containsKey(key) ? server[key] : _absent;
    final value = _mergeValue(baseValue, localValue, serverValue);
    if (identical(value, _conflict)) return _conflict;
    if (identical(value, _absent)) continue;
    result['$key'] = value;
  }
  return result;
}

Object? _mergeLists(Object? base, List<Object?> local, List<Object?> server) {
  final baseList = base is List ? base : const <Object?>[];
  final localKeyed = _keyed(local);
  final serverKeyed = _keyed(server);
  final baseKeyed = _keyed(baseList);
  final hasKeyed =
      localKeyed != null || serverKeyed != null || baseKeyed != null;
  final canBeKeyed =
      (local.isEmpty || localKeyed != null) &&
      (server.isEmpty || serverKeyed != null) &&
      (baseList.isEmpty || baseKeyed != null);
  if (hasKeyed && canBeKeyed) {
    return _mergeKeyedLists(
      baseKeyed ?? const {},
      localKeyed ?? const {},
      serverKeyed ?? const {},
    );
  }
  return _mergeScalarLists(baseList, local, server);
}

Map<String, Object?>? _keyed(List<Object?> values) {
  final result = <String, Object?>{};
  for (final value in values) {
    if (value is! Map) return null;
    final id = value['id'];
    if (id is! String || id.isEmpty) return null;
    result[id] = value;
  }
  return result;
}

Object? _mergeKeyedLists(
  Map<String, Object?> base,
  Map<String, Object?> local,
  Map<String, Object?> server,
) {
  final ids = <String>{...base.keys, ...local.keys, ...server.keys};
  final result = <Object?>[];
  for (final id in ids) {
    final value = _mergeValue(
      base.containsKey(id) ? base[id] : _absent,
      local.containsKey(id) ? local[id] : _absent,
      server.containsKey(id) ? server[id] : _absent,
    );
    if (identical(value, _conflict)) return _conflict;
    if (identical(value, _absent)) continue;
    result.add(value);
  }
  return result;
}

Object? _mergeScalarLists(
  List<Object?> base,
  List<Object?> local,
  List<Object?> server,
) {
  for (final value in [...base, ...local, ...server]) {
    if (value is Map || value is List) return _conflict;
  }
  bool inList(List<Object?> list, Object? value) {
    final key = _key(value);
    return list.any((item) => _key(item) == key);
  }

  final selected = <String>{};
  for (final value in <Object?>[...base, ...local, ...server]) {
    final key = _key(value);
    final inBase = inList(base, value);
    final inLocal = inList(local, value);
    final inServer = inList(server, value);
    final bool keep;
    if (inLocal == inServer) {
      keep = inLocal;
    } else if (inLocal == inBase) {
      keep = inServer;
    } else if (inServer == inBase) {
      keep = inLocal;
    } else {
      return _conflict;
    }
    if (keep) selected.add(key);
  }

  final result = <Object?>[];
  final seen = <String>{};
  for (final value in [...local, ...server, ...base]) {
    final key = _key(value);
    if (!selected.contains(key) || !seen.add(key)) continue;
    result.add(value);
  }
  return result;
}

bool _same(Object? first, Object? second) {
  if (identical(first, second)) return true;
  if (first is _Absent || second is _Absent) return false;
  return canonicalJsonEncode(first) == canonicalJsonEncode(second);
}

String _key(Object? value) => canonicalJsonEncode(value);

void _normalizeRoutine(Map<String, Object?> routine) {
  _sortScalarList(routine['weekdays']);
  final items = routine['items'];
  if (items is List) {
    for (final item in items) {
      if (item is Map) _sortDates(item['completedDates']);
    }
    items.sort(_byPosition);
  }
  final sections = routine['sections'];
  if (sections is List) {
    for (final section in sections) {
      if (section is! Map) continue;
      final intervals = section['intervals'];
      if (intervals is List) {
        for (final interval in intervals) {
          if (interval is Map) _sortDates(interval['completedDates']);
        }
        intervals.sort(_byPosition);
      }
    }
    sections.sort(_byPosition);
  }
}

void _sortScalarList(Object? value) {
  if (value is! List) return;
  if (value.every((item) => item is num)) {
    value.sort((a, b) => (a as num).compareTo(b as num));
  } else if (value.every((item) => item is String)) {
    value.sort((a, b) => (a as String).compareTo(b as String));
  }
}

void _sortDates(Object? value) {
  if (value is! List) return;
  value.sort((a, b) => '$a'.compareTo('$b'));
}

int _byPosition(Object? first, Object? second) {
  if (first is! Map || second is! Map) return 0;
  final a = first['position'];
  final b = second['position'];
  if (a is int && b is int && a != b) return a.compareTo(b);
  return '${first['id']}'.compareTo('${second['id']}');
}

class _Absent {
  const _Absent();
}

class _Conflict {
  const _Conflict();
}
