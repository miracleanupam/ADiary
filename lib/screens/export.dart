import 'package:adiary/models/entry.dart';
import 'package:adiary/screens/styled_text.dart';
import 'package:flutter/material.dart';

class ExportData extends StatefulWidget {
  const ExportData({super.key});

  @override
  State<ExportData> createState() => _ExportDataState();
}

class _ExportDataState extends State<ExportData> {
  bool exporting = false;

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
              StyledText(value: 'This will exported your data to a sqlite database. It will be encrypted with the password you set on the application.'),
              StyledText(value: 'If you do not remember the password, you can change it from the drawer.'),
              StyledText(value: 'Begin export when ready.'),
              SizedBox(height: 32,),
              ElevatedButton(
                  onPressed: _export,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.download),
                      Text('Export'),
                    ],
                  ),
                ),
            ],
          ),
        );
  }
}
