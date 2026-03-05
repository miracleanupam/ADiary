import 'package:adiary/compnents/alevated_button.dart';
import 'package:adiary/services/authentication.dart';
import 'package:adiary/services/password.dart';
import 'package:flutter/material.dart';

class PasswordManager extends StatefulWidget {
  const PasswordManager({super.key});

  @override
  State<PasswordManager> createState() => _PasswordManagerState();
}

class _PasswordManagerState extends State<PasswordManager> {
  void _promptForPassword() async {
    final ADauthenticationService auth = ADauthenticationService();
    bool authenticated = await auth.authenticate(context);

    if (authenticated && mounted) {
      ADiaryPasswordService passwordService =
          ADiaryPasswordService(context: context);

      passwordService.promptForPassword(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Success!")),
      );
    } else {
      mounted
          ? ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Could not authenticate")),
            )
          : () {};
    }
  }

  void _showPassword() async {
    final ADauthenticationService auth = ADauthenticationService();
    bool authenticated =
        await auth.authenticate(context, passwordFallback: false);

    if (authenticated && mounted) {
      ADiaryPasswordService passwordService =
          ADiaryPasswordService(context: context);

      passwordService.showPassword();
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
          AlevatedButton(
              onPressed: _showPassword,
              icon: Icons.visibility_outlined,
              text: 'Show Password'),
          AlevatedButton(
              onPressed: _promptForPassword,
              icon: Icons.autorenew_outlined,
              text: 'Change Password'),
        ],
      ),
    );
  }
}
