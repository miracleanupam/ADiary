import 'package:adiary/screens/about.dart';
import 'package:adiary/screens/dashboard.dart';
import 'package:adiary/screens/export.dart';
import 'package:adiary/screens/import.dart';
import 'package:adiary/screens/password.dart';
// import 'package:flutter/material.dart';

const homePageWidgetListsForDrawer = {
  'dashboard': Dashboard(),
  'export': ExportData(),
  'import': ImportData(),
  'about': About(),
  'password': PasswordManager(),
};

const homePageWidgetTitleListsForAppBar = <String, String>{
  'dashboard': 'ADiary, Get it? It\'s a Pun!!',
  'export': 'Yeah gorl, back it all up..',
  'import': 'Gorl, I got your back...',
  'about': 'Why this? You ask?',
  'password': 'Sshh! Keep this a secret!!'
};

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
