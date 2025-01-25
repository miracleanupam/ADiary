import 'package:adiary/services/storages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ADiaryPasswordService {
  final BuildContext context;
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  
  ADiaryPasswordService({required this.context});

  void promptForPassword(bool cancelable) {
    TextEditingController passwordController = TextEditingController();
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
                  onPressed: () async {
                    String password = passwordController.text;
                    if (password.isNotEmpty) {
                      Storages().writeNewPassword(password);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save')),
              cancelable ? TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancle')) : SizedBox()
            ]);
      },
    );
  }

  Future<String?> getPasswod() async {
    return await secureStorage.read(key: 'password');
  }
}
