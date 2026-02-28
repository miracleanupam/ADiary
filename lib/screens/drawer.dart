import 'package:adiary/constants.dart';
import 'package:flutter/material.dart';

class ADrawer extends StatefulWidget {
  final Function onTapCallback;
  final String selectedItem;

  const ADrawer({
    super.key,
    required this.onTapCallback,
    required this.selectedItem,
  });

  @override
  State<ADrawer> createState() => _ADrawerState();
}

class _ADrawerState extends State<ADrawer> {
  late String _currentSelection;

  // ─── Config ───────────────────────────────────────────────────────────────

  static const _navItems = [
    [
      {'id': 'dashboard', 'label': 'Home', 'icon': Icons.home},
      {'id': 'summary', 'label': 'Summary', 'icon': Icons.summarize},
      {'id': 'visualization', 'label': 'Visualization', 'icon': Icons.bar_chart},
    ],
    [
      {'id': 'notification', 'label': 'Notification', 'icon': Icons.notification_important},
      {'id': 'export', 'label': 'Export Data', 'icon': Icons.download},
      {'id': 'import', 'label': 'Import Data', 'icon': Icons.upload},
    ],
    [
      {'id': 'password', 'label': 'Password', 'icon': Icons.key},
    ],
    [
      {'id': 'about', 'label': 'About App', 'icon': Icons.info},
    ],
  ];

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _currentSelection = widget.selectedItem;
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  void _onSelect(String id) {
    setState(() => _currentSelection = id);
    widget.onTapCallback(id);
    Navigator.pop(context);
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          _buildHeader(),
          for (final group in _navItems) ...[
            ..._buildGroup(group),
            const Divider(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: PinkColors.shade200,
        image: DecorationImage(
          opacity: 0.8,
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(PinkColors.shade200, BlendMode.color),
          image: const AssetImage('assets/images/drawer_header_background.png'),
        ),
      ),
      child: Container(
        alignment: Alignment.bottomLeft,
        child: Text(
          'xoxo',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: PinkColors.shade900,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGroup(List<Map<String, Object>> items) {
    return items
        .map((item) => ListTile(
              leading: Icon(item['icon'] as IconData),
              title: Text(item['label'] as String),
              selected: _currentSelection == item['id'],
              onTap: () => _onSelect(item['id'] as String),
            ))
        .toList();
  }
}