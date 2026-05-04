import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class TaskService {
  final _col = FirebaseFirestore.instance.collection('tasks');

  /// Real-time stream of a user's tasks, newest first.
  Stream<List<TaskModel>> getUserTasks(String userId) => _col
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(TaskModel.fromFirestore).toList());

  Future<void> addTask({
    required String userId,
    required String title,
    required int colorIndex,
  }) =>
      _col.add({
        'userId': userId,
        'title': title,
        'done': false,
        'colorIndex': colorIndex,
        'createdAt': FieldValue.serverTimestamp(),
      });

  Future<void> toggleTask(String taskId, bool done) =>
      _col.doc(taskId).update({'done': done});

  Future<void> deleteTask(String taskId) => _col.doc(taskId).delete();
}
