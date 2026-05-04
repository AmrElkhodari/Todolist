import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TaskModel {
  final String id;
  final String userId;
  final String title;
  final bool done;
  final int colorIndex; // 0-3
  final DateTime createdAt;

  const TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.done,
    required this.colorIndex,
    required this.createdAt,
  });

  Color get color => _colors[colorIndex.clamp(0, _colors.length - 1)];

  static const _colors = [
    AppColors.accentMint,
    AppColors.accentBlue,
    AppColors.accentOrange,
    AppColors.accentPink,
  ];

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      userId: d['userId'] ?? '',
      title: d['title'] ?? '',
      done: d['done'] ?? false,
      colorIndex: d['colorIndex'] ?? 0,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'title': title,
        'done': done,
        'colorIndex': colorIndex,
        'createdAt': FieldValue.serverTimestamp(),
      };

  TaskModel copyWith({bool? done}) => TaskModel(
        id: id, userId: userId, title: title,
        done: done ?? this.done,
        colorIndex: colorIndex, createdAt: createdAt,
      );
}
