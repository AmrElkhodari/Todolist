import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class TaskService {
  final _col = FirebaseFirestore.instance.collection('tasks');

  Stream<List<TaskModel>> getUserTasks(String userId) => _col
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((s) {
        final tasks = s.docs.map(TaskModel.fromFirestore).toList();
        tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return tasks;
      });

  Future<void> addTask({
    required String userId,
    required String title,
    String description = '',
    required int colorIndex,
    DateTime? dueDate,
  }) {
    final data = <String, dynamic>{
      'userId': userId,
      'title': title,
      'description': description,
      'done': false,
      'colorIndex': colorIndex,
      'createdAt': FieldValue.serverTimestamp(),
    };
    if (dueDate != null) data['dueDate'] = Timestamp.fromDate(dueDate);
    return _col.add(data);
  }

  Future<void> toggleTask(String taskId, bool done) =>
      _col.doc(taskId).update({'done': done});

  Future<void> deleteTask(String taskId) => _col.doc(taskId).delete();
}
