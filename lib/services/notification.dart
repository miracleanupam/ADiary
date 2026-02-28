import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // ─── Init ─────────────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_isInitialized) return;

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    androidPlugin?.requestNotificationsPermission();

    await _configureTimezone();
    await _plugin.initialize(_initSettings);

    _isInitialized = true;
  }

  Future<void> _configureTimezone() async {
    tz.initializeTimeZones();
    final info = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(info.identifier));
  }

  static const _initSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/launcher_icon'),
    iOS: DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    ),
  );

  // ─── Notification details ─────────────────────────────────────────────────

  static const _notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'daily_channel_id',
      'Daily Notifications',
      channelDescription: 'Daily Notification Channel',
      importance: Importance.max,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  // ─── Schedule / cancel ────────────────────────────────────────────────────

  Future<void> scheduleNotification({
    String hour = '20',
    String minute = '30',
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      int.parse(hour),
      int.parse(minute),
    );

    await cancelNotifications();
    await _plugin.zonedSchedule(
      100,
      'How was your day?',
      'Add new happy moments or remember some from the past...',
      scheduled,
      _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelNotifications() async => _plugin.cancelAll();
}