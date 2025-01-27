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

  @override
  void initState() {
    super.initState();
    _checkPassword();
  }

  Future<void> _checkPassword() async {
    if (mounted) {
    ADiaryPasswordService passwordService = ADiaryPasswordService(context: context);
    String? storedPassword = await passwordService.getPassword();

    if (storedPassword == null && mounted) {
    passwordService.promptForPassword(false);
    }
    }
  }

  String _drawerScreen = 'dashboard';

  void _drawerItemTapped(String newScreen) {
    setState(() {
      _drawerScreen = newScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade100,
      appBar: AppBar(
        elevation: 1,
        shadowColor: Colors.black,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("${constants.homePageWidgetTitleListsForAppBar[_drawerScreen]}"),
        titleSpacing: 0.0,
      ),
      drawer: ADrawer(onTapCallback: _drawerItemTapped, selectedItem: _drawerScreen),
      body: Center(
        child: constants.homePageWidgetListsForDrawer[_drawerScreen],
      ),
    );
  }
}
