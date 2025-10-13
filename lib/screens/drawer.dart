import 'package:flutter/material.dart';

class ADrawer extends StatefulWidget {
  final Function onTapCallback;
  final String selectedItem;
  const ADrawer(
      {super.key, required this.onTapCallback, required this.selectedItem});

  @override
  State<ADrawer> createState() => _ADrawerState();
}

class _ADrawerState extends State<ADrawer> {
  String currentSelection = 'dashboard';

  @override
  void initState() {
    currentSelection = widget.selectedItem;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      children: [
        DrawerHeader(
          decoration: BoxDecoration(color: Colors.pink.shade200),
          child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                'What\'s up Gorlie?... xoxo',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink.shade900),
              )),
        ),
        ListTile(
          leading: Icon(Icons.home),
          title: Text(
            'Home',
          ),
          selected: currentSelection == 'dashboard',
          onTap: () {
            setState(() {
              currentSelection = 'dashboard';
            });
            widget.onTapCallback('dashboard');
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.notification_important),
          title: Text(
            'Notification',
          ),
          selected: currentSelection == 'notification',
          onTap: () {
            setState(() {
              currentSelection = 'notification';
            });
            widget.onTapCallback('notification');
            Navigator.pop(context);
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.download),
          title: Text(
            'Export Data',
          ),
          selected: currentSelection == 'export',
          onTap: () {
            setState(() {
              currentSelection = 'export';
            });
            widget.onTapCallback('export');
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.upload),
          title: Text(
            'Import Data',
          ),
          selected: currentSelection == 'import',
          onTap: () {
            setState(() {
              currentSelection = 'import';
            });
            widget.onTapCallback('import');
            Navigator.pop(context);
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.key),
          title: Text(
            'Password',
          ),
          selected: currentSelection == 'password',
          onTap: () {
            setState(() {
              currentSelection = 'password';
            });
            widget.onTapCallback('password');
            Navigator.pop(context);
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.info),
          title: Text(
            'About App',
          ),
          selected: currentSelection == 'about',
          onTap: () {
            setState(() {
              currentSelection = 'about';
            });
            widget.onTapCallback('about');
            Navigator.pop(context);
          },
        ),
      ],
    ));
  }
}
