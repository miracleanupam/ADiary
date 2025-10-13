import 'package:adiary/screens/alevated_button.dart';
import 'package:adiary/screens/styled_text.dart';
import 'package:adiary/services/notification.dart';
import 'package:adiary/services/storages.dart';
import 'package:flutter/material.dart';

class NotificationManager extends StatefulWidget {
  const NotificationManager({super.key});

  @override
  State<NotificationManager> createState() => _NotificationManagerState();
}

class _NotificationManagerState extends State<NotificationManager> {
  final Storages _storages = Storages();
  final NotificationService _notificationService = NotificationService();
  bool _currentStatus = true;
  late String _currentHour = "20";
  late String _currentMinute = "30";

  @override
  void initState() {
    super.initState();
    _loadDataFromStorages();
  }

  Future<void> _loadDataFromStorages() async {
    bool recordedNotificationStatus = await _storages.readNotificationStatus();
    var (recordedHour, recordedMinute) = await _storages.readNotificationTime();

    setState(() {
      _currentStatus = recordedNotificationStatus;
      _currentHour = recordedHour ?? _currentHour.padLeft(2, '0');
      _currentMinute = recordedMinute ?? _currentMinute.padLeft(2, '0');
    });
  }

  void handleNotificationToggle(bool newStatus) async {
    setState(() {
      _currentStatus = newStatus;
    });

    _storages.writeNotificationStatus(newStatus);
    if (newStatus) {
      _notificationService.scheduleNotification(
          hour: _currentHour, minute: _currentMinute);
    } else {
      _notificationService.cancelNotifications();
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked == null) return;

    _storages.writeNotificationTime(picked.hour, picked.minute);
    setState(() {
      _currentHour = picked.hour.toString().padLeft(2, '0');
      _currentMinute = picked.minute.toString().padLeft(2, '0');
    });

    _notificationService.scheduleNotification(
        hour: picked.hour.toString(), minute: picked.minute.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: _currentStatus
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StyledText(
                        value:
                            "** If no notification is received, ensure battery optimization for the app is disabled and the app is not put to sleep by the OS.",
                        fontSize: 16,
                        color: Colors.pink.shade300,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      StyledText(
                          value:
                              "Currently Selected Time: $_currentHour:$_currentMinute"),
                      AlevatedButton(
                          onPressed: () => _selectTime(context),
                          icon: Icons.lock_clock_rounded,
                          text: "Set New Time"),
                    ],
                  )
                : SizedBox(
                    height: 1,
                  ),
          ),
          SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Align(
                  alignment: AlignmentGeometry.centerLeft,
                  child: StyledText(value: 'Please, remind me...'),
                ),
              ),
              Switch(value: _currentStatus, onChanged: handleNotificationToggle)
            ],
          ),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
