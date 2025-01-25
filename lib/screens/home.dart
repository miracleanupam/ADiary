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
    String? storedPassword = await passwordService.getPasswod();

    if (storedPassword == null && mounted) {
    passwordService.promptForPassword(false);
    }
    }
  }

  // void _promptForPassword() {
  //   TextEditingController passwordController = TextEditingController();
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) {
  //       return AlertDialog(
  //           title: const Text(
  //               "Set Password and do NOT forget it! It will be used to encrypt data."),
  //           content: TextField(
  //             controller: passwordController,
  //             obscureText: true,
  //             decoration: const InputDecoration(labelText: "Enter a Password"),
  //           ),
  //           actions: [
  //             TextButton(
  //                 onPressed: () async {
  //                   String password = passwordController.text;
  //                   if (password.isNotEmpty) {
  //                     Storages().writeNewPassword(password);
  //                     Navigator.pop(context);
  //                   }
  //                 },
  //                 child: const Text('Save')),
  //           ]);
  //     },
  //   );
  // }

  // Widget changePasswordButton() {
  //   return ElevatedButton(
  //     onPressed: _promptForPassword,
  //     child: const Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: <Widget>[
  //         Icon(Icons.key),
  //         Text('Change Password'),
  //       ],
  //     ),
  //   );
  // }

  String _drawerScreen = 'dashboard';

  void _drawerItemTapped(String newScreen) {
    setState(() {
      _drawerScreen = newScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
