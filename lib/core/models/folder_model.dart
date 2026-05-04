import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class FolderModel {
  final String id;
  final String ownerId;
  final String name;
  final int colorIndex;  // 0-3
  final int iconIndex;   // 0-5
  final List<String> members;
  final DateTime createdAt;

  const FolderModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.colorIndex,
    required this.iconIndex,
    required this.members,
    required this.createdAt,
  });

  Color get color => _colors[colorIndex.clamp(0, _colors.length - 1)];
  Color get pastel => _pastels[colorIndex.clamp(0, _pastels.length - 1)];
  IconData get icon => _icons[iconIndex.clamp(0, _icons.length - 1)];

  static const _colors  = [AppColors.accentMint, AppColors.accentBlue, AppColors.accentPink, AppColors.accentOrange];
  static const _pastels = [AppColors.accentMintPastel, AppColors.accentBluePastel, AppColors.accentPinkPastel, AppColors.accentOrangePastel];
  static const _icons   = [
    Icons.folder_outlined,
    Icons.palette_outlined,
    Icons.code_outlined,
    Icons.campaign_outlined,
    Icons.science_outlined,
    Icons.work_outlined,
  ];

  factory FolderModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return FolderModel(
      id: doc.id,
      ownerId: d['ownerId'] ?? '',
      name: d['name'] ?? '',
      colorIndex: d['colorIndex'] ?? 0,
      iconIndex: d['iconIndex'] ?? 0,
      members: List<String>.from(d['members'] ?? []),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'ownerId': ownerId,
        'name': name,
        'colorIndex': colorIndex,
        'iconIndex': iconIndex,
        'members': members,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
