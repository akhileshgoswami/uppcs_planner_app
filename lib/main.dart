// main.dart
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uppcs_app/data_base_helper.dart';
import 'package:uppcs_app/edit_comment.dart';
import 'package:uppcs_app/notification/alarm_list.dart';
import 'package:uppcs_app/time_table/weekly_plan_page.dart';
import 'package:uppcs_app/todo_controller.dart';
import 'package:uppcs_app/todo_model.dart';
import 'master_page.dart';

/* 
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
const String alarmPlayerId = 'alarm_player';

/* final Map<String, dynamic> timeTable = {
  "plan": [
    {
      "day": "Monday",
      "slots": [
        {
          "time": "07:00 - 08:00",
          "subject": "Polity",
          "topic": "Constitution Basics & FRs"
        },
        {
          "time": "08:00 - 09:00",
          "subject": "History",
          "topic": "Modern India (1857–1905)"
        },
        {
          "time": "18:00 - 19:00",
          "subject": "Geography",
          "topic": "Physical Geography"
        },
        {
          "time": "19:00 - 20:00",
          "subject": "Economy",
          "topic": "Basic Concepts + GDP"
        }
      ]
    },
    {
      "day": "Tuesday",
      "slots": [
        {
          "time": "07:00 - 08:00",
          "subject": "Polity",
          "topic": "Parliament & State Legislature"
        },
        {
          "time": "08:00 - 09:00",
          "subject": "History",
          "topic": "Ancient India – Vedic Age"
        },
        {
          "time": "18:00 - 19:00",
          "subject": "Geography",
          "topic": "Indian Geography – Rivers"
        },
        {
          "time": "19:00 - 20:00",
          "subject": "Environment",
          "topic": "Biodiversity + Conservation"
        }
      ]
    },
    {
      "day": "Wednesday",
      "slots": [
        {
          "time": "07:00 - 08:00",
          "subject": "Polity",
          "topic": "Judiciary + Emergency"
        },
        {
          "time": "08:00 - 09:00",
          "subject": "History",
          "topic": "Freedom Struggle – 1905–1920"
        },
        {
          "time": "18:00 - 19:00",
          "subject": "Geography",
          "topic": "Climate + Soils of India"
        },
        {
          "time": "19:00 - 20:00",
          "subject": "Science & Tech",
          "topic": "Physics + Space Basics"
        }
      ]
    },
    {
      "day": "Thursday",
      "slots": [
        {
          "time": "07:00 - 08:00",
          "subject": "Polity",
          "topic": "Governance + RTI + Lokpal"
        },
        {
          "time": "08:00 - 09:00",
          "subject": "History",
          "topic": "Art & Culture – Architecture"
        },
        {
          "time": "18:00 - 19:00",
          "subject": "Geography",
          "topic": "Agriculture + Cropping Patterns"
        },
        {
          "time": "19:00 - 20:00",
          "subject": "Budget & Schemes",
          "topic": "Latest Union Budget & Major Schemes"
        }
      ]
    },
    {
      "day": "Friday",
      "slots": [
        {
          "time": "07:00 - 08:00",
          "subject": "Polity",
          "topic": "Amendments + Constitution Bodies"
        },
        {
          "time": "08:00 - 09:00",
          "subject": "History",
          "topic": "Post-Independence India"
        },
        {
          "time": "18:00 - 19:00",
          "subject": "Geography",
          "topic": "Minerals + Industries"
        },
        {
          "time": "19:00 - 20:00",
          "subject": "Economy",
          "topic": "Inflation + Banking"
        }
      ]
    },
    {
      "day": "Saturday",
      "slots": [
        {
          "time": "07:00 - 08:00",
          "subject": "Polity",
          "topic": "Test & Revision"
        },
        {"time": "08:00 - 09:00", "subject": "History", "topic": "PYQs + Mock"},
        {
          "time": "18:00 - 19:00",
          "subject": "Geography",
          "topic": "Map Practice + Location Revision"
        },
        {
          "time": "19:00 - 20:00",
          "subject": "General Science",
          "topic": "Biology Basics"
        }
      ]
    },
    {
      "day": "Sunday",
      "slots": [
        {
          "time": "07:00 - 08:00",
          "subject": "Ethics",
          "topic": "Basic Terms + Examples"
        },
        {
          "time": "08:00 - 09:00",
          "subject": "Essay",
          "topic": "Practice Essay Writing"
        },
        {
          "time": "18:00 - 19:00",
          "subject": "Geography",
          "topic": "Current Affairs Based Geography"
        },
        {
          "time": "19:00 - 20:00",
          "subject": "Current Affairs",
          "topic": "Weekly National + State News"
        }
      ]
    }
  ]
};
 */

