import '../../core/date_only.dart';
import '../calendar/event_recurrence.dart';
import '../entities/post_it.dart';

/// Grupo de post-its ativos que compartilham o mesmo horário em uma data.
final class PostItTimeConflict {
  const PostItTimeConflict({
    required this.date,
    required this.timeMinutes,
    required this.postIts,
  });

  final DateOnly date;
  final int timeMinutes;
  final List<PostIt> postIts;
}

/// Detecta conflitos pelo mesmo horário de início.
///
/// O modelo ainda não guarda duração nem horário final; portanto, dois registros
/// só são considerados conflitantes quando começam no mesmo minuto do mesmo dia.
/// Eventos e tarefas participam; concluídos, cancelados, Feito e registros sem
/// horário não participam.
final class FindPostItTimeConflicts {
  const FindPostItTimeConflicts({this.maxHorizonDays = 366});

  /// Limite de busca para séries recorrentes sem data final.
  final int maxHorizonDays;

  /// Conflitos entre os post-its de um único dia já expandido.
  List<PostItTimeConflict> forDay(List<PostIt> postIts, DateOnly date) {
    final groups = <int, List<PostIt>>{};
    for (final postIt in postIts) {
      if (!_participates(postIt) || !_coversDate(postIt, date)) continue;
      groups.putIfAbsent(postIt.timeMinutes!, () => []).add(postIt);
    }
    return _groups(date, groups);
  }

  /// Conflitos de um registro novo contra os registros existentes.
  ///
  /// Séries recorrentes e eventos de vários dias são expandidos; apenas as
  /// datas que realmente conflitam entram no resultado.
  List<PostItTimeConflict> forNewPostIt(
    PostIt candidate,
    List<PostIt> existing,
  ) {
    final start = candidate.startDate;
    if (!_participates(candidate) || start == null) return const [];

    final horizon = maxHorizonDays < 1 ? 1 : maxHorizonDays;
    final rangeEnd = candidate.hasRecurrence
        ? (candidate.recurrenceEndDate ?? start.addDays(horizon))
        : (candidate.effectiveEndDate ?? start);

    final candidateOccurrences = expandEventOccurrences(
      [candidate],
      from: start,
      to: rangeEnd,
    );
    final existingOccurrences = expandEventOccurrences(
      existing,
      from: start,
      to: rangeEnd,
    ).where(_participates).where((postIt) => postIt.id != candidate.id);

    final groups = <DateOnly, Map<int, List<PostIt>>>{};
    for (final occurrence in candidateOccurrences) {
      if (!_participates(occurrence)) continue;
      final occurrenceStart = occurrence.startDate;
      if (occurrenceStart == null) continue;
      final occurrenceEnd = occurrence.effectiveEndDate ?? occurrenceStart;
      for (
        var day = occurrenceStart;
        !day.isAfter(occurrenceEnd) && !day.isAfter(rangeEnd);
        day = day.addDays(1)
      ) {
        final time = occurrence.timeMinutes!;
        final affected = <PostIt>[];
        for (final other in existingOccurrences) {
          if (other.timeMinutes != time) continue;
          if (!_coversDate(other, day)) continue;
          if (affected.any((item) => item.id == other.id)) continue;
          affected.add(other);
        }
        if (affected.isEmpty) continue;
        groups
            .putIfAbsent(day, () => {})
            .putIfAbsent(time, () => [])
            .addAll(affected);
      }
    }

    final result = <PostItTimeConflict>[];
    final dates = groups.keys.toList()..sort();
    for (final date in dates) {
      final times = groups[date]!.keys.toList()..sort();
      for (final time in times) {
        final affected = _unique(groups[date]![time]!);
        if (affected.isEmpty) continue;
        result.add(
          PostItTimeConflict(date: date, timeMinutes: time, postIts: affected),
        );
      }
    }
    return result;
  }

  List<PostItTimeConflict> _groups(
    DateOnly date,
    Map<int, List<PostIt>> groups,
  ) {
    final times = groups.keys.toList()..sort();
    return [
      for (final time in times)
        if (groups[time]!.length > 1)
          PostItTimeConflict(
            date: date,
            timeMinutes: time,
            postIts: _unique(groups[time]!),
          ),
    ];
  }

  static List<PostIt> _unique(List<PostIt> postIts) {
    final seen = <String>{};
    return [
      for (final postIt in postIts)
        if (seen.add(postIt.id)) postIt,
    ];
  }

  static bool _participates(PostIt postIt) {
    return postIt.status == PostItStatus.active &&
        postIt.timeMinutes != null &&
        !postIt.isHighlight &&
        !postIt.isDeleted;
  }

  static bool _coversDate(PostIt postIt, DateOnly date) {
    final start = postIt.startDate;
    if (start == null) return false;
    final end = postIt.effectiveEndDate ?? start;
    return !date.isBefore(start) && !date.isAfter(end);
  }
}
