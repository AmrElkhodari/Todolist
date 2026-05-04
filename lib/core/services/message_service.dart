import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';

class MessageService {
  final _db = FirebaseFirestore.instance;

  /// Real-time stream of all chats for a user.
  Stream<List<ChatModel>> getUserChats(String userId) => _db
      .collection('chats')
      .where('participants', arrayContains: userId)
      .orderBy('lastMessageTime', descending: true)
      .snapshots()
      .map((s) => s.docs.map(ChatModel.fromFirestore).toList());

  /// Real-time stream of messages in a chat.
  Stream<List<MessageModel>> getMessages(String chatId) => _db
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .orderBy('timestamp', descending: false)
      .snapshots()
      .map((s) => s.docs.map(MessageModel.fromFirestore).toList());

  /// Returns existing chat ID or creates a new one between two users.
  Future<String> getOrCreateChat({
    required String myUid,
    required String myName,
    required String otherUid,
    required String otherName,
  }) async {
    // Check if a chat already exists between these two users.
    final existing = await _db
        .collection('chats')
        .where('participants', arrayContains: myUid)
        .get();

    for (final doc in existing.docs) {
      final participants = List<String>.from(doc['participants']);
      if (participants.contains(otherUid)) return doc.id;
    }

    // Create new chat document.
    final ref = await _db.collection('chats').add({
      'participants': [myUid, otherUid],
      'participantNames': {myUid: myName, otherUid: otherName},
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  /// Sends a message and updates the chat's last-message metadata.
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    final chatRef = _db.collection('chats').doc(chatId);
    await Future.wait([
      chatRef.collection('messages').add({
        'senderId': senderId,
        'text': text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      }),
      chatRef.update({
        'lastMessage': text.trim(),
        'lastMessageTime': FieldValue.serverTimestamp(),
      }),
    ]);
  }
}
