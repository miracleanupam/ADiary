import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Storages {
  static const _storage = FlutterSecureStorage();

  // ─── Notification status ──────────────────────────────────────────────────

  /// Master switch — if false, no notifications are sent regardless of
  /// individual settings.
  Future<bool> readNotificationStatus() async {
    final value = await _read('notification');
    return value == null ? true : value == 'true';
  }

  Future<void> writeNotificationStatus(bool status) =>
      _storage.write(key: 'notification', value: status.toString());

  /// Individual notification toggles — default to true if never set.
  Future<bool> readStreakNotificationEnabled() async =>
      (await _read('notification_streak')) != 'false';

  Future<bool> readMemoryNotificationEnabled() async =>
      (await _read('notification_memory')) != 'false';

  Future<bool> readWeeklyNotificationEnabled() async =>
      (await _read('notification_weekly')) != 'false';

  Future<void> writeStreakNotificationEnabled(bool v) =>
      _storage.write(key: 'notification_streak', value: v.toString());

  Future<void> writeMemoryNotificationEnabled(bool v) =>
      _storage.write(key: 'notification_memory', value: v.toString());

  Future<void> writeWeeklyNotificationEnabled(bool v) =>
      _storage.write(key: 'notification_weekly', value: v.toString());

  // ─── Password ─────────────────────────────────────────────────────────────

  Future<String?> readSavedPassword() => _read('password');

  Future<void> writeNewPassword(String password) =>
      _storage.write(key: 'password', value: password);

  // ─── Notification time ────────────────────────────────────────────────────

  Future<(String?, String?)> readNotificationTime() async {
    final hour = await _read('hour');
    final minute = await _read('minute');
    return (hour, minute);
  }

  Future<void> writeNotificationTime(int hour, int minute) async {
    await _storage.write(
      key: 'hour',
      value: hour.toString().padLeft(2, '0'),
    );
    await _storage.write(
      key: 'minute',
      value: minute.toString().padLeft(2, '0'),
    );
  }

  // ─── Migration ────────────────────────────────────────────────────────────

  /// Returns true if the given [migrationKey] has already been run.
  /// Bump the key in AppMigrationService whenever you need migrations to re-run.
  Future<bool> hasMigrationRun(String migrationKey) async {
    final value = await _read(migrationKey);
    return value == 'true';
  }

  Future<void> setMigrationRun(String migrationKey) =>
      _storage.write(key: migrationKey, value: 'true');

  // ─── Private ──────────────────────────────────────────────────────────────

  Future<String?> _read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (_) {
      return null;
    }
  }
}
