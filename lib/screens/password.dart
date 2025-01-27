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
    bool authenticated = await auth.authenticate();

    if (authenticated && mounted) {
      ADiaryPasswordService passwordService =
          ADiaryPasswordService(context: context);

      passwordService.promptForPassword(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Success!")),
      );
    } else {
      mounted ? ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not authenticate")),
      ) : (){};
    }
  }

  void _showPassword() async {
    final ADauthenticationService auth = ADauthenticationService();
    bool authenticated = await auth.authenticate();

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
          ElevatedButton(
            onPressed: _showPassword,
                  style: ElevatedButton.styleFrom(
          textStyle: TextStyle(
              fontFamily: 'IndieFlower', fontWeight: FontWeight.bold)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.visibility),
                Text('Show Password'),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _promptForPassword,
                  style: ElevatedButton.styleFrom(
          textStyle: TextStyle(
              fontFamily: 'IndieFlower', fontWeight: FontWeight.bold)),
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
