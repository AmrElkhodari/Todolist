import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final List<String> participants;
  final Map<String, String> participantNames; // uid → display name
  final String lastMessage;
  final DateTime? lastMessageTime;

  const ChatModel({
    required this.id,
    required this.participants,
    required this.participantNames,
    required this.lastMessage,
    this.lastMessageTime,
  });

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ChatModel(
      id: doc.id,
      participants: List<String>.from(d['participants'] ?? []),
      participantNames: Map<String, String>.from(d['participantNames'] ?? {}),
      lastMessage: d['lastMessage'] ?? '',
      lastMessageTime: (d['lastMessageTime'] as Timestamp?)?.toDate(),
    );
  }

  /// Returns the other participant's display name given the current user's uid.
  String otherName(String myUid) {
    final otherId = participants.firstWhere((p) => p != myUid, orElse: () => '');
    return participantNames[otherId] ?? 'Unknown';
  }

  /// Returns the other participant's uid.
  String otherId(String myUid) =>
      participants.firstWhere((p) => p != myUid, orElse: () => '');
}

class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      senderId: d['senderId'] ?? '',
      text: d['text'] ?? '',
      timestamp: (d['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'senderId': senderId,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      };
}
