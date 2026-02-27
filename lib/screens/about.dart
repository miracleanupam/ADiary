import 'package:adiary/screens/styled_text.dart';
import 'package:flutter/material.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: const StyledText(value: 'For Prinsu. With Love'));
  }
}