final Map<String, dynamic> timeTable = {
  "plan": [
    {
      "day": DateFormat('EEEE')
          .format(DateTime.now()), // "Monday", "Tuesday", etc.
      "slots": List.generate(5, (i) {
        final now = DateTime.now();
        final start = now.add(Duration(minutes: i * 2));
        final end = start.add(Duration(minutes: 2));
        final timeStr =
            "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} - ${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}";
        return {
          "time": timeStr,
          "subject": "Test Subject $i",
          "topic": "Test Topic $i"
        };
      }),
    }
  ]
};

@pragma('vm:entry-point')
void ringAlarm(int id, Map<String, dynamic> params) async {
  final subject = params['subject'] ?? '📚 Study Time';
  final topic = params['topic'] ?? 'No topic';

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'alarm_channel',
    'Alarm Notifications',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
    playSound: false,
  );

  const NotificationDetails platformDetails =
      NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0,
    '⏰ $subject',
    'Topic: $topic',
    platformDetails,
  );

  final player = AudioPlayer();
  final dir = await getApplicationDocumentsDirectory();
  final path = '${dir.path}/alarm_sound.mp3';

  if (File(path).existsSync()) {
    await player.setReleaseMode(ReleaseMode.loop);
    await player.setSourceDeviceFile(path);
    await player.resume();
    print("🔔 Playing alarm from: $path");
  } else {
    print("❌ Alarm sound not found at: $path");
  }
}

Future<void> _initNotifications() async {
  const initSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final settings = InitializationSettings(android: initSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
    if (response.payload == 'STOP_ALARM') {
      final player = AudioPlayer(playerId: alarmPlayerId);
      await player.stop();
      Fluttertoast.showToast(msg: "⛔ Alarm stopped");
    }
  });
}

Future<void> copyAlarmSoundToFile() async {
  final byteData = await rootBundle.load('assets/alarm_sound.mp3');

  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/alarm_sound.mp3');

  if (!await file.exists()) {
    await file.writeAsBytes(byteData.buffer.asUint8List());
    print("✅ Copied alarm sound to: ${file.path}");
  } else {
    print("ℹ️ Alarm sound already exists at: ${file.path}");
  }
}

Future<void> scheduleAlarms({bool nextWeek = false}) async {
  final weekdayMap = {
    'Monday': 1,
    'Tuesday': 2,
    'Wednesday': 3,
    'Thursday': 4,
    'Friday': 5,
    'Saturday': 6,
    'Sunday': 7,
  };

  final prefs = await SharedPreferences.getInstance();
  final now = DateTime.now();
  List<Map<String, dynamic>> scheduled = [];

  for (final day in timeTable['plan']) {
    final slots = day['slots'];
    final weekday = weekdayMap[day['day']]!;

    // Skip if not nextWeek and the day has already passed this week
    if (!nextWeek && weekday < now.weekday) {
      continue;
    }

    for (final slot in slots) {
      final parts = slot['time'].split(' - ')[0].split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      DateTime alarmTime = DateTime(now.year, now.month, now.day, hour, minute);

      // Adjust to correct weekday in current or next week
      while (alarmTime.weekday != weekday) {
        alarmTime = alarmTime.add(const Duration(days: 1));
      }

      if (nextWeek || alarmTime.isBefore(now)) {
        alarmTime = alarmTime.add(const Duration(days: 7));
      }

      final alarmKey = '${day['day']}_${slot['time']}_${slot['subject']}';
      final alarmId = alarmKey.hashCode & 0x7FFFFFFF;

      await AndroidAlarmManager.oneShotAt(
        alarmTime,
        alarmId,
        ringAlarm,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
        params: {
          'subject': slot['subject'],
          'topic': slot['topic'],
        },
      );
      log("Scheduled alarm at: $alarmTime with ID: $alarmId");

      scheduled.add({
        'id': alarmId,
        'time': alarmTime.toIso8601String(),
        'subject': slot['subject'],
        'topic': slot['topic'],
      });
    }
  }

  await prefs.setString('scheduledAlarms', jsonEncode(scheduled));
  Fluttertoast.showToast(msg: "✅ Alarms scheduled for this week!");
}

