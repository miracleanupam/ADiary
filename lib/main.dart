import 'dart:ui';

import 'package:adiary/constants.dart';
import 'package:adiary/models/entry.dart';
import 'package:adiary/screens/home.dart';
import 'package:adiary/screens/unauthenticated_screen.dart';
import 'package:adiary/services/app_migration.dart';
import 'package:adiary/services/authentication.dart';
import 'package:adiary/services/notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

// Global navigator key - top level (outside any class)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Background handler - top level (outside any class, needs @pragma)
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      DartPluginRegistrant.ensureInitialized();

      final notificationService = NotificationService();
      final password = inputData?['password'] as String?;

      if (!await notificationService.hasNotificationPermission()) {
        return true;
      }
      final entryProvider = EntryProvider(password: password);

      if (taskName == WorkerTasks.taskStreak ||
          taskName == WorkerTasks.taskStreakOneOff) {
        final hasEntry = await entryProvider.hasEntryToday();
        await notificationService.showStreakNotification(hasEntryToday: hasEntry);

      } else if (taskName == WorkerTasks.taskMemory ||
          taskName == WorkerTasks.taskMemoryOneOff) {
        final memory = await entryProvider.memoryFromLastYear();
        await notificationService.showMemoryNotification(
          memoryTitle: memory?.content,
          id: memory?.id,
        );

      } else if (taskName == WorkerTasks.taskWeekly ||
          taskName == WorkerTasks.taskWeeklyOneOff) {
        final count = await entryProvider.countLastWeek();
        await notificationService.showWeeklyNotification(entryCount: count);

      } else {
      }
      return true;
    } catch (e) {
      return true;
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppMigrationService.runIfNeeded();
  final notificationPlugin = NotificationService();
  notificationPlugin.init();

  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  runApp(const MeroApp());
}

class MeroApp extends StatefulWidget {
  const MeroApp({super.key});

  @override
  State<MeroApp> createState() => _MeroAppState();
}

class _MeroAppState extends State<MeroApp> {
  final ADauthenticationService auth = ADauthenticationService();
  final NotificationService notificationService = NotificationService();

  String _authorized = 'Not Authorized';

  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _setup();
    });
  }

  Future<void> _setup() async {
    await _askPermissions();
    await _authenticate();
  }

  Future<void> _askPermissions() async {
    // Request Android 13+ notification permission
    final androidPlugin = FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> _authenticate() async {
    bool authenticated = false;

    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      final dialogContext = navigatorKey.currentContext;
      if (dialogContext == null) return;

      authenticated = await auth.authenticate(dialogContext);

      setState(() {
        _isAuthenticating = false;
      });
    } on PlatformException catch (e) {
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - ${e.message}';
      });
    }
    if (!mounted) {
      return;
    }

    setState(
        () => _authorized = authenticated ? 'Authorized' : 'Not Authorized');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'ADiary',
      theme: ThemeData(
        fontFamily: 'IndieFlower',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        drawerTheme: DrawerThemeData(
          backgroundColor: PinkColors.shade100,
          elevation: 1,
        ),
        listTileTheme: ListTileThemeData(
            iconColor: PinkColors.shade900,
            selectedColor: PinkColors.shade700,
            textColor: PinkColors.shade900,
            titleTextStyle: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'IndieFlower')),
        dividerTheme: DividerThemeData(color: PinkColors.shade200),
        dialogTheme: DialogThemeData(
          titleTextStyle: TextStyle(
              fontFamily: 'IndieFlower',
              color: PinkColors.shade900,
              fontSize: 24),
          contentTextStyle: TextStyle(
              fontFamily: 'IndieFlower', color: Colors.pink, fontSize: 24),
        ),
        appBarTheme: AppBarTheme(
            elevation: 1,
            shadowColor: Colors.black,
            iconTheme: IconThemeData(
              color: PinkColors.shade900,
            ),
            titleSpacing: 0,
            titleTextStyle: TextStyle(
              fontFamily: 'IndieFlower',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: PinkColors.shade900,
            )),
        useMaterial3: true,
      ),
      home: _authorized == 'Authorized'
          ? const MyHomePage()
          : UnauthenticatedScreen(
              authenticate: _authenticate, isAuthenticating: _isAuthenticating),
    );
  }
}
