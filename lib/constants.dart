import 'package:adiary/screens/about.dart';
import 'package:adiary/screens/dashboard.dart';
import 'package:adiary/screens/export.dart';
import 'package:adiary/screens/import.dart';
import 'package:adiary/screens/notification.dart';
import 'package:adiary/screens/password.dart';
import 'package:adiary/screens/summary.dart';
import 'package:adiary/screens/visualization.dart';
import 'package:flutter/material.dart';


// ─── Colors ───────────────────────────────────────────────────────────────
abstract final class PinkColors {
  static const shade50  = Color(0xFFFCE4EC);
  static const shade100 = Color(0xFFF8BBD0);
  static const shade200 = Color(0xFFF48FB1);
  static const shade300 = Color(0xFFF06292);
  static const shade400 = Color(0xFFEC407A);
  static const shade500 = Color(0xFFE91E63);
  static const shade600 = Color(0xFFD81B60);
  static const shade700 = Color(0xFFC2185B);
  static const shade800 = Color(0xFFAD1457);
  static const shade900 = Color(0xFF880E4F);
}

abstract final class PinkAccentColors {
  static const shade100 = Color(0xFFFF80AB);
  static const shade200 = Color(0xFFFF4081);
  static const shade400 = Color(0xFFF50057);
  static const shade700 = Color(0xFFC51162);
}

// ─── Navigation ───────────────────────────────────────────────────────────────

const homePageWidgetListsForDrawer = <String, Widget>{
  'dashboard': Dashboard(),
  'export': ExportData(),
  'import': ImportData(),
  'about': About(),
  'password': PasswordManager(),
  'notification': NotificationManager(),
  'summary': Summary(),
  'visualization': Visualization(),
};

const homePageWidgetTitleListsForAppBar = <String, String>{
  'dashboard': "ADiary, Get it? It's a Pun!!",
  'export': 'Yeah gorl, back it all up..',
  'import': 'Gorl, I got your back...',
  'about': 'Why this? You ask?',
  'password': 'Sshh! Keep this a secret!!',
  'notification': 'I know you forget...',
  'summary': 'At a Glance!!',
  'visualization': 'In Detail!!',
};

// ─── Decorations ──────────────────────────────────────────────────────────────

final bgDecoration = BoxDecoration(
  image: DecorationImage(
    image: const AssetImage('assets/images/nature.jpg'),
    fit: BoxFit.cover,
    colorFilter: ColorFilter.mode(
      Colors.black.withValues(alpha: 0.25),
      BlendMode.dstATop,
    ),
  ),
);

final appBarBg = Container(
  decoration: BoxDecoration(
    image: DecorationImage(
      image: const AssetImage('assets/images/stars.jpeg'),
      fit: BoxFit.cover,
      colorFilter: ColorFilter.mode(
        Colors.black.withValues(alpha: 0.6),
        BlendMode.dstATop,
      ),
    ),
  ),
);

// ─── Mood options ─────────────────────────────────────────────────────────────

