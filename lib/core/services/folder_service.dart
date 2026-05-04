import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/folder_model.dart';

class FolderService {
  final _col = FirebaseFirestore.instance.collection('folders');

  /// Real-time stream of folders where user is owner or member.
  Stream<List<FolderModel>> getUserFolders(String userId) => _col
      .where('members', arrayContains: userId)
      .orderBy('createdAt', descending: false)
      .snapshots()
      .map((s) => s.docs.map(FolderModel.fromFirestore).toList());

  Future<void> createFolder({
    required String ownerId,
    required String name,
    required int colorIndex,
    required int iconIndex,
  }) =>
      _col.add({
        'ownerId': ownerId,
        'name': name,
        'colorIndex': colorIndex,
        'iconIndex': iconIndex,
        'members': [ownerId], // Creator is automatically a member.
        'createdAt': FieldValue.serverTimestamp(),
      });

  Future<void> deleteFolder(String folderId) => _col.doc(folderId).delete();

  Future<void> addMember(String folderId, String userId) =>
      _col.doc(folderId).update({
        'members': FieldValue.arrayUnion([userId]),
      });
}
