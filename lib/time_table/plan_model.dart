class StudyPlanItem {
  final int? id;
  final String weekStart;
  final String day;
  final String time;
  final String subject;
  final String topic;
  final bool completed;
  final String comment;

  StudyPlanItem({
    this.id,
    required this.weekStart,
    required this.day,
    required this.time,
    required this.subject,
    required this.topic,
    this.completed = false,
    this.comment = '',
  });

  // 🔧 Add this method to support DB updates
  Map<String, dynamic> toMap() {
    return {
      'id': id, // ✅ Ensure ID is passed for update to work
      'weekStart': weekStart,
      'day': day,
      'time': time,
      'subject': subject,
      'topic': topic,
      'completed': completed ? 1 : 0,
      'comment': comment,
    };
  }

  factory StudyPlanItem.fromMap(Map<String, dynamic> map) {
    return StudyPlanItem(
      id: map['id'],
      weekStart: map['weekStart'],
      day: map['day'],
      time: map['time'],
      subject: map['subject'],
      topic: map['topic'],
      completed: map['completed'] == 1,
      comment: map['comment'] ?? '',
    );
  }

  StudyPlanItem copyWith({
    int? id,
    String? weekStart,
    String? day,
    String? time,
    String? subject,
    String? topic,
    bool? completed,
    String? comment,
  }) {
    return StudyPlanItem(
      id: id ?? this.id,
      weekStart: weekStart ?? this.weekStart,
      day: day ?? this.day,
      time: time ?? this.time,
      subject: subject ?? this.subject,
      topic: topic ?? this.topic,
      completed: completed ?? this.completed,
      comment: comment ?? this.comment,
    );
  }
}
