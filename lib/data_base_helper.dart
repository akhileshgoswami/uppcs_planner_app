import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uppcs_app/time_table/plan_model.dart';
import 'package:uppcs_app/todo_model.dart';

class TodoDatabase {
  static final TodoDatabase instance = TodoDatabase._init();
  static Database? _database;

  TodoDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('todo.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final backupDirPath = '/storage/emulated/0/UPPCS_Backup';
    final backupFilePath = '$backupDirPath/$fileName';
    final backupFile = File(backupFilePath);
    final backupDir = Directory(backupDirPath);

    await requestStoragePermission();

    if (!await backupDir.exists()) {
      try {
        await backupDir.create(recursive: true);
        debugPrint("📁 Created backup directory: $backupDirPath");
      } catch (e) {
        debugPrint("❌ Failed to create backup folder: $e");
      }
    }

    if (!await backupFile.exists()) {
      try {
        final db =
            await openDatabase(backupFilePath, version: 3, onCreate: _createDB);
        await db.close();
        debugPrint("🆕 Created new empty DB at: $backupFilePath");
      } catch (e) {
        debugPrint("❌ Failed to create DB: $e");
      }
    }

    debugPrint("📂 Opening DB at: $backupFilePath");
    return await openDatabase(
      backupFilePath,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> updateSlot(StudyPlanItem item) async {
    final db = await database;
    await db.update(
      'study_plan',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject TEXT,
        task TEXT,
        subtask TEXT,
        isDone INTEGER,
        comment TEXT,
        doneDate TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE study_plan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        weekStart TEXT,
        day TEXT,
        time TEXT,
        subject TEXT,
        topic TEXT,
        completed INTEGER DEFAULT 0,
        comment TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      final columns = await db.rawQuery('PRAGMA table_info(todos)');
      final hasDoneDate = columns.any((col) => col['name'] == 'doneDate');
      if (!hasDoneDate) {
        await db.execute('ALTER TABLE todos ADD COLUMN doneDate TEXT');
      }
    }
  }

  Future<double> getCurrentWeekCompletionPercentage() async {
    final db = await database;
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartStr =
        weekStart.toIso8601String().substring(0, 10); // 'YYYY-MM-DD'

    // Get all study plans for the current week
    final totalPlans = await db.rawQuery('''
    SELECT COUNT(*) as count FROM study_plan
    WHERE weekStart = ?
  ''', [weekStartStr]);

    // Get completed study plans for the current week
    final completedPlans = await db.rawQuery('''
    SELECT COUNT(*) as count FROM study_plan
    WHERE weekStart = ? AND completed = 1
  ''', [weekStartStr]);

    final total = totalPlans.first['count'] as int;
    final completed = completedPlans.first['count'] as int;

    if (total == 0) return 0.0;

    return (completed / total) * 100;
  }

  Future<void> insertOrUpdate(TodoItem item) async {
    final db = await instance.database;
    final existing = await db.query(
      'todos',
      where: 'subject = ? AND task = ? AND subtask IS ?',
      whereArgs: [item.subject, item.task, item.subtask],
    );

    if (existing.isNotEmpty) {
      await db.update(
        'todos',
        item.toMap(),
        where: 'subject = ? AND task = ? AND subtask IS ?',
        whereArgs: [item.subject, item.task, item.subtask],
      );
    } else {
      await db.insert('todos', item.toMap());
    }
  }

  Future<List<TodoItem>> fetchAll() async {
    final db = await instance.database;
    final result = await db.query('todos');
    return result.map((map) => TodoItem.fromMap(map)).toList();
  }

  // === Study Plan Methods ===

  Future<void> insertStudyPlan(StudyPlanItem item) async {
    final db = await database;
    await db.insert('study_plan', item.toMap());
  }

  Future<bool> hasWeekData(String weekStartDate) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM study_plan WHERE weekStart = ?',
      [weekStartDate],
    );
    return Sqflite.firstIntValue(result)! > 0;
  }

  Future<List<StudyPlanItem>> getWeekPlan(String weekStartDate) async {
    final db = await database;
    final result = await db.query(
      'study_plan',
      where: 'weekStart = ?',
      whereArgs: [weekStartDate],
    );
    return result.map((e) => StudyPlanItem.fromMap(e)).toList();
  }

  Future<void> insertDefaultWeeklyPlanIfMissing({
    required String weekStartDate,
    required List<Map<String, dynamic>> defaultPlan,
  }) async {
    final exists = await hasWeekData(weekStartDate);
    if (!exists) {
      final batch = (await database).batch();
      for (final dayPlan in defaultPlan) {
        final day = dayPlan['day'];
        final slots = dayPlan['slots'] as List;
        for (final slot in slots) {
          batch.insert('study_plan', {
            'weekStart': weekStartDate,
            'day': day,
            'time': slot['time'],
            'subject': slot['subject'],
            'topic': slot['topic'],
            'completed': slot['completed'] ? 1 : 0,
            'comment': slot['comment'] ?? '',
          });
        }
      }
      await batch.commit(noResult: true);
      debugPrint("📅 Default weekly plan inserted for $weekStartDate");
    } else {
      debugPrint("📅 Weekly plan already exists for $weekStartDate");
    }
  }

  Future<bool> requestStoragePermission() async {
    final info = await DeviceInfoPlugin().androidInfo;
    final sdk = info.version.sdkInt;

    if (sdk >= 30) {
      final status = await Permission.manageExternalStorage.request();
      if (status.isGranted) return true;

      if (status.isPermanentlyDenied) {
        await _showPermissionDialog();
        return false;
      }
    } else {
      final status = await Permission.storage.request();
      if (status.isGranted) return true;
    }

    Get.snackbar("Permission Denied", "Storage permission is required.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black);
    return false;
  }

  Future<void> _showPermissionDialog() async {
    await Get.defaultDialog(
      title: "Permission Needed",
      middleText:
          "Storage permission is permanently denied. Please enable it in app settings to continue.",
      radius: 10,
      confirm: ElevatedButton.icon(
        icon: Icon(Icons.settings),
        label: Text("Open Settings"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo,
        ),
        onPressed: () {
          Get.back(); // Close dialog
          openAppSettings(); // Opens the app settings screen
        },
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: Text("Cancel"),
      ),
    );
  }
}
