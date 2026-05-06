import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ActivityRingsWidget extends StatelessWidget {
  final double caloriesProgress; // 0.0 to 1.0
  final double stepsProgress;
  final double moveProgress;
  final double size;

  const ActivityRingsWidget({
    super.key,
    required this.caloriesProgress,
    required this.stepsProgress,
    required this.moveProgress,
    this.size = 180,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ActivityRingsPainter(
          caloriesProgress: caloriesProgress,
          stepsProgress: stepsProgress,
          moveProgress: moveProgress,
        ),
        child: Center(
          child: Icon(
            Icons.favorite_rounded,
            color: AppTheme.accent.withValues(alpha: 0.7),
            size: size * 0.2,
          ),
        ),
      ),
    );
  }
}

class _ActivityRingsPainter extends CustomPainter {
  final double caloriesProgress;
  final double stepsProgress;
  final double moveProgress;

  _ActivityRingsPainter({
    required this.caloriesProgress,
    required this.stepsProgress,
    required this.moveProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 14.0;
    const gap = 10.0;

    _drawRing(
      canvas: canvas,
      center: center,
      radius: size.width / 2 - strokeWidth / 2,
      progress: caloriesProgress,
      color: AppTheme.ringCalories,
      strokeWidth: strokeWidth,
    );
    _drawRing(
      canvas: canvas,
      center: center,
      radius: size.width / 2 - strokeWidth / 2 - strokeWidth - gap,
      progress: stepsProgress,
      color: AppTheme.ringSteps,
      strokeWidth: strokeWidth,
    );
    _drawRing(
      canvas: canvas,
      center: center,
      radius: size.width / 2 - strokeWidth / 2 - 2 * (strokeWidth + gap),
      progress: moveProgress,
      color: AppTheme.ringMove,
      strokeWidth: strokeWidth,
    );
  }

  void _drawRing({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required double progress,
    required Color color,
    required double strokeWidth,
  }) {
    // Background ring
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress ring
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.0, 1.0),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ActivityRingsPainter oldDelegate) {
    return oldDelegate.caloriesProgress != caloriesProgress ||
        oldDelegate.stepsProgress != stepsProgress ||
        oldDelegate.moveProgress != moveProgress;
  }
}

class WeekDayStrip extends StatelessWidget {
  final int currentDay; // 0 = Monday

  const WeekDayStrip({super.key, required this.currentDay});

  @override
  Widget build(BuildContext context) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    const dayNums = [20, 21, 22, 23, 24, 25, 26, 27];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final isToday = i == currentDay;
        final isPast = i < currentDay;
        return _DayChip(
          day: days[i],
          date: dayNums[i],
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
