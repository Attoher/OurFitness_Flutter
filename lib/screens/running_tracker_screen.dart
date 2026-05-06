import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/user_model.dart';

class RunningTrackerScreen extends StatefulWidget {
  final Sport sport;

  const RunningTrackerScreen({super.key, required this.sport});

  @override
  State<RunningTrackerScreen> createState() => _RunningTrackerScreenState();
}

class _RunningTrackerScreenState extends State<RunningTrackerScreen> {
  bool _isRunning = true;
  int _elapsedSeconds = 0;
  double _distanceKm = 0.0;
  int _heartRate = 152;
  int _calories = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  void _startTracking() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isRunning) {
        setState(() {
          _elapsedSeconds++;
          _distanceKm += 0.0014; // ~5 km/h pace simulation
          _calories = (_distanceKm * 73).round();
          // Simulate HR variation
          if (_elapsedSeconds % 5 == 0) {
            _heartRate = 145 + (_elapsedSeconds % 20);
          }
        });
      }
    });
  }

  void _toggleRunning() => setState(() => _isRunning = !_isRunning);

  void _finishWorkout() {
    _timer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _WorkoutSummaryDialog(
        sport: widget.sport.name,
        duration: _formattedTime,
        distance: _distanceKm,
        calories: _calories,
        heartRate: _heartRate,
        onDone: () {
          Navigator.of(context)
            ..pop()
            ..pop();
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final h = _elapsedSeconds ~/ 3600;
    final m = (_elapsedSeconds % 3600) ~/ 60;
    final s = _elapsedSeconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get _pace {
    if (_distanceKm < 0.01) return '--:--';
    final secondsPerKm = _elapsedSeconds / _distanceKm;
    final m = (secondsPerKm ~/ 60);
    final s = (secondsPerKm % 60).toInt();
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Map area
          Expanded(
            child: Stack(
              children: [
                // Map placeholder
                _MapPlaceholder(),
                // Top bar
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.background.withValues(alpha: 0.8),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.background.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _isRunning ? Colors.red : AppTheme.textSecondary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isRunning ? 'LIVE' : 'PAUSED',
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _finishWorkout,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.accent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.stop_rounded, color: AppTheme.background),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Stats panel
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            decoration: const BoxDecoration(
              color: Color(0xFF141414),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  // Sport label
                  Row(
                    children: [
                      Text(
                        widget.sport.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const Spacer(),
                      Icon(
                        Icons.open_in_full_rounded,
                        color: AppTheme.textSecondary,
                        size: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Main stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _TrackerStat(
                        label: 'Duration',
                        value: _formattedTime,
                        unit: '',
                      ),
                      _TrackerDivider(),
                      _TrackerStat(
                        label: 'Distance (km)',
                        value: _distanceKm.toStringAsFixed(2),
                        unit: 'km',
                      ),
                      _TrackerDivider(),
                      _TrackerStat(
                        label: 'Pace/km',
                        value: _pace,
                        unit: 'min/km',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Secondary stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Heart rate
                      Row(
                        children: [
                          const Icon(Icons.favorite_rounded, color: AppTheme.heartRate, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '$_heartRate',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          _HeartRateBar(bpm: _heartRate),
                        ],
                      ),
                      // Calories
                      Row(
                        children: [
                          const Icon(Icons.local_fire_department_rounded,
                              color: AppTheme.accent, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '$_calories',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text('KCAL',
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Pause/Resume button
                  GestureDetector(
                    onTap: _toggleRunning,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _isRunning ? AppTheme.accent : AppTheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: _isRunning
                            ? [
                                BoxShadow(
                                  color: AppTheme.accent.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : null,
                      ),
                      child: Icon(
                        _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: _isRunning ? AppTheme.background : AppTheme.textPrimary,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A2030),
      child: Stack(
        children: [
          // Grid lines
          CustomPaint(
            size: Size.infinite,
            painter: _MapGridPainter(),
          ),
          // Route path
          CustomPaint(
            size: Size.infinite,
            painter: _RoutePainter(),
          ),
          // Location pin
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on_rounded, size: 28, color: AppTheme.accent),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 0.5;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accent
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    final path = Path()
      ..moveTo(cx - 60, cy + 80)
      ..lineTo(cx - 80, cy)
      ..lineTo(cx - 40, cy - 60)
      ..lineTo(cx + 20, cy - 80)
      ..lineTo(cx + 80, cy - 40)
      ..lineTo(cx + 60, cy + 40)
      ..lineTo(cx, cy + 80);

    canvas.drawPath(path, paint);

    // Current position dot
    canvas.drawCircle(
      Offset(cx, cy + 80),
      8,
      Paint()..color = AppTheme.accent,
    );
    canvas.drawCircle(
      Offset(cx, cy + 80),
      14,
      Paint()
        ..color = AppTheme.accent.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrackerStat extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _TrackerStat({required this.label, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            )),
        Text(label,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
      ],
    );
  }
}

class _TrackerDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: AppTheme.surfaceLight,
    );
  }
}

class _HeartRateBar extends StatelessWidget {
  final int bpm;

  const _HeartRateBar({required this.bpm});

  @override
  Widget build(BuildContext context) {
    final zones = [
      {'label': 'Zone 1', 'color': Colors.blue, 'range': [0, 100]},
      {'label': 'Zone 2', 'color': Colors.green, 'range': [100, 120]},
      {'label': 'Zone 3', 'color': Colors.yellow, 'range': [120, 140]},
      {'label': 'Zone 4', 'color': Colors.orange, 'range': [140, 160]},
      {'label': 'Zone 5', 'color': Colors.red, 'range': [160, 200]},
    ];

    Color activeColor = Colors.red;
    for (final z in zones) {
      final range = z['range'] as List<int>;
      if (bpm >= range[0] && bpm < range[1]) {
        activeColor = z['color'] as Color;
        break;
      }
    }

    return Row(
      children: List.generate(5, (i) {
        return Container(
          width: 4,
          height: 12 + i * 3.0,
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            color: i <= 3 ? activeColor : AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}

class _WorkoutSummaryDialog extends StatelessWidget {
  final String sport;
  final String duration;
  final double distance;
  final int calories;
  final int heartRate;
  final VoidCallback onDone;

  const _WorkoutSummaryDialog({
    required this.sport,
    required this.duration,
    required this.distance,
    required this.calories,
    required this.heartRate,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration_rounded, size: 48, color: AppTheme.accent),
            const SizedBox(height: 12),
            Text(
              'Workout Complete!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(sport, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SummaryItem(icon: Icons.timer_rounded, value: duration, label: 'Duration'),
                _SummaryItem(icon: Icons.location_on_rounded, value: '${distance.toStringAsFixed(2)} km', label: 'Distance'),
                _SummaryItem(icon: Icons.local_fire_department_rounded, value: '$calories', label: 'Calories'),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onDone,
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _SummaryItem({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: AppTheme.accent),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
