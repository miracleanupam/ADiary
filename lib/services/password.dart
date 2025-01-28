import 'package:adiary/services/storages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ADiaryPasswordService {
  final BuildContext context;
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final TextEditingController passwordController = TextEditingController();

  ADiaryPasswordService({required this.context});
  void _changePassword() async {
    String password = passwordController.text;
    if (password.isNotEmpty) {
      Storages().writeNewPassword(password);
      Navigator.pop(context);
    }
  }

  void promptForPassword(bool cancelable) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
            title: const Text(
                "Set Password and do NOT forget it! It will be used to encrypt data."),
            content: TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Enter a Password"),
            ),
            actions: [
              TextButton(
                  onPressed: _changePassword,
                  child: const Text('Save',
                      style: TextStyle(
                          fontFamily: 'IndieFlower',
                          fontSize: 24,
                          color: Color(0xFF880E4F)))),
              cancelable
                  ? TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel',
                          style: TextStyle(
                              fontFamily: 'IndieFlower',
                              fontSize: 24,
                              color: Color(0xFF880E4F))))
                  : SizedBox()
            ]);
      },
    );
  }

  void showPassword() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
              title: const Text(
                  'I know you\'re a boss but you need to remember this:'),
              content: FutureBuilder(
                  future: Storages().readSavedPassword(),
                  builder:
                      (BuildContext context, AsyncSnapshot<String?> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasData) {
                      return Text(snapshot.data ?? '');
                    } else {
                      return Text('');
                    }
                  }),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Sorry, I\'ll remember',
                        style: TextStyle(
                            fontFamily: 'IndieFlower',
                            fontSize: 24,
                            color: Color(0xFF880E4F))))
              ]);
        });
  }

  Future<String?> getPassword() async {
    return await secureStorage.read(key: 'password');
  }
}