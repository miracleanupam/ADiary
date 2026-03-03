import 'package:adiary/models/entry.dart';
import 'package:adiary/services/storages.dart';
import 'package:adiary/services/work_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ADiaryPasswordService {
  final BuildContext context;

  final _secureStorage = const FlutterSecureStorage();
  final _passwordController = TextEditingController();

  static const _buttonStyle = TextStyle(
    fontFamily: 'IndieFlower',
    fontSize: 24,
    color: Color(0xFF880E4F),
  );

  ADiaryPasswordService({required this.context});

  // ─── Public API ───────────────────────────────────────────────────────────

  Future<String?> getPassword() => _secureStorage.read(key: 'password');

  Future<void> promptForPassword(bool cancelable) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text(
          "Set Password and do NOT forget it! It will be used to encrypt data.",
        ),
        content: TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Enter a Password'),
        ),
        actions: [
          TextButton(
            onPressed: _savePassword,
            child: const Text('Save', style: _buttonStyle),
          ),
          if (cancelable)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: _buttonStyle),
            ),
        ],
      ),
    );
  }

  void showPassword() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text(
          "I know you're a boss but you need to remember this:",
        ),
        content: FutureBuilder<String?>(
          future: Storages().readSavedPassword(),
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            return Text(snapshot.data ?? '');
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Sorry, I'll remember", style: _buttonStyle),
          ),
        ],
      ),
    );
  }

  // ─── Private ──────────────────────────────────────────────────────────────

  Future<void> _savePassword() async {
    final password = _passwordController.text;
    if (password.isEmpty) return;
    final existingPassword = await Storages().readSavedPassword();
    await Storages().writeNewPassword(password);
    if (existingPassword != null) await EntryProvider().reEncryptDb(password);
    await WorkmanagerService.syncWithPreferences(password: password);
    if (context.mounted) Navigator.pop(context);
  }
}