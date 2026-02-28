import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class ADiaryPermissions {
  Future<bool> checkWritePermission() async {
    if (!Platform.isAndroid) return false;

    final status = await Permission.storage.status;
    if (status.isGranted) return true;

    final result = await Permission.storage.request();
    return result.isGranted;
  }
}