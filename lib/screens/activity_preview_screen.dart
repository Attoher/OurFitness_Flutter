import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/user_model.dart';
import 'warmup_screen.dart';
import 'running_tracker_screen.dart';

IconData _iconFromName(String name) {
  switch (name) {
    case 'directions_run': return Icons.directions_run_rounded;
    case 'two_wheeler': return Icons.two_wheeler_rounded;
    case 'pool': return Icons.pool_rounded;
    case 'directions_walk': return Icons.directions_walk_rounded;
    case 'bolt': return Icons.bolt_rounded;
    case 'fitness_center': return Icons.fitness_center_rounded;
    case 'sports_gymnastics': return Icons.sports_gymnastics_rounded;
    case 'self_improvement': return Icons.self_improvement_rounded;
    case 'local_fire_department': return Icons.local_fire_department_rounded;
    default: return Icons.sports_rounded;
  }
}

class ActivityPreviewScreen extends StatefulWidget {
  final Sport sport;

  const ActivityPreviewScreen({super.key, required this.sport});

  @override
  State<ActivityPreviewScreen> createState() => _ActivityPreviewScreenState();
}

class _ActivityPreviewScreenState extends State<ActivityPreviewScreen> {
  bool _gpsReady = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _gpsReady = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sportIcon = _iconFromName(widget.sport.icon);
    final isCardio = widget.sport.category == 'CARDIO';

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Map area (top, expandable)
          Expanded(
            child: Stack(
              children: [
                // Map fills the full expanded area
                Positioned.fill(child: _ItsPreviewMap()),
                // Gradient fade at bottom of map
                Positioned(
                  bottom: 0, left: 0, right: 0,
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
                // Top bar (close + GPS)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.background.withValues(alpha: 0.8),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded, color: AppTheme.textPrimary, size: 20),
                          ),
                        ),
                        const Spacer(),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.background.withValues(alpha: 0.8),
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
          // Bottom panel (fixed height, no Positioned needed)
          Container(
            color: AppTheme.background,
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sport info row
                  Row(
                    children: [
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
                        ),
                        child: Icon(sportIcon, color: AppTheme.accent, size: 26),
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
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
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
                  // Start button
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => WarmupScreen(sport: widget.sport)),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow_rounded, size: 28, color: Colors.black),
                          SizedBox(width: 8),
                          Text(
                            'Start Activity',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black),
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
                        MaterialPageRoute(builder: (_) => RunningTrackerScreen(sport: widget.sport)),
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

class _ItsPreviewMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF141D2C),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _PreviewGridPainter())),
          const Positioned(
            top: 120, left: 80,
            child: _MapLabel(text: 'Perpustakaan ITS'),
          ),
          const Positioned(
            top: 220, right: 60,
            child: _MapLabel(text: 'Taman Sepuluh Nopember'),
          ),
          const Positioned(
            bottom: 100, left: 50,
            child: _MapLabel(text: 'BAAK ITS', highlight: true),
          ),
          const Positioned(
            bottom: 60, right: 40,
            child: _MapLabel(text: 'Titik Nol ITS', highlight: true),
          ),
        ],
      ),
    );
  }
}

class _MapLabel extends StatelessWidget {
  final String text;
  final bool highlight;

  const _MapLabel({required this.text, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: highlight
            ? AppTheme.accent.withValues(alpha: 0.7)
            : Colors.grey.withValues(alpha: 0.4),
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _PreviewGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final thin = Paint()
      ..color = const Color(0xFF34495E).withValues(alpha: 0.2)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final thick = Paint()
      ..color = const Color(0xFF2C3E50).withValues(alpha: 0.3)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    canvas.drawPath(
      Path()
        ..moveTo(0, 110)
        ..lineTo(size.width, 160)
        ..moveTo(110, 0)
        ..lineTo(130, size.height)
        ..moveTo(size.width * 0.7, 0)
        ..lineTo(size.width * 0.8, size.height),
      thin,
    );

    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.2, 0)
        ..quadraticBezierTo(size.width * 0.5, size.height * 0.5, size.width * 0.8, size.height)
        ..moveTo(0, size.height * 0.7)
        ..lineTo(size.width, size.height * 0.6),
      thick,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
