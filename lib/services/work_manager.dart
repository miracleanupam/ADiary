// workmanager_service.dart
import 'package:adiary/constants.dart';
import 'package:adiary/services/storages.dart';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

class WorkmanagerService {
  WorkmanagerService._();

  /// Reads all user preferences from [Storages] and schedules/cancels
  /// each task accordingly. Call this on app start and whenever
  /// notification settings change.
  static Future<void> syncWithPreferences({ String? password }) async {
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
      uniqueName : WorkerTasks.taskStreak,
      uniqueNameOneOff: WorkerTasks.taskStreakOneOff,
      initialDelay: _delayUntil(DateTime.now(), hour: hour, minute: minute),
      passedPassword: password
    );

    await _syncTask(
      enabled    : memoryEnabled,
      uniqueName : WorkerTasks.taskMemory,
      uniqueNameOneOff: WorkerTasks.taskMemoryOneOff,
      initialDelay: _delayUntil(DateTime.now(), hour: hour, minute: minute),
      passedPassword: password
    );

    await _syncTask(
      enabled    : weeklyEnabled,
      uniqueName : WorkerTasks.taskWeekly,
      uniqueNameOneOff: WorkerTasks.taskWeeklyOneOff,
      frequency  : const Duration(days: 7),
      initialDelay: _delayUntilNextSunday(DateTime.now(), hour: 18, minute: 0),
      passedPassword: password
    );
  }

  /// Call this when the user changes their preferred streak notification time.
  /// Only reschedules the streak task — leaves memory and weekly untouched.
  static Future<void> rescheduleStreak({
    required int hour,
    required int minute,
    required String? password,
  }) async {
    final storages = Storages();

    // Persist the new time
    await storages.writeNotificationTime(hour, minute);
    await _cancelStreak();

    // Re-register with the new delay, replacing the old task
    await _syncTask(
      enabled    : true,
      uniqueName : WorkerTasks.taskStreak,
      uniqueNameOneOff: WorkerTasks.taskStreakOneOff,
      initialDelay: _delayUntil(DateTime.now(), hour: hour, minute: minute),
      passedPassword: password
    );
  }

  /// Cancels all registered tasks.
  static Future<void> cancelAll() async {
    await _cancelStreak();
    await _cancelMemory();
    await _cancelWeekly();
  }

  static Future<void> _cancelStreak() async {
    await Workmanager().cancelByUniqueName(WorkerTasks.taskStreak);
    await Workmanager().cancelByUniqueName(WorkerTasks.taskStreakOneOff);
  }
  static Future<void> _cancelMemory() async {
    await Workmanager().cancelByUniqueName(WorkerTasks.taskMemory);
    await Workmanager().cancelByUniqueName(WorkerTasks.taskMemoryOneOff);
  }

  static Future<void> _cancelWeekly() async {
    await Workmanager().cancelByUniqueName(WorkerTasks.taskWeekly);
    await Workmanager().cancelByUniqueName(WorkerTasks.taskWeeklyOneOff);
  }

  // ─── Private helpers ──────────────────────────────────────────────────────

  /// Schedules the task if [enabled], cancels it if not.
  static Future<void> _syncTask({
    required bool     enabled,
    required String   uniqueName,
    required String   uniqueNameOneOff,
    Duration frequency = const Duration(days: 1),
    Duration initialDelay = const Duration(days: 1),
    String? passedPassword,
  }) async {
    // Read password here (in foreground) and pass it to the background isolate
    final password = passedPassword ?? await Storages().readSavedPassword();
    if (password == null) {
      return;
    }


    if (!enabled) {
      await Workmanager().cancelByUniqueName(uniqueName);
      return;
    }

    await Workmanager().registerOneOffTask(
      uniqueNameOneOff,
      uniqueNameOneOff,
      inputData: { 'password': password },
      initialDelay: initialDelay
    );

    await Workmanager().registerPeriodicTask(
      uniqueName,
      uniqueName,
      frequency          : frequency,
      initialDelay       : initialDelay,
      inputData          : {'password': password},
      constraints        : Constraints(networkType: NetworkType.notRequired),
      existingWorkPolicy : ExistingPeriodicWorkPolicy.update,
    );
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