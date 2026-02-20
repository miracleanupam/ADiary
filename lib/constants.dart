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
    'label': "Amused",
    'icon': const Icon(Icons.outlet_outlined),
    'bgColor': Colors.indigo.shade100,
    'borderColor': Colors.indigo.shade300,
    'textColor': Colors.indigo.shade800,
  },
  {
    'label': "Beautiful",
    'icon': const Icon(Icons.photo_camera_outlined),
    'bgColor': Colors.pinkAccent.shade100,
    'borderColor': Colors.pink.shade600,
    'textColor': Colors.pink.shade900,
  },
  {
    'label': "Cheerful",
    'icon': const Icon(Icons.mood),
    'bgColor': Colors.orange.shade100,
    'borderColor': Colors.orange.shade300,
    'textColor': Colors.pink.shade800,
  },
  {
    'label': "Content",
    'icon': const Icon(Icons.tag_faces_outlined),
    'bgColor': Colors.purple.shade100,
    'borderColor': Colors.purple.shade300,
    'textColor': Colors.purple.shade800,
  },
  {
    'label': "Cozy",
    'icon': const Icon(Icons.fireplace_outlined),
    'bgColor': Colors.orangeAccent.shade100,
    'borderColor': Colors.red.shade600,
    'textColor': Colors.red.shade600,
  },
  {
    'label': "Creative",
    'icon': const Icon(Icons.brush_outlined),
    'bgColor': Colors.brown.shade200,
    'borderColor': Colors.brown.shade600,
    'textColor': Colors.brown.shade900,
  },
  {
    'label': "Delighted",
    'icon': const Icon(Icons.sentiment_very_satisfied_outlined),
    'bgColor': Colors.red.shade100,
    'borderColor': Colors.red.shade300,
    'textColor': Colors.red.shade800,
  },
  {
    'label': "Empowered",
    'icon': const Icon(Icons.rocket_outlined),
    'bgColor': Colors.deepOrange.shade100,
    'borderColor': Colors.deepOrange.shade300,
    'textColor': Colors.deepOrange.shade800,
  },
  {
    'label': "Excited",
    'icon': const Icon(Icons.sentiment_satisfied),
    'bgColor': Colors.amber.shade100,
    'borderColor': Colors.amber.shade800,
    'textColor': Colors.pink.shade600,
  },
  {
    'label': "Free",
    'icon': const Icon(Icons.wind_power_outlined),
    'bgColor': Colors.grey.shade200,
    'borderColor': Colors.grey.shade600,
    'textColor': Colors.grey.shade800,
  },
  {
    'label': "Fulfilled",
    'icon': const Icon(Icons.battery_charging_full_outlined),
    'bgColor': Colors.red.shade100,
    'borderColor': Colors.red.shade600,
    'textColor': Colors.red.shade900,
  },
  {
    'label': "Glad",
    'icon': const Icon(Icons.wb_sunny_outlined),
    'bgColor': Colors.pink.shade100,
    'borderColor': Colors.pink.shade300,
    'textColor': Colors.pink.shade800,
  },
  {
    'label': "Grateful",
    'icon': const Icon(Icons.handshake_outlined),
    'bgColor': Colors.teal.shade100,
    'borderColor': Colors.teal.shade300,
    'textColor': Colors.teal.shade800,
  },
  {
    'label': "Hopeful",
    'icon': const Icon(Icons.temple_hindu_outlined),
    'bgColor': Colors.cyan.shade100,
    'borderColor': Colors.cyan.shade300,
    'textColor': Colors.cyan.shade800,
  },
  {
    'label': "Inspired",
    'icon': const Icon(Icons.lightbulb_outline),
    'bgColor': Colors.blue.shade100,
    'borderColor': Colors.blue.shade300,
    'textColor': Colors.blue.shade800,
  },
  {
    'label': "Loved",
    'icon': const Icon(Icons.favorite_outline),
    'bgColor': Colors.brown.shade100,
    'borderColor': Colors.brown.shade300,
    'textColor': Colors.brown.shade800,
  },
  {
    'label': "Proud",
    'icon': const Icon(Icons.emoji_events_outlined),
    'bgColor': Colors.green.shade100,
    'borderColor': Colors.green.shade300,
    'textColor': Colors.green.shade800,
  },
  {
    'label': "Purposeful",
    'icon': const Icon(Icons.bolt_outlined),
    'bgColor': Colors.deepPurple.shade100,
    'borderColor': Colors.deepPurple.shade600,
    'textColor': Colors.deepPurple.shade800,
  },
  {
    'label': "Relieved",
    'icon': const Icon(Icons.thumb_up_alt_outlined),
    'bgColor': Colors.lime.shade100,
    'borderColor': Colors.lime.shade300,
    'textColor': Colors.lime.shade900,
  },
  {
    'label': "Rich",
    'icon': const Icon(Icons.euro_outlined),
    'bgColor': Colors.deepOrange.shade100,
    'borderColor': Colors.deepOrange.shade600,
    'textColor': Colors.pink.shade800,
  },
  {
    'label': "Seen",
    'icon': const Icon(Icons.visibility_outlined),
    'bgColor': Colors.grey.shade200,
    'borderColor': Colors.grey.shade400,
    'textColor': Colors.grey.shade900,
  },
  {
    'label': "Tingly",
    'icon': const Icon(Icons.vibration_outlined),
    'bgColor': Colors.indigoAccent.shade100,
    'borderColor': Colors.indigo.shade600,
    'textColor': Colors.indigo.shade600,
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
