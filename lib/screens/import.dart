import 'package:adiary/models/entry.dart';
import 'package:adiary/screens/alevated_button.dart';
import 'package:adiary/screens/styled_text.dart';
import 'package:flutter/material.dart';

class ImportData extends StatefulWidget {
  const ImportData({super.key});

  @override
  State<ImportData> createState() => _ImportDataState();
}

class _ImportDataState extends State<ImportData> {
  bool importing = false;

  Future<void> _import() async {
    setState(() {
      importing = true;
    });

    bool wasSuccess = false;
    try {
      EntryProvider entryProvider = EntryProvider();
      await entryProvider.import();
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
        ? CircularProgressIndicator()
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StyledText(
                    value:
                        'This will import your data from existing sqlite db.'),
                StyledText(
                    value:
                        'Choose the .db file you exported. If you do not see your exported .db file in the file picker, you can open the side drawer on it and choose file manager to select the .db file.'),
                StyledText(
                    value:
                        'If the password set on the exported .db file does not match with the password set on the app, it will not show anything.'),
                StyledText(
                    value:
                        'You can change the password in the app to match the password on exported .db file.'),
                StyledText(
                    value:
                        'Careful: Importing will override the existing data.'),
                StyledText(value: 'Begin import when ready.'),
                SizedBox(
                  height: 32,
                ),
                AlevatedButton(
                    onPressed: _import, icon: Icons.upload, text: 'Import'),
              ],
            ),
          );
  }
}
