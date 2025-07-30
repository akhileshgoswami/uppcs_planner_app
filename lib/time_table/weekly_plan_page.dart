import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uppcs_app/data_base_helper.dart';
import 'package:uppcs_app/time_table/time_table.dart';
import 'plan_model.dart';

class WeeklyPlanPage extends StatefulWidget {
  const WeeklyPlanPage({super.key});

  @override
  State<WeeklyPlanPage> createState() => _WeeklyPlanPageState();
}

class _WeeklyPlanPageState extends State<WeeklyPlanPage>
    with SingleTickerProviderStateMixin {
  final db = TodoDatabase.instance;
  int _weekOffset = 0;
  late List<DateTime> _weekDates;
  late String _weekStartDate;
  List<StudyPlanItem> _allSlots = [];
  RxDouble progress = 0.0.obs;
  late TabController _tabController;

  List<Map<String, dynamic>> defaultWeeklyPlan = [
    for (var dayPlan in timeTable["plan"])
      {
        "day": dayPlan["day"],
        "slots": List<Map<String, dynamic>>.from(dayPlan["slots"]),
      }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    final today = DateTime.now();
    final weekdayIndex = today.weekday - 1; // 0 = Monday

    _tabController.index = weekdayIndex; // auto-select current day
    _initializeWeekData();
  }

  Future<void> _initializeWeekData() async {
    _weekDates = _getWeekDates(_weekOffset);
    _weekStartDate = DateFormat('yyyy-MM-dd').format(_weekDates.first);

    await db.insertDefaultWeeklyPlanIfMissing(
      weekStartDate: _weekStartDate,
      defaultPlan: defaultWeeklyPlan,
    );

    _allSlots = await db.getWeekPlan(_weekStartDate);
    progress.value = await db.getCurrentWeekCompletionPercentage();
    setState(() {});
  }

  List<DateTime> _getWeekDates(int offset) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final targetMonday = monday.add(Duration(days: offset * 7));
    return List.generate(7, (i) => targetMonday.add(Duration(days: i)));
  }

  List<StudyPlanItem> _slotsForDay(String dayName) {
    return _allSlots.where((item) => item.day == dayName).toList();
  }

  void _toggleCompleted(StudyPlanItem slot) async {
    final updated = slot.copyWith(completed: !slot.completed);
    await db.updateSlot(updated);
    _refreshWeekData();
  }

  void _updateComment(StudyPlanItem slot, String newComment) async {
    final updated = slot.copyWith(comment: newComment);
    await db.updateSlot(updated);
    _refreshWeekData();
  }

  Future<void> _refreshWeekData() async {
    _allSlots = await db.getWeekPlan(_weekStartDate);
    progress.value = await db.getCurrentWeekCompletionPercentage();
    setState(() {});
  }

  Widget _buildSlotTile(StudyPlanItem slot) {
    final controller = TextEditingController(text: slot.comment);
    controller.selection =
        TextSelection.collapsed(offset: controller.text.length);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule_rounded, color: Colors.blueGrey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "${slot.time} • ${slot.subject}",
                  style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              Checkbox(
                value: slot.completed,
                onChanged: (_) => _toggleCompleted(slot),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            slot.topic,
            style:
                GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            onSubmitted: (val) => _updateComment(slot, val),
            decoration: InputDecoration(
              labelText: "Comment",
              labelStyle: GoogleFonts.poppins(fontSize: 13),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade400)),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            ),
          ),
        ],
      ),
    );
  }

  String get _weekRangeLabel {
    final start = DateFormat('dd MMM').format(_weekDates.first);
    final end = DateFormat('dd MMM yyyy').format(_weekDates.last);
    return "$start - $end";
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [themeColor, themeColor.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          "Weekly Study Plan",
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshWeekData,
          )
        ],
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Obx(() => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Progress: ${progress.value.toStringAsFixed(2)}%",
                      style: GoogleFonts.poppins(
                          fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress.value / 100,
                        minHeight: 10,
                        backgroundColor: Colors.grey[300],
                        color: themeColor,
                      ),
                    ),
                  ],
                ),
              )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: () {
                    setState(() {
                      _weekOffset -= 1;
                    });
                    _initializeWeekData();
                  },
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  // label: const Text("Prev"),
                ),
                Text(
                  _weekRangeLabel,
                  style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: _weekOffset < 0
                      ? () {
                          setState(() {
                            _weekOffset += 1;
                          });
                          _initializeWeekData();
                        }
                      : null,
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: themeColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: themeColor,
            labelStyle:
                GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
            tabs: _weekDates
                .map((date) => Tab(
                      text: DateFormat('EEE\n dd MMM').format(date),
                    ))
                .toList(),
          ),
          Expanded(
            child: _allSlots.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: _weekDates.map((date) {
                      final dayName = DateFormat('EEEE').format(date);
                      final slots = _slotsForDay(dayName);
                      return ListView(
                        padding: const EdgeInsets.all(12),
                        children: slots.isEmpty
                            ? [
                                Center(
                                  child: Text(
                                    "No slots for $dayName",
                                    style: GoogleFonts.poppins(
                                        color: Colors.grey.shade600),
                                  ),
                                )
                              ]
                            : slots.map(_buildSlotTile).toList(),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            _weekOffset = 0;
            _tabController.index = DateTime.now().weekday - 1;
          });
          _initializeWeekData();
        },
        backgroundColor: themeColor,
        icon: const Icon(Icons.today),
        label: const Text("Today"),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
