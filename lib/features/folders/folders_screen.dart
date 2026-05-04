import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/folder_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/folder_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/constants/app_dimens.dart';

class FoldersScreen extends StatelessWidget {
  const FoldersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().user!.uid;
    final service = FolderService();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimens.md),
            child: _SearchBar(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppDimens.md, 0, AppDimens.md, AppDimens.sm),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Your Workspaces',
                  style: Theme.of(context).textTheme.headlineSmall),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<FolderModel>>(
              stream: service.getUserFolders(uid),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final folders = snap.data ?? [];
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppDimens.md,
                    mainAxisSpacing: AppDimens.md,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: folders.length + 1,
                  itemBuilder: (context, i) {
                    if (i == folders.length) {
                      return _NewFolderCard(onTap: () =>
                          _showCreateSheet(context, uid, service));
                    }
                    return _FolderCard(
                      folder: folders[i],
                      onLongPress: () =>
                          _confirmDelete(context, folders[i], service),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateSheet(
      BuildContext context, String uid, FolderService service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimens.radiusLg)),
      ),
      builder: (_) => _CreateFolderSheet(uid: uid, service: service),
    );
  }

  void _confirmDelete(
      BuildContext context, FolderModel folder, FolderService service) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete "${folder.name}"?'),
        content:
            const Text('This folder and all its data will be deleted.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              service.deleteFolder(folder.id);
              Navigator.pop(context);
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ── Folder Card ───────────────────────────────────────────────────────────────

class _FolderCard extends StatelessWidget {
  const _FolderCard({required this.folder, required this.onLongPress});
  final FolderModel folder;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {},
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          boxShadow: isDark ? AppShadows.cardDark : AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: folder.pastel,
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              ),
              child: Icon(folder.icon, color: folder.color, size: 24),
            ),
            const Spacer(),
            Text(folder.name,
                style: Theme.of(context).textTheme.headlineSmall,
                maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: AppDimens.xs),
            Text('${folder.members.length} member(s)',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _NewFolderCard extends StatelessWidget {
  const _NewFolderCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: AppColors.primaryLight.withValues(alpha: 0.4), width: 2),
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryPastel,
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              ),
              child: const Icon(Icons.add, color: AppColors.primaryLight, size: 24),
            ),
            const SizedBox(height: AppDimens.sm),
            Text('New Folder',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primaryLight)),
          ],
        ),
      ),
    );
  }
}

// ── Create Folder Sheet ───────────────────────────────────────────────────────

class _CreateFolderSheet extends StatefulWidget {
  const _CreateFolderSheet({required this.uid, required this.service});
  final String uid;
  final FolderService service;

  @override
  State<_CreateFolderSheet> createState() => _CreateFolderSheetState();
}

class _CreateFolderSheetState extends State<_CreateFolderSheet> {
  final _ctrl = TextEditingController();
  int _colorIndex = 0;
  int _iconIndex = 0;
  bool _saving = false;

  static const _colors = [
    AppColors.accentMint, AppColors.accentBlue,
    AppColors.accentPink, AppColors.accentOrange,
  ];
  static const _icons = [
    Icons.folder_outlined, Icons.palette_outlined,
    Icons.code_outlined, Icons.campaign_outlined,
    Icons.science_outlined, Icons.work_outlined,
  ];

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    await widget.service.createFolder(
      ownerId: widget.uid,
      name: _ctrl.text.trim(),
      colorIndex: _colorIndex,
      iconIndex: _iconIndex,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppDimens.lg, AppDimens.lg,
          AppDimens.lg, MediaQuery.of(context).viewInsets.bottom + AppDimens.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New Folder', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppDimens.md),
          TextField(
            controller: _ctrl,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Folder name…'),
          ),
          const SizedBox(height: AppDimens.md),
          Text('Color', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppDimens.sm),
          Row(
            children: List.generate(_colors.length, (i) => GestureDetector(
              onTap: () => setState(() => _colorIndex = i),
              child: AnimatedContainer(
                duration: AppDimens.durationNormal,
                margin: const EdgeInsets.only(right: AppDimens.sm),
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: _colors[i],
                  shape: BoxShape.circle,
                  border: _colorIndex == i
                      ? Border.all(color: AppColors.primary, width: 3)
                      : null,
                ),
              ),
            )),
          ),
          const SizedBox(height: AppDimens.md),
          Text('Icon', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppDimens.sm),
          Row(
            children: List.generate(_icons.length, (i) => GestureDetector(
              onTap: () => setState(() => _iconIndex = i),
              child: AnimatedContainer(
                duration: AppDimens.durationNormal,
                margin: const EdgeInsets.only(right: AppDimens.sm),
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: _iconIndex == i
                      ? AppColors.primaryPastel
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_icons[i],
                    color: _iconIndex == i
                        ? AppColors.primaryLight
                        : Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            )),
          ),
          const SizedBox(height: AppDimens.lg),
          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: AppColors.white))
                  : const Text('Create Folder'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        boxShadow: AppShadows.card,
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search folders…',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }
}
