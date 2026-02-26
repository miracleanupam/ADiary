import 'package:adiary/compnents/bar_chart.dart';
import 'package:adiary/compnents/line_chart.dart';
import 'package:adiary/compnents/word_cloud.dart';
import 'package:adiary/models/entry.dart';
import 'package:flutter/material.dart';

class Visualization extends StatefulWidget {
  const Visualization({super.key});

  @override
  State<Visualization> createState() => _VisualizationState();
}

class _VisualizationState extends State<Visualization> {
  bool hasRecords = false;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    final count = await EntryProvider().getCount();
    setState(() {
      hasRecords = count > 0 ? true : false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: hasRecords ? SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16,),
            BarChart(),
            Divider(),
            SizedBox(height: 16,),
            LineChart(),
            Divider(),
            SizedBox(height: 16,),
            WordCloud()
          ],
        ),
      ) : Center(
        child: Text("No data to visualize yet!!! :("),
      ),
    );
  }
}
