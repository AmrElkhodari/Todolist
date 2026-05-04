import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/task_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/task_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/constants/app_dimens.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().user!.uid;
    final service = TaskService();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<TaskModel>>(
        stream: service.getUserTasks(uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final tasks = snap.data ?? [];
          final pending = tasks.where((t) => !t.done).length;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.md),
                  child: _SummaryCard(total: tasks.length, done: tasks.length - pending),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppDimens.md, 0, AppDimens.md, AppDimens.sm),
                  child: Text('My Tasks',
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
              ),
              if (tasks.isEmpty)
                const SliverToBoxAdapter(child: _EmptyState())
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _TaskCard(
                      task: tasks[i],
                      service: service,
                    ),
                    childCount: tasks.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskSheet(context, uid, TaskService()),
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Task',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context, String uid, TaskService service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusLg)),
      ),
      builder: (_) => _AddTaskSheet(uid: uid, service: service),
    );
  }
}

// ── Summary Card ──────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.total, required this.done});
  final int total;
  final int done;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : done / total;
    return Container(
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryLight, Color(0xFF9C6FFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        boxShadow: AppShadows.floating,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('My Progress',
              style: TextStyle(fontFamily: 'Poppins', color: AppColors.white,
                  fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text('$done of $total tasks done',
              style: const TextStyle(fontFamily: 'Poppins', color: AppColors.white,
                  fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppDimens.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation(AppColors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Task Card ─────────────────────────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task, required this.service});
  final TaskModel task;
  final TaskService service;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppDimens.lg),
        margin: const EdgeInsets.symmetric(
            horizontal: AppDimens.md, vertical: AppDimens.xs),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.error),
      ),
      onDismissed: (_) => service.deleteTask(task.id),
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: AppDimens.md, vertical: AppDimens.xs),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          boxShadow: isDark ? AppShadows.cardDark : AppShadows.card,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimens.md, vertical: AppDimens.xs),
          leading: Container(
            width: 12, height: 12,
            decoration: BoxDecoration(color: task.color, shape: BoxShape.circle),
          ),
          title: Text(
            task.title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  decoration: task.done ? TextDecoration.lineThrough : null,
                  color: task.done
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : null,
                ),
          ),
          trailing: GestureDetector(
            onTap: () => service.toggleTask(task.id, !task.done),
            child: AnimatedContainer(
              duration: AppDimens.durationNormal,
              width: 26, height: 26,
              decoration: BoxDecoration(
                color: task.done ? AppColors.primaryLight : Colors.transparent,
                border: Border.all(
                  color: task.done
                      ? AppColors.primaryLight
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: task.done
                  ? const Icon(Icons.check, size: 16, color: AppColors.white)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Add Task Bottom Sheet ─────────────────────────────────────────────────────

class _AddTaskSheet extends StatefulWidget {
  const _AddTaskSheet({required this.uid, required this.service});
  final String uid;
  final TaskService service;

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _ctrl = TextEditingController();
  int _colorIndex = 0;
  bool _saving = false;

  static const _colors = [
    AppColors.accentMint, AppColors.accentBlue,
    AppColors.accentOrange, AppColors.accentPink,
  ];

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    await widget.service.addTask(
        userId: widget.uid,
        title: _ctrl.text.trim(),
        colorIndex: _colorIndex);
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
          Text('New Task', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppDimens.md),
          TextField(
            controller: _ctrl,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
            decoration: const InputDecoration(hintText: 'Task title…'),
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
                width: 36, height: 36,
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
          const SizedBox(height: AppDimens.lg),
          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5,
                          color: AppColors.white))
                  : const Text('Add Task'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppDimens.xl),
    child: Column(
      children: [
        Icon(Icons.check_circle_outline,
            size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(height: AppDimens.md),
        Text('No tasks yet', style: Theme.of(context).textTheme.bodyMedium),
        Text('Tap + to add your first task',
            style: Theme.of(context).textTheme.bodySmall),
      ],
    ),
  );
}
