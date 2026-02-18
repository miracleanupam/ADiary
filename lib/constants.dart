import 'package:adiary/screens/about.dart';
import 'package:adiary/screens/dashboard.dart';
import 'package:adiary/screens/export.dart';
import 'package:adiary/screens/import.dart';
import 'package:adiary/screens/password.dart';
import 'package:adiary/screens/notification.dart';
import 'package:flutter/material.dart';

const homePageWidgetListsForDrawer = {
  'dashboard': Dashboard(),
  'export': ExportData(),
  'import': ImportData(),
  'about': About(),
  'password': PasswordManager(),
  'notification': NotificationManager(),
};

const homePageWidgetTitleListsForAppBar = <String, String>{
  'dashboard': 'ADiary, Get it? It\'s a Pun!!',
  'export': 'Yeah gorl, back it all up..',
  'import': 'Gorl, I got your back...',
  'about': 'Why this? You ask?',
  'password': 'Sshh! Keep this a secret!!',
  'notification': "I know you forget..."
};

const List<Map<String, dynamic>> MOOD_OPTIONS = [
  {'label': "Delighted", 'icon': Icon(Icons.ac_unit), 'color': Colors.red},
  {
    'label': "Cheerful",
    'icon': Icon(Icons.abc_outlined),
    'color': Colors.orange
  },
  {
    'label': "Excited",
    'icon': Icon(Icons.access_alarm_sharp),
    'color': Colors.amber
  },
  {'label': "Proud", 'icon': Icon(Icons.safety_check), 'color': Colors.green},
  {
    'label': "Grateful",
    'icon': Icon(Icons.baby_changing_station),
    'color': Colors.teal
  },
  {'label': "Hopeful", 'icon': Icon(Icons.cabin), 'color': Colors.cyan},
  {'label': "Inspired", 'icon': Icon(Icons.dangerous), 'color': Colors.blue},
  {'label': "Amused", 'icon': Icon(Icons.e_mobiledata), 'color': Colors.indigo},
  {'label': "Content", 'icon': Icon(Icons.face), 'color': Colors.purple},
  {'label': "Glad", 'icon': Icon(Icons.g_mobiledata), 'color': Colors.pink},
  {'label': "Relieved", 'icon': Icon(Icons.h_mobiledata), 'color': Colors.lime},
  {'label': "Loved", 'icon': Icon(Icons.ice_skating), 'color': Colors.brown},
  {
    'label': "Appreciated",
    'icon': Icon(Icons.javascript),
    'color': Colors.grey
  },
  {
    'label': "Empowered",
    'icon': Icon(Icons.kayaking),
    'color': Colors.deepOrange
  },
];


// const bgDecoration = BoxDecoration(
//     gradient: LinearGradient(
//       begin: Alignment.centerLeft,
//       end: Alignment.centerRight,
//       tileMode: TileMode.repeated,
//       stops: [0.1, 0.3, 0.7, 0.9],
//       colors: [
//         Color(0xFFB19ADE),
//         Color(0xFFC5BDE6),
//         Color(0xFFF4B6CF),
//         Color(0xFFE099DB),
//       ],
//     ));

// const bgDecoration = BoxDecoration(
//   image: DecorationImage(image: AssetImage("assets/images/background.jpg"), fit: BoxFit.cover)
// );
