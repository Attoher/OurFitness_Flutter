import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/user_model.dart';
import 'running_tracker_screen.dart';

class WarmupScreen extends StatefulWidget {
  final Sport sport;

  const WarmupScreen({super.key, required this.sport});

  @override
  State<WarmupScreen> createState() => _WarmupScreenState();
}

class _WarmupScreenState extends State<WarmupScreen> {
  int _totalSeconds = 30;
  int _remainingSeconds = 30;
  bool _isPlaying = true;
  Timer? _timer;
  int _currentPhase = 0;

  final List<Map<String, String>> _phases = [
    {'phase': 'Phase 1: Mobilization', 'step': '1/3'},
    {'phase': 'Phase 2: Dynamic Stretch', 'step': '2/3'},
    {'phase': 'Phase 3: Activation', 'step': '3/3'},
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds <= 0) {
        _nextPhase();
      } else {
        setState(() => _remainingSeconds--);
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
    } else {
      _timer?.cancel();
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
    super.dispose();
  }

  String get _formattedTime {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get _progress =>
      1 - (_remainingSeconds / _totalSeconds);

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
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                  minHeight: 3,
                ),
              ),
            ),
            // Video placeholder
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    color: const Color(0xFFD4C9B0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Warmup figure illustration
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 160,
                                height: 240,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD4C9B0).withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.self_improvement_rounded,
                                    size: 80,
                                    color: AppTheme.accent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Timer
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Column(
                children: [
                  Text(
                    _formattedTime,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 56,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 20),
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
                          decoration: const BoxDecoration(
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
                    child: Text(
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
