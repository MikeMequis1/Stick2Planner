import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/app_strings.dart';
import '../planner/stage_notice_card.dart';
import '../shared/count_tile.dart';
import '../shared/empty_state.dart';

/// Caderno privado. Editor e vínculos chegam na Etapa 5.
class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notes = AppScope.of(context).notes;

    if (notes.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 230,
                child: CountTile(
                  label: AppStrings.notesCount,
                  value: notes.notes.length,
                  icon: Icons.note_alt_outlined,
                ),
              ),
              if (notes.notes.isEmpty) ...[
                const SizedBox(height: 8),
                const EmptyState(
                  icon: Icons.edit_note_outlined,
                  title: AppStrings.emptyNotes,
                  message: AppStrings.notesPlaceholderBody,
                ),
              ],
              const SizedBox(height: 16),
              const StageNoticeCard(
                icon: Icons.menu_book_outlined,
                title: AppStrings.notesPlaceholderTitle,
                message: AppStrings.notesPlaceholderBody,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
