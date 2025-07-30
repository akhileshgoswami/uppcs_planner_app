import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uppcs_app/todo_controller.dart';
import 'package:uppcs_app/todo_model.dart';

class CommentEditPage extends StatefulWidget {
   TodoItem item;

   CommentEditPage(BuildContext context, {super.key, required this.item});

  @override
  State<CommentEditPage> createState() => _CommentEditPageState();
}

class _CommentEditPageState extends State<CommentEditPage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.item.comment ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveComment() async {
    final newComment = _controller.text.trim();
    await Get.find<TodoController>().updateComment(widget.item, newComment);
    Get.back(); // Return to previous screen
    Get.snackbar(
      'Success',
      'Comment saved successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.black87,
      margin: EdgeInsets.all(12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comment', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: 'Edit Comment',
                hintText: 'Type your comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.save),
                label: Text('Save'),
                onPressed: _saveComment,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
