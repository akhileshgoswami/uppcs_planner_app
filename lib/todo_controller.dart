import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uppcs_app/data_base_helper.dart';
import 'package:uppcs_app/todo_model.dart';

class TodoController extends GetxController {
  var todoItems = <TodoItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    final items = await TodoDatabase.instance.fetchAll();
    todoItems.assignAll(items);
  }

  Future<void> toggleDone(TodoItem item) async {
    item.isDone = !item.isDone;
    item.doneDate =
        item.isDone ? DateFormat('yyyy-MM-dd').format(DateTime.now()) : null;
    await TodoDatabase.instance.insertOrUpdate(item);
    loadData();
  }

  Future<void> updateComment(TodoItem item, String comment) async {
    item.comment = comment;
    await TodoDatabase.instance.insertOrUpdate(item);
    loadData();
  }
}
