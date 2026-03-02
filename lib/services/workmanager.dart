// workmanager_service.dart
import 'package:adiary/models/entry.dart';
import 'package:adiary/services/notification.dart';
import 'package:adiary/services/storages.dart';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

// ─── Task name constants ───────────────────────────────────────────────────
const kTaskStreak = 'task.streak.daily';
const kTaskMemory = 'task.memory.daily';
const kTaskWeekly = 'task.weekly.sunday';

/// Top-level callback required by Workmanager.
/// Must be a top-level (or static) function — NOT inside a class.
/// This is the entry point for all background tasks.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    final notifications = NotificationService();
    final entries       = EntryProvider();
    print(taskName);

    switch (taskName) {

      // ── Daily streak check ───────────────────────────────────────────────
      case kTaskStreak:
        final hasEntry = await entries.hasEntryToday();
        await notifications.showStreakNotification(hasEntryToday: hasEntry);

      // ── Daily memory reminder ────────────────────────────────────────────
      case kTaskMemory:
        // Fetch the first entry from exactly one year ago (null if none)
        // final memory = await entries.getEntryFromOneYearAgo();
        final memory = await entries.getRandomEntry(0);
        await notifications.showMemoryNotification(memoryTitle: memory?.content);

      // ── Weekly Sunday recap ──────────────────────────────────────────────
      case kTaskWeekly:
        final count = await entries.getCount();
        await notifications.showWeeklyNotification(entryCount: count);
    }

    return Future.value(true); // Signal success to Workmanager
  });
}

class WorkmanagerService {
  WorkmanagerService._();

  static Future<void> init() async {
    await Workmanager().initialize(callbackDispatcher);
    if (kDebugMode) debugPrint('[WorkmanagerService] Initialized.');
  }

  /// Reads all user preferences from [Storages] and schedules/cancels
  /// each task accordingly. Call this on app start and whenever
  /// notification settings change.
  static Future<void> syncWithPreferences() async {
    final storages = Storages();

    final masterEnabled = await storages.readNotificationStatus();

    // If master switch is off, cancel everything and stop.
    if (!masterEnabled) {
      await cancelAll();
      return;
    }

    final streakEnabled = await storages.readStreakNotificationEnabled();
    final memoryEnabled = await storages.readMemoryNotificationEnabled();
    final weeklyEnabled = await storages.readWeeklyNotificationEnabled();
    final (hourStr, minuteStr) = await storages.readNotificationTime();

    final hour   = int.tryParse(hourStr   ?? '') ?? 20;
    final minute = int.tryParse(minuteStr ?? '') ?? 30;

    // Schedule or cancel each task based on its individual toggle.
    await _syncTask(
      enabled    : streakEnabled,
      uniqueName : kTaskStreak,
      initialDelay: _delayUntil(DateTime.now(), hour: hour, minute: minute),
    );

    await _syncTask(
      enabled    : memoryEnabled,
      uniqueName : kTaskMemory,
      initialDelay: _delayUntil(DateTime.now(), hour: 9, minute: 0),
    );

    await _syncTask(
      enabled    : weeklyEnabled,
      uniqueName : kTaskWeekly,
      frequency  : const Duration(days: 7),
      initialDelay: _delayUntilNextSunday(DateTime.now(), hour: 18, minute: 0),
    );
  }

  /// Call this when the user changes their preferred streak notification time.
  /// Only reschedules the streak task — leaves memory and weekly untouched.
  static Future<void> rescheduleStreak({
    required int hour,
    required int minute,
  }) async {
    final storages = Storages();

    // Persist the new time
    await storages.writeNotificationTime(hour, minute);

    final masterEnabled = await storages.readNotificationStatus();
    final streakEnabled = await storages.readStreakNotificationEnabled();

    if (!masterEnabled || !streakEnabled) {
      await Workmanager().cancelByUniqueName(kTaskStreak);
      return;
    }

    // Re-register with the new delay, replacing the old task
    await _syncTask(
      enabled    : true,
      uniqueName : kTaskStreak,
      initialDelay: _delayUntil(DateTime.now(), hour: hour, minute: minute),
    );

    if (kDebugMode) debugPrint('[WorkmanagerService] Streak rescheduled → $hour:$minute');
  }

  /// Cancels all registered tasks.
  static Future<void> cancelAll() async {
    await Workmanager().cancelByUniqueName(kTaskStreak);
    await Workmanager().cancelByUniqueName(kTaskMemory);
    await Workmanager().cancelByUniqueName(kTaskWeekly);
  }

  // ─── Private helpers ──────────────────────────────────────────────────────

  /// Schedules the task if [enabled], cancels it if not.
  static Future<void> _syncTask({
    required bool     enabled,
    required String   uniqueName,
    Duration frequency    = const Duration(days: 1),
    Duration initialDelay = Duration.zero,
  }) async {
    if (!enabled) {
      await Workmanager().cancelByUniqueName(uniqueName);
      if (kDebugMode) debugPrint('[WorkmanagerService] Task cancelled: $uniqueName');
      return;
    }

    print('----Registering periodic task');
    await Workmanager().registerPeriodicTask(
      uniqueName,
      uniqueName,
      frequency          : frequency,
      initialDelay       : initialDelay,
      constraints        : Constraints(networkType: NetworkType.notRequired),
      existingWorkPolicy : ExistingPeriodicWorkPolicy.replace,
    );

    if (kDebugMode) debugPrint('[WorkmanagerService] Task scheduled: $uniqueName (delay: $initialDelay)');
  }

  static Duration _delayUntil(DateTime now, {required int hour, required int minute}) {
    var target = DateTime(now.year, now.month, now.day, hour, minute);
    if (target.isBefore(now)) target = target.add(const Duration(days: 1));
    return target.difference(now);
  }

  static Duration _delayUntilNextSunday(DateTime now, {required int hour, required int minute}) {
    final daysUntilSunday = (DateTime.sunday - now.weekday) % 7;
    var target = DateTime(now.year, now.month, now.day + daysUntilSunday, hour, minute);
    if (target.isBefore(now)) target = target.add(const Duration(days: 7));
    return target.difference(now);
  }
}