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
  bool _hasRecords = false;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    final count = await EntryProvider().getCount();
    if (mounted) setState(() => _hasRecords = count > 0);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _hasRecords ? _buildCharts() : _buildEmptyState(),
    );
  }

  Widget _buildCharts() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          const BarChart(),
          const Divider(),
          const SizedBox(height: 16),
          const LineChart(),
          const Divider(),
          const SizedBox(height: 16),
          const WordCloud(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text('No data to visualize yet!!'),
    );
  }
}