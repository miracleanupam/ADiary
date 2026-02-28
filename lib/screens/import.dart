import 'package:adiary/constants.dart';
import 'package:adiary/models/entry.dart';
import 'package:adiary/compnents/alevated_button.dart';
import 'package:adiary/compnents/styled_text.dart';
import 'package:flutter/material.dart';

class ImportData extends StatefulWidget {
  const ImportData({super.key});

  @override
  State<ImportData> createState() => _ImportDataState();
}

class _ImportDataState extends State<ImportData> {
  bool importing = false;
  final ScrollController scrollController = ScrollController();

  Future<void> _import() async {
    setState(() {
      importing = true;
    });

    bool wasSuccess = false;
    try {
      await EntryProvider().import();
      wasSuccess = true;
    } catch (_) {
    } finally {
      setState(() {
        importing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(wasSuccess
                  ? 'Successfully Imported'
                  : 'Something went wrong...'),
              duration: Duration(seconds: 8)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return importing
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: RawScrollbar(
                      controller: scrollController,
                      thumbVisibility: true,
                      thickness: 1,
                      thumbColor: Theme.of(context).colorScheme.primary,
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 2,
                          children: [
                            StyledText(
                                value:
                                    'This will import your data from existing .zip file.'),
                            StyledText(
                                value: 'Choose the .zip file you exported.'),
                            StyledText(
                                value:
                                    'If the password set on the app when the the .zip was exported does not match with the current password set on this app, it will not show anything.'),
                            StyledText(
                                value:
                                    'You can change the password in the app to match the password on exported file.'),
                            StyledText(
                                fontSize: 36,
                                color: PinkColors.shade300,
                                value:
                                    'Careful: Importing will override the existing data.'),
                            StyledText(value: 'Begin import when ready...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 16,
                      ),
                      AlevatedButton(
                          onPressed: _import,
                          icon: Icons.upload,
                          text: 'Import'),
                      SizedBox(
                        height: 16,
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
