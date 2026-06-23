import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/user_model.dart';
import '../services/fitness_service.dart';
import '../services/location_service.dart';
import '../services/theme_service.dart';

class RunningTrackerScreen extends StatefulWidget {
  final Sport sport;

  const RunningTrackerScreen({super.key, required this.sport});

  @override
  State<RunningTrackerScreen> createState() => _RunningTrackerScreenState();
}

class _RunningTrackerScreenState extends State<RunningTrackerScreen> {
  bool _isRunning = true;
  int _elapsedSeconds = 0;
  int _heartRate = 152;
  Timer? _timer;
  final _mapController = MapController();
  LocationService? _locationService;

  static const _defaultCenter = LatLng(-7.2756, 112.7947);

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _locationService = context.read<LocationService>();
      _locationService!.addListener(_onLocationUpdate);
      _locationService!.startTracking();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isRunning) {
        setState(() {
          _elapsedSeconds++;
          if (_elapsedSeconds % 5 == 0) {
            _heartRate = 145 + (_elapsedSeconds % 20);
          }
        });
      }
    });
  }

  void _onLocationUpdate() {
    if (!mounted) return;
    setState(() {});
    final pos = _locationService?.currentPosition;
    if (pos != null && _isRunning) {
      _mapController.move(LatLng(pos.latitude, pos.longitude), 17);
    }
  }

  void _toggleRunning() {
    setState(() => _isRunning = !_isRunning);
    if (_isRunning) {
      _locationService?.resumeTracking();
    } else {
      _locationService?.pauseTracking();
    }
  }

  void _finishWorkout() {
    _timer?.cancel();
    _locationService?.removeListener(_onLocationUpdate);
    _locationService?.stopTracking();

    final distanceKm = _locationService?.totalDistanceKm ?? 0.0;
    final routeData = _locationService?.getRouteForSave() ?? [];
    final calories = (distanceKm * 73).round();

    final fitness = context.read<FitnessService>();
    fitness.addWorkoutResult(
      calories: calories,
      steps: (distanceKm * 1300).round(),
      durationMinutes: _elapsedSeconds ~/ 60,
      route: routeData,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _WorkoutSummaryDialog(
        sport: widget.sport.name,
        duration: _formattedTime,
        distance: distanceKm,
        calories: calories,
        heartRate: _heartRate,
        onDone: () => Navigator.of(context)
          ..pop()
          ..pop(),
      ),
    );
  }

  void _confirmStop() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Selesai Workout?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Apakah kamu yakin ingin mengakhiri sesi olahraga ini?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Lanjutkan', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _finishWorkout();
            },
            child: const Text('Selesai', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _locationService?.removeListener(_onLocationUpdate);
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
    final distKm = _locationService?.totalDistanceKm ?? 0.0;
    if (distKm < 0.01) return '--:--';
    final secondsPerKm = _elapsedSeconds / distKm;
    final m = secondsPerKm ~/ 60;
    final s = (secondsPerKm % 60).toInt();
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  LatLng get _mapCenter {
    final pos = _locationService?.currentPosition;
    return pos != null ? LatLng(pos.latitude, pos.longitude) : _defaultCenter;
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.watch<ThemeService>().accent;
    final distanceKm = _locationService?.totalDistanceKm ?? 0.0;
    final calories = (distanceKm * 73).round();

    final routePoints = _locationService?.routePositions
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList() ??
        [];
    final currentPos = _locationService?.currentPosition != null
        ? LatLng(_locationService!.currentPosition!.latitude,
            _locationService!.currentPosition!.longitude)
        : null;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Map area
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _mapCenter,
                    initialZoom: 17,
                    minZoom: 10,
                    maxZoom: 19,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                      subdomains: const ['a', 'b', 'c', 'd'],
                      userAgentPackageName: 'com.example.imk_ourfitness',
                      maxZoom: 19,
                    ),
                    if (routePoints.length >= 2)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: routePoints,
                            color: accent,
                            strokeWidth: 5,
                          ),
                        ],
                      ),
                    if (currentPos != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: currentPos,
                            width: 28,
                            height: 28,
                            child: _UserDot(color: accent),
                          ),
                        ],
                      ),
                  ],
                ),
                // Top bar (hanya back + status LIVE)
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
                              color: AppTheme.background.withValues(alpha: 0.85),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_back_rounded,
                                color: AppTheme.textPrimary),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.background.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _isRunning ? Colors.redAccent : AppTheme.textSecondary,
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
                      ],
                    ),
                  ),
                ),
                // Re-center button
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () {
                      final pos = _locationService?.currentPosition;
                      if (pos != null) {
                        _mapController.move(LatLng(pos.latitude, pos.longitude), 17);
                      }
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.background.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(Icons.my_location_rounded, color: accent, size: 22),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Stats panel
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            decoration: const BoxDecoration(
              color: Color(0xFF141414),
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.sport.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Stats row 1
                  Row(
                    children: [
                      Expanded(child: _StatCard(value: _formattedTime, label: 'Time')),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _StatCard(
                              value: distanceKm.toStringAsFixed(2).replaceAll('.', ','),
                              label: 'Distance (km)')),
                      const SizedBox(width: 10),
                      Expanded(child: _StatCard(value: _pace, label: 'Pace (/km)')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Stats row 2
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
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(value: '$calories', label: 'Calories (kcal)'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Control buttons: Pause + Stop
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Pause / Resume
                      GestureDetector(
                        onTap: _toggleRunning,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: accent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: accent.withValues(alpha: 0.35),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: ThemeService.isLightColor(accent) ? Colors.black : Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Stop button — merah, di kanan pause
                      GestureDetector(
                        onTap: _confirmStop,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE53935).withValues(alpha: 0.35),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.stop_rounded, color: Colors.white, size: 28),
                              Text(
                                'Selesai',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserDot extends StatefulWidget {
  final Color color;

  const _UserDot({required this.color});

  @override
  State<_UserDot> createState() => _UserDotState();
}

class _UserDotState extends State<_UserDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 28 * _anim.value,
            height: 28 * _anim.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withValues(alpha: 0.3 * _anim.value),
            ),
          ),
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(color: widget.color.withValues(alpha: 0.6), blurRadius: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Widget? extra;

  const _StatCard({required this.value, required this.label, this.extra});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
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
            style: const TextStyle(color: Colors.grey, fontSize: 9),
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
    return SizedBox(
      height: 6,
      width: double.infinity,
      child: Row(
        children: [
          Expanded(child: _seg(Colors.green.withValues(alpha: 0.5), true)),
          const SizedBox(width: 2),
          Expanded(child: _seg(Colors.green)),
          const SizedBox(width: 2),
          Expanded(child: _seg(Colors.yellow)),
          const SizedBox(width: 2),
          Expanded(child: _seg(Colors.orange)),
          const SizedBox(width: 2),
          Expanded(child: _seg(Colors.red, false, true)),
        ],
      ),
    );
  }

  Widget _seg(Color color, [bool first = false, bool last = false]) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.horizontal(
          left: first ? const Radius.circular(3) : Radius.zero,
          right: last ? const Radius.circular(3) : Radius.zero,
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
    final accent = context.read<ThemeService>().accent;
    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.celebration_rounded, size: 48, color: accent),
            const SizedBox(height: 12),
            Text('Workout Complete!', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(sport, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SummaryItem(icon: Icons.timer_rounded, value: duration, label: 'Duration', color: accent),
                _SummaryItem(
                    icon: Icons.location_on_rounded,
                    value: '${distance.toStringAsFixed(2)} km',
                    label: 'Distance',
                    color: accent),
                _SummaryItem(
                    icon: Icons.local_fire_department_rounded,
                    value: '$calories',
                    label: 'Calories',
                    color: accent),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: ThemeService.isLightColor(accent) ? Colors.black : Colors.white,
              ),
              child: const Text('Selesai'),
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
  final Color color;

  const _SummaryItem(
      {required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
