import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class ADiaryPermissions {
  ADiaryPermissions();

  Future<bool> checkWritePermission() async {
    // debugger();
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;

      if (!status.isGranted) {
        final result = await Permission.storage.request();

        if (result.isDenied == true) {
          checkWritePermission();
        } else {}
      }
      return true;
    }
    return false;
  }
}
