import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A task that belongs to a collaborative folder.
class FolderTaskModel {
  final String id;
  final String createdBy;
  final String createdByName;
  final String title;
  final String description;
  final bool done;
  final int colorIndex;
  final DateTime createdAt;
  final DateTime? dueDate;

  const FolderTaskModel({
    required this.id,
    required this.createdBy,
    required this.createdByName,
    required this.title,
    this.description = '',
    required this.done,
    required this.colorIndex,
    required this.createdAt,
    this.dueDate,
  });

  Color get color => _colors[colorIndex.clamp(0, _colors.length - 1)];
  bool get isOverdue =>
      dueDate != null && !done && dueDate!.isBefore(DateTime.now());

  static const _colors = [
    AppColors.accentMint, AppColors.accentBlue,
    AppColors.accentOrange, AppColors.accentPink,
  ];

  factory FolderTaskModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return FolderTaskModel(
      id: doc.id,
      createdBy: d['createdBy'] ?? '',
      createdByName: d['createdByName'] ?? '',
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      done: d['done'] ?? false,
      colorIndex: d['colorIndex'] ?? 0,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dueDate: (d['dueDate'] as Timestamp?)?.toDate(),
    );
  }
}

/// Activity log entry for a folder.
class FolderActivity {
  final String id;
  final String userId;
  final String userName;
  final String action;
  final DateTime timestamp;

  const FolderActivity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.action,
    required this.timestamp,
  });

  factory FolderActivity.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return FolderActivity(
      id: doc.id,
      userId: d['userId'] ?? '',
      userName: d['userName'] ?? '',
      action: d['action'] ?? '',
      timestamp: (d['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

/// A group message inside a folder chat.
class FolderMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;

  const FolderMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
  });

  factory FolderMessage.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return FolderMessage(
      id: doc.id,
      senderId: d['senderId'] ?? '',
      senderName: d['senderName'] ?? '',
      text: d['text'] ?? '',
      timestamp: (d['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
