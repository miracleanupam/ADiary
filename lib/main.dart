import 'package:adiary/screens/home.dart';
import 'package:adiary/screens/unauthenticated_screen.dart';
import 'package:adiary/services/authentication.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MeroApp());
}

class MeroApp extends StatefulWidget {
  const MeroApp({super.key});

  @override
  State<MeroApp> createState() => _MeroAppState();
}

class _MeroAppState extends State<MeroApp> {
  final ADauthenticationService auth = ADauthenticationService();

  String _authorized = 'Not Authorized';

  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    bool authenticated = false;

    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate();

      setState(() {
        _isAuthenticating = false;
      });
    } on PlatformException catch (e) {
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - ${e.message}';
      });
    }
    if (!mounted) {
      return;
    }

    setState(
        () => _authorized = authenticated ? 'Authorized' : 'Not Authorized');
  }

  // Future<void> _cancelAuthentication() async {
  //   await auth.stopAuthentication();
  //   setState(() => _isAuthenticating = false);
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'IndieFlower',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      home: _authorized == 'Authorized'
          ? const MyHomePage()
          : UnauthenticatedScreen(
              authenticate: _authenticate, isAuthenticating: _isAuthenticating),
    );
  }
}
