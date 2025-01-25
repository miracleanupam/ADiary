import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Storages {
  final _storage = FlutterSecureStorage();

  Future readSavedPassword() async {
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
}