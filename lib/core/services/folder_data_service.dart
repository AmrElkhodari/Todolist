import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/folder_models.dart';

/// Manages all Firestore operations for folder sub-collections:
/// tasks, messages, activity, and files.
class FolderDataService {
  final _db = FirebaseFirestore.instance;

  CollectionReference _tasks(String folderId) =>
      _db.collection('folders').doc(folderId).collection('tasks');

  CollectionReference _messages(String folderId) =>
      _db.collection('folders').doc(folderId).collection('messages');

  CollectionReference _activity(String folderId) =>
      _db.collection('folders').doc(folderId).collection('activity');

  CollectionReference _files(String folderId) =>
      _db.collection('folders').doc(folderId).collection('files');

  // ── Tasks ──────────────────────────────────────────────────────────────────

  Stream<List<FolderTaskModel>> getTasks(String folderId) =>
      _tasks(folderId).snapshots().map((s) {
        final list = s.docs.map(FolderTaskModel.fromFirestore).toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      });

  Future<void> addTask({
    required String folderId,
    required String createdBy,
    required String createdByName,
    required String title,
    String description = '',
    required int colorIndex,
    DateTime? dueDate,
  }) async {
    final data = <String, dynamic>{
      'createdBy': createdBy,
      'createdByName': createdByName,
      'title': title,
      'description': description,
      'done': false,
      'colorIndex': colorIndex,
      'createdAt': FieldValue.serverTimestamp(),
    };
    if (dueDate != null) data['dueDate'] = Timestamp.fromDate(dueDate);
    await _tasks(folderId).add(data);
    await logActivity(folderId, createdBy, createdByName, 'added task "$title"');
  }

  Future<void> toggleTask(String folderId, String taskId, bool done,
      String userId, String userName, String taskTitle) async {
    await _tasks(folderId).doc(taskId).update({'done': done});
    if (done) {
      await logActivity(folderId, userId, userName, 'completed "$taskTitle"');
    }
  }

  Future<void> deleteTask(String folderId, String taskId) =>
      _tasks(folderId).doc(taskId).delete();

  // ── Messages ───────────────────────────────────────────────────────────────

  Stream<List<FolderMessage>> getMessages(String folderId) =>
      _messages(folderId)
          .orderBy('timestamp', descending: false)
          .snapshots()
          .map((s) => s.docs.map(FolderMessage.fromFirestore).toList());

  Future<void> sendMessage({
    required String folderId,
    required String senderId,
    required String senderName,
    required String text,
  }) =>
      _messages(folderId).add({
        'senderId': senderId,
        'senderName': senderName,
        'text': text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

  // ── Activity Log ───────────────────────────────────────────────────────────

  Stream<List<FolderActivity>> getActivity(String folderId) =>
      _activity(folderId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((s) => s.docs.map(FolderActivity.fromFirestore).toList());

  Future<void> logActivity(String folderId, String userId, String userName,
      String action) =>
      _activity(folderId).add({
        'userId': userId,
        'userName': userName,
        'action': action,
        'timestamp': FieldValue.serverTimestamp(),
      });

  // ── Files (metadata only) ──────────────────────────────────────────────────

  Stream<List<Map<String, dynamic>>> getFiles(String folderId) =>
      _files(folderId)
          .orderBy('uploadedAt', descending: true)
          .snapshots()
          .map((s) => s.docs
              .map((d) => {'id': d.id, ...d.data() as Map<String, dynamic>})
              .toList());

  Future<void> addFileMetadata({
    required String folderId,
    required String uploadedBy,
    required String uploaderName,
    required String name,
    required String type,
  }) async {
    await _files(folderId).add({
      'uploadedBy': uploadedBy,
      'uploaderName': uploaderName,
      'name': name,
      'type': type,
      'uploadedAt': FieldValue.serverTimestamp(),
    });
    await logActivity(
        folderId, uploadedBy, uploaderName, 'uploaded "$name"');
  }
}
