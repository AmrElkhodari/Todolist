import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final _col = FirebaseFirestore.instance.collection('users');

  Future<void> createUser(UserModel user) =>
      _col.doc(user.uid).set(user.toFirestore());

  Future<bool> userExists(String uid) async =>
      (await _col.doc(uid).get()).exists;

  Future<UserModel?> getUser(String uid) async {
    final doc = await _col.doc(uid).get();
    return doc.exists ? UserModel.fromFirestore(doc) : null;
  }

  Future<void> updateUser(String uid,
          {String? firstName, String? lastName, String? bio}) {
    final data = <String, dynamic>{};
    if (firstName != null) data['firstName'] = firstName;
    if (lastName != null)  data['lastName']  = lastName;
    if (bio != null)       data['bio']       = bio;
    return _col.doc(uid).update(data);
  }

  /// Search by exact email (used for starting a new DM).
  Future<UserModel?> findByEmail(String email) async {
    final snap = await _col
        .where('email', isEqualTo: email.trim().toLowerCase())
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return UserModel.fromFirestore(snap.docs.first);
  }
}
