import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/design_system.dart';

class HabitHistoryCalendar extends StatefulWidget {
  final List<DateTime> completedDates;
  final DateTime createdDate;

  const HabitHistoryCalendar({
    super.key,
    required this.completedDates,
    required this.createdDate,
  });

  @override
  State<HabitHistoryCalendar> createState() => _HabitHistoryCalendarState();
}

class _HabitHistoryCalendarState extends State<HabitHistoryCalendar> {
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
    final firstDayOffset = DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday % 7;
    final totalCells = daysInMonth + firstDayOffset;
    final rows = (totalCells / 7).ceil();

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final completedSet = widget.completedDates.map((d) => DateTime(d.year, d.month, d.day)).toSet();

    return Column(
      children: [
        // ── Calendar Header ──────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'History',
                style: AppTypography.titleMedium.copyWith(fontSize: 18),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: Implement month picker dialog if needed
                },
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      DateFormat('MMMM yyyy').format(_focusedMonth),
                      style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded, size: 20),
                      onPressed: _previousMonth,
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded, size: 20),
                      onPressed: _nextMonth,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Days of Week Labels ──────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((label) {
            return SizedBox(
              width: 32,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: AppTypography.labelMedium.copyWith(color: AppColors.textTertiary),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.sm),

        // ── Calendar Grid ────────────────────────────────────────
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 0,
          ),
          itemCount: rows * 7,
          itemBuilder: (context, index) {
            final day = index - firstDayOffset + 1;
            if (day < 1 || day > daysInMonth) return const SizedBox.shrink();

            final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
            final dateOnly = DateTime(date.year, date.month, date.day);

            final isCompleted = completedSet.contains(dateOnly);
            final isToday = dateOnly == todayOnly;
            final isMissed = !isCompleted && !isToday && dateOnly.isBefore(todayOnly) && !dateOnly.isBefore(DateTime(widget.createdDate.year, widget.createdDate.month, widget.createdDate.day));

            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCompleted ? AppColors.primary : Colors.transparent,
                      shape: BoxShape.circle,
                      border: isToday && !isCompleted
                          ? Border.all(color: AppColors.primary, width: 1.5)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$day',
                      style: AppTypography.bodySmall.copyWith(
                        color: isCompleted
                            ? AppColors.textOnPrimary
                            : isMissed
                                ? AppColors.habitCoral
                                : AppColors.textPrimary,
                        fontWeight: isToday || isCompleted ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (isCompleted)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Legend ────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _LegendItem(color: AppColors.primary, label: 'Completed'),
            _LegendItem(color: AppColors.habitCoral.withOpacity(0.2), label: 'Missed', textColor: AppColors.habitCoral),
            _LegendItem(color: Colors.transparent, label: 'Today', borderColor: AppColors.primary),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final Color? textColor;
  final Color? borderColor;

  const _LegendItem({
    required this.color,
    required this.label,
    this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: borderColor != null ? Border.all(color: borderColor!) : null,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(color: textColor ?? AppColors.textSecondary),
        ),
      ],
    );
  }
}
