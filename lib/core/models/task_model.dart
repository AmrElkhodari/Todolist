import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TaskModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final bool done;
  final int colorIndex;
  final DateTime createdAt;
  final DateTime? dueDate;

  const TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description = '',
    required this.done,
    required this.colorIndex,
    required this.createdAt,
    this.dueDate,
  });

  Color get color => _colors[colorIndex.clamp(0, _colors.length - 1)];

  static const _colors = [
    AppColors.accentMint,
    AppColors.accentBlue,
    AppColors.accentOrange,
    AppColors.accentPink,
  ];

  bool get isOverdue =>
      dueDate != null && !done && dueDate!.isBefore(DateTime.now());

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      userId: d['userId'] ?? '',
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      done: d['done'] ?? false,
      colorIndex: d['colorIndex'] ?? 0,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dueDate: (d['dueDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    final m = <String, dynamic>{
      'userId': userId,
      'title': title,
      'description': description,
      'done': done,
      'colorIndex': colorIndex,
      'createdAt': FieldValue.serverTimestamp(),
    };
    if (dueDate != null) m['dueDate'] = Timestamp.fromDate(dueDate!);
    return m;
  }

  TaskModel copyWith({bool? done}) => TaskModel(
        id: id, userId: userId, title: title,
        description: description,
        done: done ?? this.done,
        colorIndex: colorIndex, createdAt: createdAt, dueDate: dueDate,
      );
}
