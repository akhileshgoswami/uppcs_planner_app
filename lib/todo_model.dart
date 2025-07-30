class TodoItem {
  String subject;
  String task;
  String? subtask;
  bool isDone;
  String? comment;
  String? doneDate;
  TodoItem({
    required this.subject,
    required this.task,
    this.subtask,
    this.isDone = false,
    this.comment,
    this.doneDate,
  });

  Map<String, dynamic> toMap() => {
        'subject': subject,
        'task': task,
        'subtask': subtask,
        'isDone': isDone ? 1 : 0,
        'comment': comment,
        'doneDate': doneDate,
      };

  static TodoItem fromMap(Map<String, dynamic> map) => TodoItem(
        subject: map['subject'],
        task: map['task'],
        subtask: map['subtask'],
        isDone: map['isDone'] == 1,
        comment: map['comment'],
        doneDate: map['doneDate'],
      );
}
