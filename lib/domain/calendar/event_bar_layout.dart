import '../../core/date_only.dart';
import '../entities/post_it.dart';
import 'calendar_period.dart';

/// Segmento visual de um evento dentro de uma linha da grade.
///
/// O mesmo post-it pode aparecer em mais de uma semana; nesse caso os
/// segmentos compartilham o ID e marcam continuação nas pontas.
final class CalendarEventSegment {
  const CalendarEventSegment({
    required this.postIt,
    required this.startColumn,
    required this.endColumn,
    required this.lane,
    required this.continuesBefore,
    required this.continuesAfter,
  });

  final PostIt postIt;
  final int startColumn;
  final int endColumn;
  final int lane;
  final bool continuesBefore;
  final bool continuesAfter;

  int get columnSpan => endColumn - startColumn + 1;
}

final class EventBarLayout {
  const EventBarLayout({required this.segments, required this.hiddenCount});

  final List<CalendarEventSegment> segments;

  /// Eventos que não couberam no limite de faixas da linha.
  final int hiddenCount;

  static const empty = EventBarLayout(segments: [], hiddenCount: 0);
}

/// Distribui eventos multi-dia em faixas sem sobreposição.
///
/// Eventos de um único dia não entram aqui: são cartões normais da célula.
EventBarLayout layoutEventSegments(
  List<PostIt> postIts,
  CalendarWeek week, {
  int maxLanes = 3,
}) {
  final candidates = <_SegmentDraft>[];

  for (final postIt in postIts) {
    final start = postIt.startDate;
    final end = postIt.effectiveEndDate;
    if (!postIt.isEvent || start == null || end == null) continue;
    if (end.isBefore(week.start) || start.isAfter(week.end)) continue;

    final visibleStart = start.isBefore(week.start) ? week.start : start;
    final visibleEnd = end.isAfter(week.end) ? week.end : end;
    final startColumn = week.days.indexWhere(
      (day) => day.date.isSameDay(visibleStart),
    );
    final endColumn = week.days.indexWhere(
      (day) => day.date.isSameDay(visibleEnd),
    );
    if (startColumn < 0 || endColumn < 0) continue;

    candidates.add(
      _SegmentDraft(
        postIt: postIt,
        startColumn: startColumn,
        endColumn: endColumn,
        continuesBefore: start.isBefore(week.start),
        continuesAfter: end.isAfter(week.end),
      ),
    );
  }

  candidates.sort((a, b) {
    final byStart = a.startColumn.compareTo(b.startColumn);
    if (byStart != 0) return byStart;
    final byEnd = a.endColumn.compareTo(b.endColumn);
    if (byEnd != 0) return byEnd;
    return a.postIt.sortOrder.compareTo(b.postIt.sortOrder);
  });

  final laneEnds = <int>[];
  final segments = <CalendarEventSegment>[];
  var hidden = 0;

  for (final candidate in candidates) {
    var lane = -1;
    for (var index = 0; index < laneEnds.length; index++) {
      if (candidate.startColumn > laneEnds[index]) {
        lane = index;
        break;
      }
    }
    if (lane == -1) {
      if (laneEnds.length >= maxLanes) {
        hidden++;
        continue;
      }
      laneEnds.add(candidate.endColumn);
      lane = laneEnds.length - 1;
    } else {
      laneEnds[lane] = candidate.endColumn;
    }

    segments.add(
      CalendarEventSegment(
        postIt: candidate.postIt,
        startColumn: candidate.startColumn,
        endColumn: candidate.endColumn,
        lane: lane,
        continuesBefore: candidate.continuesBefore,
        continuesAfter: candidate.continuesAfter,
      ),
    );
  }

  return EventBarLayout(segments: segments, hiddenCount: hidden);
}

final class _SegmentDraft {
  const _SegmentDraft({
    required this.postIt,
    required this.startColumn,
    required this.endColumn,
    required this.continuesBefore,
    required this.continuesAfter,
  });

  final PostIt postIt;
  final int startColumn;
  final int endColumn;
  final bool continuesBefore;
  final bool continuesAfter;
}

/// Post-its exibidos como cartões dentro de um dia (exclui eventos, que são
/// desenhados como barras).
List<PostIt> singleDayItemsOn(List<PostIt> postIts, DateOnly date) {
  return [
    for (final postIt in postIts)
      if (_covers(postIt, date) && !postIt.isEvent) postIt,
  ];
}

bool _covers(PostIt postIt, DateOnly date) {
  final start = postIt.startDate;
  if (start == null) return false;
  final end = postIt.effectiveEndDate ?? start;
  return !date.isBefore(start) && !date.isAfter(end);
}
