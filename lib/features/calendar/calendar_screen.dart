import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/task_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/task_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/constants/app_dimens.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime.now();
  int? _selectedDay;

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().user!.uid;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<TaskModel>>(
        stream: TaskService().getUserTasks(uid),
        builder: (context, snap) {
          final tasks = snap.data ?? [];

          // Group tasks by the due date if set, otherwise by creation date.
          final tasksByDay = <int, List<TaskModel>>{};
          for (final t in tasks) {
            final date = t.dueDate ?? t.createdAt;
            if (date.year == _focusedMonth.year &&
                date.month == _focusedMonth.month) {
              tasksByDay.putIfAbsent(date.day, () => []).add(t);
            }
          }

          final selectedTasks = _selectedDay != null
              ? (tasksByDay[_selectedDay] ?? [])
              : <TaskModel>[];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Calendar Card ──────────────────────────────────────
                _CalendarCard(
                  focusedMonth: _focusedMonth,
                  selectedDay: _selectedDay,
                  tasksByDay: tasksByDay,
                  onMonthChanged: (d) =>
                      setState(() { _focusedMonth = d; _selectedDay = null; }),
                  onDaySelected: (d) => setState(() => _selectedDay = d),
                ),
                const SizedBox(height: AppDimens.lg),

                // ── Tasks for selected day ─────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDay != null
                          ? 'Tasks on ${_months[_focusedMonth.month - 1]} $_selectedDay'
                          : 'All Tasks This Month',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    if (snap.connectionState == ConnectionState.waiting)
                      const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: AppDimens.sm),

                if (selectedTasks.isEmpty && _selectedDay != null)
                  _EmptyDay()
                else if (_selectedDay == null && tasks.isEmpty)
                  _EmptyDay()
                else
                  ...((_selectedDay != null ? selectedTasks : tasks)
                      .map((t) => _TaskTile(task: t))),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Calendar Card ─────────────────────────────────────────────────────────────

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.focusedMonth,
    required this.selectedDay,
    required this.tasksByDay,
    required this.onMonthChanged,
    required this.onDaySelected,
  });

  final DateTime focusedMonth;
  final int? selectedDay;
  final Map<int, List<TaskModel>> tasksByDay;
  final void Function(DateTime) onMonthChanged;
  final void Function(int) onDaySelected;

  static const _weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final daysInMonth =
        DateUtils.getDaysInMonth(focusedMonth.year, focusedMonth.month);
    final firstWeekday =
        DateTime(focusedMonth.year, focusedMonth.month, 1).weekday % 7;
    final today = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(AppDimens.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        boxShadow: isDark ? AppShadows.cardDark : AppShadows.card,
      ),
      child: Column(
        children: [
          // Month navigation header
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => onMonthChanged(
                    DateTime(focusedMonth.year, focusedMonth.month - 1)),
              ),
              Expanded(
                child: Text(
                  '${_months[focusedMonth.month - 1]} ${focusedMonth.year}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => onMonthChanged(
                    DateTime(focusedMonth.year, focusedMonth.month + 1)),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sm),

          // Weekday labels
          Row(
            children: _weekdays.map((w) => Expanded(
              child: Center(
                child: Text(w,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ),
            )).toList(),
          ),
          const SizedBox(height: AppDimens.sm),

          // Day grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, childAspectRatio: 1,
            ),
            itemCount: firstWeekday + daysInMonth,
            itemBuilder: (context, i) {
              if (i < firstWeekday) return const SizedBox.shrink();
              final day = i - firstWeekday + 1;
              final isToday = today.year == focusedMonth.year &&
                  today.month == focusedMonth.month && today.day == day;
              final isSelected = day == selectedDay;
              final hasTasks = tasksByDay.containsKey(day);
              final dayTasks = tasksByDay[day] ?? [];
              final allDone = dayTasks.isNotEmpty && dayTasks.every((t) => t.done);

              return GestureDetector(
                onTap: () => onDaySelected(day),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryLight
                              : isToday
                                  ? AppColors.primaryPastel
                                  : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text('$day',
                            style: TextStyle(
                              fontFamily: 'Poppins', fontSize: 13,
                              fontWeight: isToday || isSelected
                                  ? FontWeight.w700 : FontWeight.w400,
                              color: isSelected
                                  ? AppColors.white
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      if (hasTasks)
                        Container(
                          width: 5, height: 5,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            color: allDone
                                ? AppColors.accentMint
                                : AppColors.primaryLight,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Task Tile ─────────────────────────────────────────────────────────────────

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task});
  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.sm),
      padding: const EdgeInsets.all(AppDimens.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        boxShadow: isDark ? AppShadows.cardDark : AppShadows.card,
        border: Border(left: BorderSide(color: task.color, width: 4)),
      ),
      child: Row(
        children: [
          Icon(
            task.done ? Icons.check_circle : Icons.radio_button_unchecked,
            color: task.done
                ? AppColors.accentMint
                : Theme.of(context).colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: AppDimens.sm),
          Expanded(
            child: Text(
              task.title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    decoration: task.done ? TextDecoration.lineThrough : null,
                    color: task.done
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : null,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyDay extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppDimens.lg),
    child: Center(
      child: Column(
        children: [
          Icon(Icons.event_available_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: AppDimens.sm),
          Text(
            'No tasks on this day.\nAdd tasks from My Tasks tab.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    ),
  );
}
