import 'package:adiary/constants.dart';
import 'package:adiary/models/entry_notifier.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      EntryNotifierScope.of(context).refresh();
    });
  }

  void _navigate(Widget screen) async {
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

    final notifier = EntryNotifierScope.of(context);

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
                  text: ' ${notifier.count}',
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
            onPressed: () => _navigate(AddEntry()),
            icon: Icons.add,
            text: 'Add More',
          ),
          AlevatedButton(
            onPressed: () => _navigate(DisplayEntry()),
            icon: Icons.sentiment_very_satisfied,
            text: 'Go down the memory lane',
          ),
        ],
      ),
    );
  }
}
