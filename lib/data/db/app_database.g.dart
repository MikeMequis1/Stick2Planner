// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, NoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<NoteType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<NoteType>($NotesTable.$convertertype);
  static const VerificationMeta _markdownMeta = const VerificationMeta(
    'markdown',
  );
  @override
  late final GeneratedColumn<String> markdown = GeneratedColumn<String>(
    'markdown',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    type,
    markdown,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('markdown')) {
      context.handle(
        _markdownMeta,
        markdown.isAcceptableOrUnknown(data['markdown']!, _markdownMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      type: $NotesTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      markdown: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}markdown'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<NoteType, String, String> $convertertype =
      const EnumNameConverter<NoteType>(NoteType.values);
}

class NoteRow extends DataClass implements Insertable<NoteRow> {
  final String id;
  final String title;
  final NoteType type;
  final String? markdown;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  const NoteRow({
    required this.id,
    required this.title,
    required this.type,
    this.markdown,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    {
      map['type'] = Variable<String>($NotesTable.$convertertype.toSql(type));
    }
    if (!nullToAbsent || markdown != null) {
      map['markdown'] = Variable<String>(markdown);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      title: Value(title),
      type: Value(type),
      markdown: markdown == null && nullToAbsent
          ? const Value.absent()
          : Value(markdown),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory NoteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      type: $NotesTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      markdown: serializer.fromJson<String?>(json['markdown']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'type': serializer.toJson<String>(
        $NotesTable.$convertertype.toJson(type),
      ),
      'markdown': serializer.toJson<String?>(markdown),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  NoteRow copyWith({
    String? id,
    String? title,
    NoteType? type,
    Value<String?> markdown = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
  }) => NoteRow(
    id: id ?? this.id,
    title: title ?? this.title,
    type: type ?? this.type,
    markdown: markdown.present ? markdown.value : this.markdown,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  NoteRow copyWithCompanion(NotesCompanion data) {
    return NoteRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      type: data.type.present ? data.type.value : this.type,
      markdown: data.markdown.present ? data.markdown.value : this.markdown,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('markdown: $markdown, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, type, markdown, createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.type == this.type &&
          other.markdown == this.markdown &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class NotesCompanion extends UpdateCompanion<NoteRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<NoteType> type;
  final Value<String?> markdown;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.type = const Value.absent(),
    this.markdown = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotesCompanion.insert({
    required String id,
    required String title,
    required NoteType type,
    this.markdown = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       type = Value(type),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<NoteRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? type,
    Expression<String>? markdown,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (type != null) 'type': type,
      if (markdown != null) 'markdown': markdown,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<NoteType>? type,
    Value<String?>? markdown,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return NotesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      markdown: markdown ?? this.markdown,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $NotesTable.$convertertype.toSql(type.value),
      );
    }
    if (markdown.present) {
      map['markdown'] = Variable<String>(markdown.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('markdown: $markdown, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NoteLinesTable extends NoteLines
    with TableInfo<$NoteLinesTable, NoteLineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NoteLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
  @override
  late final GeneratedColumn<String> noteId = GeneratedColumn<String>(
    'note_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES notes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCheckedMeta = const VerificationMeta(
    'isChecked',
  );
  @override
  late final GeneratedColumn<bool> isChecked = GeneratedColumn<bool>(
    'is_checked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_checked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    noteId,
    position,
    content,
    isChecked,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'note_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteLineRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('note_id')) {
      context.handle(
        _noteIdMeta,
        noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_noteIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('is_checked')) {
      context.handle(
        _isCheckedMeta,
        isChecked.isAcceptableOrUnknown(data['is_checked']!, _isCheckedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NoteLineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteLineRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      noteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      isChecked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_checked'],
      )!,
    );
  }

  @override
  $NoteLinesTable createAlias(String alias) {
    return $NoteLinesTable(attachedDatabase, alias);
  }
}

class NoteLineRow extends DataClass implements Insertable<NoteLineRow> {
  final String id;
  final String noteId;
  final int position;
  final String content;
  final bool isChecked;
  const NoteLineRow({
    required this.id,
    required this.noteId,
    required this.position,
    required this.content,
    required this.isChecked,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['note_id'] = Variable<String>(noteId);
    map['position'] = Variable<int>(position);
    map['content'] = Variable<String>(content);
    map['is_checked'] = Variable<bool>(isChecked);
    return map;
  }

  NoteLinesCompanion toCompanion(bool nullToAbsent) {
    return NoteLinesCompanion(
      id: Value(id),
      noteId: Value(noteId),
      position: Value(position),
      content: Value(content),
      isChecked: Value(isChecked),
    );
  }

  factory NoteLineRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteLineRow(
      id: serializer.fromJson<String>(json['id']),
      noteId: serializer.fromJson<String>(json['noteId']),
      position: serializer.fromJson<int>(json['position']),
      content: serializer.fromJson<String>(json['content']),
      isChecked: serializer.fromJson<bool>(json['isChecked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'noteId': serializer.toJson<String>(noteId),
      'position': serializer.toJson<int>(position),
      'content': serializer.toJson<String>(content),
      'isChecked': serializer.toJson<bool>(isChecked),
    };
  }

  NoteLineRow copyWith({
    String? id,
    String? noteId,
    int? position,
    String? content,
    bool? isChecked,
  }) => NoteLineRow(
    id: id ?? this.id,
    noteId: noteId ?? this.noteId,
    position: position ?? this.position,
    content: content ?? this.content,
    isChecked: isChecked ?? this.isChecked,
  );
  NoteLineRow copyWithCompanion(NoteLinesCompanion data) {
    return NoteLineRow(
      id: data.id.present ? data.id.value : this.id,
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      position: data.position.present ? data.position.value : this.position,
      content: data.content.present ? data.content.value : this.content,
      isChecked: data.isChecked.present ? data.isChecked.value : this.isChecked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteLineRow(')
          ..write('id: $id, ')
          ..write('noteId: $noteId, ')
          ..write('position: $position, ')
          ..write('content: $content, ')
          ..write('isChecked: $isChecked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, noteId, position, content, isChecked);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteLineRow &&
          other.id == this.id &&
          other.noteId == this.noteId &&
          other.position == this.position &&
          other.content == this.content &&
          other.isChecked == this.isChecked);
}

class NoteLinesCompanion extends UpdateCompanion<NoteLineRow> {
  final Value<String> id;
  final Value<String> noteId;
  final Value<int> position;
  final Value<String> content;
  final Value<bool> isChecked;
  final Value<int> rowid;
  const NoteLinesCompanion({
    this.id = const Value.absent(),
    this.noteId = const Value.absent(),
    this.position = const Value.absent(),
    this.content = const Value.absent(),
    this.isChecked = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NoteLinesCompanion.insert({
    required String id,
    required String noteId,
    required int position,
    required String content,
    this.isChecked = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       noteId = Value(noteId),
       position = Value(position),
       content = Value(content);
  static Insertable<NoteLineRow> custom({
    Expression<String>? id,
    Expression<String>? noteId,
    Expression<int>? position,
    Expression<String>? content,
    Expression<bool>? isChecked,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (noteId != null) 'note_id': noteId,
      if (position != null) 'position': position,
      if (content != null) 'content': content,
      if (isChecked != null) 'is_checked': isChecked,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NoteLinesCompanion copyWith({
    Value<String>? id,
    Value<String>? noteId,
    Value<int>? position,
    Value<String>? content,
    Value<bool>? isChecked,
    Value<int>? rowid,
  }) {
    return NoteLinesCompanion(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      position: position ?? this.position,
      content: content ?? this.content,
      isChecked: isChecked ?? this.isChecked,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (noteId.present) {
      map['note_id'] = Variable<String>(noteId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (isChecked.present) {
      map['is_checked'] = Variable<bool>(isChecked.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoteLinesCompanion(')
          ..write('id: $id, ')
          ..write('noteId: $noteId, ')
          ..write('position: $position, ')
          ..write('content: $content, ')
          ..write('isChecked: $isChecked, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PostItsTable extends PostIts with TableInfo<$PostItsTable, PostItRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PostItsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PostItType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PostItType>($PostItsTable.$convertertype);
  @override
  late final GeneratedColumnWithTypeConverter<PostItStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PostItStatus>($PostItsTable.$converterstatus);
  static const VerificationMeta _isHighlightMeta = const VerificationMeta(
    'isHighlight',
  );
  @override
  late final GeneratedColumn<bool> isHighlight = GeneratedColumn<bool>(
    'is_highlight',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_highlight" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _detailsMeta = const VerificationMeta(
    'details',
  );
  @override
  late final GeneratedColumn<String> details = GeneratedColumn<String>(
    'details',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
  @override
  late final GeneratedColumn<String> noteId = GeneratedColumn<String>(
    'note_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES notes (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _noteExcerptMeta = const VerificationMeta(
    'noteExcerpt',
  );
  @override
  late final GeneratedColumn<String> noteExcerpt = GeneratedColumn<String>(
    'note_excerpt',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceNoteIdMeta = const VerificationMeta(
    'sourceNoteId',
  );
  @override
  late final GeneratedColumn<String> sourceNoteId = GeneratedColumn<String>(
    'source_note_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateOnly?, String> startDate =
      GeneratedColumn<String>(
        'start_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateOnly?>($PostItsTable.$converterstartDaten);
  @override
  late final GeneratedColumnWithTypeConverter<DateOnly?, String> endDate =
      GeneratedColumn<String>(
        'end_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateOnly?>($PostItsTable.$converterendDaten);
  @override
  late final GeneratedColumnWithTypeConverter<EventRecurrence, String>
  recurrence = GeneratedColumn<String>(
    'recurrence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  ).withConverter<EventRecurrence>($PostItsTable.$converterrecurrence);
  static const VerificationMeta _recurrenceIntervalMeta =
      const VerificationMeta('recurrenceInterval');
  @override
  late final GeneratedColumn<int> recurrenceInterval = GeneratedColumn<int>(
    'recurrence_interval',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateOnly?, String>
  recurrenceEndDate = GeneratedColumn<String>(
    'recurrence_end_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<DateOnly?>($PostItsTable.$converterrecurrenceEndDaten);
  static const VerificationMeta _seriesIdMeta = const VerificationMeta(
    'seriesId',
  );
  @override
  late final GeneratedColumn<String> seriesId = GeneratedColumn<String>(
    'series_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<
    Map<DateOnly, PostItStatus>,
    String
  >
  occurrenceStatuses =
      GeneratedColumn<String>(
        'occurrence_statuses',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      ).withConverter<Map<DateOnly, PostItStatus>>(
        $PostItsTable.$converteroccurrenceStatuses,
      );
  static const VerificationMeta _timeMinutesMeta = const VerificationMeta(
    'timeMinutes',
  );
  @override
  late final GeneratedColumn<int> timeMinutes = GeneratedColumn<int>(
    'time_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderMinutesMeta = const VerificationMeta(
    'reminderMinutes',
  );
  @override
  late final GeneratedColumn<int> reminderMinutes = GeneratedColumn<int>(
    'reminder_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> tagIds =
      GeneratedColumn<String>(
        'tag_ids',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<String>>($PostItsTable.$convertertagIds);
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastRolloverAtMeta = const VerificationMeta(
    'lastRolloverAt',
  );
  @override
  late final GeneratedColumn<int> lastRolloverAt = GeneratedColumn<int>(
    'last_rollover_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    type,
    status,
    isHighlight,
    details,
    noteId,
    noteExcerpt,
    sourceNoteId,
    startDate,
    endDate,
    recurrence,
    recurrenceInterval,
    recurrenceEndDate,
    seriesId,
    occurrenceStatuses,
    timeMinutes,
    reminderMinutes,
    tagIds,
    sortOrder,
    lastRolloverAt,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'post_its';
  @override
  VerificationContext validateIntegrity(
    Insertable<PostItRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('is_highlight')) {
      context.handle(
        _isHighlightMeta,
        isHighlight.isAcceptableOrUnknown(
          data['is_highlight']!,
          _isHighlightMeta,
        ),
      );
    }
    if (data.containsKey('details')) {
      context.handle(
        _detailsMeta,
        details.isAcceptableOrUnknown(data['details']!, _detailsMeta),
      );
    }
    if (data.containsKey('note_id')) {
      context.handle(
        _noteIdMeta,
        noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta),
      );
    }
    if (data.containsKey('note_excerpt')) {
      context.handle(
        _noteExcerptMeta,
        noteExcerpt.isAcceptableOrUnknown(
          data['note_excerpt']!,
          _noteExcerptMeta,
        ),
      );
    }
    if (data.containsKey('source_note_id')) {
      context.handle(
        _sourceNoteIdMeta,
        sourceNoteId.isAcceptableOrUnknown(
          data['source_note_id']!,
          _sourceNoteIdMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_interval')) {
      context.handle(
        _recurrenceIntervalMeta,
        recurrenceInterval.isAcceptableOrUnknown(
          data['recurrence_interval']!,
          _recurrenceIntervalMeta,
        ),
      );
    }
    if (data.containsKey('series_id')) {
      context.handle(
        _seriesIdMeta,
        seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta),
      );
    }
    if (data.containsKey('time_minutes')) {
      context.handle(
        _timeMinutesMeta,
        timeMinutes.isAcceptableOrUnknown(
          data['time_minutes']!,
          _timeMinutesMeta,
        ),
      );
    }
    if (data.containsKey('reminder_minutes')) {
      context.handle(
        _reminderMinutesMeta,
        reminderMinutes.isAcceptableOrUnknown(
          data['reminder_minutes']!,
          _reminderMinutesMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('last_rollover_at')) {
      context.handle(
        _lastRolloverAtMeta,
        lastRolloverAt.isAcceptableOrUnknown(
          data['last_rollover_at']!,
          _lastRolloverAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PostItRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PostItRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      type: $PostItsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      status: $PostItsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      isHighlight: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_highlight'],
      )!,
      details: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details'],
      ),
      noteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_id'],
      ),
      noteExcerpt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_excerpt'],
      ),
      sourceNoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_note_id'],
      ),
      startDate: $PostItsTable.$converterstartDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}start_date'],
        ),
      ),
      endDate: $PostItsTable.$converterendDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}end_date'],
        ),
      ),
      recurrence: $PostItsTable.$converterrecurrence.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}recurrence'],
        )!,
      ),
      recurrenceInterval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recurrence_interval'],
      )!,
      recurrenceEndDate: $PostItsTable.$converterrecurrenceEndDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}recurrence_end_date'],
        ),
      ),
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series_id'],
      ),
      occurrenceStatuses: $PostItsTable.$converteroccurrenceStatuses.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}occurrence_statuses'],
        )!,
      ),
      timeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_minutes'],
      ),
      reminderMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_minutes'],
      ),
      tagIds: $PostItsTable.$convertertagIds.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tag_ids'],
        )!,
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      lastRolloverAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_rollover_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $PostItsTable createAlias(String alias) {
    return $PostItsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PostItType, String, String> $convertertype =
      const EnumNameConverter<PostItType>(PostItType.values);
  static JsonTypeConverter2<PostItStatus, String, String> $converterstatus =
      const EnumNameConverter<PostItStatus>(PostItStatus.values);
  static TypeConverter<DateOnly, String> $converterstartDate =
      const DateOnlyConverter();
  static TypeConverter<DateOnly?, String?> $converterstartDaten =
      NullAwareTypeConverter.wrap($converterstartDate);
  static TypeConverter<DateOnly, String> $converterendDate =
      const DateOnlyConverter();
  static TypeConverter<DateOnly?, String?> $converterendDaten =
      NullAwareTypeConverter.wrap($converterendDate);
  static JsonTypeConverter2<EventRecurrence, String, String>
  $converterrecurrence = const EnumNameConverter<EventRecurrence>(
    EventRecurrence.values,
  );
  static TypeConverter<DateOnly, String> $converterrecurrenceEndDate =
      const DateOnlyConverter();
  static TypeConverter<DateOnly?, String?> $converterrecurrenceEndDaten =
      NullAwareTypeConverter.wrap($converterrecurrenceEndDate);
  static TypeConverter<Map<DateOnly, PostItStatus>, String>
  $converteroccurrenceStatuses = const OccurrenceStatusesConverter();
  static TypeConverter<List<String>, String> $convertertagIds =
      const TagIdsConverter();
}

class PostItRow extends DataClass implements Insertable<PostItRow> {
  final String id;
  final String title;
  final PostItType type;
  final PostItStatus status;
  final bool isHighlight;
  final String? details;
  final String? noteId;
  final String? noteExcerpt;
  final String? sourceNoteId;
  final DateOnly? startDate;
  final DateOnly? endDate;
  final EventRecurrence recurrence;
  final int recurrenceInterval;
  final DateOnly? recurrenceEndDate;
  final String? seriesId;
  final Map<DateOnly, PostItStatus> occurrenceStatuses;
  final int? timeMinutes;
  final int? reminderMinutes;
  final List<String> tagIds;
  final int sortOrder;
  final int? lastRolloverAt;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  const PostItRow({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.isHighlight,
    this.details,
    this.noteId,
    this.noteExcerpt,
    this.sourceNoteId,
    this.startDate,
    this.endDate,
    required this.recurrence,
    required this.recurrenceInterval,
    this.recurrenceEndDate,
    this.seriesId,
    required this.occurrenceStatuses,
    this.timeMinutes,
    this.reminderMinutes,
    required this.tagIds,
    required this.sortOrder,
    this.lastRolloverAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    {
      map['type'] = Variable<String>($PostItsTable.$convertertype.toSql(type));
    }
    {
      map['status'] = Variable<String>(
        $PostItsTable.$converterstatus.toSql(status),
      );
    }
    map['is_highlight'] = Variable<bool>(isHighlight);
    if (!nullToAbsent || details != null) {
      map['details'] = Variable<String>(details);
    }
    if (!nullToAbsent || noteId != null) {
      map['note_id'] = Variable<String>(noteId);
    }
    if (!nullToAbsent || noteExcerpt != null) {
      map['note_excerpt'] = Variable<String>(noteExcerpt);
    }
    if (!nullToAbsent || sourceNoteId != null) {
      map['source_note_id'] = Variable<String>(sourceNoteId);
    }
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<String>(
        $PostItsTable.$converterstartDaten.toSql(startDate),
      );
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<String>(
        $PostItsTable.$converterendDaten.toSql(endDate),
      );
    }
    {
      map['recurrence'] = Variable<String>(
        $PostItsTable.$converterrecurrence.toSql(recurrence),
      );
    }
    map['recurrence_interval'] = Variable<int>(recurrenceInterval);
    if (!nullToAbsent || recurrenceEndDate != null) {
      map['recurrence_end_date'] = Variable<String>(
        $PostItsTable.$converterrecurrenceEndDaten.toSql(recurrenceEndDate),
      );
    }
    if (!nullToAbsent || seriesId != null) {
      map['series_id'] = Variable<String>(seriesId);
    }
    {
      map['occurrence_statuses'] = Variable<String>(
        $PostItsTable.$converteroccurrenceStatuses.toSql(occurrenceStatuses),
      );
    }
    if (!nullToAbsent || timeMinutes != null) {
      map['time_minutes'] = Variable<int>(timeMinutes);
    }
    if (!nullToAbsent || reminderMinutes != null) {
      map['reminder_minutes'] = Variable<int>(reminderMinutes);
    }
    {
      map['tag_ids'] = Variable<String>(
        $PostItsTable.$convertertagIds.toSql(tagIds),
      );
    }
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || lastRolloverAt != null) {
      map['last_rollover_at'] = Variable<int>(lastRolloverAt);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  PostItsCompanion toCompanion(bool nullToAbsent) {
    return PostItsCompanion(
      id: Value(id),
      title: Value(title),
      type: Value(type),
      status: Value(status),
      isHighlight: Value(isHighlight),
      details: details == null && nullToAbsent
          ? const Value.absent()
          : Value(details),
      noteId: noteId == null && nullToAbsent
          ? const Value.absent()
          : Value(noteId),
      noteExcerpt: noteExcerpt == null && nullToAbsent
          ? const Value.absent()
          : Value(noteExcerpt),
      sourceNoteId: sourceNoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceNoteId),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      recurrence: Value(recurrence),
      recurrenceInterval: Value(recurrenceInterval),
      recurrenceEndDate: recurrenceEndDate == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceEndDate),
      seriesId: seriesId == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesId),
      occurrenceStatuses: Value(occurrenceStatuses),
      timeMinutes: timeMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(timeMinutes),
      reminderMinutes: reminderMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderMinutes),
      tagIds: Value(tagIds),
      sortOrder: Value(sortOrder),
      lastRolloverAt: lastRolloverAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastRolloverAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory PostItRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PostItRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      type: $PostItsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      status: $PostItsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      isHighlight: serializer.fromJson<bool>(json['isHighlight']),
      details: serializer.fromJson<String?>(json['details']),
      noteId: serializer.fromJson<String?>(json['noteId']),
      noteExcerpt: serializer.fromJson<String?>(json['noteExcerpt']),
      sourceNoteId: serializer.fromJson<String?>(json['sourceNoteId']),
      startDate: serializer.fromJson<DateOnly?>(json['startDate']),
      endDate: serializer.fromJson<DateOnly?>(json['endDate']),
      recurrence: $PostItsTable.$converterrecurrence.fromJson(
        serializer.fromJson<String>(json['recurrence']),
      ),
      recurrenceInterval: serializer.fromJson<int>(json['recurrenceInterval']),
      recurrenceEndDate: serializer.fromJson<DateOnly?>(
        json['recurrenceEndDate'],
      ),
      seriesId: serializer.fromJson<String?>(json['seriesId']),
      occurrenceStatuses: serializer.fromJson<Map<DateOnly, PostItStatus>>(
        json['occurrenceStatuses'],
      ),
      timeMinutes: serializer.fromJson<int?>(json['timeMinutes']),
      reminderMinutes: serializer.fromJson<int?>(json['reminderMinutes']),
      tagIds: serializer.fromJson<List<String>>(json['tagIds']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      lastRolloverAt: serializer.fromJson<int?>(json['lastRolloverAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'type': serializer.toJson<String>(
        $PostItsTable.$convertertype.toJson(type),
      ),
      'status': serializer.toJson<String>(
        $PostItsTable.$converterstatus.toJson(status),
      ),
      'isHighlight': serializer.toJson<bool>(isHighlight),
      'details': serializer.toJson<String?>(details),
      'noteId': serializer.toJson<String?>(noteId),
      'noteExcerpt': serializer.toJson<String?>(noteExcerpt),
      'sourceNoteId': serializer.toJson<String?>(sourceNoteId),
      'startDate': serializer.toJson<DateOnly?>(startDate),
      'endDate': serializer.toJson<DateOnly?>(endDate),
      'recurrence': serializer.toJson<String>(
        $PostItsTable.$converterrecurrence.toJson(recurrence),
      ),
      'recurrenceInterval': serializer.toJson<int>(recurrenceInterval),
      'recurrenceEndDate': serializer.toJson<DateOnly?>(recurrenceEndDate),
      'seriesId': serializer.toJson<String?>(seriesId),
      'occurrenceStatuses': serializer.toJson<Map<DateOnly, PostItStatus>>(
        occurrenceStatuses,
      ),
      'timeMinutes': serializer.toJson<int?>(timeMinutes),
      'reminderMinutes': serializer.toJson<int?>(reminderMinutes),
      'tagIds': serializer.toJson<List<String>>(tagIds),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'lastRolloverAt': serializer.toJson<int?>(lastRolloverAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  PostItRow copyWith({
    String? id,
    String? title,
    PostItType? type,
    PostItStatus? status,
    bool? isHighlight,
    Value<String?> details = const Value.absent(),
    Value<String?> noteId = const Value.absent(),
    Value<String?> noteExcerpt = const Value.absent(),
    Value<String?> sourceNoteId = const Value.absent(),
    Value<DateOnly?> startDate = const Value.absent(),
    Value<DateOnly?> endDate = const Value.absent(),
    EventRecurrence? recurrence,
    int? recurrenceInterval,
    Value<DateOnly?> recurrenceEndDate = const Value.absent(),
    Value<String?> seriesId = const Value.absent(),
    Map<DateOnly, PostItStatus>? occurrenceStatuses,
    Value<int?> timeMinutes = const Value.absent(),
    Value<int?> reminderMinutes = const Value.absent(),
    List<String>? tagIds,
    int? sortOrder,
    Value<int?> lastRolloverAt = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
  }) => PostItRow(
    id: id ?? this.id,
    title: title ?? this.title,
    type: type ?? this.type,
    status: status ?? this.status,
    isHighlight: isHighlight ?? this.isHighlight,
    details: details.present ? details.value : this.details,
    noteId: noteId.present ? noteId.value : this.noteId,
    noteExcerpt: noteExcerpt.present ? noteExcerpt.value : this.noteExcerpt,
    sourceNoteId: sourceNoteId.present ? sourceNoteId.value : this.sourceNoteId,
    startDate: startDate.present ? startDate.value : this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    recurrence: recurrence ?? this.recurrence,
    recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
    recurrenceEndDate: recurrenceEndDate.present
        ? recurrenceEndDate.value
        : this.recurrenceEndDate,
    seriesId: seriesId.present ? seriesId.value : this.seriesId,
    occurrenceStatuses: occurrenceStatuses ?? this.occurrenceStatuses,
    timeMinutes: timeMinutes.present ? timeMinutes.value : this.timeMinutes,
    reminderMinutes: reminderMinutes.present
        ? reminderMinutes.value
        : this.reminderMinutes,
    tagIds: tagIds ?? this.tagIds,
    sortOrder: sortOrder ?? this.sortOrder,
    lastRolloverAt: lastRolloverAt.present
        ? lastRolloverAt.value
        : this.lastRolloverAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  PostItRow copyWithCompanion(PostItsCompanion data) {
    return PostItRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      type: data.type.present ? data.type.value : this.type,
      status: data.status.present ? data.status.value : this.status,
      isHighlight: data.isHighlight.present
          ? data.isHighlight.value
          : this.isHighlight,
      details: data.details.present ? data.details.value : this.details,
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      noteExcerpt: data.noteExcerpt.present
          ? data.noteExcerpt.value
          : this.noteExcerpt,
      sourceNoteId: data.sourceNoteId.present
          ? data.sourceNoteId.value
          : this.sourceNoteId,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      recurrence: data.recurrence.present
          ? data.recurrence.value
          : this.recurrence,
      recurrenceInterval: data.recurrenceInterval.present
          ? data.recurrenceInterval.value
          : this.recurrenceInterval,
      recurrenceEndDate: data.recurrenceEndDate.present
          ? data.recurrenceEndDate.value
          : this.recurrenceEndDate,
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      occurrenceStatuses: data.occurrenceStatuses.present
          ? data.occurrenceStatuses.value
          : this.occurrenceStatuses,
      timeMinutes: data.timeMinutes.present
          ? data.timeMinutes.value
          : this.timeMinutes,
      reminderMinutes: data.reminderMinutes.present
          ? data.reminderMinutes.value
          : this.reminderMinutes,
      tagIds: data.tagIds.present ? data.tagIds.value : this.tagIds,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      lastRolloverAt: data.lastRolloverAt.present
          ? data.lastRolloverAt.value
          : this.lastRolloverAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PostItRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('isHighlight: $isHighlight, ')
          ..write('details: $details, ')
          ..write('noteId: $noteId, ')
          ..write('noteExcerpt: $noteExcerpt, ')
          ..write('sourceNoteId: $sourceNoteId, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('recurrence: $recurrence, ')
          ..write('recurrenceInterval: $recurrenceInterval, ')
          ..write('recurrenceEndDate: $recurrenceEndDate, ')
          ..write('seriesId: $seriesId, ')
          ..write('occurrenceStatuses: $occurrenceStatuses, ')
          ..write('timeMinutes: $timeMinutes, ')
          ..write('reminderMinutes: $reminderMinutes, ')
          ..write('tagIds: $tagIds, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('lastRolloverAt: $lastRolloverAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    title,
    type,
    status,
    isHighlight,
    details,
    noteId,
    noteExcerpt,
    sourceNoteId,
    startDate,
    endDate,
    recurrence,
    recurrenceInterval,
    recurrenceEndDate,
    seriesId,
    occurrenceStatuses,
    timeMinutes,
    reminderMinutes,
    tagIds,
    sortOrder,
    lastRolloverAt,
    createdAt,
    updatedAt,
    deletedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PostItRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.type == this.type &&
          other.status == this.status &&
          other.isHighlight == this.isHighlight &&
          other.details == this.details &&
          other.noteId == this.noteId &&
          other.noteExcerpt == this.noteExcerpt &&
          other.sourceNoteId == this.sourceNoteId &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.recurrence == this.recurrence &&
          other.recurrenceInterval == this.recurrenceInterval &&
          other.recurrenceEndDate == this.recurrenceEndDate &&
          other.seriesId == this.seriesId &&
          other.occurrenceStatuses == this.occurrenceStatuses &&
          other.timeMinutes == this.timeMinutes &&
          other.reminderMinutes == this.reminderMinutes &&
          other.tagIds == this.tagIds &&
          other.sortOrder == this.sortOrder &&
          other.lastRolloverAt == this.lastRolloverAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class PostItsCompanion extends UpdateCompanion<PostItRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<PostItType> type;
  final Value<PostItStatus> status;
  final Value<bool> isHighlight;
  final Value<String?> details;
  final Value<String?> noteId;
  final Value<String?> noteExcerpt;
  final Value<String?> sourceNoteId;
  final Value<DateOnly?> startDate;
  final Value<DateOnly?> endDate;
  final Value<EventRecurrence> recurrence;
  final Value<int> recurrenceInterval;
  final Value<DateOnly?> recurrenceEndDate;
  final Value<String?> seriesId;
  final Value<Map<DateOnly, PostItStatus>> occurrenceStatuses;
  final Value<int?> timeMinutes;
  final Value<int?> reminderMinutes;
  final Value<List<String>> tagIds;
  final Value<int> sortOrder;
  final Value<int?> lastRolloverAt;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const PostItsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.isHighlight = const Value.absent(),
    this.details = const Value.absent(),
    this.noteId = const Value.absent(),
    this.noteExcerpt = const Value.absent(),
    this.sourceNoteId = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.recurrenceInterval = const Value.absent(),
    this.recurrenceEndDate = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.occurrenceStatuses = const Value.absent(),
    this.timeMinutes = const Value.absent(),
    this.reminderMinutes = const Value.absent(),
    this.tagIds = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.lastRolloverAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PostItsCompanion.insert({
    required String id,
    required String title,
    required PostItType type,
    required PostItStatus status,
    this.isHighlight = const Value.absent(),
    this.details = const Value.absent(),
    this.noteId = const Value.absent(),
    this.noteExcerpt = const Value.absent(),
    this.sourceNoteId = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.recurrenceInterval = const Value.absent(),
    this.recurrenceEndDate = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.occurrenceStatuses = const Value.absent(),
    this.timeMinutes = const Value.absent(),
    this.reminderMinutes = const Value.absent(),
    this.tagIds = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.lastRolloverAt = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       type = Value(type),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PostItRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? type,
    Expression<String>? status,
    Expression<bool>? isHighlight,
    Expression<String>? details,
    Expression<String>? noteId,
    Expression<String>? noteExcerpt,
    Expression<String>? sourceNoteId,
    Expression<String>? startDate,
    Expression<String>? endDate,
    Expression<String>? recurrence,
    Expression<int>? recurrenceInterval,
    Expression<String>? recurrenceEndDate,
    Expression<String>? seriesId,
    Expression<String>? occurrenceStatuses,
    Expression<int>? timeMinutes,
    Expression<int>? reminderMinutes,
    Expression<String>? tagIds,
    Expression<int>? sortOrder,
    Expression<int>? lastRolloverAt,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (isHighlight != null) 'is_highlight': isHighlight,
      if (details != null) 'details': details,
      if (noteId != null) 'note_id': noteId,
      if (noteExcerpt != null) 'note_excerpt': noteExcerpt,
      if (sourceNoteId != null) 'source_note_id': sourceNoteId,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (recurrence != null) 'recurrence': recurrence,
      if (recurrenceInterval != null) 'recurrence_interval': recurrenceInterval,
      if (recurrenceEndDate != null) 'recurrence_end_date': recurrenceEndDate,
      if (seriesId != null) 'series_id': seriesId,
      if (occurrenceStatuses != null) 'occurrence_statuses': occurrenceStatuses,
      if (timeMinutes != null) 'time_minutes': timeMinutes,
      if (reminderMinutes != null) 'reminder_minutes': reminderMinutes,
      if (tagIds != null) 'tag_ids': tagIds,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (lastRolloverAt != null) 'last_rollover_at': lastRolloverAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PostItsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<PostItType>? type,
    Value<PostItStatus>? status,
    Value<bool>? isHighlight,
    Value<String?>? details,
    Value<String?>? noteId,
    Value<String?>? noteExcerpt,
    Value<String?>? sourceNoteId,
    Value<DateOnly?>? startDate,
    Value<DateOnly?>? endDate,
    Value<EventRecurrence>? recurrence,
    Value<int>? recurrenceInterval,
    Value<DateOnly?>? recurrenceEndDate,
    Value<String?>? seriesId,
    Value<Map<DateOnly, PostItStatus>>? occurrenceStatuses,
    Value<int?>? timeMinutes,
    Value<int?>? reminderMinutes,
    Value<List<String>>? tagIds,
    Value<int>? sortOrder,
    Value<int?>? lastRolloverAt,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return PostItsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      status: status ?? this.status,
      isHighlight: isHighlight ?? this.isHighlight,
      details: details ?? this.details,
      noteId: noteId ?? this.noteId,
      noteExcerpt: noteExcerpt ?? this.noteExcerpt,
      sourceNoteId: sourceNoteId ?? this.sourceNoteId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      recurrence: recurrence ?? this.recurrence,
      recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
      seriesId: seriesId ?? this.seriesId,
      occurrenceStatuses: occurrenceStatuses ?? this.occurrenceStatuses,
      timeMinutes: timeMinutes ?? this.timeMinutes,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      tagIds: tagIds ?? this.tagIds,
      sortOrder: sortOrder ?? this.sortOrder,
      lastRolloverAt: lastRolloverAt ?? this.lastRolloverAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $PostItsTable.$convertertype.toSql(type.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $PostItsTable.$converterstatus.toSql(status.value),
      );
    }
    if (isHighlight.present) {
      map['is_highlight'] = Variable<bool>(isHighlight.value);
    }
    if (details.present) {
      map['details'] = Variable<String>(details.value);
    }
    if (noteId.present) {
      map['note_id'] = Variable<String>(noteId.value);
    }
    if (noteExcerpt.present) {
      map['note_excerpt'] = Variable<String>(noteExcerpt.value);
    }
    if (sourceNoteId.present) {
      map['source_note_id'] = Variable<String>(sourceNoteId.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(
        $PostItsTable.$converterstartDaten.toSql(startDate.value),
      );
    }
    if (endDate.present) {
      map['end_date'] = Variable<String>(
        $PostItsTable.$converterendDaten.toSql(endDate.value),
      );
    }
    if (recurrence.present) {
      map['recurrence'] = Variable<String>(
        $PostItsTable.$converterrecurrence.toSql(recurrence.value),
      );
    }
    if (recurrenceInterval.present) {
      map['recurrence_interval'] = Variable<int>(recurrenceInterval.value);
    }
    if (recurrenceEndDate.present) {
      map['recurrence_end_date'] = Variable<String>(
        $PostItsTable.$converterrecurrenceEndDaten.toSql(
          recurrenceEndDate.value,
        ),
      );
    }
    if (seriesId.present) {
      map['series_id'] = Variable<String>(seriesId.value);
    }
    if (occurrenceStatuses.present) {
      map['occurrence_statuses'] = Variable<String>(
        $PostItsTable.$converteroccurrenceStatuses.toSql(
          occurrenceStatuses.value,
        ),
      );
    }
    if (timeMinutes.present) {
      map['time_minutes'] = Variable<int>(timeMinutes.value);
    }
    if (reminderMinutes.present) {
      map['reminder_minutes'] = Variable<int>(reminderMinutes.value);
    }
    if (tagIds.present) {
      map['tag_ids'] = Variable<String>(
        $PostItsTable.$convertertagIds.toSql(tagIds.value),
      );
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (lastRolloverAt.present) {
      map['last_rollover_at'] = Variable<int>(lastRolloverAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PostItsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('isHighlight: $isHighlight, ')
          ..write('details: $details, ')
          ..write('noteId: $noteId, ')
          ..write('noteExcerpt: $noteExcerpt, ')
          ..write('sourceNoteId: $sourceNoteId, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('recurrence: $recurrence, ')
          ..write('recurrenceInterval: $recurrenceInterval, ')
          ..write('recurrenceEndDate: $recurrenceEndDate, ')
          ..write('seriesId: $seriesId, ')
          ..write('occurrenceStatuses: $occurrenceStatuses, ')
          ..write('timeMinutes: $timeMinutes, ')
          ..write('reminderMinutes: $reminderMinutes, ')
          ..write('tagIds: $tagIds, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('lastRolloverAt: $lastRolloverAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PostItHistoryEntriesTable extends PostItHistoryEntries
    with TableInfo<$PostItHistoryEntriesTable, PostItHistoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PostItHistoryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _postItIdMeta = const VerificationMeta(
    'postItId',
  );
  @override
  late final GeneratedColumn<String> postItId = GeneratedColumn<String>(
    'post_it_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES post_its (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<PostItHistoryAction, String>
  action =
      GeneratedColumn<String>(
        'action',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PostItHistoryAction>(
        $PostItHistoryEntriesTable.$converteraction,
      );
  static const VerificationMeta _fromValueMeta = const VerificationMeta(
    'fromValue',
  );
  @override
  late final GeneratedColumn<String> fromValue = GeneratedColumn<String>(
    'from_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toValueMeta = const VerificationMeta(
    'toValue',
  );
  @override
  late final GeneratedColumn<String> toValue = GeneratedColumn<String>(
    'to_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    postItId,
    action,
    fromValue,
    toValue,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'post_it_history_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<PostItHistoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('post_it_id')) {
      context.handle(
        _postItIdMeta,
        postItId.isAcceptableOrUnknown(data['post_it_id']!, _postItIdMeta),
      );
    } else if (isInserting) {
      context.missing(_postItIdMeta);
    }
    if (data.containsKey('from_value')) {
      context.handle(
        _fromValueMeta,
        fromValue.isAcceptableOrUnknown(data['from_value']!, _fromValueMeta),
      );
    }
    if (data.containsKey('to_value')) {
      context.handle(
        _toValueMeta,
        toValue.isAcceptableOrUnknown(data['to_value']!, _toValueMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PostItHistoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PostItHistoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      postItId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}post_it_id'],
      )!,
      action: $PostItHistoryEntriesTable.$converteraction.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}action'],
        )!,
      ),
      fromValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_value'],
      ),
      toValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_value'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PostItHistoryEntriesTable createAlias(String alias) {
    return $PostItHistoryEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PostItHistoryAction, String, String>
  $converteraction = const EnumNameConverter<PostItHistoryAction>(
    PostItHistoryAction.values,
  );
}

class PostItHistoryRow extends DataClass
    implements Insertable<PostItHistoryRow> {
  final String id;
  final String postItId;
  final PostItHistoryAction action;
  final String? fromValue;
  final String? toValue;
  final int createdAt;
  const PostItHistoryRow({
    required this.id,
    required this.postItId,
    required this.action,
    this.fromValue,
    this.toValue,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['post_it_id'] = Variable<String>(postItId);
    {
      map['action'] = Variable<String>(
        $PostItHistoryEntriesTable.$converteraction.toSql(action),
      );
    }
    if (!nullToAbsent || fromValue != null) {
      map['from_value'] = Variable<String>(fromValue);
    }
    if (!nullToAbsent || toValue != null) {
      map['to_value'] = Variable<String>(toValue);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  PostItHistoryEntriesCompanion toCompanion(bool nullToAbsent) {
    return PostItHistoryEntriesCompanion(
      id: Value(id),
      postItId: Value(postItId),
      action: Value(action),
      fromValue: fromValue == null && nullToAbsent
          ? const Value.absent()
          : Value(fromValue),
      toValue: toValue == null && nullToAbsent
          ? const Value.absent()
          : Value(toValue),
      createdAt: Value(createdAt),
    );
  }

  factory PostItHistoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PostItHistoryRow(
      id: serializer.fromJson<String>(json['id']),
      postItId: serializer.fromJson<String>(json['postItId']),
      action: $PostItHistoryEntriesTable.$converteraction.fromJson(
        serializer.fromJson<String>(json['action']),
      ),
      fromValue: serializer.fromJson<String?>(json['fromValue']),
      toValue: serializer.fromJson<String?>(json['toValue']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'postItId': serializer.toJson<String>(postItId),
      'action': serializer.toJson<String>(
        $PostItHistoryEntriesTable.$converteraction.toJson(action),
      ),
      'fromValue': serializer.toJson<String?>(fromValue),
      'toValue': serializer.toJson<String?>(toValue),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  PostItHistoryRow copyWith({
    String? id,
    String? postItId,
    PostItHistoryAction? action,
    Value<String?> fromValue = const Value.absent(),
    Value<String?> toValue = const Value.absent(),
    int? createdAt,
  }) => PostItHistoryRow(
    id: id ?? this.id,
    postItId: postItId ?? this.postItId,
    action: action ?? this.action,
    fromValue: fromValue.present ? fromValue.value : this.fromValue,
    toValue: toValue.present ? toValue.value : this.toValue,
    createdAt: createdAt ?? this.createdAt,
  );
  PostItHistoryRow copyWithCompanion(PostItHistoryEntriesCompanion data) {
    return PostItHistoryRow(
      id: data.id.present ? data.id.value : this.id,
      postItId: data.postItId.present ? data.postItId.value : this.postItId,
      action: data.action.present ? data.action.value : this.action,
      fromValue: data.fromValue.present ? data.fromValue.value : this.fromValue,
      toValue: data.toValue.present ? data.toValue.value : this.toValue,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PostItHistoryRow(')
          ..write('id: $id, ')
          ..write('postItId: $postItId, ')
          ..write('action: $action, ')
          ..write('fromValue: $fromValue, ')
          ..write('toValue: $toValue, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, postItId, action, fromValue, toValue, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PostItHistoryRow &&
          other.id == this.id &&
          other.postItId == this.postItId &&
          other.action == this.action &&
          other.fromValue == this.fromValue &&
          other.toValue == this.toValue &&
          other.createdAt == this.createdAt);
}

class PostItHistoryEntriesCompanion extends UpdateCompanion<PostItHistoryRow> {
  final Value<String> id;
  final Value<String> postItId;
  final Value<PostItHistoryAction> action;
  final Value<String?> fromValue;
  final Value<String?> toValue;
  final Value<int> createdAt;
  final Value<int> rowid;
  const PostItHistoryEntriesCompanion({
    this.id = const Value.absent(),
    this.postItId = const Value.absent(),
    this.action = const Value.absent(),
    this.fromValue = const Value.absent(),
    this.toValue = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PostItHistoryEntriesCompanion.insert({
    required String id,
    required String postItId,
    required PostItHistoryAction action,
    this.fromValue = const Value.absent(),
    this.toValue = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       postItId = Value(postItId),
       action = Value(action),
       createdAt = Value(createdAt);
  static Insertable<PostItHistoryRow> custom({
    Expression<String>? id,
    Expression<String>? postItId,
    Expression<String>? action,
    Expression<String>? fromValue,
    Expression<String>? toValue,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (postItId != null) 'post_it_id': postItId,
      if (action != null) 'action': action,
      if (fromValue != null) 'from_value': fromValue,
      if (toValue != null) 'to_value': toValue,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PostItHistoryEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? postItId,
    Value<PostItHistoryAction>? action,
    Value<String?>? fromValue,
    Value<String?>? toValue,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return PostItHistoryEntriesCompanion(
      id: id ?? this.id,
      postItId: postItId ?? this.postItId,
      action: action ?? this.action,
      fromValue: fromValue ?? this.fromValue,
      toValue: toValue ?? this.toValue,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (postItId.present) {
      map['post_it_id'] = Variable<String>(postItId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(
        $PostItHistoryEntriesTable.$converteraction.toSql(action.value),
      );
    }
    if (fromValue.present) {
      map['from_value'] = Variable<String>(fromValue.value);
    }
    if (toValue.present) {
      map['to_value'] = Variable<String>(toValue.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PostItHistoryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('postItId: $postItId, ')
          ..write('action: $action, ')
          ..write('fromValue: $fromValue, ')
          ..write('toValue: $toValue, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, TagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TagTone, String> tone =
      GeneratedColumn<String>(
        'tone',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TagTone>($TagsTable.$convertertone);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    tone,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<TagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      tone: $TagsTable.$convertertone.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tone'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TagTone, String, String> $convertertone =
      const EnumNameConverter<TagTone>(TagTone.values);
}

class TagRow extends DataClass implements Insertable<TagRow> {
  final String id;
  final String name;
  final TagTone tone;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  const TagRow({
    required this.id,
    required this.name,
    required this.tone,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    {
      map['tone'] = Variable<String>($TagsTable.$convertertone.toSql(tone));
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      tone: Value(tone),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory TagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      tone: $TagsTable.$convertertone.fromJson(
        serializer.fromJson<String>(json['tone']),
      ),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'tone': serializer.toJson<String>($TagsTable.$convertertone.toJson(tone)),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  TagRow copyWith({
    String? id,
    String? name,
    TagTone? tone,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
  }) => TagRow(
    id: id ?? this.id,
    name: name ?? this.name,
    tone: tone ?? this.tone,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  TagRow copyWithCompanion(TagsCompanion data) {
    return TagRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      tone: data.tone.present ? data.tone.value : this.tone,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('tone: $tone, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, tone, createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.tone == this.tone &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class TagsCompanion extends UpdateCompanion<TagRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<TagTone> tone;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.tone = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String name,
    required TagTone tone,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       tone = Value(tone),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TagRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? tone,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (tone != null) 'tone': tone,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<TagTone>? tone,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      tone: tone ?? this.tone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (tone.present) {
      map['tone'] = Variable<String>(
        $TagsTable.$convertertone.toSql(tone.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('tone: $tone, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutinesTable extends Routines
    with TableInfo<$RoutinesTable, RoutineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detailsMeta = const VerificationMeta(
    'details',
  );
  @override
  late final GeneratedColumn<String> details = GeneratedColumn<String>(
    'details',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<RoutineMode, String> mode =
      GeneratedColumn<String>(
        'mode',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('simple'),
      ).withConverter<RoutineMode>($RoutinesTable.$convertermode);
  static const VerificationMeta _weekdaysMeta = const VerificationMeta(
    'weekdays',
  );
  @override
  late final GeneratedColumn<int> weekdays = GeneratedColumn<int>(
    'weekdays',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    details,
    mode,
    weekdays,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routines';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('details')) {
      context.handle(
        _detailsMeta,
        details.isAcceptableOrUnknown(data['details']!, _detailsMeta),
      );
    }
    if (data.containsKey('weekdays')) {
      context.handle(
        _weekdaysMeta,
        weekdays.isAcceptableOrUnknown(data['weekdays']!, _weekdaysMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      details: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details'],
      ),
      mode: $RoutinesTable.$convertermode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}mode'],
        )!,
      ),
      weekdays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekdays'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RoutinesTable createAlias(String alias) {
    return $RoutinesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<RoutineMode, String, String> $convertermode =
      const EnumNameConverter<RoutineMode>(RoutineMode.values);
}

class RoutineRow extends DataClass implements Insertable<RoutineRow> {
  final String id;
  final String name;
  final String? details;
  final RoutineMode mode;
  final int weekdays;
  final int createdAt;
  final int updatedAt;
  const RoutineRow({
    required this.id,
    required this.name,
    this.details,
    required this.mode,
    required this.weekdays,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || details != null) {
      map['details'] = Variable<String>(details);
    }
    {
      map['mode'] = Variable<String>($RoutinesTable.$convertermode.toSql(mode));
    }
    map['weekdays'] = Variable<int>(weekdays);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  RoutinesCompanion toCompanion(bool nullToAbsent) {
    return RoutinesCompanion(
      id: Value(id),
      name: Value(name),
      details: details == null && nullToAbsent
          ? const Value.absent()
          : Value(details),
      mode: Value(mode),
      weekdays: Value(weekdays),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory RoutineRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      details: serializer.fromJson<String?>(json['details']),
      mode: $RoutinesTable.$convertermode.fromJson(
        serializer.fromJson<String>(json['mode']),
      ),
      weekdays: serializer.fromJson<int>(json['weekdays']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'details': serializer.toJson<String?>(details),
      'mode': serializer.toJson<String>(
        $RoutinesTable.$convertermode.toJson(mode),
      ),
      'weekdays': serializer.toJson<int>(weekdays),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  RoutineRow copyWith({
    String? id,
    String? name,
    Value<String?> details = const Value.absent(),
    RoutineMode? mode,
    int? weekdays,
    int? createdAt,
    int? updatedAt,
  }) => RoutineRow(
    id: id ?? this.id,
    name: name ?? this.name,
    details: details.present ? details.value : this.details,
    mode: mode ?? this.mode,
    weekdays: weekdays ?? this.weekdays,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RoutineRow copyWithCompanion(RoutinesCompanion data) {
    return RoutineRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      details: data.details.present ? data.details.value : this.details,
      mode: data.mode.present ? data.mode.value : this.mode,
      weekdays: data.weekdays.present ? data.weekdays.value : this.weekdays,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('details: $details, ')
          ..write('mode: $mode, ')
          ..write('weekdays: $weekdays, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, details, mode, weekdays, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.details == this.details &&
          other.mode == this.mode &&
          other.weekdays == this.weekdays &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RoutinesCompanion extends UpdateCompanion<RoutineRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> details;
  final Value<RoutineMode> mode;
  final Value<int> weekdays;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const RoutinesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.details = const Value.absent(),
    this.mode = const Value.absent(),
    this.weekdays = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutinesCompanion.insert({
    required String id,
    required String name,
    this.details = const Value.absent(),
    this.mode = const Value.absent(),
    this.weekdays = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<RoutineRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? details,
    Expression<String>? mode,
    Expression<int>? weekdays,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (details != null) 'details': details,
      if (mode != null) 'mode': mode,
      if (weekdays != null) 'weekdays': weekdays,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutinesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? details,
    Value<RoutineMode>? mode,
    Value<int>? weekdays,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return RoutinesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      details: details ?? this.details,
      mode: mode ?? this.mode,
      weekdays: weekdays ?? this.weekdays,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (details.present) {
      map['details'] = Variable<String>(details.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(
        $RoutinesTable.$convertermode.toSql(mode.value),
      );
    }
    if (weekdays.present) {
      map['weekdays'] = Variable<int>(weekdays.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutinesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('details: $details, ')
          ..write('mode: $mode, ')
          ..write('weekdays: $weekdays, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutineItemsTable extends RoutineItems
    with TableInfo<$RoutineItemsTable, RoutineItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routineIdMeta = const VerificationMeta(
    'routineId',
  );
  @override
  late final GeneratedColumn<String> routineId = GeneratedColumn<String>(
    'routine_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routines (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detailsMeta = const VerificationMeta(
    'details',
  );
  @override
  late final GeneratedColumn<String> details = GeneratedColumn<String>(
    'details',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    routineId,
    title,
    details,
    position,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('routine_id')) {
      context.handle(
        _routineIdMeta,
        routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routineIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('details')) {
      context.handle(
        _detailsMeta,
        details.isAcceptableOrUnknown(data['details']!, _detailsMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutineItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      routineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}routine_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      details: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RoutineItemsTable createAlias(String alias) {
    return $RoutineItemsTable(attachedDatabase, alias);
  }
}

class RoutineItemRow extends DataClass implements Insertable<RoutineItemRow> {
  final String id;
  final String routineId;
  final String title;
  final String? details;
  final int position;
  final int createdAt;
  final int updatedAt;
  const RoutineItemRow({
    required this.id,
    required this.routineId,
    required this.title,
    this.details,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['routine_id'] = Variable<String>(routineId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || details != null) {
      map['details'] = Variable<String>(details);
    }
    map['position'] = Variable<int>(position);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  RoutineItemsCompanion toCompanion(bool nullToAbsent) {
    return RoutineItemsCompanion(
      id: Value(id),
      routineId: Value(routineId),
      title: Value(title),
      details: details == null && nullToAbsent
          ? const Value.absent()
          : Value(details),
      position: Value(position),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory RoutineItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineItemRow(
      id: serializer.fromJson<String>(json['id']),
      routineId: serializer.fromJson<String>(json['routineId']),
      title: serializer.fromJson<String>(json['title']),
      details: serializer.fromJson<String?>(json['details']),
      position: serializer.fromJson<int>(json['position']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'routineId': serializer.toJson<String>(routineId),
      'title': serializer.toJson<String>(title),
      'details': serializer.toJson<String?>(details),
      'position': serializer.toJson<int>(position),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  RoutineItemRow copyWith({
    String? id,
    String? routineId,
    String? title,
    Value<String?> details = const Value.absent(),
    int? position,
    int? createdAt,
    int? updatedAt,
  }) => RoutineItemRow(
    id: id ?? this.id,
    routineId: routineId ?? this.routineId,
    title: title ?? this.title,
    details: details.present ? details.value : this.details,
    position: position ?? this.position,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RoutineItemRow copyWithCompanion(RoutineItemsCompanion data) {
    return RoutineItemRow(
      id: data.id.present ? data.id.value : this.id,
      routineId: data.routineId.present ? data.routineId.value : this.routineId,
      title: data.title.present ? data.title.value : this.title,
      details: data.details.present ? data.details.value : this.details,
      position: data.position.present ? data.position.value : this.position,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineItemRow(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('title: $title, ')
          ..write('details: $details, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    routineId,
    title,
    details,
    position,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineItemRow &&
          other.id == this.id &&
          other.routineId == this.routineId &&
          other.title == this.title &&
          other.details == this.details &&
          other.position == this.position &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RoutineItemsCompanion extends UpdateCompanion<RoutineItemRow> {
  final Value<String> id;
  final Value<String> routineId;
  final Value<String> title;
  final Value<String?> details;
  final Value<int> position;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const RoutineItemsCompanion({
    this.id = const Value.absent(),
    this.routineId = const Value.absent(),
    this.title = const Value.absent(),
    this.details = const Value.absent(),
    this.position = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutineItemsCompanion.insert({
    required String id,
    required String routineId,
    required String title,
    this.details = const Value.absent(),
    required int position,
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       routineId = Value(routineId),
       title = Value(title),
       position = Value(position),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<RoutineItemRow> custom({
    Expression<String>? id,
    Expression<String>? routineId,
    Expression<String>? title,
    Expression<String>? details,
    Expression<int>? position,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routineId != null) 'routine_id': routineId,
      if (title != null) 'title': title,
      if (details != null) 'details': details,
      if (position != null) 'position': position,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutineItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? routineId,
    Value<String>? title,
    Value<String?>? details,
    Value<int>? position,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return RoutineItemsCompanion(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      title: title ?? this.title,
      details: details ?? this.details,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (routineId.present) {
      map['routine_id'] = Variable<String>(routineId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (details.present) {
      map['details'] = Variable<String>(details.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineItemsCompanion(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('title: $title, ')
          ..write('details: $details, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutineCompletionsTable extends RoutineCompletions
    with TableInfo<$RoutineCompletionsTable, RoutineCompletionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineCompletionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _routineItemIdMeta = const VerificationMeta(
    'routineItemId',
  );
  @override
  late final GeneratedColumn<String> routineItemId = GeneratedColumn<String>(
    'routine_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routine_items (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateOnly, String> date =
      GeneratedColumn<String>(
        'date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateOnly>($RoutineCompletionsTable.$converterdate);
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [routineItemId, date, completedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_completions';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineCompletionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('routine_item_id')) {
      context.handle(
        _routineItemIdMeta,
        routineItemId.isAcceptableOrUnknown(
          data['routine_item_id']!,
          _routineItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_routineItemIdMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {routineItemId, date};
  @override
  RoutineCompletionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineCompletionRow(
      routineItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}routine_item_id'],
      )!,
      date: $RoutineCompletionsTable.$converterdate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}date'],
        )!,
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      )!,
    );
  }

  @override
  $RoutineCompletionsTable createAlias(String alias) {
    return $RoutineCompletionsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateOnly, String> $converterdate =
      const DateOnlyConverter();
}

class RoutineCompletionRow extends DataClass
    implements Insertable<RoutineCompletionRow> {
  final String routineItemId;
  final DateOnly date;
  final int completedAt;
  const RoutineCompletionRow({
    required this.routineItemId,
    required this.date,
    required this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['routine_item_id'] = Variable<String>(routineItemId);
    {
      map['date'] = Variable<String>(
        $RoutineCompletionsTable.$converterdate.toSql(date),
      );
    }
    map['completed_at'] = Variable<int>(completedAt);
    return map;
  }

  RoutineCompletionsCompanion toCompanion(bool nullToAbsent) {
    return RoutineCompletionsCompanion(
      routineItemId: Value(routineItemId),
      date: Value(date),
      completedAt: Value(completedAt),
    );
  }

  factory RoutineCompletionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineCompletionRow(
      routineItemId: serializer.fromJson<String>(json['routineItemId']),
      date: serializer.fromJson<DateOnly>(json['date']),
      completedAt: serializer.fromJson<int>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'routineItemId': serializer.toJson<String>(routineItemId),
      'date': serializer.toJson<DateOnly>(date),
      'completedAt': serializer.toJson<int>(completedAt),
    };
  }

  RoutineCompletionRow copyWith({
    String? routineItemId,
    DateOnly? date,
    int? completedAt,
  }) => RoutineCompletionRow(
    routineItemId: routineItemId ?? this.routineItemId,
    date: date ?? this.date,
    completedAt: completedAt ?? this.completedAt,
  );
  RoutineCompletionRow copyWithCompanion(RoutineCompletionsCompanion data) {
    return RoutineCompletionRow(
      routineItemId: data.routineItemId.present
          ? data.routineItemId.value
          : this.routineItemId,
      date: data.date.present ? data.date.value : this.date,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineCompletionRow(')
          ..write('routineItemId: $routineItemId, ')
          ..write('date: $date, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(routineItemId, date, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineCompletionRow &&
          other.routineItemId == this.routineItemId &&
          other.date == this.date &&
          other.completedAt == this.completedAt);
}

class RoutineCompletionsCompanion
    extends UpdateCompanion<RoutineCompletionRow> {
  final Value<String> routineItemId;
  final Value<DateOnly> date;
  final Value<int> completedAt;
  final Value<int> rowid;
  const RoutineCompletionsCompanion({
    this.routineItemId = const Value.absent(),
    this.date = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutineCompletionsCompanion.insert({
    required String routineItemId,
    required DateOnly date,
    required int completedAt,
    this.rowid = const Value.absent(),
  }) : routineItemId = Value(routineItemId),
       date = Value(date),
       completedAt = Value(completedAt);
  static Insertable<RoutineCompletionRow> custom({
    Expression<String>? routineItemId,
    Expression<String>? date,
    Expression<int>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (routineItemId != null) 'routine_item_id': routineItemId,
      if (date != null) 'date': date,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutineCompletionsCompanion copyWith({
    Value<String>? routineItemId,
    Value<DateOnly>? date,
    Value<int>? completedAt,
    Value<int>? rowid,
  }) {
    return RoutineCompletionsCompanion(
      routineItemId: routineItemId ?? this.routineItemId,
      date: date ?? this.date,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (routineItemId.present) {
      map['routine_item_id'] = Variable<String>(routineItemId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(
        $RoutineCompletionsTable.$converterdate.toSql(date.value),
      );
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineCompletionsCompanion(')
          ..write('routineItemId: $routineItemId, ')
          ..write('date: $date, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutineSectionsTable extends RoutineSections
    with TableInfo<$RoutineSectionsTable, RoutineSectionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineSectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routineIdMeta = const VerificationMeta(
    'routineId',
  );
  @override
  late final GeneratedColumn<String> routineId = GeneratedColumn<String>(
    'routine_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routines (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startMinutesMeta = const VerificationMeta(
    'startMinutes',
  );
  @override
  late final GeneratedColumn<int> startMinutes = GeneratedColumn<int>(
    'start_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endMinutesMeta = const VerificationMeta(
    'endMinutes',
  );
  @override
  late final GeneratedColumn<int> endMinutes = GeneratedColumn<int>(
    'end_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    routineId,
    title,
    position,
    startMinutes,
    endMinutes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_sections';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineSectionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('routine_id')) {
      context.handle(
        _routineIdMeta,
        routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routineIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('start_minutes')) {
      context.handle(
        _startMinutesMeta,
        startMinutes.isAcceptableOrUnknown(
          data['start_minutes']!,
          _startMinutesMeta,
        ),
      );
    }
    if (data.containsKey('end_minutes')) {
      context.handle(
        _endMinutesMeta,
        endMinutes.isAcceptableOrUnknown(data['end_minutes']!, _endMinutesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutineSectionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineSectionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      routineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}routine_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      startMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_minutes'],
      ),
      endMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_minutes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RoutineSectionsTable createAlias(String alias) {
    return $RoutineSectionsTable(attachedDatabase, alias);
  }
}

class RoutineSectionRow extends DataClass
    implements Insertable<RoutineSectionRow> {
  final String id;
  final String routineId;
  final String title;
  final int position;
  final int? startMinutes;
  final int? endMinutes;
  final int createdAt;
  final int updatedAt;
  const RoutineSectionRow({
    required this.id,
    required this.routineId,
    required this.title,
    required this.position,
    this.startMinutes,
    this.endMinutes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['routine_id'] = Variable<String>(routineId);
    map['title'] = Variable<String>(title);
    map['position'] = Variable<int>(position);
    if (!nullToAbsent || startMinutes != null) {
      map['start_minutes'] = Variable<int>(startMinutes);
    }
    if (!nullToAbsent || endMinutes != null) {
      map['end_minutes'] = Variable<int>(endMinutes);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  RoutineSectionsCompanion toCompanion(bool nullToAbsent) {
    return RoutineSectionsCompanion(
      id: Value(id),
      routineId: Value(routineId),
      title: Value(title),
      position: Value(position),
      startMinutes: startMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(startMinutes),
      endMinutes: endMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(endMinutes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory RoutineSectionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineSectionRow(
      id: serializer.fromJson<String>(json['id']),
      routineId: serializer.fromJson<String>(json['routineId']),
      title: serializer.fromJson<String>(json['title']),
      position: serializer.fromJson<int>(json['position']),
      startMinutes: serializer.fromJson<int?>(json['startMinutes']),
      endMinutes: serializer.fromJson<int?>(json['endMinutes']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'routineId': serializer.toJson<String>(routineId),
      'title': serializer.toJson<String>(title),
      'position': serializer.toJson<int>(position),
      'startMinutes': serializer.toJson<int?>(startMinutes),
      'endMinutes': serializer.toJson<int?>(endMinutes),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  RoutineSectionRow copyWith({
    String? id,
    String? routineId,
    String? title,
    int? position,
    Value<int?> startMinutes = const Value.absent(),
    Value<int?> endMinutes = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => RoutineSectionRow(
    id: id ?? this.id,
    routineId: routineId ?? this.routineId,
    title: title ?? this.title,
    position: position ?? this.position,
    startMinutes: startMinutes.present ? startMinutes.value : this.startMinutes,
    endMinutes: endMinutes.present ? endMinutes.value : this.endMinutes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RoutineSectionRow copyWithCompanion(RoutineSectionsCompanion data) {
    return RoutineSectionRow(
      id: data.id.present ? data.id.value : this.id,
      routineId: data.routineId.present ? data.routineId.value : this.routineId,
      title: data.title.present ? data.title.value : this.title,
      position: data.position.present ? data.position.value : this.position,
      startMinutes: data.startMinutes.present
          ? data.startMinutes.value
          : this.startMinutes,
      endMinutes: data.endMinutes.present
          ? data.endMinutes.value
          : this.endMinutes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineSectionRow(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('title: $title, ')
          ..write('position: $position, ')
          ..write('startMinutes: $startMinutes, ')
          ..write('endMinutes: $endMinutes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    routineId,
    title,
    position,
    startMinutes,
    endMinutes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineSectionRow &&
          other.id == this.id &&
          other.routineId == this.routineId &&
          other.title == this.title &&
          other.position == this.position &&
          other.startMinutes == this.startMinutes &&
          other.endMinutes == this.endMinutes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RoutineSectionsCompanion extends UpdateCompanion<RoutineSectionRow> {
  final Value<String> id;
  final Value<String> routineId;
  final Value<String> title;
  final Value<int> position;
  final Value<int?> startMinutes;
  final Value<int?> endMinutes;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const RoutineSectionsCompanion({
    this.id = const Value.absent(),
    this.routineId = const Value.absent(),
    this.title = const Value.absent(),
    this.position = const Value.absent(),
    this.startMinutes = const Value.absent(),
    this.endMinutes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutineSectionsCompanion.insert({
    required String id,
    required String routineId,
    required String title,
    required int position,
    this.startMinutes = const Value.absent(),
    this.endMinutes = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       routineId = Value(routineId),
       title = Value(title),
       position = Value(position),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<RoutineSectionRow> custom({
    Expression<String>? id,
    Expression<String>? routineId,
    Expression<String>? title,
    Expression<int>? position,
    Expression<int>? startMinutes,
    Expression<int>? endMinutes,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routineId != null) 'routine_id': routineId,
      if (title != null) 'title': title,
      if (position != null) 'position': position,
      if (startMinutes != null) 'start_minutes': startMinutes,
      if (endMinutes != null) 'end_minutes': endMinutes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutineSectionsCompanion copyWith({
    Value<String>? id,
    Value<String>? routineId,
    Value<String>? title,
    Value<int>? position,
    Value<int?>? startMinutes,
    Value<int?>? endMinutes,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return RoutineSectionsCompanion(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      title: title ?? this.title,
      position: position ?? this.position,
      startMinutes: startMinutes ?? this.startMinutes,
      endMinutes: endMinutes ?? this.endMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (routineId.present) {
      map['routine_id'] = Variable<String>(routineId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (startMinutes.present) {
      map['start_minutes'] = Variable<int>(startMinutes.value);
    }
    if (endMinutes.present) {
      map['end_minutes'] = Variable<int>(endMinutes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineSectionsCompanion(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('title: $title, ')
          ..write('position: $position, ')
          ..write('startMinutes: $startMinutes, ')
          ..write('endMinutes: $endMinutes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutineIntervalsTable extends RoutineIntervals
    with TableInfo<$RoutineIntervalsTable, RoutineIntervalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineIntervalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectionIdMeta = const VerificationMeta(
    'sectionId',
  );
  @override
  late final GeneratedColumn<String> sectionId = GeneratedColumn<String>(
    'section_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routine_sections (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _startMinutesMeta = const VerificationMeta(
    'startMinutes',
  );
  @override
  late final GeneratedColumn<int> startMinutes = GeneratedColumn<int>(
    'start_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMinutesMeta = const VerificationMeta(
    'endMinutes',
  );
  @override
  late final GeneratedColumn<int> endMinutes = GeneratedColumn<int>(
    'end_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskTitleMeta = const VerificationMeta(
    'taskTitle',
  );
  @override
  late final GeneratedColumn<String> taskTitle = GeneratedColumn<String>(
    'task_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taskDetailsMeta = const VerificationMeta(
    'taskDetails',
  );
  @override
  late final GeneratedColumn<String> taskDetails = GeneratedColumn<String>(
    'task_details',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sectionId,
    startMinutes,
    endMinutes,
    position,
    taskTitle,
    taskDetails,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_intervals';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineIntervalRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('section_id')) {
      context.handle(
        _sectionIdMeta,
        sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sectionIdMeta);
    }
    if (data.containsKey('start_minutes')) {
      context.handle(
        _startMinutesMeta,
        startMinutes.isAcceptableOrUnknown(
          data['start_minutes']!,
          _startMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startMinutesMeta);
    }
    if (data.containsKey('end_minutes')) {
      context.handle(
        _endMinutesMeta,
        endMinutes.isAcceptableOrUnknown(data['end_minutes']!, _endMinutesMeta),
      );
    } else if (isInserting) {
      context.missing(_endMinutesMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('task_title')) {
      context.handle(
        _taskTitleMeta,
        taskTitle.isAcceptableOrUnknown(data['task_title']!, _taskTitleMeta),
      );
    }
    if (data.containsKey('task_details')) {
      context.handle(
        _taskDetailsMeta,
        taskDetails.isAcceptableOrUnknown(
          data['task_details']!,
          _taskDetailsMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutineIntervalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineIntervalRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}section_id'],
      )!,
      startMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_minutes'],
      )!,
      endMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_minutes'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      taskTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_title'],
      ),
      taskDetails: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_details'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RoutineIntervalsTable createAlias(String alias) {
    return $RoutineIntervalsTable(attachedDatabase, alias);
  }
}

class RoutineIntervalRow extends DataClass
    implements Insertable<RoutineIntervalRow> {
  final String id;
  final String sectionId;
  final int startMinutes;
  final int endMinutes;
  final int position;
  final String? taskTitle;
  final String? taskDetails;
  final int createdAt;
  final int updatedAt;
  const RoutineIntervalRow({
    required this.id,
    required this.sectionId,
    required this.startMinutes,
    required this.endMinutes,
    required this.position,
    this.taskTitle,
    this.taskDetails,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['section_id'] = Variable<String>(sectionId);
    map['start_minutes'] = Variable<int>(startMinutes);
    map['end_minutes'] = Variable<int>(endMinutes);
    map['position'] = Variable<int>(position);
    if (!nullToAbsent || taskTitle != null) {
      map['task_title'] = Variable<String>(taskTitle);
    }
    if (!nullToAbsent || taskDetails != null) {
      map['task_details'] = Variable<String>(taskDetails);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  RoutineIntervalsCompanion toCompanion(bool nullToAbsent) {
    return RoutineIntervalsCompanion(
      id: Value(id),
      sectionId: Value(sectionId),
      startMinutes: Value(startMinutes),
      endMinutes: Value(endMinutes),
      position: Value(position),
      taskTitle: taskTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(taskTitle),
      taskDetails: taskDetails == null && nullToAbsent
          ? const Value.absent()
          : Value(taskDetails),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory RoutineIntervalRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineIntervalRow(
      id: serializer.fromJson<String>(json['id']),
      sectionId: serializer.fromJson<String>(json['sectionId']),
      startMinutes: serializer.fromJson<int>(json['startMinutes']),
      endMinutes: serializer.fromJson<int>(json['endMinutes']),
      position: serializer.fromJson<int>(json['position']),
      taskTitle: serializer.fromJson<String?>(json['taskTitle']),
      taskDetails: serializer.fromJson<String?>(json['taskDetails']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sectionId': serializer.toJson<String>(sectionId),
      'startMinutes': serializer.toJson<int>(startMinutes),
      'endMinutes': serializer.toJson<int>(endMinutes),
      'position': serializer.toJson<int>(position),
      'taskTitle': serializer.toJson<String?>(taskTitle),
      'taskDetails': serializer.toJson<String?>(taskDetails),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  RoutineIntervalRow copyWith({
    String? id,
    String? sectionId,
    int? startMinutes,
    int? endMinutes,
    int? position,
    Value<String?> taskTitle = const Value.absent(),
    Value<String?> taskDetails = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => RoutineIntervalRow(
    id: id ?? this.id,
    sectionId: sectionId ?? this.sectionId,
    startMinutes: startMinutes ?? this.startMinutes,
    endMinutes: endMinutes ?? this.endMinutes,
    position: position ?? this.position,
    taskTitle: taskTitle.present ? taskTitle.value : this.taskTitle,
    taskDetails: taskDetails.present ? taskDetails.value : this.taskDetails,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RoutineIntervalRow copyWithCompanion(RoutineIntervalsCompanion data) {
    return RoutineIntervalRow(
      id: data.id.present ? data.id.value : this.id,
      sectionId: data.sectionId.present ? data.sectionId.value : this.sectionId,
      startMinutes: data.startMinutes.present
          ? data.startMinutes.value
          : this.startMinutes,
      endMinutes: data.endMinutes.present
          ? data.endMinutes.value
          : this.endMinutes,
      position: data.position.present ? data.position.value : this.position,
      taskTitle: data.taskTitle.present ? data.taskTitle.value : this.taskTitle,
      taskDetails: data.taskDetails.present
          ? data.taskDetails.value
          : this.taskDetails,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineIntervalRow(')
          ..write('id: $id, ')
          ..write('sectionId: $sectionId, ')
          ..write('startMinutes: $startMinutes, ')
          ..write('endMinutes: $endMinutes, ')
          ..write('position: $position, ')
          ..write('taskTitle: $taskTitle, ')
          ..write('taskDetails: $taskDetails, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sectionId,
    startMinutes,
    endMinutes,
    position,
    taskTitle,
    taskDetails,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineIntervalRow &&
          other.id == this.id &&
          other.sectionId == this.sectionId &&
          other.startMinutes == this.startMinutes &&
          other.endMinutes == this.endMinutes &&
          other.position == this.position &&
          other.taskTitle == this.taskTitle &&
          other.taskDetails == this.taskDetails &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RoutineIntervalsCompanion extends UpdateCompanion<RoutineIntervalRow> {
  final Value<String> id;
  final Value<String> sectionId;
  final Value<int> startMinutes;
  final Value<int> endMinutes;
  final Value<int> position;
  final Value<String?> taskTitle;
  final Value<String?> taskDetails;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const RoutineIntervalsCompanion({
    this.id = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.startMinutes = const Value.absent(),
    this.endMinutes = const Value.absent(),
    this.position = const Value.absent(),
    this.taskTitle = const Value.absent(),
    this.taskDetails = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutineIntervalsCompanion.insert({
    required String id,
    required String sectionId,
    required int startMinutes,
    required int endMinutes,
    required int position,
    this.taskTitle = const Value.absent(),
    this.taskDetails = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sectionId = Value(sectionId),
       startMinutes = Value(startMinutes),
       endMinutes = Value(endMinutes),
       position = Value(position),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<RoutineIntervalRow> custom({
    Expression<String>? id,
    Expression<String>? sectionId,
    Expression<int>? startMinutes,
    Expression<int>? endMinutes,
    Expression<int>? position,
    Expression<String>? taskTitle,
    Expression<String>? taskDetails,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sectionId != null) 'section_id': sectionId,
      if (startMinutes != null) 'start_minutes': startMinutes,
      if (endMinutes != null) 'end_minutes': endMinutes,
      if (position != null) 'position': position,
      if (taskTitle != null) 'task_title': taskTitle,
      if (taskDetails != null) 'task_details': taskDetails,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutineIntervalsCompanion copyWith({
    Value<String>? id,
    Value<String>? sectionId,
    Value<int>? startMinutes,
    Value<int>? endMinutes,
    Value<int>? position,
    Value<String?>? taskTitle,
    Value<String?>? taskDetails,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return RoutineIntervalsCompanion(
      id: id ?? this.id,
      sectionId: sectionId ?? this.sectionId,
      startMinutes: startMinutes ?? this.startMinutes,
      endMinutes: endMinutes ?? this.endMinutes,
      position: position ?? this.position,
      taskTitle: taskTitle ?? this.taskTitle,
      taskDetails: taskDetails ?? this.taskDetails,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sectionId.present) {
      map['section_id'] = Variable<String>(sectionId.value);
    }
    if (startMinutes.present) {
      map['start_minutes'] = Variable<int>(startMinutes.value);
    }
    if (endMinutes.present) {
      map['end_minutes'] = Variable<int>(endMinutes.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (taskTitle.present) {
      map['task_title'] = Variable<String>(taskTitle.value);
    }
    if (taskDetails.present) {
      map['task_details'] = Variable<String>(taskDetails.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineIntervalsCompanion(')
          ..write('id: $id, ')
          ..write('sectionId: $sectionId, ')
          ..write('startMinutes: $startMinutes, ')
          ..write('endMinutes: $endMinutes, ')
          ..write('position: $position, ')
          ..write('taskTitle: $taskTitle, ')
          ..write('taskDetails: $taskDetails, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutineIntervalCompletionsTable extends RoutineIntervalCompletions
    with
        TableInfo<
          $RoutineIntervalCompletionsTable,
          RoutineIntervalCompletionRow
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineIntervalCompletionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _intervalIdMeta = const VerificationMeta(
    'intervalId',
  );
  @override
  late final GeneratedColumn<String> intervalId = GeneratedColumn<String>(
    'interval_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routine_intervals (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateOnly, String> date =
      GeneratedColumn<String>(
        'date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateOnly>(
        $RoutineIntervalCompletionsTable.$converterdate,
      );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [intervalId, date, completedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_interval_completions';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineIntervalCompletionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('interval_id')) {
      context.handle(
        _intervalIdMeta,
        intervalId.isAcceptableOrUnknown(data['interval_id']!, _intervalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_intervalIdMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {intervalId, date};
  @override
  RoutineIntervalCompletionRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineIntervalCompletionRow(
      intervalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}interval_id'],
      )!,
      date: $RoutineIntervalCompletionsTable.$converterdate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}date'],
        )!,
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      )!,
    );
  }

  @override
  $RoutineIntervalCompletionsTable createAlias(String alias) {
    return $RoutineIntervalCompletionsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateOnly, String> $converterdate =
      const DateOnlyConverter();
}

class RoutineIntervalCompletionRow extends DataClass
    implements Insertable<RoutineIntervalCompletionRow> {
  final String intervalId;
  final DateOnly date;
  final int completedAt;
  const RoutineIntervalCompletionRow({
    required this.intervalId,
    required this.date,
    required this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['interval_id'] = Variable<String>(intervalId);
    {
      map['date'] = Variable<String>(
        $RoutineIntervalCompletionsTable.$converterdate.toSql(date),
      );
    }
    map['completed_at'] = Variable<int>(completedAt);
    return map;
  }

  RoutineIntervalCompletionsCompanion toCompanion(bool nullToAbsent) {
    return RoutineIntervalCompletionsCompanion(
      intervalId: Value(intervalId),
      date: Value(date),
      completedAt: Value(completedAt),
    );
  }

  factory RoutineIntervalCompletionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineIntervalCompletionRow(
      intervalId: serializer.fromJson<String>(json['intervalId']),
      date: serializer.fromJson<DateOnly>(json['date']),
      completedAt: serializer.fromJson<int>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'intervalId': serializer.toJson<String>(intervalId),
      'date': serializer.toJson<DateOnly>(date),
      'completedAt': serializer.toJson<int>(completedAt),
    };
  }

  RoutineIntervalCompletionRow copyWith({
    String? intervalId,
    DateOnly? date,
    int? completedAt,
  }) => RoutineIntervalCompletionRow(
    intervalId: intervalId ?? this.intervalId,
    date: date ?? this.date,
    completedAt: completedAt ?? this.completedAt,
  );
  RoutineIntervalCompletionRow copyWithCompanion(
    RoutineIntervalCompletionsCompanion data,
  ) {
    return RoutineIntervalCompletionRow(
      intervalId: data.intervalId.present
          ? data.intervalId.value
          : this.intervalId,
      date: data.date.present ? data.date.value : this.date,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineIntervalCompletionRow(')
          ..write('intervalId: $intervalId, ')
          ..write('date: $date, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(intervalId, date, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineIntervalCompletionRow &&
          other.intervalId == this.intervalId &&
          other.date == this.date &&
          other.completedAt == this.completedAt);
}

class RoutineIntervalCompletionsCompanion
    extends UpdateCompanion<RoutineIntervalCompletionRow> {
  final Value<String> intervalId;
  final Value<DateOnly> date;
  final Value<int> completedAt;
  final Value<int> rowid;
  const RoutineIntervalCompletionsCompanion({
    this.intervalId = const Value.absent(),
    this.date = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutineIntervalCompletionsCompanion.insert({
    required String intervalId,
    required DateOnly date,
    required int completedAt,
    this.rowid = const Value.absent(),
  }) : intervalId = Value(intervalId),
       date = Value(date),
       completedAt = Value(completedAt);
  static Insertable<RoutineIntervalCompletionRow> custom({
    Expression<String>? intervalId,
    Expression<String>? date,
    Expression<int>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (intervalId != null) 'interval_id': intervalId,
      if (date != null) 'date': date,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutineIntervalCompletionsCompanion copyWith({
    Value<String>? intervalId,
    Value<DateOnly>? date,
    Value<int>? completedAt,
    Value<int>? rowid,
  }) {
    return RoutineIntervalCompletionsCompanion(
      intervalId: intervalId ?? this.intervalId,
      date: date ?? this.date,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (intervalId.present) {
      map['interval_id'] = Variable<String>(intervalId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(
        $RoutineIntervalCompletionsTable.$converterdate.toSql(date.value),
      );
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineIntervalCompletionsCompanion(')
          ..write('intervalId: $intervalId, ')
          ..write('date: $date, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutineRemindersTable extends RoutineReminders
    with TableInfo<$RoutineRemindersTable, RoutineReminderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineRemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routineIdMeta = const VerificationMeta(
    'routineId',
  );
  @override
  late final GeneratedColumn<String> routineId = GeneratedColumn<String>(
    'routine_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _intervalIdMeta = const VerificationMeta(
    'intervalId',
  );
  @override
  late final GeneratedColumn<String> intervalId = GeneratedColumn<String>(
    'interval_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<RoutineReminderMode, String>
  mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<RoutineReminderMode>($RoutineRemindersTable.$convertermode);
  static const VerificationMeta _timesPerDayMeta = const VerificationMeta(
    'timesPerDay',
  );
  @override
  late final GeneratedColumn<int> timesPerDay = GeneratedColumn<int>(
    'times_per_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _startMinutesMeta = const VerificationMeta(
    'startMinutes',
  );
  @override
  late final GeneratedColumn<int> startMinutes = GeneratedColumn<int>(
    'start_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(480),
  );
  static const VerificationMeta _endMinutesMeta = const VerificationMeta(
    'endMinutes',
  );
  @override
  late final GeneratedColumn<int> endMinutes = GeneratedColumn<int>(
    'end_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1200),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<int>, String> times =
      GeneratedColumn<String>(
        'times',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<int>>($RoutineRemindersTable.$convertertimes);
  static const VerificationMeta _weekdaysMeta = const VerificationMeta(
    'weekdays',
  );
  @override
  late final GeneratedColumn<int> weekdays = GeneratedColumn<int>(
    'weekdays',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _pausedMeta = const VerificationMeta('paused');
  @override
  late final GeneratedColumn<bool> paused = GeneratedColumn<bool>(
    'paused',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("paused" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    routineId,
    itemId,
    intervalId,
    mode,
    timesPerDay,
    startMinutes,
    endMinutes,
    times,
    weekdays,
    enabled,
    paused,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineReminderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('routine_id')) {
      context.handle(
        _routineIdMeta,
        routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routineIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    }
    if (data.containsKey('interval_id')) {
      context.handle(
        _intervalIdMeta,
        intervalId.isAcceptableOrUnknown(data['interval_id']!, _intervalIdMeta),
      );
    }
    if (data.containsKey('times_per_day')) {
      context.handle(
        _timesPerDayMeta,
        timesPerDay.isAcceptableOrUnknown(
          data['times_per_day']!,
          _timesPerDayMeta,
        ),
      );
    }
    if (data.containsKey('start_minutes')) {
      context.handle(
        _startMinutesMeta,
        startMinutes.isAcceptableOrUnknown(
          data['start_minutes']!,
          _startMinutesMeta,
        ),
      );
    }
    if (data.containsKey('end_minutes')) {
      context.handle(
        _endMinutesMeta,
        endMinutes.isAcceptableOrUnknown(data['end_minutes']!, _endMinutesMeta),
      );
    }
    if (data.containsKey('weekdays')) {
      context.handle(
        _weekdaysMeta,
        weekdays.isAcceptableOrUnknown(data['weekdays']!, _weekdaysMeta),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('paused')) {
      context.handle(
        _pausedMeta,
        paused.isAcceptableOrUnknown(data['paused']!, _pausedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutineReminderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineReminderRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      routineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}routine_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      ),
      intervalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}interval_id'],
      ),
      mode: $RoutineRemindersTable.$convertermode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}mode'],
        )!,
      ),
      timesPerDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}times_per_day'],
      )!,
      startMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_minutes'],
      )!,
      endMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_minutes'],
      )!,
      times: $RoutineRemindersTable.$convertertimes.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}times'],
        )!,
      ),
      weekdays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekdays'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      paused: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}paused'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RoutineRemindersTable createAlias(String alias) {
    return $RoutineRemindersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<RoutineReminderMode, String, String>
  $convertermode = const EnumNameConverter<RoutineReminderMode>(
    RoutineReminderMode.values,
  );
  static TypeConverter<List<int>, String> $convertertimes =
      const MinutesListConverter();
}

class RoutineReminderRow extends DataClass
    implements Insertable<RoutineReminderRow> {
  final String id;
  final String routineId;
  final String? itemId;
  final String? intervalId;
  final RoutineReminderMode mode;
  final int timesPerDay;
  final int startMinutes;
  final int endMinutes;
  final List<int> times;
  final int weekdays;
  final bool enabled;
  final bool paused;
  final int createdAt;
  final int updatedAt;
  const RoutineReminderRow({
    required this.id,
    required this.routineId,
    this.itemId,
    this.intervalId,
    required this.mode,
    required this.timesPerDay,
    required this.startMinutes,
    required this.endMinutes,
    required this.times,
    required this.weekdays,
    required this.enabled,
    required this.paused,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['routine_id'] = Variable<String>(routineId);
    if (!nullToAbsent || itemId != null) {
      map['item_id'] = Variable<String>(itemId);
    }
    if (!nullToAbsent || intervalId != null) {
      map['interval_id'] = Variable<String>(intervalId);
    }
    {
      map['mode'] = Variable<String>(
        $RoutineRemindersTable.$convertermode.toSql(mode),
      );
    }
    map['times_per_day'] = Variable<int>(timesPerDay);
    map['start_minutes'] = Variable<int>(startMinutes);
    map['end_minutes'] = Variable<int>(endMinutes);
    {
      map['times'] = Variable<String>(
        $RoutineRemindersTable.$convertertimes.toSql(times),
      );
    }
    map['weekdays'] = Variable<int>(weekdays);
    map['enabled'] = Variable<bool>(enabled);
    map['paused'] = Variable<bool>(paused);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  RoutineRemindersCompanion toCompanion(bool nullToAbsent) {
    return RoutineRemindersCompanion(
      id: Value(id),
      routineId: Value(routineId),
      itemId: itemId == null && nullToAbsent
          ? const Value.absent()
          : Value(itemId),
      intervalId: intervalId == null && nullToAbsent
          ? const Value.absent()
          : Value(intervalId),
      mode: Value(mode),
      timesPerDay: Value(timesPerDay),
      startMinutes: Value(startMinutes),
      endMinutes: Value(endMinutes),
      times: Value(times),
      weekdays: Value(weekdays),
      enabled: Value(enabled),
      paused: Value(paused),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory RoutineReminderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineReminderRow(
      id: serializer.fromJson<String>(json['id']),
      routineId: serializer.fromJson<String>(json['routineId']),
      itemId: serializer.fromJson<String?>(json['itemId']),
      intervalId: serializer.fromJson<String?>(json['intervalId']),
      mode: $RoutineRemindersTable.$convertermode.fromJson(
        serializer.fromJson<String>(json['mode']),
      ),
      timesPerDay: serializer.fromJson<int>(json['timesPerDay']),
      startMinutes: serializer.fromJson<int>(json['startMinutes']),
      endMinutes: serializer.fromJson<int>(json['endMinutes']),
      times: serializer.fromJson<List<int>>(json['times']),
      weekdays: serializer.fromJson<int>(json['weekdays']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      paused: serializer.fromJson<bool>(json['paused']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'routineId': serializer.toJson<String>(routineId),
      'itemId': serializer.toJson<String?>(itemId),
      'intervalId': serializer.toJson<String?>(intervalId),
      'mode': serializer.toJson<String>(
        $RoutineRemindersTable.$convertermode.toJson(mode),
      ),
      'timesPerDay': serializer.toJson<int>(timesPerDay),
      'startMinutes': serializer.toJson<int>(startMinutes),
      'endMinutes': serializer.toJson<int>(endMinutes),
      'times': serializer.toJson<List<int>>(times),
      'weekdays': serializer.toJson<int>(weekdays),
      'enabled': serializer.toJson<bool>(enabled),
      'paused': serializer.toJson<bool>(paused),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  RoutineReminderRow copyWith({
    String? id,
    String? routineId,
    Value<String?> itemId = const Value.absent(),
    Value<String?> intervalId = const Value.absent(),
    RoutineReminderMode? mode,
    int? timesPerDay,
    int? startMinutes,
    int? endMinutes,
    List<int>? times,
    int? weekdays,
    bool? enabled,
    bool? paused,
    int? createdAt,
    int? updatedAt,
  }) => RoutineReminderRow(
    id: id ?? this.id,
    routineId: routineId ?? this.routineId,
    itemId: itemId.present ? itemId.value : this.itemId,
    intervalId: intervalId.present ? intervalId.value : this.intervalId,
    mode: mode ?? this.mode,
    timesPerDay: timesPerDay ?? this.timesPerDay,
    startMinutes: startMinutes ?? this.startMinutes,
    endMinutes: endMinutes ?? this.endMinutes,
    times: times ?? this.times,
    weekdays: weekdays ?? this.weekdays,
    enabled: enabled ?? this.enabled,
    paused: paused ?? this.paused,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RoutineReminderRow copyWithCompanion(RoutineRemindersCompanion data) {
    return RoutineReminderRow(
      id: data.id.present ? data.id.value : this.id,
      routineId: data.routineId.present ? data.routineId.value : this.routineId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      intervalId: data.intervalId.present
          ? data.intervalId.value
          : this.intervalId,
      mode: data.mode.present ? data.mode.value : this.mode,
      timesPerDay: data.timesPerDay.present
          ? data.timesPerDay.value
          : this.timesPerDay,
      startMinutes: data.startMinutes.present
          ? data.startMinutes.value
          : this.startMinutes,
      endMinutes: data.endMinutes.present
          ? data.endMinutes.value
          : this.endMinutes,
      times: data.times.present ? data.times.value : this.times,
      weekdays: data.weekdays.present ? data.weekdays.value : this.weekdays,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      paused: data.paused.present ? data.paused.value : this.paused,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineReminderRow(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('itemId: $itemId, ')
          ..write('intervalId: $intervalId, ')
          ..write('mode: $mode, ')
          ..write('timesPerDay: $timesPerDay, ')
          ..write('startMinutes: $startMinutes, ')
          ..write('endMinutes: $endMinutes, ')
          ..write('times: $times, ')
          ..write('weekdays: $weekdays, ')
          ..write('enabled: $enabled, ')
          ..write('paused: $paused, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    routineId,
    itemId,
    intervalId,
    mode,
    timesPerDay,
    startMinutes,
    endMinutes,
    times,
    weekdays,
    enabled,
    paused,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineReminderRow &&
          other.id == this.id &&
          other.routineId == this.routineId &&
          other.itemId == this.itemId &&
          other.intervalId == this.intervalId &&
          other.mode == this.mode &&
          other.timesPerDay == this.timesPerDay &&
          other.startMinutes == this.startMinutes &&
          other.endMinutes == this.endMinutes &&
          other.times == this.times &&
          other.weekdays == this.weekdays &&
          other.enabled == this.enabled &&
          other.paused == this.paused &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RoutineRemindersCompanion extends UpdateCompanion<RoutineReminderRow> {
  final Value<String> id;
  final Value<String> routineId;
  final Value<String?> itemId;
  final Value<String?> intervalId;
  final Value<RoutineReminderMode> mode;
  final Value<int> timesPerDay;
  final Value<int> startMinutes;
  final Value<int> endMinutes;
  final Value<List<int>> times;
  final Value<int> weekdays;
  final Value<bool> enabled;
  final Value<bool> paused;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const RoutineRemindersCompanion({
    this.id = const Value.absent(),
    this.routineId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.intervalId = const Value.absent(),
    this.mode = const Value.absent(),
    this.timesPerDay = const Value.absent(),
    this.startMinutes = const Value.absent(),
    this.endMinutes = const Value.absent(),
    this.times = const Value.absent(),
    this.weekdays = const Value.absent(),
    this.enabled = const Value.absent(),
    this.paused = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutineRemindersCompanion.insert({
    required String id,
    required String routineId,
    this.itemId = const Value.absent(),
    this.intervalId = const Value.absent(),
    required RoutineReminderMode mode,
    this.timesPerDay = const Value.absent(),
    this.startMinutes = const Value.absent(),
    this.endMinutes = const Value.absent(),
    this.times = const Value.absent(),
    this.weekdays = const Value.absent(),
    this.enabled = const Value.absent(),
    this.paused = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       routineId = Value(routineId),
       mode = Value(mode),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<RoutineReminderRow> custom({
    Expression<String>? id,
    Expression<String>? routineId,
    Expression<String>? itemId,
    Expression<String>? intervalId,
    Expression<String>? mode,
    Expression<int>? timesPerDay,
    Expression<int>? startMinutes,
    Expression<int>? endMinutes,
    Expression<String>? times,
    Expression<int>? weekdays,
    Expression<bool>? enabled,
    Expression<bool>? paused,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routineId != null) 'routine_id': routineId,
      if (itemId != null) 'item_id': itemId,
      if (intervalId != null) 'interval_id': intervalId,
      if (mode != null) 'mode': mode,
      if (timesPerDay != null) 'times_per_day': timesPerDay,
      if (startMinutes != null) 'start_minutes': startMinutes,
      if (endMinutes != null) 'end_minutes': endMinutes,
      if (times != null) 'times': times,
      if (weekdays != null) 'weekdays': weekdays,
      if (enabled != null) 'enabled': enabled,
      if (paused != null) 'paused': paused,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutineRemindersCompanion copyWith({
    Value<String>? id,
    Value<String>? routineId,
    Value<String?>? itemId,
    Value<String?>? intervalId,
    Value<RoutineReminderMode>? mode,
    Value<int>? timesPerDay,
    Value<int>? startMinutes,
    Value<int>? endMinutes,
    Value<List<int>>? times,
    Value<int>? weekdays,
    Value<bool>? enabled,
    Value<bool>? paused,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return RoutineRemindersCompanion(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      itemId: itemId ?? this.itemId,
      intervalId: intervalId ?? this.intervalId,
      mode: mode ?? this.mode,
      timesPerDay: timesPerDay ?? this.timesPerDay,
      startMinutes: startMinutes ?? this.startMinutes,
      endMinutes: endMinutes ?? this.endMinutes,
      times: times ?? this.times,
      weekdays: weekdays ?? this.weekdays,
      enabled: enabled ?? this.enabled,
      paused: paused ?? this.paused,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (routineId.present) {
      map['routine_id'] = Variable<String>(routineId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (intervalId.present) {
      map['interval_id'] = Variable<String>(intervalId.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(
        $RoutineRemindersTable.$convertermode.toSql(mode.value),
      );
    }
    if (timesPerDay.present) {
      map['times_per_day'] = Variable<int>(timesPerDay.value);
    }
    if (startMinutes.present) {
      map['start_minutes'] = Variable<int>(startMinutes.value);
    }
    if (endMinutes.present) {
      map['end_minutes'] = Variable<int>(endMinutes.value);
    }
    if (times.present) {
      map['times'] = Variable<String>(
        $RoutineRemindersTable.$convertertimes.toSql(times.value),
      );
    }
    if (weekdays.present) {
      map['weekdays'] = Variable<int>(weekdays.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (paused.present) {
      map['paused'] = Variable<bool>(paused.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineRemindersCompanion(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('itemId: $itemId, ')
          ..write('intervalId: $intervalId, ')
          ..write('mode: $mode, ')
          ..write('timesPerDay: $timesPerDay, ')
          ..write('startMinutes: $startMinutes, ')
          ..write('endMinutes: $endMinutes, ')
          ..write('times: $times, ')
          ..write('weekdays: $weekdays, ')
          ..write('enabled: $enabled, ')
          ..write('paused: $paused, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutineExecutionsTable extends RoutineExecutions
    with TableInfo<$RoutineExecutionsTable, RoutineExecutionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineExecutionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routineIdMeta = const VerificationMeta(
    'routineId',
  );
  @override
  late final GeneratedColumn<String> routineId = GeneratedColumn<String>(
    'routine_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _intervalIdMeta = const VerificationMeta(
    'intervalId',
  );
  @override
  late final GeneratedColumn<String> intervalId = GeneratedColumn<String>(
    'interval_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderIdMeta = const VerificationMeta(
    'reminderId',
  );
  @override
  late final GeneratedColumn<String> reminderId = GeneratedColumn<String>(
    'reminder_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateOnly, String> date =
      GeneratedColumn<String>(
        'date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateOnly>($RoutineExecutionsTable.$converterdate);
  static const VerificationMeta _executedAtMeta = const VerificationMeta(
    'executedAt',
  );
  @override
  late final GeneratedColumn<int> executedAt = GeneratedColumn<int>(
    'executed_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<RoutineExecutionOrigin, String>
  origin =
      GeneratedColumn<String>(
        'origin',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RoutineExecutionOrigin>(
        $RoutineExecutionsTable.$converterorigin,
      );
  static const VerificationMeta _dedupeKeyMeta = const VerificationMeta(
    'dedupeKey',
  );
  @override
  late final GeneratedColumn<String> dedupeKey = GeneratedColumn<String>(
    'dedupe_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    routineId,
    itemId,
    intervalId,
    reminderId,
    date,
    executedAt,
    origin,
    dedupeKey,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_executions';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineExecutionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('routine_id')) {
      context.handle(
        _routineIdMeta,
        routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routineIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    }
    if (data.containsKey('interval_id')) {
      context.handle(
        _intervalIdMeta,
        intervalId.isAcceptableOrUnknown(data['interval_id']!, _intervalIdMeta),
      );
    }
    if (data.containsKey('reminder_id')) {
      context.handle(
        _reminderIdMeta,
        reminderId.isAcceptableOrUnknown(data['reminder_id']!, _reminderIdMeta),
      );
    }
    if (data.containsKey('executed_at')) {
      context.handle(
        _executedAtMeta,
        executedAt.isAcceptableOrUnknown(data['executed_at']!, _executedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_executedAtMeta);
    }
    if (data.containsKey('dedupe_key')) {
      context.handle(
        _dedupeKeyMeta,
        dedupeKey.isAcceptableOrUnknown(data['dedupe_key']!, _dedupeKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dedupeKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutineExecutionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineExecutionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      routineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}routine_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      ),
      intervalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}interval_id'],
      ),
      reminderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_id'],
      ),
      date: $RoutineExecutionsTable.$converterdate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}date'],
        )!,
      ),
      executedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}executed_at'],
      )!,
      origin: $RoutineExecutionsTable.$converterorigin.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}origin'],
        )!,
      ),
      dedupeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dedupe_key'],
      )!,
    );
  }

  @override
  $RoutineExecutionsTable createAlias(String alias) {
    return $RoutineExecutionsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateOnly, String> $converterdate =
      const DateOnlyConverter();
  static JsonTypeConverter2<RoutineExecutionOrigin, String, String>
  $converterorigin = const EnumNameConverter<RoutineExecutionOrigin>(
    RoutineExecutionOrigin.values,
  );
}

class RoutineExecutionRow extends DataClass
    implements Insertable<RoutineExecutionRow> {
  final String id;
  final String routineId;
  final String? itemId;
  final String? intervalId;
  final String? reminderId;
  final DateOnly date;
  final int executedAt;
  final RoutineExecutionOrigin origin;
  final String dedupeKey;
  const RoutineExecutionRow({
    required this.id,
    required this.routineId,
    this.itemId,
    this.intervalId,
    this.reminderId,
    required this.date,
    required this.executedAt,
    required this.origin,
    required this.dedupeKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['routine_id'] = Variable<String>(routineId);
    if (!nullToAbsent || itemId != null) {
      map['item_id'] = Variable<String>(itemId);
    }
    if (!nullToAbsent || intervalId != null) {
      map['interval_id'] = Variable<String>(intervalId);
    }
    if (!nullToAbsent || reminderId != null) {
      map['reminder_id'] = Variable<String>(reminderId);
    }
    {
      map['date'] = Variable<String>(
        $RoutineExecutionsTable.$converterdate.toSql(date),
      );
    }
    map['executed_at'] = Variable<int>(executedAt);
    {
      map['origin'] = Variable<String>(
        $RoutineExecutionsTable.$converterorigin.toSql(origin),
      );
    }
    map['dedupe_key'] = Variable<String>(dedupeKey);
    return map;
  }

  RoutineExecutionsCompanion toCompanion(bool nullToAbsent) {
    return RoutineExecutionsCompanion(
      id: Value(id),
      routineId: Value(routineId),
      itemId: itemId == null && nullToAbsent
          ? const Value.absent()
          : Value(itemId),
      intervalId: intervalId == null && nullToAbsent
          ? const Value.absent()
          : Value(intervalId),
      reminderId: reminderId == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderId),
      date: Value(date),
      executedAt: Value(executedAt),
      origin: Value(origin),
      dedupeKey: Value(dedupeKey),
    );
  }

  factory RoutineExecutionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineExecutionRow(
      id: serializer.fromJson<String>(json['id']),
      routineId: serializer.fromJson<String>(json['routineId']),
      itemId: serializer.fromJson<String?>(json['itemId']),
      intervalId: serializer.fromJson<String?>(json['intervalId']),
      reminderId: serializer.fromJson<String?>(json['reminderId']),
      date: serializer.fromJson<DateOnly>(json['date']),
      executedAt: serializer.fromJson<int>(json['executedAt']),
      origin: $RoutineExecutionsTable.$converterorigin.fromJson(
        serializer.fromJson<String>(json['origin']),
      ),
      dedupeKey: serializer.fromJson<String>(json['dedupeKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'routineId': serializer.toJson<String>(routineId),
      'itemId': serializer.toJson<String?>(itemId),
      'intervalId': serializer.toJson<String?>(intervalId),
      'reminderId': serializer.toJson<String?>(reminderId),
      'date': serializer.toJson<DateOnly>(date),
      'executedAt': serializer.toJson<int>(executedAt),
      'origin': serializer.toJson<String>(
        $RoutineExecutionsTable.$converterorigin.toJson(origin),
      ),
      'dedupeKey': serializer.toJson<String>(dedupeKey),
    };
  }

  RoutineExecutionRow copyWith({
    String? id,
    String? routineId,
    Value<String?> itemId = const Value.absent(),
    Value<String?> intervalId = const Value.absent(),
    Value<String?> reminderId = const Value.absent(),
    DateOnly? date,
    int? executedAt,
    RoutineExecutionOrigin? origin,
    String? dedupeKey,
  }) => RoutineExecutionRow(
    id: id ?? this.id,
    routineId: routineId ?? this.routineId,
    itemId: itemId.present ? itemId.value : this.itemId,
    intervalId: intervalId.present ? intervalId.value : this.intervalId,
    reminderId: reminderId.present ? reminderId.value : this.reminderId,
    date: date ?? this.date,
    executedAt: executedAt ?? this.executedAt,
    origin: origin ?? this.origin,
    dedupeKey: dedupeKey ?? this.dedupeKey,
  );
  RoutineExecutionRow copyWithCompanion(RoutineExecutionsCompanion data) {
    return RoutineExecutionRow(
      id: data.id.present ? data.id.value : this.id,
      routineId: data.routineId.present ? data.routineId.value : this.routineId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      intervalId: data.intervalId.present
          ? data.intervalId.value
          : this.intervalId,
      reminderId: data.reminderId.present
          ? data.reminderId.value
          : this.reminderId,
      date: data.date.present ? data.date.value : this.date,
      executedAt: data.executedAt.present
          ? data.executedAt.value
          : this.executedAt,
      origin: data.origin.present ? data.origin.value : this.origin,
      dedupeKey: data.dedupeKey.present ? data.dedupeKey.value : this.dedupeKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineExecutionRow(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('itemId: $itemId, ')
          ..write('intervalId: $intervalId, ')
          ..write('reminderId: $reminderId, ')
          ..write('date: $date, ')
          ..write('executedAt: $executedAt, ')
          ..write('origin: $origin, ')
          ..write('dedupeKey: $dedupeKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    routineId,
    itemId,
    intervalId,
    reminderId,
    date,
    executedAt,
    origin,
    dedupeKey,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineExecutionRow &&
          other.id == this.id &&
          other.routineId == this.routineId &&
          other.itemId == this.itemId &&
          other.intervalId == this.intervalId &&
          other.reminderId == this.reminderId &&
          other.date == this.date &&
          other.executedAt == this.executedAt &&
          other.origin == this.origin &&
          other.dedupeKey == this.dedupeKey);
}

class RoutineExecutionsCompanion extends UpdateCompanion<RoutineExecutionRow> {
  final Value<String> id;
  final Value<String> routineId;
  final Value<String?> itemId;
  final Value<String?> intervalId;
  final Value<String?> reminderId;
  final Value<DateOnly> date;
  final Value<int> executedAt;
  final Value<RoutineExecutionOrigin> origin;
  final Value<String> dedupeKey;
  final Value<int> rowid;
  const RoutineExecutionsCompanion({
    this.id = const Value.absent(),
    this.routineId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.intervalId = const Value.absent(),
    this.reminderId = const Value.absent(),
    this.date = const Value.absent(),
    this.executedAt = const Value.absent(),
    this.origin = const Value.absent(),
    this.dedupeKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutineExecutionsCompanion.insert({
    required String id,
    required String routineId,
    this.itemId = const Value.absent(),
    this.intervalId = const Value.absent(),
    this.reminderId = const Value.absent(),
    required DateOnly date,
    required int executedAt,
    required RoutineExecutionOrigin origin,
    required String dedupeKey,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       routineId = Value(routineId),
       date = Value(date),
       executedAt = Value(executedAt),
       origin = Value(origin),
       dedupeKey = Value(dedupeKey);
  static Insertable<RoutineExecutionRow> custom({
    Expression<String>? id,
    Expression<String>? routineId,
    Expression<String>? itemId,
    Expression<String>? intervalId,
    Expression<String>? reminderId,
    Expression<String>? date,
    Expression<int>? executedAt,
    Expression<String>? origin,
    Expression<String>? dedupeKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routineId != null) 'routine_id': routineId,
      if (itemId != null) 'item_id': itemId,
      if (intervalId != null) 'interval_id': intervalId,
      if (reminderId != null) 'reminder_id': reminderId,
      if (date != null) 'date': date,
      if (executedAt != null) 'executed_at': executedAt,
      if (origin != null) 'origin': origin,
      if (dedupeKey != null) 'dedupe_key': dedupeKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutineExecutionsCompanion copyWith({
    Value<String>? id,
    Value<String>? routineId,
    Value<String?>? itemId,
    Value<String?>? intervalId,
    Value<String?>? reminderId,
    Value<DateOnly>? date,
    Value<int>? executedAt,
    Value<RoutineExecutionOrigin>? origin,
    Value<String>? dedupeKey,
    Value<int>? rowid,
  }) {
    return RoutineExecutionsCompanion(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      itemId: itemId ?? this.itemId,
      intervalId: intervalId ?? this.intervalId,
      reminderId: reminderId ?? this.reminderId,
      date: date ?? this.date,
      executedAt: executedAt ?? this.executedAt,
      origin: origin ?? this.origin,
      dedupeKey: dedupeKey ?? this.dedupeKey,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (routineId.present) {
      map['routine_id'] = Variable<String>(routineId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (intervalId.present) {
      map['interval_id'] = Variable<String>(intervalId.value);
    }
    if (reminderId.present) {
      map['reminder_id'] = Variable<String>(reminderId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(
        $RoutineExecutionsTable.$converterdate.toSql(date.value),
      );
    }
    if (executedAt.present) {
      map['executed_at'] = Variable<int>(executedAt.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(
        $RoutineExecutionsTable.$converterorigin.toSql(origin.value),
      );
    }
    if (dedupeKey.present) {
      map['dedupe_key'] = Variable<String>(dedupeKey.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineExecutionsCompanion(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('itemId: $itemId, ')
          ..write('intervalId: $intervalId, ')
          ..write('reminderId: $reminderId, ')
          ..write('date: $date, ')
          ..write('executedAt: $executedAt, ')
          ..write('origin: $origin, ')
          ..write('dedupeKey: $dedupeKey, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxTable extends SyncOutbox
    with TableInfo<$SyncOutboxTable, SyncOutboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseRevMeta = const VerificationMeta(
    'baseRev',
  );
  @override
  late final GeneratedColumn<int> baseRev = GeneratedColumn<int>(
    'base_rev',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _changeIdMeta = const VerificationMeta(
    'changeId',
  );
  @override
  late final GeneratedColumn<String> changeId = GeneratedColumn<String>(
    'change_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    entity,
    entityId,
    payload,
    baseRev,
    changeId,
    updatedAt,
    attempts,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncOutboxRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('base_rev')) {
      context.handle(
        _baseRevMeta,
        baseRev.isAcceptableOrUnknown(data['base_rev']!, _baseRevMeta),
      );
    }
    if (data.containsKey('change_id')) {
      context.handle(
        _changeIdMeta,
        changeId.isAcceptableOrUnknown(data['change_id']!, _changeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_changeIdMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entity, entityId};
  @override
  SyncOutboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOutboxRow(
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      baseRev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_rev'],
      )!,
      changeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}change_id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $SyncOutboxTable createAlias(String alias) {
    return $SyncOutboxTable(attachedDatabase, alias);
  }
}

class SyncOutboxRow extends DataClass implements Insertable<SyncOutboxRow> {
  final String entity;
  final String entityId;
  final String payload;
  final int baseRev;
  final String changeId;
  final int updatedAt;
  final int attempts;
  final String? lastError;
  const SyncOutboxRow({
    required this.entity,
    required this.entityId,
    required this.payload,
    required this.baseRev,
    required this.changeId,
    required this.updatedAt,
    required this.attempts,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity'] = Variable<String>(entity);
    map['entity_id'] = Variable<String>(entityId);
    map['payload'] = Variable<String>(payload);
    map['base_rev'] = Variable<int>(baseRev);
    map['change_id'] = Variable<String>(changeId);
    map['updated_at'] = Variable<int>(updatedAt);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  SyncOutboxCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxCompanion(
      entity: Value(entity),
      entityId: Value(entityId),
      payload: Value(payload),
      baseRev: Value(baseRev),
      changeId: Value(changeId),
      updatedAt: Value(updatedAt),
      attempts: Value(attempts),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory SyncOutboxRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOutboxRow(
      entity: serializer.fromJson<String>(json['entity']),
      entityId: serializer.fromJson<String>(json['entityId']),
      payload: serializer.fromJson<String>(json['payload']),
      baseRev: serializer.fromJson<int>(json['baseRev']),
      changeId: serializer.fromJson<String>(json['changeId']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entity': serializer.toJson<String>(entity),
      'entityId': serializer.toJson<String>(entityId),
      'payload': serializer.toJson<String>(payload),
      'baseRev': serializer.toJson<int>(baseRev),
      'changeId': serializer.toJson<String>(changeId),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'attempts': serializer.toJson<int>(attempts),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  SyncOutboxRow copyWith({
    String? entity,
    String? entityId,
    String? payload,
    int? baseRev,
    String? changeId,
    int? updatedAt,
    int? attempts,
    Value<String?> lastError = const Value.absent(),
  }) => SyncOutboxRow(
    entity: entity ?? this.entity,
    entityId: entityId ?? this.entityId,
    payload: payload ?? this.payload,
    baseRev: baseRev ?? this.baseRev,
    changeId: changeId ?? this.changeId,
    updatedAt: updatedAt ?? this.updatedAt,
    attempts: attempts ?? this.attempts,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  SyncOutboxRow copyWithCompanion(SyncOutboxCompanion data) {
    return SyncOutboxRow(
      entity: data.entity.present ? data.entity.value : this.entity,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      payload: data.payload.present ? data.payload.value : this.payload,
      baseRev: data.baseRev.present ? data.baseRev.value : this.baseRev,
      changeId: data.changeId.present ? data.changeId.value : this.changeId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxRow(')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('payload: $payload, ')
          ..write('baseRev: $baseRev, ')
          ..write('changeId: $changeId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    entity,
    entityId,
    payload,
    baseRev,
    changeId,
    updatedAt,
    attempts,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOutboxRow &&
          other.entity == this.entity &&
          other.entityId == this.entityId &&
          other.payload == this.payload &&
          other.baseRev == this.baseRev &&
          other.changeId == this.changeId &&
          other.updatedAt == this.updatedAt &&
          other.attempts == this.attempts &&
          other.lastError == this.lastError);
}

class SyncOutboxCompanion extends UpdateCompanion<SyncOutboxRow> {
  final Value<String> entity;
  final Value<String> entityId;
  final Value<String> payload;
  final Value<int> baseRev;
  final Value<String> changeId;
  final Value<int> updatedAt;
  final Value<int> attempts;
  final Value<String?> lastError;
  final Value<int> rowid;
  const SyncOutboxCompanion({
    this.entity = const Value.absent(),
    this.entityId = const Value.absent(),
    this.payload = const Value.absent(),
    this.baseRev = const Value.absent(),
    this.changeId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncOutboxCompanion.insert({
    required String entity,
    required String entityId,
    required String payload,
    this.baseRev = const Value.absent(),
    required String changeId,
    required int updatedAt,
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : entity = Value(entity),
       entityId = Value(entityId),
       payload = Value(payload),
       changeId = Value(changeId),
       updatedAt = Value(updatedAt);
  static Insertable<SyncOutboxRow> custom({
    Expression<String>? entity,
    Expression<String>? entityId,
    Expression<String>? payload,
    Expression<int>? baseRev,
    Expression<String>? changeId,
    Expression<int>? updatedAt,
    Expression<int>? attempts,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entity_id': entityId,
      if (payload != null) 'payload': payload,
      if (baseRev != null) 'base_rev': baseRev,
      if (changeId != null) 'change_id': changeId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (attempts != null) 'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncOutboxCompanion copyWith({
    Value<String>? entity,
    Value<String>? entityId,
    Value<String>? payload,
    Value<int>? baseRev,
    Value<String>? changeId,
    Value<int>? updatedAt,
    Value<int>? attempts,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return SyncOutboxCompanion(
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      payload: payload ?? this.payload,
      baseRev: baseRev ?? this.baseRev,
      changeId: changeId ?? this.changeId,
      updatedAt: updatedAt ?? this.updatedAt,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (baseRev.present) {
      map['base_rev'] = Variable<int>(baseRev.value);
    }
    if (changeId.present) {
      map['change_id'] = Variable<String>(changeId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxCompanion(')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('payload: $payload, ')
          ..write('baseRev: $baseRev, ')
          ..write('changeId: $changeId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncRowStatesTable extends SyncRowStates
    with TableInfo<$SyncRowStatesTable, SyncRowStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncRowStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverRevMeta = const VerificationMeta(
    'serverRev',
  );
  @override
  late final GeneratedColumn<int> serverRev = GeneratedColumn<int>(
    'server_rev',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<int> lastSyncedAt = GeneratedColumn<int>(
    'last_synced_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    entity,
    entityId,
    serverRev,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_row_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncRowStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('server_rev')) {
      context.handle(
        _serverRevMeta,
        serverRev.isAcceptableOrUnknown(data['server_rev']!, _serverRevMeta),
      );
    } else if (isInserting) {
      context.missing(_serverRevMeta);
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSyncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entity, entityId};
  @override
  SyncRowStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncRowStateRow(
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      serverRev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_rev'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_synced_at'],
      )!,
    );
  }

  @override
  $SyncRowStatesTable createAlias(String alias) {
    return $SyncRowStatesTable(attachedDatabase, alias);
  }
}

class SyncRowStateRow extends DataClass implements Insertable<SyncRowStateRow> {
  final String entity;
  final String entityId;
  final int serverRev;
  final int lastSyncedAt;
  const SyncRowStateRow({
    required this.entity,
    required this.entityId,
    required this.serverRev,
    required this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity'] = Variable<String>(entity);
    map['entity_id'] = Variable<String>(entityId);
    map['server_rev'] = Variable<int>(serverRev);
    map['last_synced_at'] = Variable<int>(lastSyncedAt);
    return map;
  }

  SyncRowStatesCompanion toCompanion(bool nullToAbsent) {
    return SyncRowStatesCompanion(
      entity: Value(entity),
      entityId: Value(entityId),
      serverRev: Value(serverRev),
      lastSyncedAt: Value(lastSyncedAt),
    );
  }

  factory SyncRowStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncRowStateRow(
      entity: serializer.fromJson<String>(json['entity']),
      entityId: serializer.fromJson<String>(json['entityId']),
      serverRev: serializer.fromJson<int>(json['serverRev']),
      lastSyncedAt: serializer.fromJson<int>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entity': serializer.toJson<String>(entity),
      'entityId': serializer.toJson<String>(entityId),
      'serverRev': serializer.toJson<int>(serverRev),
      'lastSyncedAt': serializer.toJson<int>(lastSyncedAt),
    };
  }

  SyncRowStateRow copyWith({
    String? entity,
    String? entityId,
    int? serverRev,
    int? lastSyncedAt,
  }) => SyncRowStateRow(
    entity: entity ?? this.entity,
    entityId: entityId ?? this.entityId,
    serverRev: serverRev ?? this.serverRev,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
  );
  SyncRowStateRow copyWithCompanion(SyncRowStatesCompanion data) {
    return SyncRowStateRow(
      entity: data.entity.present ? data.entity.value : this.entity,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      serverRev: data.serverRev.present ? data.serverRev.value : this.serverRev,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncRowStateRow(')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('serverRev: $serverRev, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entity, entityId, serverRev, lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncRowStateRow &&
          other.entity == this.entity &&
          other.entityId == this.entityId &&
          other.serverRev == this.serverRev &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class SyncRowStatesCompanion extends UpdateCompanion<SyncRowStateRow> {
  final Value<String> entity;
  final Value<String> entityId;
  final Value<int> serverRev;
  final Value<int> lastSyncedAt;
  final Value<int> rowid;
  const SyncRowStatesCompanion({
    this.entity = const Value.absent(),
    this.entityId = const Value.absent(),
    this.serverRev = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncRowStatesCompanion.insert({
    required String entity,
    required String entityId,
    required int serverRev,
    required int lastSyncedAt,
    this.rowid = const Value.absent(),
  }) : entity = Value(entity),
       entityId = Value(entityId),
       serverRev = Value(serverRev),
       lastSyncedAt = Value(lastSyncedAt);
  static Insertable<SyncRowStateRow> custom({
    Expression<String>? entity,
    Expression<String>? entityId,
    Expression<int>? serverRev,
    Expression<int>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entity_id': entityId,
      if (serverRev != null) 'server_rev': serverRev,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncRowStatesCompanion copyWith({
    Value<String>? entity,
    Value<String>? entityId,
    Value<int>? serverRev,
    Value<int>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return SyncRowStatesCompanion(
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      serverRev: serverRev ?? this.serverRev,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (serverRev.present) {
      map['server_rev'] = Variable<int>(serverRev.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<int>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncRowStatesCompanion(')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('serverRev: $serverRev, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncBasesTable extends SyncBases
    with TableInfo<$SyncBasesTable, SyncBaseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncBasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [entity, entityId, payload, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_bases';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncBaseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entity, entityId};
  @override
  SyncBaseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncBaseRow(
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SyncBasesTable createAlias(String alias) {
    return $SyncBasesTable(attachedDatabase, alias);
  }
}

class SyncBaseRow extends DataClass implements Insertable<SyncBaseRow> {
  final String entity;
  final String entityId;
  final String payload;
  final int updatedAt;
  const SyncBaseRow({
    required this.entity,
    required this.entityId,
    required this.payload,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity'] = Variable<String>(entity);
    map['entity_id'] = Variable<String>(entityId);
    map['payload'] = Variable<String>(payload);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  SyncBasesCompanion toCompanion(bool nullToAbsent) {
    return SyncBasesCompanion(
      entity: Value(entity),
      entityId: Value(entityId),
      payload: Value(payload),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncBaseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncBaseRow(
      entity: serializer.fromJson<String>(json['entity']),
      entityId: serializer.fromJson<String>(json['entityId']),
      payload: serializer.fromJson<String>(json['payload']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entity': serializer.toJson<String>(entity),
      'entityId': serializer.toJson<String>(entityId),
      'payload': serializer.toJson<String>(payload),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  SyncBaseRow copyWith({
    String? entity,
    String? entityId,
    String? payload,
    int? updatedAt,
  }) => SyncBaseRow(
    entity: entity ?? this.entity,
    entityId: entityId ?? this.entityId,
    payload: payload ?? this.payload,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SyncBaseRow copyWithCompanion(SyncBasesCompanion data) {
    return SyncBaseRow(
      entity: data.entity.present ? data.entity.value : this.entity,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      payload: data.payload.present ? data.payload.value : this.payload,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncBaseRow(')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entity, entityId, payload, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncBaseRow &&
          other.entity == this.entity &&
          other.entityId == this.entityId &&
          other.payload == this.payload &&
          other.updatedAt == this.updatedAt);
}

class SyncBasesCompanion extends UpdateCompanion<SyncBaseRow> {
  final Value<String> entity;
  final Value<String> entityId;
  final Value<String> payload;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const SyncBasesCompanion({
    this.entity = const Value.absent(),
    this.entityId = const Value.absent(),
    this.payload = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncBasesCompanion.insert({
    required String entity,
    required String entityId,
    required String payload,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : entity = Value(entity),
       entityId = Value(entityId),
       payload = Value(payload),
       updatedAt = Value(updatedAt);
  static Insertable<SyncBaseRow> custom({
    Expression<String>? entity,
    Expression<String>? entityId,
    Expression<String>? payload,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entity_id': entityId,
      if (payload != null) 'payload': payload,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncBasesCompanion copyWith({
    Value<String>? entity,
    Value<String>? entityId,
    Value<String>? payload,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return SyncBasesCompanion(
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      payload: payload ?? this.payload,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncBasesCompanion(')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStatesTable extends SyncStates
    with TableInfo<$SyncStatesTable, SyncStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SyncStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SyncStatesTable createAlias(String alias) {
    return $SyncStatesTable(attachedDatabase, alias);
  }
}

class SyncStateRow extends DataClass implements Insertable<SyncStateRow> {
  final String key;
  final String value;
  const SyncStateRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SyncStatesCompanion toCompanion(bool nullToAbsent) {
    return SyncStatesCompanion(key: Value(key), value: Value(value));
  }

  factory SyncStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SyncStateRow copyWith({String? key, String? value}) =>
      SyncStateRow(key: key ?? this.key, value: value ?? this.value);
  SyncStateRow copyWithCompanion(SyncStatesCompanion data) {
    return SyncStateRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SyncStatesCompanion extends UpdateCompanion<SyncStateRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SyncStatesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStatesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SyncStateRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStatesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SyncStatesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStatesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $NoteLinesTable noteLines = $NoteLinesTable(this);
  late final $PostItsTable postIts = $PostItsTable(this);
  late final $PostItHistoryEntriesTable postItHistoryEntries =
      $PostItHistoryEntriesTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $RoutinesTable routines = $RoutinesTable(this);
  late final $RoutineItemsTable routineItems = $RoutineItemsTable(this);
  late final $RoutineCompletionsTable routineCompletions =
      $RoutineCompletionsTable(this);
  late final $RoutineSectionsTable routineSections = $RoutineSectionsTable(
    this,
  );
  late final $RoutineIntervalsTable routineIntervals = $RoutineIntervalsTable(
    this,
  );
  late final $RoutineIntervalCompletionsTable routineIntervalCompletions =
      $RoutineIntervalCompletionsTable(this);
  late final $RoutineRemindersTable routineReminders = $RoutineRemindersTable(
    this,
  );
  late final $RoutineExecutionsTable routineExecutions =
      $RoutineExecutionsTable(this);
  late final $SyncOutboxTable syncOutbox = $SyncOutboxTable(this);
  late final $SyncRowStatesTable syncRowStates = $SyncRowStatesTable(this);
  late final $SyncBasesTable syncBases = $SyncBasesTable(this);
  late final $SyncStatesTable syncStates = $SyncStatesTable(this);
  late final Index idxNoteLinesNoteId = Index(
    'idx_note_lines_note_id',
    'CREATE INDEX idx_note_lines_note_id ON note_lines (note_id)',
  );
  late final Index idxPostItsStartDate = Index(
    'idx_post_its_start_date',
    'CREATE INDEX idx_post_its_start_date ON post_its (start_date)',
  );
  late final Index idxPostItsStatus = Index(
    'idx_post_its_status',
    'CREATE INDEX idx_post_its_status ON post_its (status)',
  );
  late final Index idxPostItsNoteId = Index(
    'idx_post_its_note_id',
    'CREATE INDEX idx_post_its_note_id ON post_its (note_id)',
  );
  late final Index idxPostItHistoryPostItId = Index(
    'idx_post_it_history_post_it_id',
    'CREATE INDEX idx_post_it_history_post_it_id ON post_it_history_entries (post_it_id)',
  );
  late final Index idxTagsName = Index(
    'idx_tags_name',
    'CREATE INDEX idx_tags_name ON tags (name)',
  );
  late final Index idxRoutineItemsRoutineId = Index(
    'idx_routine_items_routine_id',
    'CREATE INDEX idx_routine_items_routine_id ON routine_items (routine_id)',
  );
  late final Index idxRoutineCompletionsItem = Index(
    'idx_routine_completions_item',
    'CREATE INDEX idx_routine_completions_item ON routine_completions (routine_item_id)',
  );
  late final Index idxRoutineSectionsRoutineId = Index(
    'idx_routine_sections_routine_id',
    'CREATE INDEX idx_routine_sections_routine_id ON routine_sections (routine_id)',
  );
  late final Index idxRoutineIntervalsSectionId = Index(
    'idx_routine_intervals_section_id',
    'CREATE INDEX idx_routine_intervals_section_id ON routine_intervals (section_id)',
  );
  late final Index idxRoutineIntervalCompletionsInterval = Index(
    'idx_routine_interval_completions_interval',
    'CREATE INDEX idx_routine_interval_completions_interval ON routine_interval_completions (interval_id)',
  );
  late final Index idxRoutineRemindersRoutine = Index(
    'idx_routine_reminders_routine',
    'CREATE INDEX idx_routine_reminders_routine ON routine_reminders (routine_id)',
  );
  late final Index idxRoutineExecutionsDate = Index(
    'idx_routine_executions_date',
    'CREATE INDEX idx_routine_executions_date ON routine_executions (date)',
  );
  late final Index idxRoutineExecutionsRoutine = Index(
    'idx_routine_executions_routine',
    'CREATE INDEX idx_routine_executions_routine ON routine_executions (routine_id)',
  );
  late final Index idxRoutineExecutionsDedupe = Index(
    'idx_routine_executions_dedupe',
    'CREATE UNIQUE INDEX idx_routine_executions_dedupe ON routine_executions (dedupe_key)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    appSettings,
    notes,
    noteLines,
    postIts,
    postItHistoryEntries,
    tags,
    routines,
    routineItems,
    routineCompletions,
    routineSections,
    routineIntervals,
    routineIntervalCompletions,
    routineReminders,
    routineExecutions,
    syncOutbox,
    syncRowStates,
    syncBases,
    syncStates,
    idxNoteLinesNoteId,
    idxPostItsStartDate,
    idxPostItsStatus,
    idxPostItsNoteId,
    idxPostItHistoryPostItId,
    idxTagsName,
    idxRoutineItemsRoutineId,
    idxRoutineCompletionsItem,
    idxRoutineSectionsRoutineId,
    idxRoutineIntervalsSectionId,
    idxRoutineIntervalCompletionsInterval,
    idxRoutineRemindersRoutine,
    idxRoutineExecutionsDate,
    idxRoutineExecutionsRoutine,
    idxRoutineExecutionsDedupe,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'notes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('note_lines', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'notes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('post_its', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'post_its',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('post_it_history_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'routines',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('routine_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'routine_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('routine_completions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'routines',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('routine_sections', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'routine_sections',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('routine_intervals', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'routine_intervals',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('routine_interval_completions', kind: UpdateKind.delete),
      ],
    ),
  ]);
}

typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSetting>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$NotesTableCreateCompanionBuilder = NotesCompanion Function({
  required String id,
  required String title,
  required NoteType type,
  Value<String?> markdown,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});
typedef $$NotesTableUpdateCompanionBuilder = NotesCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<NoteType> type,
  Value<String?> markdown,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});

final class $$NotesTableReferences
    extends BaseReferences<_$AppDatabase, $NotesTable, NoteRow> {
  $$NotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$NoteLinesTable, List<NoteLineRow>>
  _noteLinesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.noteLines,
    aliasName: 'notes__id__note_lines__note_id',
  );

  $$NoteLinesTableProcessedTableManager get noteLinesRefs {
    final manager = $$NoteLinesTableTableManager(
      $_db,
      $_db.noteLines,
    ).filter((f) => f.noteId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_noteLinesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PostItsTable, List<PostItRow>> _postItsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.postIts,
    aliasName: 'notes__id__post_its__note_id',
  );

  $$PostItsTableProcessedTableManager get postItsRefs {
    final manager = $$PostItsTableTableManager(
      $_db,
      $_db.postIts,
    ).filter((f) => f.noteId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_postItsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$NotesTableFilterComposer extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<NoteType, NoteType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get markdown => $composableBuilder(
    column: $table.markdown,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> noteLinesRefs(
    Expression<bool> Function($$NoteLinesTableFilterComposer f) f,
  ) {
    final $$NoteLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteLines,
      getReferencedColumn: (t) => t.noteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteLinesTableFilterComposer(
            $db: $db,
            $table: $db.noteLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> postItsRefs(
    Expression<bool> Function($$PostItsTableFilterComposer f) f,
  ) {
    final $$PostItsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.postIts,
      getReferencedColumn: (t) => t.noteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PostItsTableFilterComposer(
            $db: $db,
            $table: $db.postIts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NotesTableOrderingComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get markdown => $composableBuilder(
    column: $table.markdown,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumnWithTypeConverter<NoteType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get markdown =>
      $composableBuilder(column: $table.markdown, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> noteLinesRefs<T extends Object>(
    Expression<T> Function($$NoteLinesTableAnnotationComposer a) f,
  ) {
    final $$NoteLinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteLines,
      getReferencedColumn: (t) => t.noteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteLinesTableAnnotationComposer(
            $db: $db,
            $table: $db.noteLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> postItsRefs<T extends Object>(
    Expression<T> Function($$PostItsTableAnnotationComposer a) f,
  ) {
    final $$PostItsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.postIts,
      getReferencedColumn: (t) => t.noteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PostItsTableAnnotationComposer(
            $db: $db,
            $table: $db.postIts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotesTable,
          NoteRow,
          $$NotesTableFilterComposer,
          $$NotesTableOrderingComposer,
          $$NotesTableAnnotationComposer,
          $$NotesTableCreateCompanionBuilder,
          $$NotesTableUpdateCompanionBuilder,
          (NoteRow, $$NotesTableReferences),
          NoteRow,
          PrefetchHooks Function({bool noteLinesRefs, bool postItsRefs})
        > {
  $$NotesTableTableManager(_$AppDatabase db, $NotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<NoteType> type = const Value.absent(),
                Value<String?> markdown = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion(
                id: id,
                title: title,
                type: type,
                markdown: markdown,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required NoteType type,
                Value<String?> markdown = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion.insert(
                id: id,
                title: title,
                type: type,
                markdown: markdown,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NotesTable, NoteRow>(table),
                  $$NotesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({noteLinesRefs = false, postItsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (noteLinesRefs) db.noteLines,
                    if (postItsRefs) db.postIts,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (noteLinesRefs)
                        await $_getPrefetchedDataByColumns<
                          NoteRow,
                          $NotesTable,
                          NoteLineRow,
                          $NoteLinesTable
                        >(
                          currentTable: table,
                          referencedTable: $$NotesTableReferences
                              ._noteLinesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NotesTableReferences(
                                db,
                                table,
                                p0,
                              ).noteLinesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'note_id',
                          typedResults: items,
                        ),
                      if (postItsRefs)
                        await $_getPrefetchedDataByColumns<
                          NoteRow,
                          $NotesTable,
                          PostItRow,
                          $PostItsTable
                        >(
                          currentTable: table,
                          referencedTable: $$NotesTableReferences
                              ._postItsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NotesTableReferences(db, table, p0).postItsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'note_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$NotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotesTable,
      NoteRow,
      $$NotesTableFilterComposer,
      $$NotesTableOrderingComposer,
      $$NotesTableAnnotationComposer,
      $$NotesTableCreateCompanionBuilder,
      $$NotesTableUpdateCompanionBuilder,
      (NoteRow, $$NotesTableReferences),
      NoteRow,
      PrefetchHooks Function({bool noteLinesRefs, bool postItsRefs})
    >;
typedef $$NoteLinesTableCreateCompanionBuilder = NoteLinesCompanion Function({
  required String id,
  required String noteId,
  required int position,
  required String content,
  Value<bool> isChecked,
  Value<int> rowid,
});
typedef $$NoteLinesTableUpdateCompanionBuilder = NoteLinesCompanion Function({
  Value<String> id,
  Value<String> noteId,
  Value<int> position,
  Value<String> content,
  Value<bool> isChecked,
  Value<int> rowid,
});

final class $$NoteLinesTableReferences
    extends BaseReferences<_$AppDatabase, $NoteLinesTable, NoteLineRow> {
  $$NoteLinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $NotesTable _noteIdTable(_$AppDatabase db) =>
      db.notes.createAlias('note_lines__note_id__notes__id');

  $$NotesTableProcessedTableManager get noteId {
    final $_column = $_itemColumn<String>('note_id')!;

    final manager = $$NotesTableTableManager(
      $_db,
      $_db.notes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_noteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NoteLinesTableFilterComposer
    extends Composer<_$AppDatabase, $NoteLinesTable> {
  $$NoteLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isChecked => $composableBuilder(
    column: $table.isChecked,
    builder: (column) => ColumnFilters(column),
  );

  $$NotesTableFilterComposer get noteId {
    final $$NotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableFilterComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $NoteLinesTable> {
  $$NoteLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isChecked => $composableBuilder(
    column: $table.isChecked,
    builder: (column) => ColumnOrderings(column),
  );

  $$NotesTableOrderingComposer get noteId {
    final $$NotesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableOrderingComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NoteLinesTable> {
  $$NoteLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<bool> get isChecked =>
      $composableBuilder(column: $table.isChecked, builder: (column) => column);

  $$NotesTableAnnotationComposer get noteId {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableAnnotationComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NoteLinesTable,
          NoteLineRow,
          $$NoteLinesTableFilterComposer,
          $$NoteLinesTableOrderingComposer,
          $$NoteLinesTableAnnotationComposer,
          $$NoteLinesTableCreateCompanionBuilder,
          $$NoteLinesTableUpdateCompanionBuilder,
          (NoteLineRow, $$NoteLinesTableReferences),
          NoteLineRow,
          PrefetchHooks Function({bool noteId})
        > {
  $$NoteLinesTableTableManager(_$AppDatabase db, $NoteLinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NoteLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NoteLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NoteLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> noteId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<bool> isChecked = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NoteLinesCompanion(
                id: id,
                noteId: noteId,
                position: position,
                content: content,
                isChecked: isChecked,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String noteId,
                required int position,
                required String content,
                Value<bool> isChecked = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NoteLinesCompanion.insert(
                id: id,
                noteId: noteId,
                position: position,
                content: content,
                isChecked: isChecked,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NoteLinesTable, NoteLineRow>(table),
                  $$NoteLinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({noteId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (noteId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.noteId,
                        referencedTable: $$NoteLinesTableReferences
                            ._noteIdTable(db),
                        referencedColumn: $$NoteLinesTableReferences
                            ._noteIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$NoteLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NoteLinesTable,
      NoteLineRow,
      $$NoteLinesTableFilterComposer,
      $$NoteLinesTableOrderingComposer,
      $$NoteLinesTableAnnotationComposer,
      $$NoteLinesTableCreateCompanionBuilder,
      $$NoteLinesTableUpdateCompanionBuilder,
      (NoteLineRow, $$NoteLinesTableReferences),
      NoteLineRow,
      PrefetchHooks Function({bool noteId})
    >;
typedef $$PostItsTableCreateCompanionBuilder = PostItsCompanion Function({
  required String id,
  required String title,
  required PostItType type,
  required PostItStatus status,
  Value<bool> isHighlight,
  Value<String?> details,
  Value<String?> noteId,
  Value<String?> noteExcerpt,
  Value<String?> sourceNoteId,
  Value<DateOnly?> startDate,
  Value<DateOnly?> endDate,
  Value<EventRecurrence> recurrence,
  Value<int> recurrenceInterval,
  Value<DateOnly?> recurrenceEndDate,
  Value<String?> seriesId,
  Value<Map<DateOnly, PostItStatus>> occurrenceStatuses,
  Value<int?> timeMinutes,
  Value<int?> reminderMinutes,
  Value<List<String>> tagIds,
  Value<int> sortOrder,
  Value<int?> lastRolloverAt,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});
typedef $$PostItsTableUpdateCompanionBuilder = PostItsCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<PostItType> type,
  Value<PostItStatus> status,
  Value<bool> isHighlight,
  Value<String?> details,
  Value<String?> noteId,
  Value<String?> noteExcerpt,
  Value<String?> sourceNoteId,
  Value<DateOnly?> startDate,
  Value<DateOnly?> endDate,
  Value<EventRecurrence> recurrence,
  Value<int> recurrenceInterval,
  Value<DateOnly?> recurrenceEndDate,
  Value<String?> seriesId,
  Value<Map<DateOnly, PostItStatus>> occurrenceStatuses,
  Value<int?> timeMinutes,
  Value<int?> reminderMinutes,
  Value<List<String>> tagIds,
  Value<int> sortOrder,
  Value<int?> lastRolloverAt,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});

final class $$PostItsTableReferences
    extends BaseReferences<_$AppDatabase, $PostItsTable, PostItRow> {
  $$PostItsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $NotesTable _noteIdTable(_$AppDatabase db) =>
      db.notes.createAlias('post_its__note_id__notes__id');

  $$NotesTableProcessedTableManager? get noteId {
    final $_column = $_itemColumn<String>('note_id');
    if ($_column == null) return null;
    final manager = $$NotesTableTableManager(
      $_db,
      $_db.notes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_noteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PostItHistoryEntriesTable, List<PostItHistoryRow>>
  _postItHistoryEntriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.postItHistoryEntries,
        aliasName: 'post_its__id__post_it_history_entries__post_it_id',
      );

  $$PostItHistoryEntriesTableProcessedTableManager
  get postItHistoryEntriesRefs {
    final manager = $$PostItHistoryEntriesTableTableManager(
      $_db,
      $_db.postItHistoryEntries,
    ).filter((f) => f.postItId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _postItHistoryEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PostItsTableFilterComposer
    extends Composer<_$AppDatabase, $PostItsTable> {
  $$PostItsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PostItType, PostItType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<PostItStatus, PostItStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get isHighlight => $composableBuilder(
    column: $table.isHighlight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noteExcerpt => $composableBuilder(
    column: $table.noteExcerpt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceNoteId => $composableBuilder(
    column: $table.sourceNoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateOnly?, DateOnly, String> get startDate =>
      $composableBuilder(
        column: $table.startDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateOnly?, DateOnly, String> get endDate =>
      $composableBuilder(
        column: $table.endDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<EventRecurrence, EventRecurrence, String>
  get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get recurrenceInterval => $composableBuilder(
    column: $table.recurrenceInterval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateOnly?, DateOnly, String>
  get recurrenceEndDate => $composableBuilder(
    column: $table.recurrenceEndDate,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<DateOnly, PostItStatus>,
    Map<DateOnly, PostItStatus>,
    String
  >
  get occurrenceStatuses => $composableBuilder(
    column: $table.occurrenceStatuses,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get timeMinutes => $composableBuilder(
    column: $table.timeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderMinutes => $composableBuilder(
    column: $table.reminderMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get tagIds => $composableBuilder(
    column: $table.tagIds,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastRolloverAt => $composableBuilder(
    column: $table.lastRolloverAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$NotesTableFilterComposer get noteId {
    final $$NotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableFilterComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> postItHistoryEntriesRefs(
    Expression<bool> Function($$PostItHistoryEntriesTableFilterComposer f) f,
  ) {
    final $$PostItHistoryEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.postItHistoryEntries,
      getReferencedColumn: (t) => t.postItId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PostItHistoryEntriesTableFilterComposer(
            $db: $db,
            $table: $db.postItHistoryEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PostItsTableOrderingComposer
    extends Composer<_$AppDatabase, $PostItsTable> {
  $$PostItsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHighlight => $composableBuilder(
    column: $table.isHighlight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteExcerpt => $composableBuilder(
    column: $table.noteExcerpt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceNoteId => $composableBuilder(
    column: $table.sourceNoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recurrenceInterval => $composableBuilder(
    column: $table.recurrenceInterval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrenceEndDate => $composableBuilder(
    column: $table.recurrenceEndDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get occurrenceStatuses => $composableBuilder(
    column: $table.occurrenceStatuses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeMinutes => $composableBuilder(
    column: $table.timeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderMinutes => $composableBuilder(
    column: $table.reminderMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagIds => $composableBuilder(
    column: $table.tagIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastRolloverAt => $composableBuilder(
    column: $table.lastRolloverAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$NotesTableOrderingComposer get noteId {
    final $$NotesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableOrderingComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PostItsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PostItsTable> {
  $$PostItsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PostItType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PostItStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get isHighlight => $composableBuilder(
    column: $table.isHighlight,
    builder: (column) => column,
  );

  GeneratedColumn<String> get details =>
      $composableBuilder(column: $table.details, builder: (column) => column);

  GeneratedColumn<String> get noteExcerpt => $composableBuilder(
    column: $table.noteExcerpt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceNoteId => $composableBuilder(
    column: $table.sourceNoteId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateOnly?, String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateOnly?, String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EventRecurrence, String> get recurrence =>
      $composableBuilder(
        column: $table.recurrence,
        builder: (column) => column,
      );

  GeneratedColumn<int> get recurrenceInterval => $composableBuilder(
    column: $table.recurrenceInterval,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateOnly?, String> get recurrenceEndDate =>
      $composableBuilder(
        column: $table.recurrenceEndDate,
        builder: (column) => column,
      );

  GeneratedColumn<String> get seriesId =>
      $composableBuilder(column: $table.seriesId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<DateOnly, PostItStatus>, String>
  get occurrenceStatuses => $composableBuilder(
    column: $table.occurrenceStatuses,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeMinutes => $composableBuilder(
    column: $table.timeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderMinutes => $composableBuilder(
    column: $table.reminderMinutes,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>, String> get tagIds =>
      $composableBuilder(column: $table.tagIds, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get lastRolloverAt => $composableBuilder(
    column: $table.lastRolloverAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$NotesTableAnnotationComposer get noteId {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableAnnotationComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> postItHistoryEntriesRefs<T extends Object>(
    Expression<T> Function($$PostItHistoryEntriesTableAnnotationComposer a) f,
  ) {
    final $$PostItHistoryEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.postItHistoryEntries,
          getReferencedColumn: (t) => t.postItId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PostItHistoryEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.postItHistoryEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PostItsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PostItsTable,
          PostItRow,
          $$PostItsTableFilterComposer,
          $$PostItsTableOrderingComposer,
          $$PostItsTableAnnotationComposer,
          $$PostItsTableCreateCompanionBuilder,
          $$PostItsTableUpdateCompanionBuilder,
          (PostItRow, $$PostItsTableReferences),
          PostItRow,
          PrefetchHooks Function({bool noteId, bool postItHistoryEntriesRefs})
        > {
  $$PostItsTableTableManager(_$AppDatabase db, $PostItsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PostItsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PostItsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PostItsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<PostItType> type = const Value.absent(),
                Value<PostItStatus> status = const Value.absent(),
                Value<bool> isHighlight = const Value.absent(),
                Value<String?> details = const Value.absent(),
                Value<String?> noteId = const Value.absent(),
                Value<String?> noteExcerpt = const Value.absent(),
                Value<String?> sourceNoteId = const Value.absent(),
                Value<DateOnly?> startDate = const Value.absent(),
                Value<DateOnly?> endDate = const Value.absent(),
                Value<EventRecurrence> recurrence = const Value.absent(),
                Value<int> recurrenceInterval = const Value.absent(),
                Value<DateOnly?> recurrenceEndDate = const Value.absent(),
                Value<String?> seriesId = const Value.absent(),
                Value<Map<DateOnly, PostItStatus>> occurrenceStatuses =
                    const Value.absent(),
                Value<int?> timeMinutes = const Value.absent(),
                Value<int?> reminderMinutes = const Value.absent(),
                Value<List<String>> tagIds = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int?> lastRolloverAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PostItsCompanion(
                id: id,
                title: title,
                type: type,
                status: status,
                isHighlight: isHighlight,
                details: details,
                noteId: noteId,
                noteExcerpt: noteExcerpt,
                sourceNoteId: sourceNoteId,
                startDate: startDate,
                endDate: endDate,
                recurrence: recurrence,
                recurrenceInterval: recurrenceInterval,
                recurrenceEndDate: recurrenceEndDate,
                seriesId: seriesId,
                occurrenceStatuses: occurrenceStatuses,
                timeMinutes: timeMinutes,
                reminderMinutes: reminderMinutes,
                tagIds: tagIds,
                sortOrder: sortOrder,
                lastRolloverAt: lastRolloverAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required PostItType type,
                required PostItStatus status,
                Value<bool> isHighlight = const Value.absent(),
                Value<String?> details = const Value.absent(),
                Value<String?> noteId = const Value.absent(),
                Value<String?> noteExcerpt = const Value.absent(),
                Value<String?> sourceNoteId = const Value.absent(),
                Value<DateOnly?> startDate = const Value.absent(),
                Value<DateOnly?> endDate = const Value.absent(),
                Value<EventRecurrence> recurrence = const Value.absent(),
                Value<int> recurrenceInterval = const Value.absent(),
                Value<DateOnly?> recurrenceEndDate = const Value.absent(),
                Value<String?> seriesId = const Value.absent(),
                Value<Map<DateOnly, PostItStatus>> occurrenceStatuses =
                    const Value.absent(),
                Value<int?> timeMinutes = const Value.absent(),
                Value<int?> reminderMinutes = const Value.absent(),
                Value<List<String>> tagIds = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int?> lastRolloverAt = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PostItsCompanion.insert(
                id: id,
                title: title,
                type: type,
                status: status,
                isHighlight: isHighlight,
                details: details,
                noteId: noteId,
                noteExcerpt: noteExcerpt,
                sourceNoteId: sourceNoteId,
                startDate: startDate,
                endDate: endDate,
                recurrence: recurrence,
                recurrenceInterval: recurrenceInterval,
                recurrenceEndDate: recurrenceEndDate,
                seriesId: seriesId,
                occurrenceStatuses: occurrenceStatuses,
                timeMinutes: timeMinutes,
                reminderMinutes: reminderMinutes,
                tagIds: tagIds,
                sortOrder: sortOrder,
                lastRolloverAt: lastRolloverAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PostItsTable, PostItRow>(table),
                  $$PostItsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({noteId = false, postItHistoryEntriesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (postItHistoryEntriesRefs) db.postItHistoryEntries,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (noteId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.noteId,
                            referencedTable: $$PostItsTableReferences
                                ._noteIdTable(db),
                            referencedColumn: $$PostItsTableReferences
                                ._noteIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (postItHistoryEntriesRefs)
                        await $_getPrefetchedDataByColumns<
                          PostItRow,
                          $PostItsTable,
                          PostItHistoryRow,
                          $PostItHistoryEntriesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PostItsTableReferences
                              ._postItHistoryEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PostItsTableReferences(
                                db,
                                table,
                                p0,
                              ).postItHistoryEntriesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'post_it_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PostItsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PostItsTable,
      PostItRow,
      $$PostItsTableFilterComposer,
      $$PostItsTableOrderingComposer,
      $$PostItsTableAnnotationComposer,
      $$PostItsTableCreateCompanionBuilder,
      $$PostItsTableUpdateCompanionBuilder,
      (PostItRow, $$PostItsTableReferences),
      PostItRow,
      PrefetchHooks Function({bool noteId, bool postItHistoryEntriesRefs})
    >;
typedef $$PostItHistoryEntriesTableCreateCompanionBuilder =
    PostItHistoryEntriesCompanion Function({
      required String id,
      required String postItId,
      required PostItHistoryAction action,
      Value<String?> fromValue,
      Value<String?> toValue,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$PostItHistoryEntriesTableUpdateCompanionBuilder =
    PostItHistoryEntriesCompanion Function({
      Value<String> id,
      Value<String> postItId,
      Value<PostItHistoryAction> action,
      Value<String?> fromValue,
      Value<String?> toValue,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$PostItHistoryEntriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PostItHistoryEntriesTable,
          PostItHistoryRow
        > {
  $$PostItHistoryEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PostItsTable _postItIdTable(_$AppDatabase db) => db.postIts
      .createAlias('post_it_history_entries__post_it_id__post_its__id');

  $$PostItsTableProcessedTableManager get postItId {
    final $_column = $_itemColumn<String>('post_it_id')!;

    final manager = $$PostItsTableTableManager(
      $_db,
      $_db.postIts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_postItIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PostItHistoryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $PostItHistoryEntriesTable> {
  $$PostItHistoryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    PostItHistoryAction,
    PostItHistoryAction,
    String
  >
  get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get fromValue => $composableBuilder(
    column: $table.fromValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toValue => $composableBuilder(
    column: $table.toValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PostItsTableFilterComposer get postItId {
    final $$PostItsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.postItId,
      referencedTable: $db.postIts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PostItsTableFilterComposer(
            $db: $db,
            $table: $db.postIts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PostItHistoryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $PostItHistoryEntriesTable> {
  $$PostItHistoryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromValue => $composableBuilder(
    column: $table.fromValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toValue => $composableBuilder(
    column: $table.toValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PostItsTableOrderingComposer get postItId {
    final $$PostItsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.postItId,
      referencedTable: $db.postIts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PostItsTableOrderingComposer(
            $db: $db,
            $table: $db.postIts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PostItHistoryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PostItHistoryEntriesTable> {
  $$PostItHistoryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PostItHistoryAction, String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get fromValue =>
      $composableBuilder(column: $table.fromValue, builder: (column) => column);

  GeneratedColumn<String> get toValue =>
      $composableBuilder(column: $table.toValue, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PostItsTableAnnotationComposer get postItId {
    final $$PostItsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.postItId,
      referencedTable: $db.postIts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PostItsTableAnnotationComposer(
            $db: $db,
            $table: $db.postIts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PostItHistoryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PostItHistoryEntriesTable,
          PostItHistoryRow,
          $$PostItHistoryEntriesTableFilterComposer,
          $$PostItHistoryEntriesTableOrderingComposer,
          $$PostItHistoryEntriesTableAnnotationComposer,
          $$PostItHistoryEntriesTableCreateCompanionBuilder,
          $$PostItHistoryEntriesTableUpdateCompanionBuilder,
          (PostItHistoryRow, $$PostItHistoryEntriesTableReferences),
          PostItHistoryRow,
          PrefetchHooks Function({bool postItId})
        > {
  $$PostItHistoryEntriesTableTableManager(
    _$AppDatabase db,
    $PostItHistoryEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PostItHistoryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PostItHistoryEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PostItHistoryEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> postItId = const Value.absent(),
                Value<PostItHistoryAction> action = const Value.absent(),
                Value<String?> fromValue = const Value.absent(),
                Value<String?> toValue = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PostItHistoryEntriesCompanion(
                id: id,
                postItId: postItId,
                action: action,
                fromValue: fromValue,
                toValue: toValue,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String postItId,
                required PostItHistoryAction action,
                Value<String?> fromValue = const Value.absent(),
                Value<String?> toValue = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PostItHistoryEntriesCompanion.insert(
                id: id,
                postItId: postItId,
                action: action,
                fromValue: fromValue,
                toValue: toValue,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PostItHistoryEntriesTable, PostItHistoryRow>(
                    table,
                  ),
                  $$PostItHistoryEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({postItId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (postItId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.postItId,
                        referencedTable: $$PostItHistoryEntriesTableReferences
                            ._postItIdTable(db),
                        referencedColumn: $$PostItHistoryEntriesTableReferences
                            ._postItIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PostItHistoryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PostItHistoryEntriesTable,
      PostItHistoryRow,
      $$PostItHistoryEntriesTableFilterComposer,
      $$PostItHistoryEntriesTableOrderingComposer,
      $$PostItHistoryEntriesTableAnnotationComposer,
      $$PostItHistoryEntriesTableCreateCompanionBuilder,
      $$PostItHistoryEntriesTableUpdateCompanionBuilder,
      (PostItHistoryRow, $$PostItHistoryEntriesTableReferences),
      PostItHistoryRow,
      PrefetchHooks Function({bool postItId})
    >;
typedef $$TagsTableCreateCompanionBuilder = TagsCompanion Function({
  required String id,
  required String name,
  required TagTone tone,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});
typedef $$TagsTableUpdateCompanionBuilder = TagsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<TagTone> tone,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> rowid,
});

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TagTone, TagTone, String> get tone =>
      $composableBuilder(
        column: $table.tone,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tone => $composableBuilder(
    column: $table.tone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TagTone, String> get tone =>
      $composableBuilder(column: $table.tone, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          TagRow,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (TagRow, BaseReferences<_$AppDatabase, $TagsTable, TagRow>),
          TagRow,
          PrefetchHooks Function()
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<TagTone> tone = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion(
                id: id,
                name: name,
                tone: tone,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required TagTone tone,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion.insert(
                id: id,
                name: name,
                tone: tone,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TagsTable, TagRow>(table),
                  BaseReferences<_$AppDatabase, $TagsTable, TagRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      TagRow,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (TagRow, BaseReferences<_$AppDatabase, $TagsTable, TagRow>),
      TagRow,
      PrefetchHooks Function()
    >;
typedef $$RoutinesTableCreateCompanionBuilder = RoutinesCompanion Function({
  required String id,
  required String name,
  Value<String?> details,
  Value<RoutineMode> mode,
  Value<int> weekdays,
  required int createdAt,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$RoutinesTableUpdateCompanionBuilder = RoutinesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> details,
  Value<RoutineMode> mode,
  Value<int> weekdays,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});

final class $$RoutinesTableReferences
    extends BaseReferences<_$AppDatabase, $RoutinesTable, RoutineRow> {
  $$RoutinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RoutineItemsTable, List<RoutineItemRow>>
  _routineItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.routineItems,
    aliasName: 'routines__id__routine_items__routine_id',
  );

  $$RoutineItemsTableProcessedTableManager get routineItemsRefs {
    final manager = $$RoutineItemsTableTableManager(
      $_db,
      $_db.routineItems,
    ).filter((f) => f.routineId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_routineItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RoutineSectionsTable, List<RoutineSectionRow>>
  _routineSectionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.routineSections,
    aliasName: 'routines__id__routine_sections__routine_id',
  );

  $$RoutineSectionsTableProcessedTableManager get routineSectionsRefs {
    final manager = $$RoutineSectionsTableTableManager(
      $_db,
      $_db.routineSections,
    ).filter((f) => f.routineId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _routineSectionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoutinesTableFilterComposer
    extends Composer<_$AppDatabase, $RoutinesTable> {
  $$RoutinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RoutineMode, RoutineMode, String> get mode =>
      $composableBuilder(
        column: $table.mode,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get weekdays => $composableBuilder(
    column: $table.weekdays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> routineItemsRefs(
    Expression<bool> Function($$RoutineItemsTableFilterComposer f) f,
  ) {
    final $$RoutineItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineItems,
      getReferencedColumn: (t) => t.routineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineItemsTableFilterComposer(
            $db: $db,
            $table: $db.routineItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> routineSectionsRefs(
    Expression<bool> Function($$RoutineSectionsTableFilterComposer f) f,
  ) {
    final $$RoutineSectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineSections,
      getReferencedColumn: (t) => t.routineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineSectionsTableFilterComposer(
            $db: $db,
            $table: $db.routineSections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutinesTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutinesTable> {
  $$RoutinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekdays => $composableBuilder(
    column: $table.weekdays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoutinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutinesTable> {
  $$RoutinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get details =>
      $composableBuilder(column: $table.details, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RoutineMode, String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<int> get weekdays =>
      $composableBuilder(column: $table.weekdays, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> routineItemsRefs<T extends Object>(
    Expression<T> Function($$RoutineItemsTableAnnotationComposer a) f,
  ) {
    final $$RoutineItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineItems,
      getReferencedColumn: (t) => t.routineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.routineItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> routineSectionsRefs<T extends Object>(
    Expression<T> Function($$RoutineSectionsTableAnnotationComposer a) f,
  ) {
    final $$RoutineSectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineSections,
      getReferencedColumn: (t) => t.routineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineSectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.routineSections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutinesTable,
          RoutineRow,
          $$RoutinesTableFilterComposer,
          $$RoutinesTableOrderingComposer,
          $$RoutinesTableAnnotationComposer,
          $$RoutinesTableCreateCompanionBuilder,
          $$RoutinesTableUpdateCompanionBuilder,
          (RoutineRow, $$RoutinesTableReferences),
          RoutineRow,
          PrefetchHooks Function({
            bool routineItemsRefs,
            bool routineSectionsRefs,
          })
        > {
  $$RoutinesTableTableManager(_$AppDatabase db, $RoutinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> details = const Value.absent(),
                Value<RoutineMode> mode = const Value.absent(),
                Value<int> weekdays = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutinesCompanion(
                id: id,
                name: name,
                details: details,
                mode: mode,
                weekdays: weekdays,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> details = const Value.absent(),
                Value<RoutineMode> mode = const Value.absent(),
                Value<int> weekdays = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => RoutinesCompanion.insert(
                id: id,
                name: name,
                details: details,
                mode: mode,
                weekdays: weekdays,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RoutinesTable, RoutineRow>(table),
                  $$RoutinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({routineItemsRefs = false, routineSectionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (routineItemsRefs) db.routineItems,
                    if (routineSectionsRefs) db.routineSections,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (routineItemsRefs)
                        await $_getPrefetchedDataByColumns<
                          RoutineRow,
                          $RoutinesTable,
                          RoutineItemRow,
                          $RoutineItemsTable
                        >(
                          currentTable: table,
                          referencedTable: $$RoutinesTableReferences
                              ._routineItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RoutinesTableReferences(
                                db,
                                table,
                                p0,
                              ).routineItemsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'routine_id',
                          typedResults: items,
                        ),
                      if (routineSectionsRefs)
                        await $_getPrefetchedDataByColumns<
                          RoutineRow,
                          $RoutinesTable,
                          RoutineSectionRow,
                          $RoutineSectionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$RoutinesTableReferences
                              ._routineSectionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RoutinesTableReferences(
                                db,
                                table,
                                p0,
                              ).routineSectionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'routine_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RoutinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutinesTable,
      RoutineRow,
      $$RoutinesTableFilterComposer,
      $$RoutinesTableOrderingComposer,
      $$RoutinesTableAnnotationComposer,
      $$RoutinesTableCreateCompanionBuilder,
      $$RoutinesTableUpdateCompanionBuilder,
      (RoutineRow, $$RoutinesTableReferences),
      RoutineRow,
      PrefetchHooks Function({bool routineItemsRefs, bool routineSectionsRefs})
    >;
typedef $$RoutineItemsTableCreateCompanionBuilder =
    RoutineItemsCompanion Function({
      required String id,
      required String routineId,
      required String title,
      Value<String?> details,
      required int position,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$RoutineItemsTableUpdateCompanionBuilder =
    RoutineItemsCompanion Function({
      Value<String> id,
      Value<String> routineId,
      Value<String> title,
      Value<String?> details,
      Value<int> position,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

final class $$RoutineItemsTableReferences
    extends BaseReferences<_$AppDatabase, $RoutineItemsTable, RoutineItemRow> {
  $$RoutineItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RoutinesTable _routineIdTable(_$AppDatabase db) =>
      db.routines.createAlias('routine_items__routine_id__routines__id');

  $$RoutinesTableProcessedTableManager get routineId {
    final $_column = $_itemColumn<String>('routine_id')!;

    final manager = $$RoutinesTableTableManager(
      $_db,
      $_db.routines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $RoutineCompletionsTable,
    List<RoutineCompletionRow>
  >
  _routineCompletionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.routineCompletions,
        aliasName: 'routine_items__id__routine_completions__routine_item_id',
      );

  $$RoutineCompletionsTableProcessedTableManager get routineCompletionsRefs {
    final manager = $$RoutineCompletionsTableTableManager(
      $_db,
      $_db.routineCompletions,
    ).filter((f) => f.routineItemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _routineCompletionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoutineItemsTableFilterComposer
    extends Composer<_$AppDatabase, $RoutineItemsTable> {
  $$RoutineItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$RoutinesTableFilterComposer get routineId {
    final $$RoutinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableFilterComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> routineCompletionsRefs(
    Expression<bool> Function($$RoutineCompletionsTableFilterComposer f) f,
  ) {
    final $$RoutineCompletionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineCompletions,
      getReferencedColumn: (t) => t.routineItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineCompletionsTableFilterComposer(
            $db: $db,
            $table: $db.routineCompletions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutineItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutineItemsTable> {
  $$RoutineItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoutinesTableOrderingComposer get routineId {
    final $$RoutinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableOrderingComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutineItemsTable> {
  $$RoutineItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get details =>
      $composableBuilder(column: $table.details, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$RoutinesTableAnnotationComposer get routineId {
    final $$RoutinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableAnnotationComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> routineCompletionsRefs<T extends Object>(
    Expression<T> Function($$RoutineCompletionsTableAnnotationComposer a) f,
  ) {
    final $$RoutineCompletionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.routineCompletions,
          getReferencedColumn: (t) => t.routineItemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RoutineCompletionsTableAnnotationComposer(
                $db: $db,
                $table: $db.routineCompletions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$RoutineItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutineItemsTable,
          RoutineItemRow,
          $$RoutineItemsTableFilterComposer,
          $$RoutineItemsTableOrderingComposer,
          $$RoutineItemsTableAnnotationComposer,
          $$RoutineItemsTableCreateCompanionBuilder,
          $$RoutineItemsTableUpdateCompanionBuilder,
          (RoutineItemRow, $$RoutineItemsTableReferences),
          RoutineItemRow,
          PrefetchHooks Function({bool routineId, bool routineCompletionsRefs})
        > {
  $$RoutineItemsTableTableManager(_$AppDatabase db, $RoutineItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutineItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutineItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutineItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> routineId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> details = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutineItemsCompanion(
                id: id,
                routineId: routineId,
                title: title,
                details: details,
                position: position,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String routineId,
                required String title,
                Value<String?> details = const Value.absent(),
                required int position,
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => RoutineItemsCompanion.insert(
                id: id,
                routineId: routineId,
                title: title,
                details: details,
                position: position,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RoutineItemsTable, RoutineItemRow>(table),
                  $$RoutineItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({routineId = false, routineCompletionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (routineCompletionsRefs) db.routineCompletions,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (routineId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.routineId,
                            referencedTable: $$RoutineItemsTableReferences
                                ._routineIdTable(db),
                            referencedColumn: $$RoutineItemsTableReferences
                                ._routineIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (routineCompletionsRefs)
                        await $_getPrefetchedDataByColumns<
                          RoutineItemRow,
                          $RoutineItemsTable,
                          RoutineCompletionRow,
                          $RoutineCompletionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$RoutineItemsTableReferences
                              ._routineCompletionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RoutineItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).routineCompletionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'routine_item_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RoutineItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutineItemsTable,
      RoutineItemRow,
      $$RoutineItemsTableFilterComposer,
      $$RoutineItemsTableOrderingComposer,
      $$RoutineItemsTableAnnotationComposer,
      $$RoutineItemsTableCreateCompanionBuilder,
      $$RoutineItemsTableUpdateCompanionBuilder,
      (RoutineItemRow, $$RoutineItemsTableReferences),
      RoutineItemRow,
      PrefetchHooks Function({bool routineId, bool routineCompletionsRefs})
    >;
typedef $$RoutineCompletionsTableCreateCompanionBuilder =
    RoutineCompletionsCompanion Function({
      required String routineItemId,
      required DateOnly date,
      required int completedAt,
      Value<int> rowid,
    });
typedef $$RoutineCompletionsTableUpdateCompanionBuilder =
    RoutineCompletionsCompanion Function({
      Value<String> routineItemId,
      Value<DateOnly> date,
      Value<int> completedAt,
      Value<int> rowid,
    });

final class $$RoutineCompletionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RoutineCompletionsTable,
          RoutineCompletionRow
        > {
  $$RoutineCompletionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RoutineItemsTable _routineItemIdTable(_$AppDatabase db) => db
      .routineItems
      .createAlias('routine_completions__routine_item_id__routine_items__id');

  $$RoutineItemsTableProcessedTableManager get routineItemId {
    final $_column = $_itemColumn<String>('routine_item_id')!;

    final manager = $$RoutineItemsTableTableManager(
      $_db,
      $_db.routineItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routineItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RoutineCompletionsTableFilterComposer
    extends Composer<_$AppDatabase, $RoutineCompletionsTable> {
  $$RoutineCompletionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<DateOnly, DateOnly, String> get date =>
      $composableBuilder(
        column: $table.date,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$RoutineItemsTableFilterComposer get routineItemId {
    final $$RoutineItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineItemId,
      referencedTable: $db.routineItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineItemsTableFilterComposer(
            $db: $db,
            $table: $db.routineItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineCompletionsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutineCompletionsTable> {
  $$RoutineCompletionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoutineItemsTableOrderingComposer get routineItemId {
    final $$RoutineItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineItemId,
      referencedTable: $db.routineItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineItemsTableOrderingComposer(
            $db: $db,
            $table: $db.routineItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineCompletionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutineCompletionsTable> {
  $$RoutineCompletionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<DateOnly, String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  $$RoutineItemsTableAnnotationComposer get routineItemId {
    final $$RoutineItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineItemId,
      referencedTable: $db.routineItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.routineItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineCompletionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutineCompletionsTable,
          RoutineCompletionRow,
          $$RoutineCompletionsTableFilterComposer,
          $$RoutineCompletionsTableOrderingComposer,
          $$RoutineCompletionsTableAnnotationComposer,
          $$RoutineCompletionsTableCreateCompanionBuilder,
          $$RoutineCompletionsTableUpdateCompanionBuilder,
          (RoutineCompletionRow, $$RoutineCompletionsTableReferences),
          RoutineCompletionRow,
          PrefetchHooks Function({bool routineItemId})
        > {
  $$RoutineCompletionsTableTableManager(
    _$AppDatabase db,
    $RoutineCompletionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutineCompletionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutineCompletionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutineCompletionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> routineItemId = const Value.absent(),
                Value<DateOnly> date = const Value.absent(),
                Value<int> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutineCompletionsCompanion(
                routineItemId: routineItemId,
                date: date,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String routineItemId,
                required DateOnly date,
                required int completedAt,
                Value<int> rowid = const Value.absent(),
              }) => RoutineCompletionsCompanion.insert(
                routineItemId: routineItemId,
                date: date,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RoutineCompletionsTable, RoutineCompletionRow>(
                    table,
                  ),
                  $$RoutineCompletionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({routineItemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (routineItemId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.routineItemId,
                        referencedTable: $$RoutineCompletionsTableReferences
                            ._routineItemIdTable(db),
                        referencedColumn: $$RoutineCompletionsTableReferences
                            ._routineItemIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RoutineCompletionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutineCompletionsTable,
      RoutineCompletionRow,
      $$RoutineCompletionsTableFilterComposer,
      $$RoutineCompletionsTableOrderingComposer,
      $$RoutineCompletionsTableAnnotationComposer,
      $$RoutineCompletionsTableCreateCompanionBuilder,
      $$RoutineCompletionsTableUpdateCompanionBuilder,
      (RoutineCompletionRow, $$RoutineCompletionsTableReferences),
      RoutineCompletionRow,
      PrefetchHooks Function({bool routineItemId})
    >;
typedef $$RoutineSectionsTableCreateCompanionBuilder =
    RoutineSectionsCompanion Function({
      required String id,
      required String routineId,
      required String title,
      required int position,
      Value<int?> startMinutes,
      Value<int?> endMinutes,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$RoutineSectionsTableUpdateCompanionBuilder =
    RoutineSectionsCompanion Function({
      Value<String> id,
      Value<String> routineId,
      Value<String> title,
      Value<int> position,
      Value<int?> startMinutes,
      Value<int?> endMinutes,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

final class $$RoutineSectionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RoutineSectionsTable,
          RoutineSectionRow
        > {
  $$RoutineSectionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RoutinesTable _routineIdTable(_$AppDatabase db) =>
      db.routines.createAlias('routine_sections__routine_id__routines__id');

  $$RoutinesTableProcessedTableManager get routineId {
    final $_column = $_itemColumn<String>('routine_id')!;

    final manager = $$RoutinesTableTableManager(
      $_db,
      $_db.routines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RoutineIntervalsTable, List<RoutineIntervalRow>>
  _routineIntervalsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.routineIntervals,
    aliasName: 'routine_sections__id__routine_intervals__section_id',
  );

  $$RoutineIntervalsTableProcessedTableManager get routineIntervalsRefs {
    final manager = $$RoutineIntervalsTableTableManager(
      $_db,
      $_db.routineIntervals,
    ).filter((f) => f.sectionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _routineIntervalsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoutineSectionsTableFilterComposer
    extends Composer<_$AppDatabase, $RoutineSectionsTable> {
  $$RoutineSectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMinutes => $composableBuilder(
    column: $table.endMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$RoutinesTableFilterComposer get routineId {
    final $$RoutinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableFilterComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> routineIntervalsRefs(
    Expression<bool> Function($$RoutineIntervalsTableFilterComposer f) f,
  ) {
    final $$RoutineIntervalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineIntervals,
      getReferencedColumn: (t) => t.sectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineIntervalsTableFilterComposer(
            $db: $db,
            $table: $db.routineIntervals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutineSectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutineSectionsTable> {
  $$RoutineSectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMinutes => $composableBuilder(
    column: $table.endMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoutinesTableOrderingComposer get routineId {
    final $$RoutinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableOrderingComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineSectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutineSectionsTable> {
  $$RoutineSectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endMinutes => $composableBuilder(
    column: $table.endMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$RoutinesTableAnnotationComposer get routineId {
    final $$RoutinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableAnnotationComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> routineIntervalsRefs<T extends Object>(
    Expression<T> Function($$RoutineIntervalsTableAnnotationComposer a) f,
  ) {
    final $$RoutineIntervalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineIntervals,
      getReferencedColumn: (t) => t.sectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineIntervalsTableAnnotationComposer(
            $db: $db,
            $table: $db.routineIntervals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutineSectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutineSectionsTable,
          RoutineSectionRow,
          $$RoutineSectionsTableFilterComposer,
          $$RoutineSectionsTableOrderingComposer,
          $$RoutineSectionsTableAnnotationComposer,
          $$RoutineSectionsTableCreateCompanionBuilder,
          $$RoutineSectionsTableUpdateCompanionBuilder,
          (RoutineSectionRow, $$RoutineSectionsTableReferences),
          RoutineSectionRow,
          PrefetchHooks Function({bool routineId, bool routineIntervalsRefs})
        > {
  $$RoutineSectionsTableTableManager(
    _$AppDatabase db,
    $RoutineSectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutineSectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutineSectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutineSectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> routineId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int?> startMinutes = const Value.absent(),
                Value<int?> endMinutes = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutineSectionsCompanion(
                id: id,
                routineId: routineId,
                title: title,
                position: position,
                startMinutes: startMinutes,
                endMinutes: endMinutes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String routineId,
                required String title,
                required int position,
                Value<int?> startMinutes = const Value.absent(),
                Value<int?> endMinutes = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => RoutineSectionsCompanion.insert(
                id: id,
                routineId: routineId,
                title: title,
                position: position,
                startMinutes: startMinutes,
                endMinutes: endMinutes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RoutineSectionsTable, RoutineSectionRow>(table),
                  $$RoutineSectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({routineId = false, routineIntervalsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (routineIntervalsRefs) db.routineIntervals,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (routineId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.routineId,
                            referencedTable: $$RoutineSectionsTableReferences
                                ._routineIdTable(db),
                            referencedColumn: $$RoutineSectionsTableReferences
                                ._routineIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (routineIntervalsRefs)
                        await $_getPrefetchedDataByColumns<
                          RoutineSectionRow,
                          $RoutineSectionsTable,
                          RoutineIntervalRow,
                          $RoutineIntervalsTable
                        >(
                          currentTable: table,
                          referencedTable: $$RoutineSectionsTableReferences
                              ._routineIntervalsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RoutineSectionsTableReferences(
                                db,
                                table,
                                p0,
                              ).routineIntervalsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'section_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RoutineSectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutineSectionsTable,
      RoutineSectionRow,
      $$RoutineSectionsTableFilterComposer,
      $$RoutineSectionsTableOrderingComposer,
      $$RoutineSectionsTableAnnotationComposer,
      $$RoutineSectionsTableCreateCompanionBuilder,
      $$RoutineSectionsTableUpdateCompanionBuilder,
      (RoutineSectionRow, $$RoutineSectionsTableReferences),
      RoutineSectionRow,
      PrefetchHooks Function({bool routineId, bool routineIntervalsRefs})
    >;
typedef $$RoutineIntervalsTableCreateCompanionBuilder =
    RoutineIntervalsCompanion Function({
      required String id,
      required String sectionId,
      required int startMinutes,
      required int endMinutes,
      required int position,
      Value<String?> taskTitle,
      Value<String?> taskDetails,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$RoutineIntervalsTableUpdateCompanionBuilder =
    RoutineIntervalsCompanion Function({
      Value<String> id,
      Value<String> sectionId,
      Value<int> startMinutes,
      Value<int> endMinutes,
      Value<int> position,
      Value<String?> taskTitle,
      Value<String?> taskDetails,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

final class $$RoutineIntervalsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RoutineIntervalsTable,
          RoutineIntervalRow
        > {
  $$RoutineIntervalsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RoutineSectionsTable _sectionIdTable(_$AppDatabase db) => db
      .routineSections
      .createAlias('routine_intervals__section_id__routine_sections__id');

  $$RoutineSectionsTableProcessedTableManager get sectionId {
    final $_column = $_itemColumn<String>('section_id')!;

    final manager = $$RoutineSectionsTableTableManager(
      $_db,
      $_db.routineSections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $RoutineIntervalCompletionsTable,
    List<RoutineIntervalCompletionRow>
  >
  _routineIntervalCompletionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.routineIntervalCompletions,
        aliasName:
            'routine_intervals__id__routine_interval_completions__interval_id',
      );

  $$RoutineIntervalCompletionsTableProcessedTableManager
  get routineIntervalCompletionsRefs {
    final manager = $$RoutineIntervalCompletionsTableTableManager(
      $_db,
      $_db.routineIntervalCompletions,
    ).filter((f) => f.intervalId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _routineIntervalCompletionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoutineIntervalsTableFilterComposer
    extends Composer<_$AppDatabase, $RoutineIntervalsTable> {
  $$RoutineIntervalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMinutes => $composableBuilder(
    column: $table.endMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskTitle => $composableBuilder(
    column: $table.taskTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskDetails => $composableBuilder(
    column: $table.taskDetails,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$RoutineSectionsTableFilterComposer get sectionId {
    final $$RoutineSectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.routineSections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineSectionsTableFilterComposer(
            $db: $db,
            $table: $db.routineSections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> routineIntervalCompletionsRefs(
    Expression<bool> Function($$RoutineIntervalCompletionsTableFilterComposer f)
    f,
  ) {
    final $$RoutineIntervalCompletionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.routineIntervalCompletions,
          getReferencedColumn: (t) => t.intervalId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RoutineIntervalCompletionsTableFilterComposer(
                $db: $db,
                $table: $db.routineIntervalCompletions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$RoutineIntervalsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutineIntervalsTable> {
  $$RoutineIntervalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMinutes => $composableBuilder(
    column: $table.endMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskTitle => $composableBuilder(
    column: $table.taskTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskDetails => $composableBuilder(
    column: $table.taskDetails,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoutineSectionsTableOrderingComposer get sectionId {
    final $$RoutineSectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.routineSections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineSectionsTableOrderingComposer(
            $db: $db,
            $table: $db.routineSections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineIntervalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutineIntervalsTable> {
  $$RoutineIntervalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endMinutes => $composableBuilder(
    column: $table.endMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get taskTitle =>
      $composableBuilder(column: $table.taskTitle, builder: (column) => column);

  GeneratedColumn<String> get taskDetails => $composableBuilder(
    column: $table.taskDetails,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$RoutineSectionsTableAnnotationComposer get sectionId {
    final $$RoutineSectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.routineSections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineSectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.routineSections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> routineIntervalCompletionsRefs<T extends Object>(
    Expression<T> Function(
      $$RoutineIntervalCompletionsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$RoutineIntervalCompletionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.routineIntervalCompletions,
          getReferencedColumn: (t) => t.intervalId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RoutineIntervalCompletionsTableAnnotationComposer(
                $db: $db,
                $table: $db.routineIntervalCompletions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$RoutineIntervalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutineIntervalsTable,
          RoutineIntervalRow,
          $$RoutineIntervalsTableFilterComposer,
          $$RoutineIntervalsTableOrderingComposer,
          $$RoutineIntervalsTableAnnotationComposer,
          $$RoutineIntervalsTableCreateCompanionBuilder,
          $$RoutineIntervalsTableUpdateCompanionBuilder,
          (RoutineIntervalRow, $$RoutineIntervalsTableReferences),
          RoutineIntervalRow,
          PrefetchHooks Function({
            bool sectionId,
            bool routineIntervalCompletionsRefs,
          })
        > {
  $$RoutineIntervalsTableTableManager(
    _$AppDatabase db,
    $RoutineIntervalsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutineIntervalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutineIntervalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutineIntervalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sectionId = const Value.absent(),
                Value<int> startMinutes = const Value.absent(),
                Value<int> endMinutes = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String?> taskTitle = const Value.absent(),
                Value<String?> taskDetails = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutineIntervalsCompanion(
                id: id,
                sectionId: sectionId,
                startMinutes: startMinutes,
                endMinutes: endMinutes,
                position: position,
                taskTitle: taskTitle,
                taskDetails: taskDetails,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sectionId,
                required int startMinutes,
                required int endMinutes,
                required int position,
                Value<String?> taskTitle = const Value.absent(),
                Value<String?> taskDetails = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => RoutineIntervalsCompanion.insert(
                id: id,
                sectionId: sectionId,
                startMinutes: startMinutes,
                endMinutes: endMinutes,
                position: position,
                taskTitle: taskTitle,
                taskDetails: taskDetails,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RoutineIntervalsTable, RoutineIntervalRow>(
                    table,
                  ),
                  $$RoutineIntervalsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({sectionId = false, routineIntervalCompletionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (routineIntervalCompletionsRefs)
                      db.routineIntervalCompletions,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sectionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.sectionId,
                            referencedTable: $$RoutineIntervalsTableReferences
                                ._sectionIdTable(db),
                            referencedColumn: $$RoutineIntervalsTableReferences
                                ._sectionIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (routineIntervalCompletionsRefs)
                        await $_getPrefetchedDataByColumns<
                          RoutineIntervalRow,
                          $RoutineIntervalsTable,
                          RoutineIntervalCompletionRow,
                          $RoutineIntervalCompletionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$RoutineIntervalsTableReferences
                              ._routineIntervalCompletionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RoutineIntervalsTableReferences(
                                db,
                                table,
                                p0,
                              ).routineIntervalCompletionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'interval_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RoutineIntervalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutineIntervalsTable,
      RoutineIntervalRow,
      $$RoutineIntervalsTableFilterComposer,
      $$RoutineIntervalsTableOrderingComposer,
      $$RoutineIntervalsTableAnnotationComposer,
      $$RoutineIntervalsTableCreateCompanionBuilder,
      $$RoutineIntervalsTableUpdateCompanionBuilder,
      (RoutineIntervalRow, $$RoutineIntervalsTableReferences),
      RoutineIntervalRow,
      PrefetchHooks Function({
        bool sectionId,
        bool routineIntervalCompletionsRefs,
      })
    >;
typedef $$RoutineIntervalCompletionsTableCreateCompanionBuilder =
    RoutineIntervalCompletionsCompanion Function({
      required String intervalId,
      required DateOnly date,
      required int completedAt,
      Value<int> rowid,
    });
typedef $$RoutineIntervalCompletionsTableUpdateCompanionBuilder =
    RoutineIntervalCompletionsCompanion Function({
      Value<String> intervalId,
      Value<DateOnly> date,
      Value<int> completedAt,
      Value<int> rowid,
    });

final class $$RoutineIntervalCompletionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RoutineIntervalCompletionsTable,
          RoutineIntervalCompletionRow
        > {
  $$RoutineIntervalCompletionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RoutineIntervalsTable _intervalIdTable(_$AppDatabase db) =>
      db.routineIntervals.createAlias(
        'routine_interval_completions__interval_id__routine_intervals__id',
      );

  $$RoutineIntervalsTableProcessedTableManager get intervalId {
    final $_column = $_itemColumn<String>('interval_id')!;

    final manager = $$RoutineIntervalsTableTableManager(
      $_db,
      $_db.routineIntervals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_intervalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RoutineIntervalCompletionsTableFilterComposer
    extends Composer<_$AppDatabase, $RoutineIntervalCompletionsTable> {
  $$RoutineIntervalCompletionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<DateOnly, DateOnly, String> get date =>
      $composableBuilder(
        column: $table.date,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$RoutineIntervalsTableFilterComposer get intervalId {
    final $$RoutineIntervalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.intervalId,
      referencedTable: $db.routineIntervals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineIntervalsTableFilterComposer(
            $db: $db,
            $table: $db.routineIntervals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineIntervalCompletionsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutineIntervalCompletionsTable> {
  $$RoutineIntervalCompletionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoutineIntervalsTableOrderingComposer get intervalId {
    final $$RoutineIntervalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.intervalId,
      referencedTable: $db.routineIntervals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineIntervalsTableOrderingComposer(
            $db: $db,
            $table: $db.routineIntervals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineIntervalCompletionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutineIntervalCompletionsTable> {
  $$RoutineIntervalCompletionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<DateOnly, String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  $$RoutineIntervalsTableAnnotationComposer get intervalId {
    final $$RoutineIntervalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.intervalId,
      referencedTable: $db.routineIntervals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineIntervalsTableAnnotationComposer(
            $db: $db,
            $table: $db.routineIntervals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineIntervalCompletionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutineIntervalCompletionsTable,
          RoutineIntervalCompletionRow,
          $$RoutineIntervalCompletionsTableFilterComposer,
          $$RoutineIntervalCompletionsTableOrderingComposer,
          $$RoutineIntervalCompletionsTableAnnotationComposer,
          $$RoutineIntervalCompletionsTableCreateCompanionBuilder,
          $$RoutineIntervalCompletionsTableUpdateCompanionBuilder,
          (
            RoutineIntervalCompletionRow,
            $$RoutineIntervalCompletionsTableReferences,
          ),
          RoutineIntervalCompletionRow,
          PrefetchHooks Function({bool intervalId})
        > {
  $$RoutineIntervalCompletionsTableTableManager(
    _$AppDatabase db,
    $RoutineIntervalCompletionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutineIntervalCompletionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$RoutineIntervalCompletionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RoutineIntervalCompletionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> intervalId = const Value.absent(),
                Value<DateOnly> date = const Value.absent(),
                Value<int> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutineIntervalCompletionsCompanion(
                intervalId: intervalId,
                date: date,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String intervalId,
                required DateOnly date,
                required int completedAt,
                Value<int> rowid = const Value.absent(),
              }) => RoutineIntervalCompletionsCompanion.insert(
                intervalId: intervalId,
                date: date,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $RoutineIntervalCompletionsTable,
                    RoutineIntervalCompletionRow
                  >(table),
                  $$RoutineIntervalCompletionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({intervalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (intervalId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.intervalId,
                        referencedTable:
                            $$RoutineIntervalCompletionsTableReferences
                                ._intervalIdTable(db),
                        referencedColumn:
                            $$RoutineIntervalCompletionsTableReferences
                                ._intervalIdTable(db)
                                .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RoutineIntervalCompletionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutineIntervalCompletionsTable,
      RoutineIntervalCompletionRow,
      $$RoutineIntervalCompletionsTableFilterComposer,
      $$RoutineIntervalCompletionsTableOrderingComposer,
      $$RoutineIntervalCompletionsTableAnnotationComposer,
      $$RoutineIntervalCompletionsTableCreateCompanionBuilder,
      $$RoutineIntervalCompletionsTableUpdateCompanionBuilder,
      (
        RoutineIntervalCompletionRow,
        $$RoutineIntervalCompletionsTableReferences,
      ),
      RoutineIntervalCompletionRow,
      PrefetchHooks Function({bool intervalId})
    >;
typedef $$RoutineRemindersTableCreateCompanionBuilder =
    RoutineRemindersCompanion Function({
      required String id,
      required String routineId,
      Value<String?> itemId,
      Value<String?> intervalId,
      required RoutineReminderMode mode,
      Value<int> timesPerDay,
      Value<int> startMinutes,
      Value<int> endMinutes,
      Value<List<int>> times,
      Value<int> weekdays,
      Value<bool> enabled,
      Value<bool> paused,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$RoutineRemindersTableUpdateCompanionBuilder =
    RoutineRemindersCompanion Function({
      Value<String> id,
      Value<String> routineId,
      Value<String?> itemId,
      Value<String?> intervalId,
      Value<RoutineReminderMode> mode,
      Value<int> timesPerDay,
      Value<int> startMinutes,
      Value<int> endMinutes,
      Value<List<int>> times,
      Value<int> weekdays,
      Value<bool> enabled,
      Value<bool> paused,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$RoutineRemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RoutineRemindersTable> {
  $$RoutineRemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routineId => $composableBuilder(
    column: $table.routineId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get intervalId => $composableBuilder(
    column: $table.intervalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    RoutineReminderMode,
    RoutineReminderMode,
    String
  >
  get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get timesPerDay => $composableBuilder(
    column: $table.timesPerDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMinutes => $composableBuilder(
    column: $table.endMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<int>, List<int>, String> get times =>
      $composableBuilder(
        column: $table.times,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get weekdays => $composableBuilder(
    column: $table.weekdays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get paused => $composableBuilder(
    column: $table.paused,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RoutineRemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutineRemindersTable> {
  $$RoutineRemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routineId => $composableBuilder(
    column: $table.routineId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get intervalId => $composableBuilder(
    column: $table.intervalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timesPerDay => $composableBuilder(
    column: $table.timesPerDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMinutes => $composableBuilder(
    column: $table.endMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get times => $composableBuilder(
    column: $table.times,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekdays => $composableBuilder(
    column: $table.weekdays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get paused => $composableBuilder(
    column: $table.paused,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoutineRemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutineRemindersTable> {
  $$RoutineRemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get routineId =>
      $composableBuilder(column: $table.routineId, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get intervalId => $composableBuilder(
    column: $table.intervalId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<RoutineReminderMode, String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<int> get timesPerDay => $composableBuilder(
    column: $table.timesPerDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endMinutes => $composableBuilder(
    column: $table.endMinutes,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<int>, String> get times =>
      $composableBuilder(column: $table.times, builder: (column) => column);

  GeneratedColumn<int> get weekdays =>
      $composableBuilder(column: $table.weekdays, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<bool> get paused =>
      $composableBuilder(column: $table.paused, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RoutineRemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutineRemindersTable,
          RoutineReminderRow,
          $$RoutineRemindersTableFilterComposer,
          $$RoutineRemindersTableOrderingComposer,
          $$RoutineRemindersTableAnnotationComposer,
          $$RoutineRemindersTableCreateCompanionBuilder,
          $$RoutineRemindersTableUpdateCompanionBuilder,
          (
            RoutineReminderRow,
            BaseReferences<
              _$AppDatabase,
              $RoutineRemindersTable,
              RoutineReminderRow
            >,
          ),
          RoutineReminderRow,
          PrefetchHooks Function()
        > {
  $$RoutineRemindersTableTableManager(
    _$AppDatabase db,
    $RoutineRemindersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutineRemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutineRemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutineRemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> routineId = const Value.absent(),
                Value<String?> itemId = const Value.absent(),
                Value<String?> intervalId = const Value.absent(),
                Value<RoutineReminderMode> mode = const Value.absent(),
                Value<int> timesPerDay = const Value.absent(),
                Value<int> startMinutes = const Value.absent(),
                Value<int> endMinutes = const Value.absent(),
                Value<List<int>> times = const Value.absent(),
                Value<int> weekdays = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<bool> paused = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutineRemindersCompanion(
                id: id,
                routineId: routineId,
                itemId: itemId,
                intervalId: intervalId,
                mode: mode,
                timesPerDay: timesPerDay,
                startMinutes: startMinutes,
                endMinutes: endMinutes,
                times: times,
                weekdays: weekdays,
                enabled: enabled,
                paused: paused,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String routineId,
                Value<String?> itemId = const Value.absent(),
                Value<String?> intervalId = const Value.absent(),
                required RoutineReminderMode mode,
                Value<int> timesPerDay = const Value.absent(),
                Value<int> startMinutes = const Value.absent(),
                Value<int> endMinutes = const Value.absent(),
                Value<List<int>> times = const Value.absent(),
                Value<int> weekdays = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<bool> paused = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => RoutineRemindersCompanion.insert(
                id: id,
                routineId: routineId,
                itemId: itemId,
                intervalId: intervalId,
                mode: mode,
                timesPerDay: timesPerDay,
                startMinutes: startMinutes,
                endMinutes: endMinutes,
                times: times,
                weekdays: weekdays,
                enabled: enabled,
                paused: paused,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RoutineRemindersTable, RoutineReminderRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $RoutineRemindersTable,
                    RoutineReminderRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RoutineRemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutineRemindersTable,
      RoutineReminderRow,
      $$RoutineRemindersTableFilterComposer,
      $$RoutineRemindersTableOrderingComposer,
      $$RoutineRemindersTableAnnotationComposer,
      $$RoutineRemindersTableCreateCompanionBuilder,
      $$RoutineRemindersTableUpdateCompanionBuilder,
      (
        RoutineReminderRow,
        BaseReferences<
          _$AppDatabase,
          $RoutineRemindersTable,
          RoutineReminderRow
        >,
      ),
      RoutineReminderRow,
      PrefetchHooks Function()
    >;
typedef $$RoutineExecutionsTableCreateCompanionBuilder =
    RoutineExecutionsCompanion Function({
      required String id,
      required String routineId,
      Value<String?> itemId,
      Value<String?> intervalId,
      Value<String?> reminderId,
      required DateOnly date,
      required int executedAt,
      required RoutineExecutionOrigin origin,
      required String dedupeKey,
      Value<int> rowid,
    });
typedef $$RoutineExecutionsTableUpdateCompanionBuilder =
    RoutineExecutionsCompanion Function({
      Value<String> id,
      Value<String> routineId,
      Value<String?> itemId,
      Value<String?> intervalId,
      Value<String?> reminderId,
      Value<DateOnly> date,
      Value<int> executedAt,
      Value<RoutineExecutionOrigin> origin,
      Value<String> dedupeKey,
      Value<int> rowid,
    });

class $$RoutineExecutionsTableFilterComposer
    extends Composer<_$AppDatabase, $RoutineExecutionsTable> {
  $$RoutineExecutionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routineId => $composableBuilder(
    column: $table.routineId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get intervalId => $composableBuilder(
    column: $table.intervalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminderId => $composableBuilder(
    column: $table.reminderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateOnly, DateOnly, String> get date =>
      $composableBuilder(
        column: $table.date,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get executedAt => $composableBuilder(
    column: $table.executedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    RoutineExecutionOrigin,
    RoutineExecutionOrigin,
    String
  >
  get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get dedupeKey => $composableBuilder(
    column: $table.dedupeKey,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RoutineExecutionsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutineExecutionsTable> {
  $$RoutineExecutionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routineId => $composableBuilder(
    column: $table.routineId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get intervalId => $composableBuilder(
    column: $table.intervalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderId => $composableBuilder(
    column: $table.reminderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get executedAt => $composableBuilder(
    column: $table.executedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dedupeKey => $composableBuilder(
    column: $table.dedupeKey,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoutineExecutionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutineExecutionsTable> {
  $$RoutineExecutionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get routineId =>
      $composableBuilder(column: $table.routineId, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get intervalId => $composableBuilder(
    column: $table.intervalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reminderId => $composableBuilder(
    column: $table.reminderId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateOnly, String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get executedAt => $composableBuilder(
    column: $table.executedAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<RoutineExecutionOrigin, String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<String> get dedupeKey =>
      $composableBuilder(column: $table.dedupeKey, builder: (column) => column);
}

class $$RoutineExecutionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutineExecutionsTable,
          RoutineExecutionRow,
          $$RoutineExecutionsTableFilterComposer,
          $$RoutineExecutionsTableOrderingComposer,
          $$RoutineExecutionsTableAnnotationComposer,
          $$RoutineExecutionsTableCreateCompanionBuilder,
          $$RoutineExecutionsTableUpdateCompanionBuilder,
          (
            RoutineExecutionRow,
            BaseReferences<
              _$AppDatabase,
              $RoutineExecutionsTable,
              RoutineExecutionRow
            >,
          ),
          RoutineExecutionRow,
          PrefetchHooks Function()
        > {
  $$RoutineExecutionsTableTableManager(
    _$AppDatabase db,
    $RoutineExecutionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutineExecutionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutineExecutionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutineExecutionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> routineId = const Value.absent(),
                Value<String?> itemId = const Value.absent(),
                Value<String?> intervalId = const Value.absent(),
                Value<String?> reminderId = const Value.absent(),
                Value<DateOnly> date = const Value.absent(),
                Value<int> executedAt = const Value.absent(),
                Value<RoutineExecutionOrigin> origin = const Value.absent(),
                Value<String> dedupeKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutineExecutionsCompanion(
                id: id,
                routineId: routineId,
                itemId: itemId,
                intervalId: intervalId,
                reminderId: reminderId,
                date: date,
                executedAt: executedAt,
                origin: origin,
                dedupeKey: dedupeKey,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String routineId,
                Value<String?> itemId = const Value.absent(),
                Value<String?> intervalId = const Value.absent(),
                Value<String?> reminderId = const Value.absent(),
                required DateOnly date,
                required int executedAt,
                required RoutineExecutionOrigin origin,
                required String dedupeKey,
                Value<int> rowid = const Value.absent(),
              }) => RoutineExecutionsCompanion.insert(
                id: id,
                routineId: routineId,
                itemId: itemId,
                intervalId: intervalId,
                reminderId: reminderId,
                date: date,
                executedAt: executedAt,
                origin: origin,
                dedupeKey: dedupeKey,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RoutineExecutionsTable, RoutineExecutionRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $RoutineExecutionsTable,
                    RoutineExecutionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RoutineExecutionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutineExecutionsTable,
      RoutineExecutionRow,
      $$RoutineExecutionsTableFilterComposer,
      $$RoutineExecutionsTableOrderingComposer,
      $$RoutineExecutionsTableAnnotationComposer,
      $$RoutineExecutionsTableCreateCompanionBuilder,
      $$RoutineExecutionsTableUpdateCompanionBuilder,
      (
        RoutineExecutionRow,
        BaseReferences<
          _$AppDatabase,
          $RoutineExecutionsTable,
          RoutineExecutionRow
        >,
      ),
      RoutineExecutionRow,
      PrefetchHooks Function()
    >;
typedef $$SyncOutboxTableCreateCompanionBuilder = SyncOutboxCompanion Function({
  required String entity,
  required String entityId,
  required String payload,
  Value<int> baseRev,
  required String changeId,
  required int updatedAt,
  Value<int> attempts,
  Value<String?> lastError,
  Value<int> rowid,
});
typedef $$SyncOutboxTableUpdateCompanionBuilder = SyncOutboxCompanion Function({
  Value<String> entity,
  Value<String> entityId,
  Value<String> payload,
  Value<int> baseRev,
  Value<String> changeId,
  Value<int> updatedAt,
  Value<int> attempts,
  Value<String?> lastError,
  Value<int> rowid,
});

class $$SyncOutboxTableFilterComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseRev => $composableBuilder(
    column: $table.baseRev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get changeId => $composableBuilder(
    column: $table.changeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncOutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseRev => $composableBuilder(
    column: $table.baseRev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get changeId => $composableBuilder(
    column: $table.changeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncOutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get baseRev =>
      $composableBuilder(column: $table.baseRev, builder: (column) => column);

  GeneratedColumn<String> get changeId =>
      $composableBuilder(column: $table.changeId, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$SyncOutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncOutboxTable,
          SyncOutboxRow,
          $$SyncOutboxTableFilterComposer,
          $$SyncOutboxTableOrderingComposer,
          $$SyncOutboxTableAnnotationComposer,
          $$SyncOutboxTableCreateCompanionBuilder,
          $$SyncOutboxTableUpdateCompanionBuilder,
          (
            SyncOutboxRow,
            BaseReferences<_$AppDatabase, $SyncOutboxTable, SyncOutboxRow>,
          ),
          SyncOutboxRow,
          PrefetchHooks Function()
        > {
  $$SyncOutboxTableTableManager(_$AppDatabase db, $SyncOutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entity = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> baseRev = const Value.absent(),
                Value<String> changeId = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxCompanion(
                entity: entity,
                entityId: entityId,
                payload: payload,
                baseRev: baseRev,
                changeId: changeId,
                updatedAt: updatedAt,
                attempts: attempts,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entity,
                required String entityId,
                required String payload,
                Value<int> baseRev = const Value.absent(),
                required String changeId,
                required int updatedAt,
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxCompanion.insert(
                entity: entity,
                entityId: entityId,
                payload: payload,
                baseRev: baseRev,
                changeId: changeId,
                updatedAt: updatedAt,
                attempts: attempts,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncOutboxTable, SyncOutboxRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SyncOutboxTable,
                    SyncOutboxRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncOutboxTable,
      SyncOutboxRow,
      $$SyncOutboxTableFilterComposer,
      $$SyncOutboxTableOrderingComposer,
      $$SyncOutboxTableAnnotationComposer,
      $$SyncOutboxTableCreateCompanionBuilder,
      $$SyncOutboxTableUpdateCompanionBuilder,
      (
        SyncOutboxRow,
        BaseReferences<_$AppDatabase, $SyncOutboxTable, SyncOutboxRow>,
      ),
      SyncOutboxRow,
      PrefetchHooks Function()
    >;
typedef $$SyncRowStatesTableCreateCompanionBuilder =
    SyncRowStatesCompanion Function({
      required String entity,
      required String entityId,
      required int serverRev,
      required int lastSyncedAt,
      Value<int> rowid,
    });
typedef $$SyncRowStatesTableUpdateCompanionBuilder =
    SyncRowStatesCompanion Function({
      Value<String> entity,
      Value<String> entityId,
      Value<int> serverRev,
      Value<int> lastSyncedAt,
      Value<int> rowid,
    });

class $$SyncRowStatesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncRowStatesTable> {
  $$SyncRowStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverRev => $composableBuilder(
    column: $table.serverRev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncRowStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncRowStatesTable> {
  $$SyncRowStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverRev => $composableBuilder(
    column: $table.serverRev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncRowStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncRowStatesTable> {
  $$SyncRowStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<int> get serverRev =>
      $composableBuilder(column: $table.serverRev, builder: (column) => column);

  GeneratedColumn<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$SyncRowStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncRowStatesTable,
          SyncRowStateRow,
          $$SyncRowStatesTableFilterComposer,
          $$SyncRowStatesTableOrderingComposer,
          $$SyncRowStatesTableAnnotationComposer,
          $$SyncRowStatesTableCreateCompanionBuilder,
          $$SyncRowStatesTableUpdateCompanionBuilder,
          (
            SyncRowStateRow,
            BaseReferences<_$AppDatabase, $SyncRowStatesTable, SyncRowStateRow>,
          ),
          SyncRowStateRow,
          PrefetchHooks Function()
        > {
  $$SyncRowStatesTableTableManager(_$AppDatabase db, $SyncRowStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncRowStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncRowStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncRowStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entity = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<int> serverRev = const Value.absent(),
                Value<int> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncRowStatesCompanion(
                entity: entity,
                entityId: entityId,
                serverRev: serverRev,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entity,
                required String entityId,
                required int serverRev,
                required int lastSyncedAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncRowStatesCompanion.insert(
                entity: entity,
                entityId: entityId,
                serverRev: serverRev,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncRowStatesTable, SyncRowStateRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SyncRowStatesTable,
                    SyncRowStateRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncRowStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncRowStatesTable,
      SyncRowStateRow,
      $$SyncRowStatesTableFilterComposer,
      $$SyncRowStatesTableOrderingComposer,
      $$SyncRowStatesTableAnnotationComposer,
      $$SyncRowStatesTableCreateCompanionBuilder,
      $$SyncRowStatesTableUpdateCompanionBuilder,
      (
        SyncRowStateRow,
        BaseReferences<_$AppDatabase, $SyncRowStatesTable, SyncRowStateRow>,
      ),
      SyncRowStateRow,
      PrefetchHooks Function()
    >;
typedef $$SyncBasesTableCreateCompanionBuilder = SyncBasesCompanion Function({
  required String entity,
  required String entityId,
  required String payload,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$SyncBasesTableUpdateCompanionBuilder = SyncBasesCompanion Function({
  Value<String> entity,
  Value<String> entityId,
  Value<String> payload,
  Value<int> updatedAt,
  Value<int> rowid,
});

class $$SyncBasesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncBasesTable> {
  $$SyncBasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncBasesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncBasesTable> {
  $$SyncBasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncBasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncBasesTable> {
  $$SyncBasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SyncBasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncBasesTable,
          SyncBaseRow,
          $$SyncBasesTableFilterComposer,
          $$SyncBasesTableOrderingComposer,
          $$SyncBasesTableAnnotationComposer,
          $$SyncBasesTableCreateCompanionBuilder,
          $$SyncBasesTableUpdateCompanionBuilder,
          (
            SyncBaseRow,
            BaseReferences<_$AppDatabase, $SyncBasesTable, SyncBaseRow>,
          ),
          SyncBaseRow,
          PrefetchHooks Function()
        > {
  $$SyncBasesTableTableManager(_$AppDatabase db, $SyncBasesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncBasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncBasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncBasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entity = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncBasesCompanion(
                entity: entity,
                entityId: entityId,
                payload: payload,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entity,
                required String entityId,
                required String payload,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncBasesCompanion.insert(
                entity: entity,
                entityId: entityId,
                payload: payload,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncBasesTable, SyncBaseRow>(table),
                  BaseReferences<_$AppDatabase, $SyncBasesTable, SyncBaseRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncBasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncBasesTable,
      SyncBaseRow,
      $$SyncBasesTableFilterComposer,
      $$SyncBasesTableOrderingComposer,
      $$SyncBasesTableAnnotationComposer,
      $$SyncBasesTableCreateCompanionBuilder,
      $$SyncBasesTableUpdateCompanionBuilder,
      (
        SyncBaseRow,
        BaseReferences<_$AppDatabase, $SyncBasesTable, SyncBaseRow>,
      ),
      SyncBaseRow,
      PrefetchHooks Function()
    >;
typedef $$SyncStatesTableCreateCompanionBuilder = SyncStatesCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SyncStatesTableUpdateCompanionBuilder = SyncStatesCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SyncStatesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SyncStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncStatesTable,
          SyncStateRow,
          $$SyncStatesTableFilterComposer,
          $$SyncStatesTableOrderingComposer,
          $$SyncStatesTableAnnotationComposer,
          $$SyncStatesTableCreateCompanionBuilder,
          $$SyncStatesTableUpdateCompanionBuilder,
          (
            SyncStateRow,
            BaseReferences<_$AppDatabase, $SyncStatesTable, SyncStateRow>,
          ),
          SyncStateRow,
          PrefetchHooks Function()
        > {
  $$SyncStatesTableTableManager(_$AppDatabase db, $SyncStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SyncStatesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SyncStatesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncStatesTable, SyncStateRow>(table),
                  BaseReferences<_$AppDatabase, $SyncStatesTable, SyncStateRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncStatesTable,
      SyncStateRow,
      $$SyncStatesTableFilterComposer,
      $$SyncStatesTableOrderingComposer,
      $$SyncStatesTableAnnotationComposer,
      $$SyncStatesTableCreateCompanionBuilder,
      $$SyncStatesTableUpdateCompanionBuilder,
      (
        SyncStateRow,
        BaseReferences<_$AppDatabase, $SyncStatesTable, SyncStateRow>,
      ),
      SyncStateRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$NoteLinesTableTableManager get noteLines =>
      $$NoteLinesTableTableManager(_db, _db.noteLines);
  $$PostItsTableTableManager get postIts =>
      $$PostItsTableTableManager(_db, _db.postIts);
  $$PostItHistoryEntriesTableTableManager get postItHistoryEntries =>
      $$PostItHistoryEntriesTableTableManager(_db, _db.postItHistoryEntries);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$RoutinesTableTableManager get routines =>
      $$RoutinesTableTableManager(_db, _db.routines);
  $$RoutineItemsTableTableManager get routineItems =>
      $$RoutineItemsTableTableManager(_db, _db.routineItems);
  $$RoutineCompletionsTableTableManager get routineCompletions =>
      $$RoutineCompletionsTableTableManager(_db, _db.routineCompletions);
  $$RoutineSectionsTableTableManager get routineSections =>
      $$RoutineSectionsTableTableManager(_db, _db.routineSections);
  $$RoutineIntervalsTableTableManager get routineIntervals =>
      $$RoutineIntervalsTableTableManager(_db, _db.routineIntervals);
  $$RoutineIntervalCompletionsTableTableManager
  get routineIntervalCompletions =>
      $$RoutineIntervalCompletionsTableTableManager(
        _db,
        _db.routineIntervalCompletions,
      );
  $$RoutineRemindersTableTableManager get routineReminders =>
      $$RoutineRemindersTableTableManager(_db, _db.routineReminders);
  $$RoutineExecutionsTableTableManager get routineExecutions =>
      $$RoutineExecutionsTableTableManager(_db, _db.routineExecutions);
  $$SyncOutboxTableTableManager get syncOutbox =>
      $$SyncOutboxTableTableManager(_db, _db.syncOutbox);
  $$SyncRowStatesTableTableManager get syncRowStates =>
      $$SyncRowStatesTableTableManager(_db, _db.syncRowStates);
  $$SyncBasesTableTableManager get syncBases =>
      $$SyncBasesTableTableManager(_db, _db.syncBases);
  $$SyncStatesTableTableManager get syncStates =>
      $$SyncStatesTableTableManager(_db, _db.syncStates);
}
