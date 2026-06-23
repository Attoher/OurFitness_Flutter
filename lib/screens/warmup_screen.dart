import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../models/user_model.dart';
import 'running_tracker_screen.dart';
import 'package:video_player/video_player.dart';

class WarmupScreen extends StatefulWidget {
  final Sport sport;

  const WarmupScreen({super.key, required this.sport});

  @override
  State<WarmupScreen> createState() => _WarmupScreenState();
}

class _WarmupScreenState extends State<WarmupScreen> {
  final int _totalSeconds = 30;
  int _remainingSeconds = 30;
  bool _isPlaying = true;
  Timer? _timer;
  int _currentPhase = 0;
  late VideoPlayerController _videoController;

  static const _sportPhases = <String, List<Map<String, String>>>{
    'Running': [
      {'phase': 'Leg Swing & Ankle Roll', 'step': '1/3'},
      {'phase': 'High Knees & Butt Kicks', 'step': '2/3'},
      {'phase': 'Hip Circle & Sprint Drill', 'step': '3/3'},
    ],
    'Cycling': [
      {'phase': 'Neck & Shoulder Roll', 'step': '1/3'},
      {'phase': 'Hip Flexor Stretch', 'step': '2/3'},
      {'phase': 'Quad Activation', 'step': '3/3'},
    ],
    'Swimming': [
      {'phase': 'Arm Circle & Shoulder Stretch', 'step': '1/3'},
      {'phase': 'Torso Rotation', 'step': '2/3'},
      {'phase': 'Leg Kick Activation', 'step': '3/3'},
    ],
    'Walking': [
      {'phase': 'Calf Stretch & Ankle Flex', 'step': '1/3'},
      {'phase': 'Hamstring Mobilization', 'step': '2/3'},
      {'phase': 'Hip Opener', 'step': '3/3'},
    ],
    'Treadmill': [
      {'phase': 'Calf Raise & Ankle Roll', 'step': '1/3'},
      {'phase': 'Quad & Hamstring Stretch', 'step': '2/3'},
      {'phase': 'Power Walk Activation', 'step': '3/3'},
    ],
    'HIIT': [
      {'phase': 'Joint Mobilization', 'step': '1/3'},
      {'phase': 'Dynamic Stretch', 'step': '2/3'},
      {'phase': 'Explosive Activation', 'step': '3/3'},
    ],
    'Weight Training': [
      {'phase': 'Shoulder & Wrist Circles', 'step': '1/3'},
      {'phase': 'Thoracic Spine Rotation', 'step': '2/3'},
      {'phase': 'Glute & Core Activation', 'step': '3/3'},
    ],
    'Bodyweight (Calisthenics)': [
      {'phase': 'Full Body Mobility Flow', 'step': '1/3'},
      {'phase': 'Scapular Push-up Prep', 'step': '2/3'},
      {'phase': 'Core & Hip Activation', 'step': '3/3'},
    ],
    'Pilates': [
      {'phase': 'Spine Articulation', 'step': '1/3'},
      {'phase': 'Pelvic Floor Awareness', 'step': '2/3'},
      {'phase': 'Breath & Core Connect', 'step': '3/3'},
    ],
    'Yoga': [
      {'phase': 'Child Pose & Cat-Cow', 'step': '1/3'},
      {'phase': 'Sun Salutation Flow', 'step': '2/3'},
      {'phase': 'Warrior Prep Stretch', 'step': '3/3'},
    ],
    'CrossFit': [
      {'phase': 'Burpee & Jump Prep', 'step': '1/3'},
      {'phase': 'Overhead Shoulder Warm-up', 'step': '2/3'},
      {'phase': 'Posterior Chain Activation', 'step': '3/3'},
    ],
  };

  static const _defaultPhases = <Map<String, String>>[
    {'phase': 'Phase 1: Mobilization', 'step': '1/3'},
    {'phase': 'Phase 2: Dynamic Stretch', 'step': '2/3'},
    {'phase': 'Phase 3: Activation', 'step': '3/3'},
  ];

  List<Map<String, String>> get _phases =>
      _sportPhases[widget.sport.name] ?? _defaultPhases;

  @override
  void initState() {
    super.initState();
    _startTimer();

    _videoController = VideoPlayerController.asset('assets/videos/jumping_jack.mp4')
      ..initialize().then((_) {
        setState(() {});
        _videoController.setLooping(true);
        if (_isPlaying) {
          _videoController.play();
        }
      });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds <= 0) {
        HapticFeedback.mediumImpact();
        _nextPhase();
      } else {
        setState(() => _remainingSeconds--);
        if (_remainingSeconds <= 5) HapticFeedback.lightImpact();
      }
    });
  }

  void _nextPhase() {
    if (_currentPhase < _phases.length - 1) {
      setState(() {
        _currentPhase++;
        _remainingSeconds = 30;
      });
    } else {
      _timer?.cancel();
      _goToTracker();
    }
  }

  void _togglePlay() {
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      _startTimer();
      _videoController.play();
    } else {
      _timer?.cancel();
      _videoController.pause();
    }
  }

  void _goToTracker() {
    _timer?.cancel();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => RunningTrackerScreen(sport: widget.sport),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _videoController.dispose();
    super.dispose();
  }

  String get _formattedTime {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get _progress => 1 - (_remainingSeconds / _totalSeconds);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.chevron_left_rounded, size: 28, color: AppTheme.textPrimary),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Warming-up',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 28),
                ],
              ),
            ),
            // Phase indicator
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Text(
                    _phases[_currentPhase]['phase']!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Text(
                    _phases[_currentPhase]['step']!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            // Progress bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: AppTheme.surfaceLight,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accent),
                  minHeight: 3,
                ),
              ),
            ),
            // Video area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    color: const Color(0xFFD4C9B0),
                    width: double.infinity,
                    height: double.infinity,
                    child: _videoController.value.hasError
                        ? Center(
                            child: Icon(
                              Icons.accessibility_new_rounded,
                              size: 80,
                              color: AppTheme.accent,
                            ),
                          )
                        : _videoController.value.isInitialized
                            ? FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width: _videoController.value.size.width,
                                  height: _videoController.value.size.height,
                                  child: VideoPlayer(_videoController),
                                ),
                              )
                            : Center(
                                child: CircularProgressIndicator(color: AppTheme.accent),
                              ),
                  ),
                ),
              ),
            ),
            // Timer with circular ring
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Ring painter
                        CustomPaint(
                          size: const Size(140, 140),
                          painter: _CountdownRingPainter(
                            progress: _progress,
                            color: AppTheme.accent,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _formattedTime,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 40,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 1,
                              ),
                            ),
                            Text(
                              'sec',
                              style: TextStyle(
                                color: AppTheme.accent,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ControlButton(
                        icon: Icons.skip_previous_rounded,
                        onTap: () {
                          _timer?.cancel();
                          setState(() {
                            _remainingSeconds = _totalSeconds;
                            if (_currentPhase > 0) _currentPhase--;
                          });
                          if (_isPlaying) _startTimer();
                        },
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: _togglePlay,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppTheme.accent,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: AppTheme.background,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      _ControlButton(
                        icon: Icons.skip_next_rounded,
                        onTap: _nextPhase,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _goToTracker,
                    child: const Text(
                      'Skip warming-up',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                        decorationColor: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ControlButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppTheme.textPrimary, size: 24),
      ),
    );
  }
}

class _CountdownRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _CountdownRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 6.0;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    if (progress <= 0) return;

    // Glow
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = color.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 4
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_CountdownRingPainter old) => old.progress != progress;
}
