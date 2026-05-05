import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/folder_model.dart';
import '../../core/models/folder_models.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/folder_data_service.dart';
import '../../core/services/user_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/constants/app_dimens.dart';

class FolderDetailScreen extends StatelessWidget {
  const FolderDetailScreen({super.key, required this.folder});
  final FolderModel folder;

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final uid = auth.user!.uid;
    final userName = auth.user?.displayName ?? 'User';
    final svc = FolderDataService();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Row(children: [
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(color: folder.pastel, borderRadius: BorderRadius.circular(8)),
              child: Icon(folder.icon, color: folder.color, size: 16),
            ),
            const SizedBox(width: 10),
            Text(folder.name),
          ]),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add_outlined),
              tooltip: 'Invite member',
              onPressed: () => _inviteMember(context),
            ),
          ],
          bottom: const TabBar(tabs: [
            Tab(icon: Icon(Icons.check_box_outlined), text: 'Tasks'),
            Tab(icon: Icon(Icons.attach_file), text: 'Files'),
            Tab(icon: Icon(Icons.history), text: 'Activity'),
            Tab(icon: Icon(Icons.chat_bubble_outline), text: 'Chat'),
          ]),
        ),
        body: TabBarView(children: [
          _TasksTab(folder: folder, uid: uid, userName: userName, svc: svc),
          _FilesTab(folder: folder, uid: uid, userName: userName, svc: svc),
          _ActivityTab(folder: folder, svc: svc),
          _ChatTab(folder: folder, uid: uid, userName: userName, svc: svc),
        ]),
      ),
    );
  }

  void _inviteMember(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Invite Member'),
        content: TextField(controller: ctrl, autofocus: true,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: "Member's email")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final user = await UserService().findByEmail(ctrl.text);
              if (!context.mounted) return;
              if (user == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User not found.'), behavior: SnackBarBehavior.floating));
                return;
              }
              await FolderDataService().logActivity(
                  folder.id, user.uid, user.fullName, 'joined the folder');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${user.fullName} invited!'), behavior: SnackBarBehavior.floating));
              }
            },
            child: const Text('Invite'),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TASKS TAB
// ══════════════════════════════════════════════════════════════════════════════

class _TasksTab extends StatelessWidget {
  const _TasksTab({required this.folder, required this.uid, required this.userName, required this.svc});
  final FolderModel folder;
  final String uid, userName;
  final FolderDataService svc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<FolderTaskModel>>(
        stream: svc.getTasks(folder.id),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final tasks = snap.data ?? [];
          if (tasks.isEmpty) {
            return const _EmptyHint(icon: Icons.check_box_outline_blank, text: 'No tasks yet.\nTap + to add one.');
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppDimens.md),
            itemCount: tasks.length,
            itemBuilder: (_, i) => _FolderTaskCard(
                task: tasks[i], folderId: folder.id, uid: uid, userName: userName, svc: svc),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context, isScrollControlled: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (_) => _AddFolderTaskSheet(
              folderId: folder.id, uid: uid, userName: userName, svc: svc),
        ),
        backgroundColor: folder.color,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add),
        label: const Text('Task',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _FolderTaskCard extends StatefulWidget {
  const _FolderTaskCard(
      {required this.task, required this.folderId, required this.uid, required this.userName, required this.svc});
  final FolderTaskModel task;
  final String folderId, uid, userName;
  final FolderDataService svc;

  @override
  State<_FolderTaskCard> createState() => _FolderTaskCardState();
}

class _FolderTaskCardState extends State<_FolderTaskCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = widget.task;
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: AppDimens.durationNormal,
        margin: const EdgeInsets.only(bottom: AppDimens.sm),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          boxShadow: isDark ? AppShadows.cardDark : AppShadows.card,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.md, vertical: AppDimens.sm),
            child: Row(children: [
              Container(width: 10, height: 10,
                  decoration: BoxDecoration(color: t.color, shape: BoxShape.circle)),
              const SizedBox(width: AppDimens.sm),
              Expanded(child: Text(t.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    decoration: t.done ? TextDecoration.lineThrough : null,
                    color: t.done
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : null),
              )),
              AnimatedRotation(turns: _expanded ? 0.5 : 0,
                  duration: AppDimens.durationNormal,
                  child: const Icon(Icons.keyboard_arrow_down, size: 18)),
              const SizedBox(width: AppDimens.sm),
              GestureDetector(
                onTap: () => widget.svc.toggleTask(
                    widget.folderId, t.id, !t.done, widget.uid, widget.userName, t.title),
                child: AnimatedContainer(
                  duration: AppDimens.durationNormal,
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    color: t.done ? AppColors.primaryLight : Colors.transparent,
                    border: Border.all(
                        color: t.done ? AppColors.primaryLight
                            : Theme.of(context).colorScheme.onSurfaceVariant, width: 2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: t.done
                      ? const Icon(Icons.check, size: 14, color: AppColors.white)
                      : null,
                ),
              ),
            ]),
          ),
          AnimatedCrossFade(
            duration: AppDimens.durationNormal,
            crossFadeState: _expanded
                ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(
                  AppDimens.md, 0, AppDimens.md, AppDimens.md),
              padding: const EdgeInsets.all(AppDimens.sm),
              decoration: BoxDecoration(
                  color: t.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppDimens.radiusSm)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.description.isEmpty ? 'No description.' : t.description,
                    style: Theme.of(context).textTheme.bodySmall),
                if (t.dueDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Due: ${t.dueDate!.day}/${t.dueDate!.month}/${t.dueDate!.year}',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 11,
                          color: t.isOverdue ? AppColors.error : AppColors.accentBlue),
                    ),
                  ),
                Text('Added by ${t.createdByName}',
                    style: Theme.of(context).textTheme.bodySmall),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _AddFolderTaskSheet extends StatefulWidget {
  const _AddFolderTaskSheet(
      {required this.folderId, required this.uid, required this.userName, required this.svc});
  final String folderId, uid, userName;
  final FolderDataService svc;

  @override
  State<_AddFolderTaskSheet> createState() => _AddFolderTaskSheetState();
}

