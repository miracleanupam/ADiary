import 'package:adiary/constants.dart';
import 'package:adiary/models/entry.dart';
import 'package:adiary/screens/add_entry.dart';
import 'package:adiary/compnents/alevated_button.dart';
import 'package:adiary/screens/display_entry.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _entryCount = 0;

  @override
  void initState() {
    super.initState();
    _refreshCount();
  }

  Future<void> _refreshCount() async {
    final count = await EntryProvider().getCount();
    if (mounted) setState(() => _entryCount = count);
  }

  void _navigate(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final headingStyle = TextStyle(
      fontSize: 32,
      color: PinkColors.shade900,
      fontFamily: 'IndieFlower',
      fontWeight: FontWeight.bold,
    );

    final blossomShadow = Shadow(
      color: PinkColors.shade900,
      blurRadius: 10,
      offset: Offset.zero,
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Blossom header
          Text(
            '🌸',
            style: headingStyle.copyWith(shadows: [blossomShadow]),
          ),
          const SizedBox(height: 32),

          // Entry count
          Text.rich(
            TextSpan(
              text: 'You have collected',
              style: headingStyle,
              children: [
                TextSpan(
                  text: ' $_entryCount',
                  style: TextStyle(color: PinkColors.shade600),
                ),
                const TextSpan(text: ' good memories so far...'),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Blossom footer
          Text(
            '🌸🌸🌸',
            style: headingStyle.copyWith(shadows: [blossomShadow]),
          ),
          const SizedBox(height: 64),

          // Actions
          AlevatedButton(
            onPressed: () => _navigate(AddEntry(fn: _refreshCount)),
            icon: Icons.add,
            text: 'Add More',
          ),
          AlevatedButton(
            onPressed: () => _navigate(DisplayEntry(fn: _refreshCount)),
            icon: Icons.sentiment_very_satisfied,
            text: 'Go down the memory lane',
          ),
        ],
      ),
    );
  }
}