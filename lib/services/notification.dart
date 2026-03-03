import 'dart:convert';

import 'package:adiary/main.dart';
import 'package:adiary/screens/add_entry.dart';
import 'package:adiary/screens/display_entry.dart';
import 'package:adiary/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Handles all notification display logic.
/// Scheduling is handled by WorkmanagerService — this class only
/// initialises the plugin and fires individual notifications.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // ─── Notification IDs ────────────────────────────────────────────────────
  static const int _idStreak = 1;
  static const int _idMemory = 2;
  static const int _idWeekly = 3;

  // ─── Channel IDs ─────────────────────────────────────────────────────────
  static const String _channelStreak = 'streak_channel';
  static const String _channelMemory = 'memory_channel';
  static const String _channelWeekly = 'weekly_channel';

  // ─── Init ─────────────────────────────────────────────────────────────────
  Future<void> init() async {
    if (_isInitialized) return;

    await _configureTimezone();
    await _plugin.initialize(
      _initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleTap(response.payload);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    // Handle tap when app was fully closed
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true) {
      _handleTap(launchDetails?.notificationResponse?.payload);
    }
    _isInitialized = true;
  }

  void _handleTap(String? payload) {
    if (payload == null) return;
    final context = navigatorKey.currentContext;
    if (context == null) return;
    final data = jsonDecode(payload);
    switch (data['kind']) {
      case 'streak':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => data['dashboard'] ? MyHomePage() : AddEntry()),
        );
        break;
      case 'memory':
        final entryId = data['id'];
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) => DisplayEntry(
                    selectedEntryId: entryId,
                  )),
        );
        break;
      case 'weekly':
        break;
    }
  }

  Future<void> _configureTimezone() async {
    tz.initializeTimeZones();
    final info = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(info.identifier));
  }

  Future<bool> hasNotificationPermission() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await androidPlugin?.areNotificationsEnabled() ??
        true; // true = assume granted on iOS
  }

  static const _initSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/launcher_icon'),
    iOS: DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    ),
  );

  // ─── Notification details helpers ─────────────────────────────────────────

  NotificationDetails _details(
          String channelId, String channelName, String desc) =>
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: desc,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      );

  // ─── Public fire methods (called from Workmanager background tasks) ────────

  /// Fires the streak notification.
  /// Shows a congratulatory message if [hasEntryToday] is true,
  /// otherwise nudges the user to record a happy moment.
  Future<void> showStreakNotification({required bool hasEntryToday}) async {
    await _ensureInitialized();

    final title =
        hasEntryToday ? '🔥 Streak maintained!' : '⏰ Don\'t break your streak!';
    final body = hasEntryToday
        ? 'Great job! You recorded a happy moment today. Keep it up!'
        : 'You haven\'t logged a happy moment yet today. Take a minute to record one!';

    await _plugin.show(
      _idStreak,
      title,
      body,
      _details(_channelStreak, 'Streak Reminders',
          'Daily streak check-in notifications'),
      payload: jsonEncode({'kind': 'streak', 'dashboard': hasEntryToday })
    );
  }

  /// Fires the "On this day" memory notification.
  /// [memoryTitle] is the title of the entry from one year ago,
  /// or null if no entry exists.
  Future<void> showMemoryNotification({String? memoryTitle, int? id}) async {
    await _ensureInitialized();

    // Silently skip if there's nothing to remind about
    if (memoryTitle == null) return;

    await _plugin.show(
        _idMemory,
        '📸 On this day, 1 year ago...',
        'You wrote: "$memoryTitle" — tap to revisit the memory.',
        _details(_channelMemory, 'Memory Reminders',
            'Daily "on this day" memory notifications'),
        payload: jsonEncode({'kind': 'memory', 'id': id})
      );
  }

  /// Fires the weekly summary notification on Sundays.
  /// [entryCount] is the number of entries recorded in the past 7 days.
  Future<void> showWeeklyNotification({required int entryCount}) async {
    await _ensureInitialized();

    final body = entryCount == 0
        ? 'You didn\'t record any happy moments last week. Let\'s change that this week! 💪'
        : 'You recorded $entryCount happy moment${entryCount == 1 ? '' : 's'} last week. Amazing! 🌟';

    await _plugin.show(
      _idWeekly,
      '📅 Your weekly recap',
      body,
      _details(_channelWeekly, 'Weekly Recap',
          'Weekly summary of your happy moments'),
    );
  }

  // ─── Private helpers ──────────────────────────────────────────────────────

  /// Initialises the plugin lazily when called from a background isolate,
  /// where [init] may not have been called yet.
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) await init();
  }
}