class _AddFolderTaskSheetState extends State<_AddFolderTaskSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  int _colorIdx    = 0;
  DateTime? _due;
  bool _saving     = false;

  static const _colors = [
    AppColors.accentMint, AppColors.accentBlue,
    AppColors.accentOrange, AppColors.accentPink,
  ];

  @override
  void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  Future<void> _pickDate() async {
    final p = await showDatePicker(context: context,
        initialDate: DateTime.now().add(const Duration(days: 1)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)));
    if (p != null) setState(() => _due = p);
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    await widget.svc.addTask(
        folderId: widget.folderId, createdBy: widget.uid,
        createdByName: widget.userName, title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(), colorIndex: _colorIdx, dueDate: _due);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppDimens.lg, AppDimens.lg, AppDimens.lg,
          MediaQuery.of(context).viewInsets.bottom + AppDimens.lg),
      child: Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('New Task', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppDimens.md),
        TextField(controller: _titleCtrl, autofocus: true,
            decoration: const InputDecoration(hintText: 'Task title')),
        const SizedBox(height: AppDimens.sm),
        TextField(controller: _descCtrl, maxLines: 2,
            decoration: const InputDecoration(hintText: 'Description (optional)')),
        const SizedBox(height: AppDimens.sm),
        OutlinedButton.icon(onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today_outlined, size: 16),
            label: Text(_due == null ? 'Set due date'
                : 'Due: ${_due!.day}/${_due!.month}/${_due!.year}',
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 13))),
        const SizedBox(height: AppDimens.sm),
        Row(children: List.generate(_colors.length, (i) => GestureDetector(
          onTap: () => setState(() => _colorIdx = i),
          child: AnimatedContainer(duration: AppDimens.durationNormal,
            margin: const EdgeInsets.only(right: AppDimens.sm),
            width: 32, height: 32,
            decoration: BoxDecoration(color: _colors[i], shape: BoxShape.circle,
                border: _colorIdx == i
                    ? Border.all(color: AppColors.primary, width: 3) : null)),
        ))),
        const SizedBox(height: AppDimens.md),
        SizedBox(width: double.infinity, height: 50,
          child: ElevatedButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.white))
                : const Text('Add Task'),
          ),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// FILES TAB
// ══════════════════════════════════════════════════════════════════════════════