Future<void> cancelAllAlarms() async {
  final prefs = await SharedPreferences.getInstance();
  final data = prefs.getString('scheduledAlarms');
  if (data != null) {
    final alarms = jsonDecode(data);
    for (final alarm in alarms) {
      await AndroidAlarmManager.cancel(alarm['id']);
    }
    await prefs.remove('scheduledAlarms');
    Fluttertoast.showToast(msg: "❌ Alarms cancelled");
  }
}

Future<void> stopCurrentAlarm() async {
  final player = AudioPlayer(playerId: alarmPlayerId);
  await player.stop();
  Fluttertoast.showToast(msg: "🛑 Alarm stopped manually");
}

Future<void> mannualAlarmtest() async {
  final now = DateTime.now();
  final alarmTime = now.add(const Duration(seconds: 60)); // 2 minutes from now
  const alarmId = 123456; // Use a unique ID or generate one

  await AndroidAlarmManager.oneShotAt(
    alarmTime,
    alarmId,
    ringAlarm, // Your callback function
    exact: true,
    wakeup: true,
    rescheduleOnReboot: true,
    params: {
      'subject': "History",
      'topic': "Chapter Topic",
    },
  );

  log("Scheduled alarm at: $alarmTime with ID: $alarmId");
}
 */
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestAndOpenNotificationPermission();
  // Request permission before DB access
  await TodoDatabase.instance.requestStoragePermission();
  await TodoDatabase.instance.database;
  // await copyAlarmSoundToFile();
  // await AndroidAlarmManager.initialize();
  // await _initNotifications();
  // await checkAndRequestBatteryOptimizationPermission();
  Get.put(TodoController());

  runApp(UPPCSPlannerApp());
}

/* Future<void> checkAndRequestBatteryOptimizationPermission() async {
  final isIgnoring =
      await DisableBatteryOptimization.isAllBatteryOptimizationDisabled;

  if (!isIgnoring!) {
    final success = await DisableBatteryOptimization
        .showDisableBatteryOptimizationSettings();
    if (success!) {
      print("✅ User opened battery optimization settings.");
    } else {
      print("❌ Failed to open battery optimization settings.");
    }
  } else {
    print("✅ Battery optimization already disabled for this app.");
  }
}
 */
Future<void> requestAndOpenNotificationPermission() async {
  if (Platform.isAndroid) {
    final status = await Permission.notification.status;

    if (status.isGranted) {
      print("✅ Notification permission already granted.");
      return;
    }

    final result = await Permission.notification.request();

    if (result.isDenied || result.isPermanentlyDenied) {
      // Open settings to let the user enable it manually
      openAppSettings();
      return;
    }
  } else if (Platform.isIOS) {
    final result = await Permission.notification.request();
    if (result.isDenied || result.isPermanentlyDenied) {
      await openAppSettings();
    }
  }
}

class UPPCSPlannerApp extends StatelessWidget {
  final ColorScheme customColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF3949AB),
    onPrimary: Colors.white,
    secondary: Color(0xFF546E7A),
    onSecondary: Colors.white,
    error: Colors.redAccent,
    onError: Colors.white,
    background: Color(0xFFF7F9FB),
    onBackground: Colors.black,
    surface: Colors.white,
    onSurface: Colors.black,
  );

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UPPCS Subject Planner',
      theme: ThemeData(
        colorScheme: customColorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: customColorScheme.background,
        textTheme: GoogleFonts.poppinsTextTheme(),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: customColorScheme.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: customColorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        ),
      ),
      home: DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(16), bottomRight: Radius.circular(16)),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueGrey,
              ),
              child: Text(
                '📚 Study Planner',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            /*     ListTile(
              leading: const Icon(Icons.alarm_add),
              title: const Text('Add Schedule Alarms'),
              onTap: () async {
                Navigator.pop(context);
                await openAlarmPermissionSettings();
                await scheduleAlarms();
              },
            ),
            ListTile(
              leading: const Icon(Icons.alarm_add),
              title: const Text('Schedule Alarms for Next Week'),
              onTap: () async {
                Navigator.pop(context);
                await openAlarmPermissionSettings();
                await scheduleAlarms(nextWeek: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.view_list),
              title: const Text('View Scheduled Alarms'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ScheduledAlarmsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Stop Current Alarms'),
              onTap: () async {
                Navigator.pop(context);
                await stopCurrentAlarm();
              },
            ),
            /* kDebugMode
                ?  */
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Start Current Alarms'),
              onTap: () async {
                Navigator.pop(context);
                await mannualAlarmtest();
              },
            ) /*  : SizedBox() */,
         */
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('UPPCS Planner'),
        actions: [
          IconButton(
            icon: Icon(Icons.timelapse_rounded),
            onPressed: () => Get.to(() => WeeklyPlanPage())!.then((va) {
              Get.find<TodoController>().loadData();
            }),
          ),
          IconButton(
            icon: Icon(Icons.library_add),
            onPressed: () => Get.to(() => MasterEntryPage())!.then((va) {
              Get.find<TodoController>().loadData();
            }),
          )
        ],
      ),
      body: SubjectTodoPage(),
    );
  }

  Future<void> openAlarmPermissionSettings() async {
    if (!Platform.isAndroid) return;

    final info = await DeviceInfoPlugin().androidInfo;
    final sdkInt = info.version.sdkInt;

    if (sdkInt >= 31) {
      final status = await Permission.scheduleExactAlarm.status;

      if (status.isGranted) {
        // Permission already granted, no need to open settings
        print("✅ Exact alarm permission already granted.");
        return;
      }

      // Not granted, open settings
      final intent = AndroidIntent(
        action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
      );
      await intent.launch();
    }
  }
}

