import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/app_strings.dart';
import '../../../app/controllers/app_navigation_controller.dart';
import '../../../app/controllers/planner_controller.dart';
import '../../../domain/entities/post_it.dart';
import '../../notes/note_detail_page.dart';
import 'post_it_details_sheet.dart';
import 'post_it_editor_sheet.dart';

/// Abre os detalhes de um post-it existente, opcionalmente indo para a Agenda.
///
/// Reutiliza o mesmo fluxo de detalhes/edição em qualquer origem (Agenda,
/// Caixinha ou Notas), sem criar cópias nem alterar o registro.
Future<bool> openPostItDetailsById(
  BuildContext context, {
  required String postItId,
  bool goToAgenda = true,
}) async {
  final app = AppScope.of(context);
  final planner = app.planner;
  final notes = app.notes;
  final navigation = app.navigation;
  final postIt = _findPostIt(planner, postItId);

  if (postIt == null) {
    _showMessage(context, AppStrings.postItNotFound);
    return false;
  }

  final navigator = Navigator.of(context, rootNavigator: true);
  final route = ModalRoute.of(context);
  if (goToAgenda) {
    navigation.select(AppSection.agenda);
    if (route != null && !route.isFirst) {
      navigator.popUntil((current) => current.isFirst);
    }
  }

  await showPostItDetailsSheet(
    navigator.context,
    postIt: postIt,
    planner: planner,
    notesController: notes,
    onOpenNote: (note) => navigator.push(
      MaterialPageRoute<void>(
        builder: (context) => NoteDetailPage(noteId: note.id),
      ),
    ),
    onEdit: (current) => showPostItEditorSheet(
      navigator.context,
      controller: planner,
      initialDate: current.startDate ?? planner.selectedDate,
      existing: current,
    ),
  );
  return true;
}

/// Leva o usuário para a Agenda, seleciona a data e realça o post-it.
Future<bool> revealPostItOnAgenda(
  BuildContext context, {
  required String postItId,
}) async {
  final app = AppScope.of(context);
  final planner = app.planner;
  final navigation = app.navigation;
  final postIt = _findPostIt(planner, postItId);

  if (postIt == null) {
    _showMessage(context, AppStrings.postItNotFound);
    return false;
  }
  final date = postIt.startDate;
  if (date == null) {
    _showMessage(context, AppStrings.postItWithoutDate);
    return false;
  }

  final navigator = Navigator.of(context, rootNavigator: true);
  final route = ModalRoute.of(context);
  navigation.select(AppSection.agenda);
  navigation.focusPostIt(postIt.id);
  planner.selectDate(date);
  if (route != null && !route.isFirst) {
    navigator.popUntil((current) => current.isFirst);
  }
  return true;
}

void _showMessage(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

PostIt? _findPostIt(PlannerController planner, String id) {
  for (final postIt in planner.postIts) {
    if (postIt.id == id) return postIt;
  }
  return null;
}
