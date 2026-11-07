import 'package:flutter_test/flutter_test.dart';
import 'package:stick2planner/core/date_only.dart';
import 'package:stick2planner/domain/entities/post_it.dart';
import 'package:stick2planner/domain/entities/tag.dart';

import '../helpers/test_dependencies.dart';

void main() {
  test('cria, reutiliza e exclui tags sem apagar post-its', () async {
    final dependencies = testDependencies(now: DateTime(2026, 11, 6, 12));
    await dependencies.initialize();
    addTearDown(dependencies.dispose);

    final work = await dependencies.tags.create(
      name: 'Trabalho',
      tone: TagTone.primary,
    );
    final home = await dependencies.tags.create(
      name: 'Casa',
      tone: TagTone.secondarySoft,
    );
    expect(dependencies.tags.tags, hasLength(2));

    final task = await dependencies.planner.createPostIt(
      title: 'Tarefa',
      type: PostItType.task,
      startDate: DateOnly(2026, 11, 6),
      tagIds: [work.id, home.id, work.id],
    );
    expect(task.tagIds, [work.id, home.id]);

    await dependencies.tags.delete(work);
    final updated = dependencies.planner.postIts.single;
    expect(updated.id, task.id);
    expect(updated.tagIds, [home.id]);
    expect(dependencies.tags.tags.map((tag) => tag.name), ['Casa']);
  });

  test('backup inclui tags, horário e associações', () async {
    final dependencies = testDependencies(now: DateTime(2026, 11, 6, 12));
    await dependencies.initialize();
    addTearDown(dependencies.dispose);
    final tag = await dependencies.tags.create(
      name: 'Backup',
      tone: TagTone.primarySoft,
    );
    await dependencies.planner.createPostIt(
      title: 'Evento',
      type: PostItType.event,
      startDate: DateOnly(2026, 11, 6),
      timeMinutes: 14 * 60 + 15,
      tagIds: [tag.id],
    );

    final document = await dependencies.backup.buildExport();

    expect(document.data['tags'], hasLength(1));
    final postIt = (document.data['postIts'] as List)
        .cast<Map<String, Object?>>()
        .single;
    expect(postIt['timeMinutes'], 855);
    expect(postIt['tagIds'], [tag.id]);
  });

  test('horário e tags são preservados ao editar e mover', () async {
    final dependencies = testDependencies(now: DateTime(2026, 11, 6, 12));
    await dependencies.initialize();
    addTearDown(dependencies.dispose);
    final tag = await dependencies.tags.create(
      name: 'Viagem',
      tone: TagTone.secondary,
    );
    final event = await dependencies.planner.createPostIt(
      title: 'Voo',
      type: PostItType.event,
      startDate: DateOnly(2026, 11, 6),
      timeMinutes: 9 * 60 + 30,
      tagIds: [tag.id],
    );

    await dependencies.planner.updatePostIt(
      event,
      title: 'Voo editado',
      type: PostItType.event,
      startDate: DateOnly(2026, 11, 6),
      timeMinutes: 9 * 60 + 30,
      tagIds: [tag.id],
    );
    await dependencies.planner.movePostIt(event, DateOnly(2026, 11, 7));

    final moved = dependencies.planner.postIts.single;
    expect(moved.title, 'Voo editado');
    expect(moved.timeMinutes, 570);
    expect(moved.tagIds, [tag.id]);
    expect(moved.startDate, DateOnly(2026, 11, 7));
  });

  test('recusa nome vazio, longo ou duplicado', () async {
    final dependencies = testDependencies(now: DateTime(2026, 11, 6, 12));
    await dependencies.initialize();
    addTearDown(dependencies.dispose);

    await dependencies.tags.create(name: 'Estudo', tone: TagTone.secondary);
    await expectLater(
      dependencies.tags.create(name: '  ', tone: TagTone.primary),
      throwsFormatException,
    );
    await expectLater(
      dependencies.tags.create(name: 'estudo', tone: TagTone.primary),
      throwsFormatException,
    );
    await expectLater(
      dependencies.tags.create(name: 'x' * 41, tone: TagTone.primary),
      throwsFormatException,
    );
  });
}
