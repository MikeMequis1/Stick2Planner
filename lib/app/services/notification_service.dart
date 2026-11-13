// ignore_for_file: prefer_initializing_formals

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../core/clock.dart';
import '../../core/date_formatting.dart';
import '../../core/date_only.dart';
import '../../core/platform_support.dart';
import '../../domain/entities/post_it.dart';
import '../../domain/entities/routine.dart';
import '../app_strings.dart';

/// Notificação já calculada, pronta para ser entregue ao plugin.
final class PlannedNotification {
  const PlannedNotification({
    required this.id,
    required this.at,
    required this.title,
    required this.body,
  });

  final int id;
  final DateTime at;
  final String title;
  final String body;
}

/// Calcula resumo diário e lembretes sem tocar em plugins (testável).
List<PlannedNotification> buildNotificationPlan({
  required List<PostIt> postIts,
  required List<Routine> routines,
  required DateTime now,
}) {
  final today = DateOnly.fromDateTime(now);
  final result = <PlannedNotification>[];
  final active = [
    for (final postIt in postIts)
      if (postIt.status == PostItStatus.active && !postIt.isDeleted) postIt,
  ];

  for (var offset = 0; offset < 7; offset++) {
    final date = today.addDays(offset);
    final at = DateTime(date.year, date.month, date.day, 8);
    if (!at.isAfter(now)) continue;

    final lines = <String>[];
    for (final postIt in active) {
      if (!_covers(postIt, date)) continue;
      final time = postIt.timeMinutes;
      lines.add(
        time == null
            ? postIt.title
            : '${DateFormats.clockTime(time)} · ${postIt.title}',
      );
    }
    for (final routine in routines) {
      if (!routine.runsOn(date) || routine.items.isEmpty) continue;
      final pending = [
        for (final item in routine.items)
          if (!item.isCompletedOn(date)) item.title,
      ];
      if (pending.isEmpty) continue;
      lines.add('${routine.name}: ${pending.take(3).join(', ')}');
    }
    if (lines.isEmpty) continue;
    final visible = lines.take(6).toList(growable: false);
    final extra = lines.length - visible.length;
    result.add(
      PlannedNotification(
        id: 1000 + offset,
        at: at,
        title: AppStrings.notificationDailyTitle,
        body: [
          ...visible,
          if (extra > 0) AppStrings.notificationSummaryMore(extra),
        ].join('\n'),
      ),
    );
  }

  for (final postIt in active) {
    final date = postIt.startDate;
    final time = postIt.timeMinutes;
    final reminder = postIt.reminderMinutes;
    if (date == null || time == null || reminder == null) continue;
    if (reminder < 0 || time < 0 || time >= 24 * 60) continue;
    final at = DateTime(
      date.year,
      date.month,
      date.day,
      time ~/ 60,
      time % 60,
    ).subtract(Duration(minutes: reminder));
    if (!at.isAfter(now)) continue;
    result.add(
      PlannedNotification(
        id: 100000 + (postIt.id.hashCode.abs() % 100000000),
        at: at,
        title: AppStrings.notificationReminderTitle,
        body: AppStrings.notificationReminderBody(postIt.title, reminder),
      ),
    );
  }

  return result;
}

bool _covers(PostIt postIt, DateOnly date) {
  final start = postIt.startDate;
  if (start == null) return false;
  final end = postIt.effectiveEndDate ?? start;
  return !date.isBefore(start) && !date.isAfter(end);
}

/// Agendador Android. Em outras plataformas é um no-op que preserva o app.
final class AppNotificationService {
  AppNotificationService({Clock clock = const SystemClock()}) : _clock = clock;

  final Clock _clock;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;
  bool _enabled = false;
  bool _exactAllowed = false;
  String? _lastError;

  bool get isSupported => supportsAndroidNotifications;
  bool get isReady => _ready;
  bool get exactAllowed => _exactAllowed;
  String? get lastError => _lastError;

  static const _notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'planner_reminders',
      'Lembretes do Planner',
      channelDescription:
          'Resumo diário e lembretes de eventos, tarefas e rotinas.',
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_stat_planner',
    ),
  );

  Future<void> initialize({required bool enabled}) async {
    _enabled = enabled;
    _lastError = null;
    if (!isSupported) return;
    try {
      tz.initializeTimeZones();
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } on Object catch (error) {
      // Mantém o fuso padrão; o agendamento ainda funciona.
      _lastError = error.toString();
    }
    const android = AndroidInitializationSettings('ic_stat_planner');
    const settings = InitializationSettings(android: android);
    try {
      final initialized = await _plugin.initialize(settings: settings);
      _ready = initialized ?? true;
      _exactAllowed = await _canScheduleExact();
      if (!_ready) _lastError = 'notification_initialize_failed';
    } on Object catch (error) {
      _ready = false;
      _lastError = error.toString();
    }
  }

  Future<bool> requestPermission() async {
    if (!isSupported) return false;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return false;
    final granted = await android.requestNotificationsPermission();
    _exactAllowed = await _canScheduleExact();
    return granted ?? true;
  }

  Future<bool> requestExactPermission() async {
    if (!isSupported) return false;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return false;
    final granted = await android.requestExactAlarmsPermission();
    _exactAllowed = granted ?? await _canScheduleExact();
    return _exactAllowed;
  }

  Future<bool> _canScheduleExact() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.canScheduleExactNotifications() ?? false;
  }

  AndroidScheduleMode get _scheduleMode => _exactAllowed
      ? AndroidScheduleMode.exactAllowWhileIdle
      : AndroidScheduleMode.inexactAllowWhileIdle;

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    if (!value && _ready) await _plugin.cancelAll();
  }

  /// Envia uma notificação imediata e agenda outra em 10 s para validar o
  /// canal, a permissão e o agendador.
  Future<bool> sendTest() async {
    if (!isSupported) return false;
    if (!_ready) {
      await initialize(enabled: _enabled);
    }
    if (!_ready) return false;
    try {
      await _plugin.show(
        id: _testImmediateId,
        title: AppStrings.notificationTestTitle,
        body: AppStrings.notificationTestBody,
        notificationDetails: _notificationDetails,
      );
      final at = _clock.now().add(const Duration(seconds: 10));
      await _plugin.zonedSchedule(
        id: _testScheduledId,
        title: AppStrings.notificationTestScheduledTitle,
        body: AppStrings.notificationTestScheduledBody,
        scheduledDate: _toTz(at),
        androidScheduleMode: _scheduleMode,
        notificationDetails: _notificationDetails,
      );
      _lastError = null;
      return true;
    } on Object catch (error) {
      _lastError = error.toString();
      return false;
    }
  }

  Future<void> sync({
    required List<PostIt> postIts,
    required List<Routine> routines,
  }) async {
    if (!_ready) return;
    try {
      await _plugin.cancelAll();
      if (!_enabled) return;
      final now = _clock.now();
      final plan = buildNotificationPlan(
        postIts: postIts,
        routines: routines,
        now: now,
      );
      for (final notification in plan) {
        await _plugin.zonedSchedule(
          id: notification.id,
          title: notification.title,
          body: notification.body,
          scheduledDate: _toTz(notification.at),
          androidScheduleMode: _scheduleMode,
          notificationDetails: _notificationDetails,
        );
      }
      _lastError = null;
    } on Object catch (error) {
      _lastError = error.toString();
    }
  }

  tz.TZDateTime _toTz(DateTime value) => tz.TZDateTime(
    tz.local,
    value.year,
    value.month,
    value.day,
    value.hour,
    value.minute,
    value.second,
  );

  static const _testImmediateId = 999999;
  static const _testScheduledId = 999998;
}