class _FilesTab extends StatelessWidget {
  const _FilesTab({required this.folder, required this.uid, required this.userName, required this.svc});
  final FolderModel folder;
  final String uid, userName;
  final FolderDataService svc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: svc.getFiles(folder.id),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final files = snap.data ?? [];
          if (files.isEmpty) {
            return const _EmptyHint(icon: Icons.folder_open_outlined,
                text: 'No files yet.\nTap + to add one.');
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppDimens.md),
            itemCount: files.length,
            itemBuilder: (_, i) {
              final f = files[i];
              return ListTile(
                leading: const Icon(Icons.insert_drive_file_outlined,
                    color: AppColors.accentBlue),
                title: Text(f['name'] ?? '',
                    style: Theme.of(context).textTheme.bodyMedium),
                subtitle: Text('By ${f['uploaderName'] ?? ''}',
                    style: Theme.of(context).textTheme.bodySmall),
                trailing: Chip(
                  label: Text(f['type'] ?? 'FILE',
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 11)),
                  backgroundColor: AppColors.accentBluePastel,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFileDialog(context),
        backgroundColor: folder.color,
        foregroundColor: AppColors.white,
        child: const Icon(Icons.upload_file_outlined),
      ),
    );
  }

  void _showAddFileDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add File Reference'),
        content: TextField(controller: ctrl, autofocus: true,
            decoration: const InputDecoration(
                hintText: 'File name (e.g. Design.pdf)')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              Navigator.pop(context);
              final name = ctrl.text.trim();
              final ext = name.contains('.') ? name.split('.').last.toUpperCase() : 'FILE';
              await svc.addFileMetadata(folderId: folder.id, uploadedBy: uid,
                  uploaderName: userName, name: name, type: ext);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ACTIVITY TAB
// ══════════════════════════════════════════════════════════════════════════════

class _ActivityTab extends StatelessWidget {
  const _ActivityTab({required this.folder, required this.svc});
  final FolderModel folder;
  final FolderDataService svc;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FolderActivity>>(
      stream: svc.getActivity(folder.id),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final logs = snap.data ?? [];
        if (logs.isEmpty) {
          return const _EmptyHint(icon: Icons.history, text: 'No activity yet.');
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppDimens.md),
          itemCount: logs.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppDimens.xs),
          itemBuilder: (_, i) {
            final log = logs[i];
            return ListTile(
              leading: CircleAvatar(
                radius: 18, backgroundColor: AppColors.primaryPastel,
                child: Text(
                    log.userName.isNotEmpty ? log.userName[0].toUpperCase() : '?',
                    style: const TextStyle(color: AppColors.primaryLight,
                        fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
              ),
              title: RichText(text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(text: log.userName,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  TextSpan(text: ' ${log.action}'),
                ],
              )),
              subtitle: Text(_timeAgo(log.timestamp),
                  style: Theme.of(context).textTheme.bodySmall),
            );
          },
        );
      },
    );
  }

  String _timeAgo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${t.day}/${t.month}/${t.year}';
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CHAT TAB
// ══════════════════════════════════════════════════════════════════════════════

class _ChatTab extends StatefulWidget {
  const _ChatTab(
      {required this.folder, required this.uid, required this.userName, required this.svc});
  final FolderModel folder;
  final String uid, userName;
  final FolderDataService svc;

  @override
  State<_ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<_ChatTab> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _sending = false;

  @override
  void dispose() { _ctrl.dispose(); _scrollCtrl.dispose(); super.dispose(); }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _sending) return;
    _ctrl.clear();
    setState(() => _sending = true);
    await widget.svc.sendMessage(folderId: widget.folder.id,
        senderId: widget.uid, senderName: widget.userName, text: text);
    setState(() => _sending = false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: AppDimens.durationNormal, curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
        child: StreamBuilder<List<FolderMessage>>(
          stream: widget.svc.getMessages(widget.folder.id),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final msgs = snap.data ?? [];
            if (msgs.isEmpty) {
              return const _EmptyHint(icon: Icons.chat_bubble_outline,
                  text: 'No messages yet.\nSay hi to the team!');
            }
            return ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(AppDimens.md),
              itemCount: msgs.length,
              itemBuilder: (_, i) {
                final m = msgs[i];
                final isMe = m.senderId == widget.uid;
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: AppDimens.sm),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.md, vertical: AppDimens.sm),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.72),
                    decoration: BoxDecoration(
                      color: isMe ? AppColors.primaryLight
                          : (isDark ? AppColors.cardDark : AppColors.surfaceLight),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(AppDimens.radiusMd),
                        topRight: const Radius.circular(AppDimens.radiusMd),
                        bottomLeft: Radius.circular(isMe ? AppDimens.radiusMd : 4),
                        bottomRight: Radius.circular(isMe ? 4 : AppDimens.radiusMd),
                      ),
                      boxShadow: AppShadows.card,
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        if (!isMe)
                          Text(m.senderName,
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: widget.folder.color)),
                        Text(m.text,
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 14,
                                color: isMe ? AppColors.white
                                    : Theme.of(context).colorScheme.onSurface)),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      // Input bar
      Container(
        padding: EdgeInsets.fromLTRB(AppDimens.md, AppDimens.sm, AppDimens.sm,
            MediaQuery.of(context).viewInsets.bottom + AppDimens.sm),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 12, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          top: false,
          child: Row(children: [
            Expanded(child: TextField(controller: _ctrl,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: const InputDecoration(hintText: 'Message the team…'))),
            IconButton(
              onPressed: _sending ? null : _send,
              icon: _sending
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.send_rounded, color: AppColors.primaryLight),
            ),
          ]),
        ),
      ),
    ]);
  }
}

// ── Shared helper ─────────────────────────────────────────────────────────────

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 56, color: Theme.of(context).colorScheme.onSurfaceVariant),
      const SizedBox(height: AppDimens.md),
      Text(text, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
    ]),
  );
}
