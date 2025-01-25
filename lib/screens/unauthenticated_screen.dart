import 'package:flutter/material.dart';

class UnauthenticatedScreen extends StatelessWidget {
  final bool isAuthenticating;
  final VoidCallback authenticate;
  const UnauthenticatedScreen({super.key, required this.authenticate, required this.isAuthenticating});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Please Authenticate...'),
      ),
      body: Center(
        child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (isAuthenticating)
                    ElevatedButton(
                      onPressed: () {},
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text('Awaiting Authentication'),
                          Icon(Icons.more_horiz),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: authenticate,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text('Authenticate'),
                              Icon(Icons.perm_device_information),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
      ),
    );
  }
}