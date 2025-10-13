import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Storages {
  final _storage = FlutterSecureStorage();

  Future<String?> readSavedPassword() async {
    try {
      String? savedPassword = await _storage.read(key: 'password');
      return savedPassword;
    } catch (e) {
      return null;
    }
  }

  Future writeNewPassword(newPassword) async {
    _storage.write(key: 'password', value: newPassword);
  }

  Future<bool> readNotificationStatus() async {
    try {
      String? notificationStatus = await _storage.read(key: 'notification');
      return notificationStatus == "true";
    } catch (e) {
      return true;
    }
  }

  Future writeNotificationStatus(newStatus) async {
    _storage.write(key: 'notification', value: newStatus.toString());
  }

  Future<(String?, String?)> readNotificationTime() async {
    try {
      String? hour = await _storage.read(key: 'hour');
      String? minute = await _storage.read(key: 'minute');

      return (hour, minute);
    } catch (e) {
      return (null, null);
    }
  }

  Future writeNotificationTime(newHour, newMinute) async {
    _storage.write(key: "hour", value: newHour.toString().padLeft(2, '0'));
    _storage.write(key: 'minute', value: newMinute.toString().padLeft(2, '0'));
  }
}
