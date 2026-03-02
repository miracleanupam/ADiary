import 'package:adiary/services/storages.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AppMigrationService {
  static const _kMigrationVersion = 'migration_v2_v3';

  static Future<void> runIfNeeded() async {
    final storages = Storages();
    if (await storages.hasMigrationRun(_kMigrationVersion)) return;

    await _runMigrations();

    await storages.setMigrationRun(_kMigrationVersion);
  }

  static Future<void> _runMigrations() async {
    print('----Running App Migration');
    await FlutterLocalNotificationsPlugin().cancelAll();
  }
}