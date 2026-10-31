import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/app_strings.dart';
import '../../core/date_formatting.dart';
import '../../app/planner_view_mode.dart';
import '../shared/count_tile.dart';
import 'stage_notice_card.dart';

/// Visão geral da agenda na Etapa 1: data selecionada e contagens.
///
/// A grade de dias e os post-its interativos entram na Etapa 2.
class AgendaPage extends StatelessWidget {
  const AgendaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final planner = AppScope.of(context).planner;
    final theme = Theme.of(context);
    final orientation = MediaQuery.orientationOf(context);

    if (planner.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final selected = planner.selectedDate;
    final dayPostIts = planner.postItsOn(selected);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.selectedDate,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    DateFormats.fullDate(selected),
                    style: theme.textTheme.headlineSmall,
                  ),
                  if (selected == planner.today)
                    Chip(
                      avatar: const Icon(Icons.today, size: 18),
                      label: const Text(AppStrings.today),
                    ),
                  Chip(
                    avatar: const Icon(Icons.view_agenda_outlined, size: 18),
                    label: Text(planner.modeFor(orientation).label),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 230,
                    child: CountTile(
                      label: AppStrings.postItsOnDay,
                      value: dayPostIts.length,
                      icon: Icons.sticky_note_2_outlined,
                      semanticLabel:
                          '${AppStrings.postItsOnDay}: ${dayPostIts.length}',
                    ),
                  ),
                  SizedBox(
                    width: 230,
                    child: CountTile(
                      label: AppStrings.undated,
                      value: planner.undatedPostIts.length,
                      icon: Icons.inbox_outlined,
                    ),
                  ),
                  SizedBox(
                    width: 230,
                    child: CountTile(
                      label: AppStrings.notesCount,
                      value: AppScope.of(context).notes.notes.length,
                      icon: Icons.note_alt_outlined,
                    ),
                  ),
                ],
              ),
              if (planner.error != null) ...[
                const SizedBox(height: 16),
                Card(
                  color: theme.colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      AppStrings.loadError,
                      style: TextStyle(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              const StageNoticeCard(
                icon: Icons.calendar_view_week_outlined,
                title: AppStrings.agendaPlaceholderTitle,
                message: AppStrings.agendaPlaceholderBody,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
