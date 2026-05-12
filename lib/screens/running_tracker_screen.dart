import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/user_model.dart';
import '../services/fitness_service.dart';

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
    
    // Save to FitnessService
    final fitness = context.read<FitnessService>();
    fitness.addWorkoutResult(
      calories: _calories,
      steps: (_distanceKm * 1300).round(), // 1km approx 1300 steps
      durationMinutes: _elapsedSeconds ~/ 60,
    );

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
                            decoration: const BoxDecoration(
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
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            decoration: const BoxDecoration(
              color: Color(0xFF141414),
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  // Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 24),
                      Text(
                        widget.sport.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 22,
                            ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.open_in_full_rounded, color: Colors.white, size: 18),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Stats Grid
                  Row(
                    children: [
                      Expanded(child: _StatCard(value: _formattedTime, label: 'Time')),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(value: _distanceKm.toStringAsFixed(2).replaceAll('.', ','), label: 'Distance (km)')),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(value: _pace, label: 'Pace (/km)')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _StatCard(
                          value: '$_heartRate',
                          label: 'Heart Rate (bpm)',
                          extra: _HeartRateBar(bpm: _heartRate),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(value: '$_calories', label: 'Calories (kcal)'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Pause button
                  GestureDetector(
                    onTap: _toggleRunning,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: AppTheme.accent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x4DCBEF43), // AppTheme.accent with alpha
                            blurRadius: 15,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: Icon(
                        _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.black,
                        size: 40,
                      ),
                    ),
                  ),
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
      color: const Color(0xFF141D2C),
      child: Stack(
        children: [
          // Grid lines
          CustomPaint(
            size: Size.infinite,
            painter: _MapGridPainter(),
          ),
          // Map Labels
          const Positioned(
            top: 100,
            left: 80,
            child: _MapLabel(text: 'Perpustakaan ITS'),
          ),
          const Positioned(
            top: 200,
            right: 60,
            child: _MapLabel(text: 'Taman Sepuluh Nopember'),
          ),
          const Positioned(
            bottom: 300,
            left: 50,
            child: _MapLabel(text: 'BAAK ITS', isHighlight: true),
          ),
          const Positioned(
            bottom: 250,
            right: 40,
            child: _MapLabel(text: 'Titik Nol ITS', isHighlight: true),
          ),
          // Route path
          CustomPaint(
            size: Size.infinite,
            painter: _RoutePainter(),
          ),
          // Location pins
          Positioned(
            bottom: 280,
            right: 150,
            child: Icon(Icons.location_on, color: Colors.purple.shade300, size: 24),
          ),
          Positioned(
            top: 150,
            right: 100,
            child: Icon(Icons.location_on, color: Colors.yellow.shade300, size: 24),
          ),
        ],
      ),
    );
  }
}

class _MapLabel extends StatelessWidget {
  final String text;
  final bool isHighlight;

  const _MapLabel({required this.text, this.isHighlight = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: isHighlight ? const Color(0xFFCBEF43).withValues(alpha: 0.8) : Colors.grey.withValues(alpha: 0.5),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFF2C3E50).withValues(alpha: 0.3)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    final roadPaintThin = Paint()
      ..color = const Color(0xFF34495E).withValues(alpha: 0.2)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // Simulate roads
    final path = Path()
      ..moveTo(0, 100)
      ..lineTo(size.width, 150)
      ..moveTo(100, 0)
      ..lineTo(120, size.height)
      ..moveTo(size.width * 0.7, 0)
      ..lineTo(size.width * 0.8, size.height);
    
    canvas.drawPath(path, roadPaintThin);

    final path2 = Path()
      ..moveTo(size.width * 0.2, 0)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.5, size.width * 0.8, size.height)
      ..moveTo(0, size.height * 0.7)
      ..lineTo(size.width, size.height * 0.6);
    
    canvas.drawPath(path2, roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8B4513) // Brownish/Orange path
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final glowPaint = Paint()
      ..color = const Color(0xFF8B4513).withValues(alpha: 0.3)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    final path = Path()
      ..moveTo(cx - 100, cy + 150)
      ..lineTo(cx - 120, cy + 50)
      ..lineTo(cx - 80, cy - 50)
      ..lineTo(cx + 50, cy - 80)
      ..lineTo(cx + 120, cy - 40)
      ..lineTo(cx + 120, cy + 100)
      ..lineTo(cx + 20, cy + 120);

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);

    // Current position
    final headPaint = Paint()..color = const Color(0xFF3498DB); // Blue head
    canvas.drawCircle(Offset(cx + 20, cy + 120), 8, headPaint);
    canvas.drawCircle(Offset(cx + 20, cy + 120), 14, Paint()..color = const Color(0xFF3498DB).withValues(alpha: 0.3));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Widget? extra;

  const _StatCard({required this.value, required this.label, this.extra});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (extra != null) ...[
            const SizedBox(height: 4),
            extra!,
          ],
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeartRateBar extends StatelessWidget {
  final int bpm;

  const _HeartRateBar({required this.bpm});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      width: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Expanded(child: _segment(Colors.green.withValues(alpha: 0.5), true)),
          const SizedBox(width: 2),
          Expanded(child: _segment(Colors.green, false)),
          const SizedBox(width: 2),
          Expanded(child: _segment(Colors.yellow, false)),
          const SizedBox(width: 2),
          Expanded(child: _segment(Colors.orange, false)),
          const SizedBox(width: 2),
          Expanded(child: _segment(Colors.red, false, true)),
        ],
      ),
    );
  }

  Widget _segment(Color color, [bool first = false, bool last = false]) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.horizontal(
          left: first ? const Radius.circular(4) : Radius.zero,
          right: last ? const Radius.circular(4) : Radius.zero,
        ),
      ),
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