class SubjectTodoPage extends StatelessWidget {
  final controller = Get.find<TodoController>();

  void _showCommentBottomSheet(BuildContext context, TodoItem item) {
    final textController = TextEditingController(text: item.comment);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 24,
          left: 24,
          right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.comment,
                    color: Theme.of(context).colorScheme.primary),
                SizedBox(width: 8),
                Text('Edit Comment',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: 'Add your comment...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              maxLines: 4,
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.save),
                label: Text('Save'),
                onPressed: () async {
                  await controller.updateComment(item, textController.text);
                  Navigator.pop(context);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final allItems = controller.todoItems;

      final grouped = <String, Map<String, List<TodoItem>>>{};
      for (var item in allItems) {
        grouped[item.subject] ??= {};
        grouped[item.subject]![item.task] ??= [];
        grouped[item.subject]![item.task]!.add(item);
      }

      return ListView(
        padding: EdgeInsets.all(4),
        children: grouped.isEmpty
            ? [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 300),
                    Icon(
                      Icons.menu_book, // Or Icons.subject, Icons.add_box, etc.
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Please add subject",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () =>
                          Get.to(() => MasterEntryPage())!.then((va) {
                        Get.find<TodoController>().loadData();
                      }),
                      child: SizedBox(
                        width: Get.width * 0.4,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                            Text("Add Subject"),
                          ],
                        ),
                      ),
                    )
                  ],
                )
              ]
            : grouped.entries.map((subjectEntry) {
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        childrenPadding: EdgeInsets.zero,
                        collapsedBackgroundColor: Colors.transparent,
                        backgroundColor: Colors.transparent,
                        maintainState: true,
                        title: Text(
                          subjectEntry.key,
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 18),
                        ),
                        children: subjectEntry.value.entries.map((taskEntry) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: ExpansionTile(
                              tilePadding: EdgeInsets.zero,
                              childrenPadding: EdgeInsets.zero,
                              collapsedBackgroundColor: Colors.transparent,
                              backgroundColor: Colors.transparent,
                              maintainState: true,
                              title: Text(
                                taskEntry.key,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                              children: taskEntry.value.map((item) {
                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    tileColor: Colors
                                        .transparent, // ensures no background
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    leading: Checkbox.adaptive(
                                      value: item.isDone,
                                      onChanged: (_) =>
                                          controller.toggleDone(item),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    title: Text(
                                      item.subtask ?? 'No Subtopic',
                                      style: TextStyle(
                                        decoration: item.isDone
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                        fontSize: 15.5,
                                        fontWeight: item.isDone
                                            ? FontWeight.normal
                                            : FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: (item.comment?.isNotEmpty ??
                                            false)
                                        ? Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Text(
                                              item.comment!,
                                              style: TextStyle(
                                                fontSize: 13.5,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          )
                                        : null,
                                    trailing: IconButton(
                                      icon: Icon(Icons.edit_note,
                                          color: Colors.indigo),
                                      onPressed: () {
                                        Get.to(() => CommentEditPage(
                                                  context,
                                                  item: item,
                                                ))!
                                            .then((ca) {
                                          Get.find<TodoController>().loadData();
                                        });
                                      },
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              }).toList(),
      );
    });
  }
}