const List<Map<String, dynamic>> MOOD_OPTIONS = [
  {
    'label': 'Amused',
    'icon': Icon(Icons.outlet_outlined),
    'bgColor': Colors.indigo,
    'borderColor': Colors.indigo,
    'textColor': Colors.indigo,
  },
  {
    'label': 'Beautiful',
    'icon': Icon(Icons.photo_camera_outlined),
    'bgColor': Colors.pinkAccent,
    'borderColor': Colors.pink,
    'textColor': Colors.pink,
  },
  {
    'label': 'Cheerful',
    'icon': Icon(Icons.mood),
    'bgColor': Colors.orange,
    'borderColor': Colors.orange,
    'textColor': Colors.pink,
  },
  {
    'label': 'Content',
    'icon': Icon(Icons.tag_faces_outlined),
    'bgColor': Colors.purple,
    'borderColor': Colors.purple,
    'textColor': Colors.purple,
  },
  {
    'label': 'Cozy',
    'icon': Icon(Icons.fireplace_outlined),
    'bgColor': Colors.orangeAccent,
    'borderColor': Colors.red,
    'textColor': Colors.red,
  },
  {
    'label': 'Creative',
    'icon': Icon(Icons.brush_outlined),
    'bgColor': Colors.brown,
    'borderColor': Colors.brown,
    'textColor': Colors.brown,
  },
  {
    'label': 'Delighted',
    'icon': Icon(Icons.sentiment_very_satisfied_outlined),
    'bgColor': Colors.red,
    'borderColor': Colors.red,
    'textColor': Colors.red,
  },
  {
    'label': 'Empowered',
    'icon': Icon(Icons.rocket_outlined),
    'bgColor': Colors.deepOrange,
    'borderColor': Colors.deepOrange,
    'textColor': Colors.deepOrange,
  },
  {
    'label': 'Excited',
    'icon': Icon(Icons.sentiment_satisfied),
    'bgColor': Colors.amber,
    'borderColor': Colors.amber,
    'textColor': Colors.pink,
  },
  {
    'label': 'Free',
    'icon': Icon(Icons.wind_power_outlined),
    'bgColor': Colors.grey,
    'borderColor': Colors.grey,
    'textColor': Colors.grey,
  },
  {
    'label': 'Fulfilled',
    'icon': Icon(Icons.battery_charging_full_outlined),
    'bgColor': Colors.red,
    'borderColor': Colors.red,
    'textColor': Colors.red,
  },
  {
    'label': 'Glad',
    'icon': Icon(Icons.wb_sunny_outlined),
    'bgColor': Colors.pink,
    'borderColor': Colors.pink,
    'textColor': Colors.pink,
  },
  {
    'label': 'Grateful',
    'icon': Icon(Icons.handshake_outlined),
    'bgColor': Colors.teal,
    'borderColor': Colors.teal,
    'textColor': Colors.teal,
  },
  {
    'label': 'Hopeful',
    'icon': Icon(Icons.temple_hindu_outlined),
    'bgColor': Colors.cyan,
    'borderColor': Colors.cyan,
    'textColor': Colors.cyan,
  },
  {
    'label': 'Inspired',
    'icon': Icon(Icons.lightbulb_outline),
    'bgColor': Colors.blue,
    'borderColor': Colors.blue,
    'textColor': Colors.blue,
  },
  {
    'label': 'Loved',
    'icon': Icon(Icons.favorite_outline),
    'bgColor': Colors.brown,
    'borderColor': Colors.brown,
    'textColor': Colors.brown,
  },
  {
    'label': 'Proud',
    'icon': Icon(Icons.emoji_events_outlined),
    'bgColor': Colors.green,
    'borderColor': Colors.green,
    'textColor': Colors.green,
  },
  {
    'label': 'Purposeful',
    'icon': Icon(Icons.bolt_outlined),
    'bgColor': Colors.deepPurple,
    'borderColor': Colors.deepPurple,
    'textColor': Colors.deepPurple,
  },
  {
    'label': 'Relieved',
    'icon': Icon(Icons.thumb_up_alt_outlined),
    'bgColor': Colors.lime,
    'borderColor': Colors.lime,
    'textColor': Colors.lime,
  },
  {
    'label': 'Rich',
    'icon': Icon(Icons.euro_outlined),
    'bgColor': Colors.deepOrange,
    'borderColor': Colors.deepOrange,
    'textColor': Colors.pink,
  },
  {
    'label': 'Seen',
    'icon': Icon(Icons.visibility_outlined),
    'bgColor': Colors.grey,
    'borderColor': Colors.grey,
    'textColor': Colors.grey,
  },
  {
    'label': 'Tingly',
    'icon': Icon(Icons.vibration_outlined),
    'bgColor': Colors.indigoAccent,
    'borderColor': Colors.indigo,
    'textColor': Colors.indigo,
  },
];