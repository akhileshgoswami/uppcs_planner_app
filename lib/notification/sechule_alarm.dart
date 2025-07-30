/* import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:uppcs_app/main.dart';
import 'package:uppcs_app/notification/alarm_list.dart';

class SechuleAlaramPage extends StatelessWidget {
  const SechuleAlaramPage({super.key});

  Future<void> openAlarmPermissionSettings() async {
    if (Platform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      final version = info.version.sdkInt;
      if (version >= 31) {
        final intent = AndroidIntent(
          action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
        );
        await intent.launch();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Study Alarm App')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          ElevatedButton(
            onPressed: () async {
              await openAlarmPermissionSettings();
              await scheduleAlarms();
            },
            child: const Text('📅 Schedule Alarms This Week'),
          ),
          ElevatedButton(
            onPressed: () async {
              await scheduleAlarms(nextWeek: true);
            },
            child: const Text('📆 Schedule Alarms Next Week'),
          ),
          ElevatedButton(
            onPressed: () => stopCurrentAlarm(),
            child: const Text('🔕 Stop Current Alarm'),
          ),
          ElevatedButton(
            onPressed: () => cancelAllAlarms(),
            child: const Text('❌ Cancel All Alarms'),
          ),
          SizedBox(
            height: 50,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ScheduledAlarmsScreen()),
              );
            },
            child: const Text('📋 View/Cancel Scheduled Alarms'),
          ),
        ]),
      ),
    );
  }
}
 */