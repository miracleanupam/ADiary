import 'package:adiary/compnents/styled_text.dart';
import 'package:adiary/constants.dart';
import 'package:adiary/services/storages.dart';
import 'package:adiary/services/work_manager.dart';
import 'package:flutter/material.dart';

class NotificationManager extends StatefulWidget {
  const NotificationManager({super.key});

  @override
  State<NotificationManager> createState() => _NotificationManagerState();
}

class _NotificationManagerState extends State<NotificationManager> {
  final Storages _storages = Storages();

  // ─── State ────────────────────────────────────────────────────────────────
  bool _masterEnabled = true;
  bool _streakEnabled = true;
  bool _memoryEnabled = true;
  bool _weeklyEnabled = true;
  String _hour = '20';
  String _minute = '30';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // ─── Load ─────────────────────────────────────────────────────────────────

  Future<void> _loadPreferences() async {
    final master = await _storages.readNotificationStatus();
    final streak = await _storages.readStreakNotificationEnabled();
    final memory = await _storages.readMemoryNotificationEnabled();
    final weekly = await _storages.readWeeklyNotificationEnabled();
    final (hour, minute) = await _storages.readNotificationTime();

    setState(() {
      _masterEnabled = master;
      _streakEnabled = streak;
      _memoryEnabled = memory;
      _weeklyEnabled = weekly;
      _hour = hour ?? '20';
      _minute = minute ?? '30';
      _isLoading = false;
    });
  }

  // ─── Handlers ─────────────────────────────────────────────────────────────

  Future<void> _onMasterToggle(bool value) async {
    setState(() => _masterEnabled = value);
    await _storages.writeNotificationStatus(value);
    await WorkmanagerService.syncWithPreferences();
  }

  Future<void> _onStreakToggle(bool value) async {
    setState(() => _streakEnabled = value);
    await _storages.writeStreakNotificationEnabled(value);
    await WorkmanagerService.syncWithPreferences();
  }

  Future<void> _onMemoryToggle(bool value) async {
    setState(() => _memoryEnabled = value);
    await _storages.writeMemoryNotificationEnabled(value);
    await WorkmanagerService.syncWithPreferences();
  }

  Future<void> _onWeeklyToggle(bool value) async {
    setState(() => _weeklyEnabled = value);
    await _storages.writeWeeklyNotificationEnabled(value);
    await WorkmanagerService.syncWithPreferences();
  }

  Future<void> _onSelectStreakTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.tryParse(_hour) ?? 20,
        minute: int.tryParse(_minute) ?? 30,
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(1.0), // Prevent text scaling issues
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;

    setState(() {
      _hour = picked.hour.toString().padLeft(2, '0');
      _minute = picked.minute.toString().padLeft(2, '0');
    });

    // Persists the new time and reschedules only the streak task
    await WorkmanagerService.rescheduleStreak(
        hour: picked.hour,
        minute: picked.minute,
        password: await _storages.readSavedPassword());
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Battery optimisation warning ──────────────────────────
                    StyledText(
                      value:
                          '** If no notification is received, ensure battery optimization for the app is disabled and the app is not put to sleep by the OS. **',
                      fontSize: 16,
                      color: PinkColors.shade300,
                    ),
                    const SizedBox(height: 24),
              
                    // ── Individual toggles (only visible when master is on) ───
                    _SectionHeader(title: 'Notification Types'),
                    const SizedBox(height: 8),
                    Divider(),
                    _NotificationRow(
                      title: 'Daily Streak Reminder',
                      subtitle: 'Reminds you to log a happy moment each day',
                      value: _streakEnabled,
                      enabled: _masterEnabled,
                      onChanged: _onStreakToggle,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          StyledText(
                            value: 'Remind me at: $_hour:$_minute',
                            fontSize: 16,
                          ),
                          // const SizedBox(height: 4),
                          ElevatedButton(
                            onPressed: (_masterEnabled && _streakEnabled)
                                ? () => _onSelectStreakTime(context)
                                : null,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: PinkColors.shade200,
                                foregroundColor: PinkColors.shade900,
                                iconColor: PinkColors.shade900,
                                textStyle:
                                    TextStyle(color: PinkColors.shade900)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.autorenew),
                                const SizedBox(width: 5),
                                Text("Change"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Divider(),
              
                    _NotificationRow(
                      title: 'Daily Memory',
                      subtitle:
                          'Revisit a moment from 1 year ago if there is one',
                      value: _memoryEnabled,
                      enabled: _masterEnabled,
                      onChanged: _onMemoryToggle,
                    ),
              
                    Divider(),
                    _NotificationRow(
                      title: 'Weekly Recap',
                      subtitle: 'Summary of your happy moments last week',
                      value: _weeklyEnabled,
                      enabled: _masterEnabled,
                      onChanged: _onWeeklyToggle,
                    ),
              
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // ── Master toggle (always visible at the bottom) ─────────────────
          Row(
            children: [
              Expanded(child: StyledText(value: 'Please, remind me...')),
              Switch(value: _masterEnabled, onChanged: _onMasterToggle),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─── Helper widgets ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return StyledText(
      value: title,
      fontSize: 32,
    );
  }
}

/// A single notification type row with title, subtitle and a toggle switch.
class _NotificationRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _NotificationRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StyledText(value: title),
                StyledText(
                  value: subtitle,
                  fontSize: 14,
                  color: PinkColors.shade300,
                  align: TextAlign.start,
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: enabled ? onChanged : null),
        ],
      ),
    );
  }
}
