import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../services/theme_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _mainCtrl;
  late final AnimationController _pulseCtrl;

  // Logo: scale + fade 0→600ms
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  // Logo glow pulse: 500ms+
  late final Animation<double> _glowOpacity;
  // Brand name: slide up + fade 400→900ms
  late final Animation<Offset> _nameSlide;
  late final Animation<double> _nameFade;
  // Tagline: fade 700ms→1100ms
  late final Animation<double> _tagFade;

  @override
  void initState() {
    super.initState();

    _mainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // Logo
    _logoScale = Tween(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );
    _logoFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );

    // Glow
    _glowOpacity = Tween(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // Brand name
    _nameSlide = Tween(begin: const Offset(0, 0.4), end: Offset.zero).animate(
      CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.35, 0.75, curve: Curves.easeOut)),
    );
    _nameFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.35, 0.7, curve: Curves.easeOut)),
    );

    // Tagline
    _tagFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.6, 1.0, curve: Curves.easeOut)),
    );

    _mainCtrl.forward();

    Future.delayed(const Duration(milliseconds: 2800), () {
      if (!mounted) return;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Background radial glow
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _glowOpacity,
              builder: (_, __) => CustomPaint(
                painter: _RadialGlowPainter(
                  color: AppTheme.accent,
                  opacity: _glowOpacity.value * 0.12,
                ),
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                AnimatedBuilder(
                  animation: Listenable.merge([_mainCtrl, _pulseCtrl]),
                  builder: (_, child) => Transform.scale(
                    scale: _logoScale.value,
                    child: Opacity(
                      opacity: _logoFade.value,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow ring
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.accent.withValues(alpha: _glowOpacity.value),
                                  blurRadius: 40,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          // Logo circle
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [AppTheme.accent, AppTheme.accentDark],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.fitness_center_rounded,
                                size: 52,
                                color: ThemeService.isLightColor(AppTheme.accent)
                                    ? Colors.black
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Brand name
                SlideTransition(
                  position: _nameSlide,
                  child: FadeTransition(
                    opacity: _nameFade,
                    child: Text(
                      'OurFitness',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Tagline
                FadeTransition(
                  opacity: _tagFade,
                  child: Text(
                    'Your personal fitness companion',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ),
              ],
            ),
          ),

          // Loading dots at bottom
          Positioned(
            bottom: 56,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _tagFade,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) => _LoadingDot(delay: Duration(milliseconds: i * 180))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Radial glow background painter
class _RadialGlowPainter extends CustomPainter {
  final Color color;
  final double opacity;
  const _RadialGlowPainter({required this.color, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.42);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color.withValues(alpha: opacity), Colors.transparent],
        stops: const [0.0, 1.0],
        radius: 0.5,
      ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.7));
    canvas.drawCircle(center, size.width * 0.7, paint);
  }

  @override
  bool shouldRepaint(_RadialGlowPainter old) => old.opacity != opacity;
}

// Bouncing loading dots
class _LoadingDot extends StatefulWidget {
  final Duration delay;
  const _LoadingDot({required this.delay});

  @override
  State<_LoadingDot> createState() => _LoadingDotState();
}

class _LoadingDotState extends State<_LoadingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _ctrl.reverse();
        if (s == AnimationStatus.dismissed) {
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) _ctrl.forward();
          });
        }
      });
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
    _bounce = Tween(begin: 0.0, end: -8.0).animate(
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
      animation: _bounce,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _bounce.value),
        child: Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: AppTheme.accent.withValues(alpha: 0.7),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

