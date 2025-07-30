import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:uppcs_app/data_base_helper.dart';
import 'package:uppcs_app/todo_model.dart';

class MasterEntryPage extends StatefulWidget {
  @override
  _MasterEntryPageState createState() => _MasterEntryPageState();
}

class _MasterEntryPageState extends State<MasterEntryPage> {
  final subtopicCtrl = TextEditingController();
  final manualSubjCtrl = TextEditingController();
  final manualChapCtrl = TextEditingController();
  final manualTopicCtrl = TextEditingController();

  List<TodoItem> allItems = [];
  List<String> subjects = [], chapters = [], topics = [];

  String? sSubject, sChapter, sTopic;
  bool isNewSubject = false;
  bool isNewChapter = false;
  bool isNewTopic = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    allItems = await TodoDatabase.instance.fetchAll();
    subjects = allItems.map((e) => e.subject).toSet().toList()..sort();
    setState(() {});
  }

  void _refreshChapters() {
    final filtered = sSubject != null
        ? allItems.where((e) => e.subject == sSubject!).toList()
        : [];
    chapters = filtered
        .map((e) => e.task.split(' > ').first)
        .toSet()
        .toList()
        .cast<String>()
      ..sort();
    if (!chapters.contains(sChapter)) sChapter = null;
  }

  void _refreshTopics() {
    final filtered = allItems.where((e) =>
        (sSubject != null && e.subject == sSubject!) &&
        (sChapter != null && e.task.split(' > ').first == sChapter!));
    topics = filtered
        .map((e) => e.task.contains('>') ? e.task.split(' > ').last : '')
        .where((t) => t.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    if (!topics.contains(sTopic)) sTopic = null;
  }

  String _finalValue(String? selected, TextEditingController manual) =>
      (selected != null && selected.isNotEmpty) ? selected : manual.text.trim();

  void _saveEntry() async {
    final subject = _finalValue(isNewSubject ? null : sSubject, manualSubjCtrl);
    final chapter = _finalValue(isNewChapter ? null : sChapter, manualChapCtrl);
    final topic = _finalValue(isNewTopic ? null : sTopic, manualTopicCtrl);
    final subtopic = subtopicCtrl.text.trim();

    if ([subject, chapter, topic, subtopic].any((s) => s.isEmpty)) {
      Get.snackbar("Error", "Please fill in all fields.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.black);
      return;
    }

    final newItem = TodoItem(
      subject: subject,
      task: "$chapter > $topic",
      subtask: subtopic,
    );

    await TodoDatabase.instance.insertOrUpdate(newItem);

    Get.snackbar("Success", "Entry saved.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.black);

    manualSubjCtrl.clear();
    manualChapCtrl.clear();
    manualTopicCtrl.clear();
    subtopicCtrl.clear();
    sSubject = sChapter = sTopic = null;
    isNewSubject = isNewChapter = isNewTopic = false;
    await _loadAll();
  }

  Widget _buildToggleInput({
    required String label,
    required bool useManual,
    required Function(bool) onToggle,
    required List<String> options,
    required String? selected,
    required void Function(String?) onChanged,
    required TextEditingController manualCtrl,
    bool isDisabled = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, top: 12.0),
          child: Row(
            children: [
              Text("Type new $label",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Spacer(),
              Text(useManual ? "New" : "OLD",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Switch(value: useManual, onChanged: isDisabled ? null : onToggle),
            ],
          ),
        ),
        const SizedBox(height: 8),
        useManual
            ? TextField(
                controller: manualCtrl,
                // enabled: !isDisabled,
                decoration: InputDecoration(
                  labelText: 'Enter new $label',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )
            : DropdownSearch<String>(
                items: options,
                selectedItem: selected,
                onChanged: isDisabled ? null : onChanged,
                // enabled: !isDisabled,
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Select $label",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      hintText: "Search $label",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool disableChapterAndTopic = isNewSubject;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text("📘 Master Entry",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildToggleInput(
                    label: "Subject",
                    useManual: isNewSubject,
                    onToggle: (val) {
                      setState(() {
                        isNewSubject = val;

                        isNewChapter = val;
                        isNewTopic = val;

                        if (!val) _refreshChapters();
                      });
                    },
                    options: subjects,
                    selected: sSubject,
                    onChanged: (v) {
                      sSubject = v;
                      _refreshChapters();
                      _refreshTopics();
                      setState(() {});
                    },
                    manualCtrl: manualSubjCtrl,
                  ),
                  SizedBox(height: 20),
                  _buildToggleInput(
                    label: "Chapter",
                    useManual: isNewChapter,
                    isDisabled: isNewSubject ? true : false,
                    onToggle: (val) {
                      setState(() {
                        isNewChapter = val;
                        isNewTopic = val;
                        if (!val) _refreshTopics();
                      });
                    },
                    options: chapters,
                    selected: sChapter,
                    onChanged: (v) {
                      sChapter = v;
                      _refreshTopics();
                      setState(() {});
                    },
                    manualCtrl: manualChapCtrl,
                    // isDisabled: disableChapterAndTopic,
                  ),
                  SizedBox(height: 20),
                  _buildToggleInput(
                    label: "Topic",
                    useManual: isNewTopic,
                    isDisabled: isNewChapter ? true : false,
                    onToggle: (val) => setState(() => isNewTopic = val),
                    options: topics,
                    selected: sTopic,
                    onChanged: (v) => setState(() => sTopic = v),
                    manualCtrl: manualTopicCtrl,
                    // isDisabled: disableChapterAndTopic,
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: subtopicCtrl,
                    // enabled: !disableChapterAndTopic,
                    decoration: InputDecoration(
                      labelText: "Subtopic",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.save),
                      label: Text("Save"),
                      onPressed: _saveEntry,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        textStyle: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
