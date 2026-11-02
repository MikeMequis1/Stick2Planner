import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/app_strings.dart';
import '../../domain/entities/post_it.dart';
import '../planner/stage_notice_card.dart';
import '../shared/count_tile.dart';
import '../shared/empty_state.dart';

/// Repositório central de post-its. Filtros e busca chegam na Etapa 4.
class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    final planner = AppScope.of(context).planner;

    return ListenableBuilder(
      listenable: planner,
      builder: (context, _) {
        if (planner.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final hasAnyPostIt = planner.postIts.isNotEmpty;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: 230,
                        child: CountTile(
                          label: AppStrings.active,
                          value: planner.countByStatus(PostItStatus.active),
                          icon: Icons.radio_button_unchecked,
                        ),
                      ),
                      SizedBox(
                        width: 230,
                        child: CountTile(
                          label: AppStrings.done,
                          value: planner.countByStatus(PostItStatus.done),
                          icon: Icons.check_circle_outline,
                        ),
                      ),
                      SizedBox(
                        width: 230,
                        child: CountTile(
                          label: AppStrings.cancelled,
                          value: planner.countByStatus(PostItStatus.cancelled),
                          icon: Icons.cancel_outlined,
                        ),
                      ),
                      SizedBox(
                        width: 230,
                        child: CountTile(
                          label: AppStrings.undated,
                          value: planner.undatedPostIts.length,
                          icon: Icons.event_busy_outlined,
                        ),
                      ),
                    ],
                  ),
                  if (!hasAnyPostIt) ...[
                    const SizedBox(height: 8),
                    const EmptyState(
                      icon: Icons.inbox_outlined,
                      title: AppStrings.emptyInbox,
                      message: AppStrings.inboxPlaceholderBody,
                    ),
                  ],
                  const SizedBox(height: 16),
                  const StageNoticeCard(
                    icon: Icons.filter_alt_outlined,
                    title: AppStrings.inboxPlaceholderTitle,
                    message: AppStrings.inboxPlaceholderBody,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
