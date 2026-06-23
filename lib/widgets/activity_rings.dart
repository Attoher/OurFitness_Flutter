import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ActivityRingsWidget extends StatefulWidget {
  final double caloriesProgress;
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
  State<ActivityRingsWidget> createState() => _ActivityRingsWidgetState();
}

class _ActivityRingsWidgetState extends State<ActivityRingsWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _sweep;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _sweep = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(ActivityRingsWidget old) {
    super.didUpdateWidget(old);
    // Re-animate when progress values change significantly
    if ((old.caloriesProgress - widget.caloriesProgress).abs() > 0.01 ||
        (old.stepsProgress - widget.stepsProgress).abs() > 0.01 ||
        (old.moveProgress - widget.moveProgress).abs() > 0.01) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return SizedBox(
      width: s,
      height: s,
      child: AnimatedBuilder(
        animation: _sweep,
        builder: (_, child) => CustomPaint(
          painter: _ActivityRingsPainter(
            caloriesProgress: widget.caloriesProgress * _sweep.value,
            stepsProgress: widget.stepsProgress * _sweep.value,
            moveProgress: widget.moveProgress * _sweep.value,
          ),
          child: child,
        ),
        child: Center(
          child: _PulsingIcon(
            icon: Icons.favorite_rounded,
            color: AppTheme.accent,
            size: s * 0.2,
          ),
        ),
      ),
    );
  }
}

class _PulsingIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;
  const _PulsingIcon({required this.icon, required this.color, required this.size});

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _opacity = Tween(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _scale = Tween(begin: 0.88, end: 1.12)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Transform.scale(
        scale: _scale.value,
        child: Icon(
          widget.icon,
          color: widget.color.withValues(alpha: _opacity.value),
          size: widget.size,
        ),
      ),
    );
  }
}

class _ActivityRingsPainter extends CustomPainter {
  final double caloriesProgress;
  final double stepsProgress;
  final double moveProgress;

  const _ActivityRingsPainter({
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
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    if (progress <= 0) return;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Subtle glow shadow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, -math.pi / 2, sweep, false, glowPaint);
    canvas.drawArc(rect, -math.pi / 2, sweep, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _ActivityRingsPainter old) =>
      old.caloriesProgress != caloriesProgress ||
      old.stepsProgress != stepsProgress ||
      old.moveProgress != moveProgress;
}
