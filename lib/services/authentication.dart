import 'package:adiary/services/storages.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class ADauthenticationService {
  final _auth = LocalAuthentication();

  Future<bool> authenticate(BuildContext context,
      {bool passwordFallback = true}) async {
    if (!await _auth.isDeviceSupported()) {
      if (!passwordFallback) return true;

      return await _authenticateWithAppPassword(context);
    }

    // If device is supported, continue with biometrics logic
    final didAuthenticate = await _auth.authenticate(
      localizedReason: 'Press back button to authenticate with ADiary Password',
      options:
          const AuthenticationOptions(biometricOnly: false, stickyAuth: true),
    );
    if (didAuthenticate) {
      return true;
    }
    return await _authenticateWithAppPassword(context);
  }

  Future<bool> _authenticateWithAppPassword(BuildContext context) async {
    final storedPassword = await Storages().readSavedPassword();

    if (storedPassword == null) {
      return true; // first time
    }

    String? error;

    while (true) {
      final entered = await _showPasswordDialog(context, errorText: error);

      if (entered == null) return false;

      if (entered == storedPassword) return true;

      error = "Incorrect password";
    }
  }

  Future<String?> _showPasswordDialog(BuildContext context,
      {String? errorText}) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        // Request focus after build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          focusNode.requestFocus();
        });

        return AlertDialog(
          title: const Text('Enter Password'),
          content: TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: true,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: 'Password',
              errorText: errorText,
            ),
            onSubmitted: (_) {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                Navigator.of(context).pop(value);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.isNotEmpty) {
                  Navigator.of(context).pop(value);
                }
              },
              child: const Text('Unlock'),
            ),
          ],
        );
      },
    );
  }
}
