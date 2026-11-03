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
    startDate,
    endDate,
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
  final DateOnly? startDate;
  final DateOnly? endDate;
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
    this.startDate,
    this.endDate,
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
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
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
      startDate: serializer.fromJson<DateOnly?>(json['startDate']),
      endDate: serializer.fromJson<DateOnly?>(json['endDate']),
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
      'startDate': serializer.toJson<DateOnly?>(startDate),
      'endDate': serializer.toJson<DateOnly?>(endDate),
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
    Value<DateOnly?> startDate = const Value.absent(),
    Value<DateOnly?> endDate = const Value.absent(),
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
    startDate: startDate.present ? startDate.value : this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
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
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
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
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('lastRolloverAt: $lastRolloverAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    type,
    status,
    isHighlight,
    details,
    noteId,
    noteExcerpt,
    startDate,
    endDate,
    sortOrder,
    lastRolloverAt,
    createdAt,
    updatedAt,
    deletedAt,
  );
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
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
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
  final Value<DateOnly?> startDate;
  final Value<DateOnly?> endDate;
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
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
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
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
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
    Expression<String>? startDate,
    Expression<String>? endDate,
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
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
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
    Value<DateOnly?>? startDate,
    Value<DateOnly?>? endDate,
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
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
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
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $NoteLinesTable noteLines = $NoteLinesTable(this);
  late final $PostItsTable postIts = $PostItsTable(this);
  late final $PostItHistoryEntriesTable postItHistoryEntries =
      $PostItHistoryEntriesTable(this);
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
    idxNoteLinesNoteId,
    idxPostItsStartDate,
    idxPostItsStatus,
    idxPostItsNoteId,
    idxPostItHistoryPostItId,
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
  Value<DateOnly?> startDate,
  Value<DateOnly?> endDate,
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
  Value<DateOnly?> startDate,
  Value<DateOnly?> endDate,
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

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endDate => $composableBuilder(
    column: $table.endDate,
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

  GeneratedColumnWithTypeConverter<DateOnly?, String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateOnly?, String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

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
                Value<DateOnly?> startDate = const Value.absent(),
                Value<DateOnly?> endDate = const Value.absent(),
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
                startDate: startDate,
                endDate: endDate,
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
                Value<DateOnly?> startDate = const Value.absent(),
                Value<DateOnly?> endDate = const Value.absent(),
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
                startDate: startDate,
                endDate: endDate,
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
}
