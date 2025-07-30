/* import 'dart:convert';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduledAlarmsScreen extends StatefulWidget {
  const ScheduledAlarmsScreen({Key? key}) : super(key: key);

  @override
  State<ScheduledAlarmsScreen> createState() => _ScheduledAlarmsScreenState();
}

class _ScheduledAlarmsScreenState extends State<ScheduledAlarmsScreen> {
  List<Map<String, dynamic>> scheduled = [];

  Future<void> loadScheduledAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('scheduledAlarms');
    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data);
      setState(() {
        scheduled = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      });
    }
  }

  Future<void> cancelOneAlarm(int id) async {
    await AndroidAlarmManager.cancel(id);
    setState(() {
      scheduled.removeWhere((alarm) => alarm['id'] == id);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('scheduledAlarms', jsonEncode(scheduled));
    Fluttertoast.showToast(msg: "🚫 Cancelled alarm $id");
  }

  @override
  void initState() {
    super.initState();
    loadScheduledAlarms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📋 Scheduled Alarms')),
      body: scheduled.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.notifications_off, size: 100, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'No scheduled alarms found.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: scheduled.length,
              itemBuilder: (context, index) {
                final alarm = scheduled[index];
                final time = DateTime.parse(alarm['time']);
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    title: Text(
                      alarm['subject'],
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          alarm['topic'],
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}  on  ${_dayName(time.weekday)}",
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      tooltip: 'Cancel Alarm',
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () => cancelOneAlarm(alarm['id']),
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _dayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[weekday - 1];
  }
}
 */