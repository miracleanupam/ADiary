import 'package:adiary/models/entry.dart';
import 'package:adiary/screens/alevated_button.dart';
import 'package:adiary/screens/styled_text.dart';
import 'package:flutter/material.dart';

class ExportData extends StatefulWidget {
  const ExportData({super.key});

  @override
  State<ExportData> createState() => _ExportDataState();
}

class _ExportDataState extends State<ExportData> {
  bool exporting = false;
  final ScrollController scrollController = ScrollController();

  Future<void> _export() async {
    setState(() {
      exporting = true;
    });

    try {
      EntryProvider entryProvider = EntryProvider();
      String exportedPath = await entryProvider.export();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Exported to $exportedPath"),
              duration: Duration(seconds: 8)),
        );
      }
    } catch (_) {
    } finally {
      setState(() {
        exporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return exporting
        ? CircularProgressIndicator()
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
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 2,
                          children: [
                            StyledText(
                                value:
                                    'This will export your data to a sqlite database. It will be encrypted with the password you set on the application.'),
                            StyledText(
                                value:
                                    'If you do not remember the password, you can change it from the drawer.'),
                            StyledText(value: 'Begin export when ready.'),                 
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
                          onPressed: _export,
                          icon: Icons.download,
                          text: 'Export'),
                    ],
                  ),
                )
              ],
            ),
          );
  }
}
