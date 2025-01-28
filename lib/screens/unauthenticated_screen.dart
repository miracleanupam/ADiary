import 'package:adiary/screens/alevated_button.dart';
import 'package:flutter/material.dart';

class UnauthenticatedScreen extends StatelessWidget {
  final bool isAuthenticating;
  final VoidCallback authenticate;
  const UnauthenticatedScreen(
      {super.key, required this.authenticate, required this.isAuthenticating});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade100,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Please Authenticate...'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (isAuthenticating)
              AlevatedButton(
                  onPressed: () {},
                  icon: Icons.more_horiz,
                  text: 'Awaiting Authentication')
            else
              Column(
                children: <Widget>[
                  AlevatedButton(
                      onPressed: authenticate,
                      icon: Icons.perm_device_information,
                      text: 'Authenticate'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
