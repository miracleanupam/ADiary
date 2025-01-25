import 'package:adiary/services/password.dart';
import 'package:flutter/material.dart';

class PasswordManager extends StatefulWidget {
  const PasswordManager({super.key});

  @override
  State<PasswordManager> createState() => _PasswordManagerState();
}

class _PasswordManagerState extends State<PasswordManager> {
  void _promptForPassword() {
    if (mounted) {
      ADiaryPasswordService passwordService =
          ADiaryPasswordService(context: context);
      passwordService.promptForPassword(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _promptForPassword,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.key),
                Text('Change Password'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
