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

final List<Map<String, dynamic>> MOOD_OPTIONS = [
  {
    'label': "Delighted",
    'icon': const Icon(Icons.ac_unit),
    'bgColor': Colors.red.shade100,
    'borderColor': Colors.red.shade300,
    'textColor': Colors.red.shade800,
  },
  {
    'label': "Cheerful",
    'icon': const Icon(Icons.abc_outlined),
    'bgColor': Colors.orange.shade100,
    'borderColor': Colors.orange.shade300,
    'textColor': Colors.orange.shade800,
  },
  {
    'label': "Excited",
    'icon': const Icon(Icons.access_alarm_sharp),
    'bgColor': Colors.amber.shade100,
    'borderColor': Colors.amber.shade300,
    'textColor': Colors.amber.shade800,
  },
  {
    'label': "Proud",
    'icon': const Icon(Icons.safety_check),
    'bgColor': Colors.green.shade100,
    'borderColor': Colors.green.shade300,
    'textColor': Colors.green.shade800,
  },
  {
    'label': "Grateful",
    'icon': const Icon(Icons.baby_changing_station),
    'bgColor': Colors.teal.shade100,
    'borderColor': Colors.teal.shade300,
    'textColor': Colors.teal.shade800,
  },
  {
    'label': "Hopeful",
    'icon': const Icon(Icons.cabin),
    'bgColor': Colors.cyan.shade100,
    'borderColor': Colors.cyan.shade300,
    'textColor': Colors.cyan.shade800,
  },
  {
    'label': "Inspired",
    'icon': const Icon(Icons.dangerous),
    'bgColor': Colors.blue.shade100,
    'borderColor': Colors.blue.shade300,
    'textColor': Colors.blue.shade800,
  },
  {
    'label': "Amused",
    'icon': const Icon(Icons.e_mobiledata),
    'bgColor': Colors.indigo.shade100,
    'borderColor': Colors.indigo.shade300,
    'textColor': Colors.indigo.shade800,
  },
  {
    'label': "Content",
    'icon': const Icon(Icons.face),
    'bgColor': Colors.purple.shade100,
    'borderColor': Colors.purple.shade300,
    'textColor': Colors.purple.shade800,
  },
  {
    'label': "Glad",
    'icon': const Icon(Icons.g_mobiledata),
    'bgColor': Colors.pink.shade100,
    'borderColor': Colors.pink.shade300,
    'textColor': Colors.pink.shade800,
  },
  {
    'label': "Relieved",
    'icon': const Icon(Icons.h_mobiledata),
    'bgColor': Colors.lime.shade100,
    'borderColor': Colors.lime.shade300,
    'textColor': Colors.lime.shade800,
  },
  {
    'label': "Loved",
    'icon': const Icon(Icons.ice_skating),
    'bgColor': Colors.brown.shade100,
    'borderColor': Colors.brown.shade300,
    'textColor': Colors.brown.shade800,
  },
  {
    'label': "Appreciated",
    'icon': const Icon(Icons.javascript),
    'bgColor': Colors.grey.shade200,
    'borderColor': Colors.grey.shade400,
    'textColor': Colors.grey.shade900,
  },
  {
    'label': "Empowered",
    'icon': const Icon(Icons.kayaking),
    'bgColor': Colors.deepOrange.shade100,
    'borderColor': Colors.deepOrange.shade300,
    'textColor': Colors.deepOrange.shade800,
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
