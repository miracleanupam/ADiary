import 'package:adiary/constants.dart';
import 'package:adiary/screens/drawer.dart';
import 'package:adiary/services/password.dart';
import 'package:flutter/material.dart';
import 'package:adiary/constants.dart' as constants;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _drawerScreen = 'dashboard';

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _checkPassword();
  }

  // ─── Password ─────────────────────────────────────────────────────────────

  Future<void> _checkPassword() async {
    if (!mounted) return;
    final passwordService = ADiaryPasswordService(context: context);
    final stored = await passwordService.getPassword();
    if (stored == null && mounted) passwordService.promptForPassword(false);
  }

  // ─── Navigation ───────────────────────────────────────────────────────────

  void _onDrawerItemTapped(String screen) {
    setState(() => _drawerScreen = screen);
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PinkColors.shade100,
      appBar: AppBar(
        flexibleSpace: constants.appBarBg,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(constants.homePageWidgetTitleListsForAppBar[_drawerScreen]!),
      ),
      drawer: ADrawer(
        onTapCallback: _onDrawerItemTapped,
        selectedItem: _drawerScreen,
      ),
      body: Container(
        decoration: constants.bgDecoration,
        height: double.infinity,
        child: constants.homePageWidgetListsForDrawer[_drawerScreen],
      ),
    );
  }
}