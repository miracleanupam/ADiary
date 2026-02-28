import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Storages {
  static const _storage = FlutterSecureStorage();

  // ─── Password ─────────────────────────────────────────────────────────────

  Future<String?> readSavedPassword() => _read('password');

  Future<void> writeNewPassword(String password) =>
      _storage.write(key: 'password', value: password);

  // ─── Notification status ──────────────────────────────────────────────────

  Future<bool> readNotificationStatus() async {
    final value = await _read('notification');
    return value == null ? true : value == 'true';
  }

  Future<void> writeNotificationStatus(bool status) =>
      _storage.write(key: 'notification', value: status.toString());

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

  // ─── Private ──────────────────────────────────────────────────────────────

  Future<String?> _read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (_) {
      return null;
    }
  }
}