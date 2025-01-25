import 'package:adiary/models/entry.dart';
import 'package:adiary/screens/add_entry.dart';
import 'package:adiary/screens/display_entry.dart';
import 'package:adiary/services/storages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  bool exporting = false;
  bool importing = false;

  @override
  void initState() {
    super.initState();
    _checkPassword();
  }

  Future<void> _checkPassword() async {
    String? storedPassword = await secureStorage.read(key: 'password');
    if (storedPassword == null) {
      _promptForPassword();
    }
  }

  Future<void> _export() async {
    setState(() {
      exporting = true;
    });
    try {
      EntryProvider entryProvider = EntryProvider();
      String exportedPath = await entryProvider.export();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Exported to $exportedPath"),
              duration: Duration(seconds: 8)),
        );
      }
    } catch (_) {
    } finally {
      setState(() {
        exporting = false;
      });
    }
  }

  Future<void> _import() async {
    setState(() {
      importing = true;
    });

    bool wasSuccess = false;
    try {
      EntryProvider entryProvider = EntryProvider();
      await entryProvider.import();
      wasSuccess = true;
    } catch (_) {
    } finally {
      setState(() {
        importing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(wasSuccess
                  ? 'Successfully Imported'
                  : 'Something went wrong...'),
              duration: Duration(seconds: 8)),
        );
      }
    }
  }

  void _promptForPassword() {
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
            ]);
      },
    );
  }

  Widget addEntryButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AddEntry()),
        );
      },
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.favorite_border),
          Text('Add an Entry'),
        ],
      ),
    );
  }

  Widget memoryButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const DisplayEntry()),
        );
      },
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.sentiment_very_satisfied),
          Text('Go down the memory lane.'),
        ],
      ),
    );
  }

  Widget exportButton() {
    return exporting
        ? CircularProgressIndicator()
        : ElevatedButton(
            onPressed: _export,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.download),
                Text('Export'),
              ],
            ),
          );
  }

  Widget importButton() {
    return importing
        ? CircularProgressIndicator()
        : ElevatedButton(
            onPressed: _import,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.upload),
                Text('Import'),
              ],
            ),
          );
  }

  Widget changePasswordButton() {
    return ElevatedButton(
      onPressed: _promptForPassword,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.key),
          Text('Change Password'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('ADiary, Get it? It' 's a Pun!!'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            addEntryButton(),
            memoryButton(),
            exportButton(),
            importButton(),
            changePasswordButton(),
          ],
        ),
      ),
    );
  }
}
