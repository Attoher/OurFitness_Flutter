import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WeekDayStrip extends StatelessWidget {
  final int currentDay; // 0 = Monday

  const WeekDayStrip({super.key, required this.currentDay});

  @override
  Widget build(BuildContext context) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    
    // Calculate dates for the current week (starting Monday)
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekDates = List.generate(7, (i) => monday.add(Duration(days: i)).day);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final isToday = i == currentDay;
        final isPast = i < currentDay;
        return _DayChip(
          day: days[i],
          date: weekDates[i],
          isToday: isToday,
          isPast: isPast,
        );
      }),
    );
  }
}

class _DayChip extends StatelessWidget {
  final String day;
  final int date;
  final bool isToday;
  final bool isPast;

  const _DayChip({
    required this.day,
    required this.date,
    required this.isToday,
    required this.isPast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          day,
          style: TextStyle(
            fontSize: 11,
            color: isToday
                ? AppTheme.accent
                : isPast
                    ? AppTheme.textSecondary
                    : AppTheme.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isToday ? AppTheme.accent : Colors.transparent,
            shape: BoxShape.circle,
            border: isPast && !isToday
                ? Border.all(color: AppTheme.textMuted, width: 1)
                : null,
          ),
          child: Center(
            child: Text(
              '$date',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isToday
                    ? AppTheme.background
                    : isPast
                        ? AppTheme.textSecondary
                        : AppTheme.textMuted,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
