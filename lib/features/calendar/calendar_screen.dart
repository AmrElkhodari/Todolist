import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/constants/app_dimens.dart';

/// Calendar tab — shows a month view with task events.
/// Phase 4 will wire events to Firestore.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime.now();
  int? _selectedDay;

  // Dummy events keyed by day-of-month
  final Map<int, List<_Event>> _events = {
    5:  [_Event('Team Standup', AppColors.accentMint)],
    10: [_Event('Design Review', AppColors.accentBlue), _Event('Sprint Planning', AppColors.accentPink)],
    15: [_Event('Client Demo', AppColors.accentOrange)],
    20: [_Event('Deadline: Prototype', AppColors.error)],
    25: [_Event('Monthly Retro', AppColors.primaryLight)],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Calendar Card ────────────────────────────────────────
            _CalendarCard(
              focusedMonth: _focusedMonth,
              selectedDay: _selectedDay,
              events: _events,
              onMonthChanged: (d) => setState(() => _focusedMonth = d),
              onDaySelected: (d) => setState(() => _selectedDay = d),
            ),
            const SizedBox(height: AppDimens.lg),

            // ── Events for selected day ──────────────────────────────
            Text('Events', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppDimens.sm),
            if (_selectedDay != null && _events.containsKey(_selectedDay))
              ..._events[_selectedDay]!.map((e) => _EventTile(event: e))
            else
              _EmptyEvents(selectedDay: _selectedDay),
          ],
        ),
      ),
    );
  }
}

// ── Calendar Card ─────────────────────────────────────────────────────────────

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.focusedMonth,
    required this.selectedDay,
    required this.events,
    required this.onMonthChanged,
    required this.onDaySelected,
  });

  final DateTime focusedMonth;
  final int? selectedDay;
  final Map<int, List<_Event>> events;
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
          // Header
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => onMonthChanged(
                  DateTime(focusedMonth.year, focusedMonth.month - 1),
                ),
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
                  DateTime(focusedMonth.year, focusedMonth.month + 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sm),

          // Weekday labels
          Row(
            children: _weekdays
                .map((w) => Expanded(
                      child: Center(
                        child: Text(w,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontWeight: FontWeight.w600)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: AppDimens.sm),

          // Day grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: firstWeekday + daysInMonth,
            itemBuilder: (context, i) {
              if (i < firstWeekday) return const SizedBox.shrink();
              final day = i - firstWeekday + 1;
              final isToday = today.year == focusedMonth.year &&
                  today.month == focusedMonth.month &&
                  today.day == day;
              final isSelected = day == selectedDay;
              final hasEvent = events.containsKey(day);

              return GestureDetector(
                onTap: () => onDaySelected(day),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryLight
                              : isToday
                                  ? AppColors.primaryPastel
                                  : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$day',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: isToday || isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: isSelected
                                  ? AppColors.white
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      if (hasEvent)
                        Container(
                          width: 5,
                          height: 5,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryLight,
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

// ── Event Tile ────────────────────────────────────────────────────────────────

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});
  final _Event event;

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
        border: Border(
          left: BorderSide(color: event.color, width: 4),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_note_outlined, size: 20),
          const SizedBox(width: AppDimens.sm),
          Text(event.title, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _EmptyEvents extends StatelessWidget {
  const _EmptyEvents({required this.selectedDay});
  final int? selectedDay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.lg),
      child: Center(
        child: Text(
          selectedDay == null
              ? 'Tap a day to see events'
              : 'No events on this day',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}

class _Event {
  const _Event(this.title, this.color);
  final String title;
  final Color color;
}
