// main.dart
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uppcs_app/data_base_helper.dart';
import 'package:uppcs_app/edit_comment.dart';
import 'package:uppcs_app/time_table/weekly_plan_page.dart';
import 'package:uppcs_app/todo_controller.dart';
import 'package:uppcs_app/todo_model.dart';
import 'master_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request permission before DB access
  await TodoDatabase.instance.requestStoragePermission();
  await TodoDatabase.instance.database;

  Get.put(TodoController());

  runApp(UPPCSPlannerApp());
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
