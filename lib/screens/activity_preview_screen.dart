import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/user_model.dart';
import '../services/location_service.dart';
import '../services/theme_service.dart';
import 'warmup_screen.dart';
import 'running_tracker_screen.dart';

IconData _iconFromName(String name) {
  switch (name) {
    case 'directions_run':
      return Icons.directions_run_rounded;
    case 'two_wheeler':
      return Icons.two_wheeler_rounded;
    case 'pool':
      return Icons.pool_rounded;
    case 'directions_walk':
      return Icons.directions_walk_rounded;
    case 'bolt':
      return Icons.bolt_rounded;
    case 'fitness_center':
      return Icons.fitness_center_rounded;
    case 'sports_gymnastics':
      return Icons.sports_gymnastics_rounded;
    case 'self_improvement':
      return Icons.self_improvement_rounded;
    case 'local_fire_department':
      return Icons.local_fire_department_rounded;
    default:
      return Icons.sports_rounded;
  }
}

class ActivityPreviewScreen extends StatefulWidget {
  final Sport sport;

  const ActivityPreviewScreen({super.key, required this.sport});

  @override
  State<ActivityPreviewScreen> createState() => _ActivityPreviewScreenState();
}

class _ActivityPreviewScreenState extends State<ActivityPreviewScreen> {
  final _mapController = MapController();
  LocationService? _locationService;

  static const _defaultCenter = LatLng(-7.2756, 112.7947);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _locationService = context.read<LocationService>();
      _locationService!.addListener(_onLocationUpdate);
      _locationService!.fetchCurrentPosition();
    });
  }

  void _onLocationUpdate() {
    if (!mounted) return;
    setState(() {});
    final pos = _locationService?.currentPosition;
    if (pos != null) {
      _mapController.move(LatLng(pos.latitude, pos.longitude), 16);
    }
  }

  @override
  void dispose() {
    _locationService?.removeListener(_onLocationUpdate);
    super.dispose();
  }

  bool get _gpsReady => _locationService?.currentPosition != null;

  LatLng get _mapCenter {
    final pos = _locationService?.currentPosition;
    return pos != null ? LatLng(pos.latitude, pos.longitude) : _defaultCenter;
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.watch<ThemeService>().accent;
    final sportIcon = _iconFromName(widget.sport.icon);
    final isCardio = widget.sport.category == 'CARDIO';

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // OpenStreetMap via flutter_map
                Positioned.fill(
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _mapCenter,
                      initialZoom: 16,
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
                      if (_gpsReady)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _mapCenter,
                              width: 24,
                              height: 24,
                              child: _LocationDot(color: accent),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                // Gradient fade at bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 120,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppTheme.background.withValues(alpha: 0.95),
                        ],
                      ),
                    ),
                  ),
                ),
                // Top bar
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
                            child: const Icon(
                              Icons.close_rounded,
                              color: AppTheme.textPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                        const Spacer(),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.background.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.gps_fixed_rounded,
                                size: 13,
                                color: _gpsReady ? Colors.greenAccent : Colors.orange,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _gpsReady ? 'GPS Ready' : 'Locating…',
                                style: TextStyle(
                                  color: _gpsReady ? Colors.greenAccent : Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom panel
          Container(
            color: AppTheme.background,
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: accent.withValues(alpha: 0.3)),
                        ),
                        child: Icon(sportIcon, color: accent, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.sport.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              widget.sport.category,
                              style: const TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isCardio
                              ? AppTheme.cardio.withValues(alpha: 0.15)
                              : AppTheme.strength.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isCardio ? 'Cardio' : 'Strength',
                          style: TextStyle(
                            color: isCardio ? AppTheme.cardio : AppTheme.strength,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => WarmupScreen(sport: widget.sport)),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: ThemeService.isLightColor(accent) ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow_rounded, size: 28),
                          SizedBox(width: 8),
                          Text(
                            'Start Activity',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => RunningTrackerScreen(sport: widget.sport)),
                      ),
                      child: const Text(
                        'Skip warmup',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                          decorationColor: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationDot extends StatefulWidget {
  final Color color;

  const _LocationDot({required this.color});

  @override
  State<_LocationDot> createState() => _LocationDotState();
}

class _LocationDotState extends State<_LocationDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.6, end: 1.0).animate(
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
      animation: _pulse,
      builder: (_, __) => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 24 * _pulse.value,
            height: 24 * _pulse.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withValues(alpha: 0.25 * _pulse.value),
            ),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(color: widget.color.withValues(alpha: 0.5), blurRadius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
