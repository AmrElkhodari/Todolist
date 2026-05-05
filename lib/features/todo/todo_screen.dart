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
                  child: _SummaryCard(
                      total: tasks.length, done: tasks.length - pending),
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
                    (context, i) =>
                        _TaskCard(task: tasks[i], service: service),
                    childCount: tasks.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            _showAddTaskSheet(context, uid, TaskService()),
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Task',
            style: TextStyle(
                fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _showAddTaskSheet(
      BuildContext context, String uid, TaskService service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimens.radiusLg)),
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
              style: TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text('$done of $total tasks done',
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700)),
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

// ── Expandable Task Card ──────────────────────────────────────────────────────

class _TaskCard extends StatefulWidget {
  const _TaskCard({required this.task, required this.service});
  final TaskModel task;
  final TaskService service;

  @override
  State<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<_TaskCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: AppDimens.durationNormal);
    _expandAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _controller.forward() : _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = widget.task;

    return Dismissible(
      key: Key(t.id),
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
      onDismissed: (_) => widget.service.deleteTask(t.id),
      child: GestureDetector(
        onTap: _toggle,
        child: AnimatedContainer(
          duration: AppDimens.durationNormal,
          margin: const EdgeInsets.symmetric(
              horizontal: AppDimens.md, vertical: AppDimens.xs),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            boxShadow: isDark ? AppShadows.cardDark : AppShadows.card,
            border: t.isOverdue
                ? Border.all(
                    color: AppColors.error.withValues(alpha: 0.4), width: 1)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Main row ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.md, vertical: AppDimens.sm),
                child: Row(
                  children: [
                    Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(
                          color: t.color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: AppDimens.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.title,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  decoration: t.done
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: t.done
                                      ? Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                      : null,
                                ),
                          ),
                          if (t.dueDate != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 11,
                                    color: t.isOverdue
                                        ? AppColors.error
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    _formatDate(t.dueDate!),
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11,
                                      color: t.isOverdue
                                          ? AppColors.error
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Expand chevron
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: AppDimens.durationNormal,
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 18,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: AppDimens.sm),
                    // Checkbox
                    GestureDetector(
                      onTap: () =>
                          widget.service.toggleTask(t.id, !t.done),
                      child: AnimatedContainer(
                        duration: AppDimens.durationNormal,
                        width: 26, height: 26,
                        decoration: BoxDecoration(
                          color: t.done
                              ? AppColors.primaryLight
                              : Colors.transparent,
                          border: Border.all(
                            color: t.done
                                ? AppColors.primaryLight
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: t.done
                            ? const Icon(Icons.check,
                                size: 16, color: AppColors.white)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Expandable description panel ──────────────────────────
              SizeTransition(
                sizeFactor: _expandAnim,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(
                      AppDimens.md, 0, AppDimens.md, AppDimens.md),
                  padding: const EdgeInsets.all(AppDimens.md),
                  decoration: BoxDecoration(
                    color: t.color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                  ),
                  child: Text(
                    t.description.isEmpty
                        ? 'No description.'
                        : t.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year}';
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
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  int _colorIndex  = 0;
  DateTime? _dueDate;
  bool _saving     = false;

  static const _colors = [
    AppColors.accentMint, AppColors.accentBlue,
    AppColors.accentOrange, AppColors.accentPink,
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    await widget.service.addTask(
      userId: widget.uid,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      colorIndex: _colorIndex,
      dueDate: _dueDate,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          AppDimens.lg, AppDimens.lg, AppDimens.lg,
          MediaQuery.of(context).viewInsets.bottom + AppDimens.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New Task', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppDimens.md),

          // Title
          TextField(
            controller: _titleCtrl,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Task title (required)'),
          ),
          const SizedBox(height: AppDimens.md),

          // Description
          TextField(
            controller: _descCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Description (optional)',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: AppDimens.md),

          // Due date
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today_outlined, size: 16),
                  label: Text(
                    _dueDate == null
                        ? 'Set due date (optional)'
                        : 'Due: ${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                  ),
                ),
              ),
              if (_dueDate != null) ...[
                const SizedBox(width: AppDimens.sm),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => setState(() => _dueDate = null),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppDimens.md),

          // Color
          Text('Color', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppDimens.sm),
          Row(
            children: List.generate(
              _colors.length,
              (i) => GestureDetector(
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
              ),
            ),
          ),
          const SizedBox(height: AppDimens.lg),

          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: AppColors.white))
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
    child: Column(children: [
      Icon(Icons.check_circle_outline,
          size: 64,
          color: Theme.of(context).colorScheme.onSurfaceVariant),
      const SizedBox(height: AppDimens.md),
      Text('No tasks yet', style: Theme.of(context).textTheme.bodyMedium),
      Text('Tap + to add your first task',
          style: Theme.of(context).textTheme.bodySmall),
    ]),
  );
}
