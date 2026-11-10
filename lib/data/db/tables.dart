import 'package:drift/drift.dart';

import '../../domain/entities/note.dart';
import '../../domain/entities/post_it.dart';
import '../../domain/entities/post_it_history.dart';
import '../../domain/entities/tag.dart';
import 'converters.dart';

/// Preferências de visualização e estado leve do aplicativo.
///
/// Chave/valor mantém a tabela estável: novas preferências não exigem
/// migração de esquema.
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// Notas privadas.
@DataClassName('NoteRow')
class Notes extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get type => textEnum<NoteType>()();
  TextColumn get markdown => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Linhas de uma nota ou itens de checklist, em ordem.
@DataClassName('NoteLineRow')
@TableIndex(name: 'idx_note_lines_note_id', columns: {#noteId})
class NoteLines extends Table {
  TextColumn get id => text()();
  TextColumn get noteId =>
      text().references(Notes, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  TextColumn get content => text()();
  BoolColumn get isChecked => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Tags compartilhadas por eventos e tarefas.
@DataClassName('TagRow')
@TableIndex(name: 'idx_tags_name', columns: {#name})
class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get tone => textEnum<TagTone>()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Post-its da agenda.
@DataClassName('PostItRow')
@TableIndex(name: 'idx_post_its_start_date', columns: {#startDate})
@TableIndex(name: 'idx_post_its_status', columns: {#status})
@TableIndex(name: 'idx_post_its_note_id', columns: {#noteId})
class PostIts extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get type => textEnum<PostItType>()();
  TextColumn get status => textEnum<PostItStatus>()();
  BoolColumn get isHighlight => boolean().withDefault(const Constant(false))();
  TextColumn get details => text().nullable()();
  TextColumn get noteId =>
      text().nullable().references(Notes, #id, onDelete: KeyAction.setNull)();
  TextColumn get noteExcerpt => text().nullable()();
  TextColumn get sourceNoteId => text().nullable()();
  TextColumn get startDate =>
      text().map(const DateOnlyConverter()).nullable()();
  TextColumn get endDate => text().map(const DateOnlyConverter()).nullable()();
  TextColumn get recurrence =>
      textEnum<EventRecurrence>().withDefault(const Constant('none'))();
  IntColumn get recurrenceInterval =>
      integer().withDefault(const Constant(1))();
  IntColumn get timeMinutes => integer().nullable()();
  IntColumn get reminderMinutes => integer().nullable()();
  TextColumn get tagIds =>
      text().map(const TagIdsConverter()).withDefault(const Constant('[]'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get lastRolloverAt => integer().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Histórico de alterações de post-its.
@DataClassName('PostItHistoryRow')
@TableIndex(name: 'idx_post_it_history_post_it_id', columns: {#postItId})
class PostItHistoryEntries extends Table {
  TextColumn get id => text()();
  TextColumn get postItId =>
      text().references(PostIts, #id, onDelete: KeyAction.cascade)();
  TextColumn get action => textEnum<PostItHistoryAction>()();
  TextColumn get fromValue => text().nullable()();
  TextColumn get toValue => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Rotinas semanais, locais ao dispositivo.
@DataClassName('RoutineRow')
class Routines extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get details => text().nullable()();
  IntColumn get weekdays => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Atividades de uma rotina, em ordem.
@DataClassName('RoutineItemRow')
@TableIndex(name: 'idx_routine_items_routine_id', columns: {#routineId})
class RoutineItems extends Table {
  TextColumn get id => text()();
  TextColumn get routineId =>
      text().references(Routines, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  TextColumn get details => text().nullable()();
  IntColumn get position => integer()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Conclusão de uma atividade em uma data específica.
@DataClassName('RoutineCompletionRow')
@TableIndex(name: 'idx_routine_completions_item', columns: {#routineItemId})
class RoutineCompletions extends Table {
  TextColumn get routineItemId =>
      text().references(RoutineItems, #id, onDelete: KeyAction.cascade)();
  TextColumn get date => text().map(const DateOnlyConverter())();
  IntColumn get completedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {routineItemId, date};
}

/// Fila local de alterações pendentes de envio ao servidor.
///
/// O payload é o estado completo da entidade em JSON canônico; edições
/// sucessivas coalescem em uma única linha por `(entity, entityId)`.
@DataClassName('SyncOutboxRow')
class SyncOutbox extends Table {
  TextColumn get entity => text()();
  TextColumn get entityId => text()();
  TextColumn get payload => text()();
  IntColumn get baseRev => integer().withDefault(const Constant(0))();
  TextColumn get changeId => text()();
  IntColumn get updatedAt => integer()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {entity, entityId};
}

/// Revisão do servidor já aplicada localmente, por entidade.
@DataClassName('SyncRowStateRow')
class SyncRowStates extends Table {
  TextColumn get entity => text()();
  TextColumn get entityId => text()();
  IntColumn get serverRev => integer()();
  IntColumn get lastSyncedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {entity, entityId};
}

/// Estado global da sincronização (deviceId, cursor, servidor, erros).
@DataClassName('SyncStateRow')
class SyncStates extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
