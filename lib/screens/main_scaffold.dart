import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/fitness_service.dart';
import 'home_screen.dart';
import 'gamification_screen.dart';
import 'statistics_screen.dart';
import 'profile_screen.dart';
import 'sport_selection_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  Map<String, dynamic>? _toastBadge;
  bool _toastVisible = false;

  final List<Widget> _screens = const [
    HomeScreen(),
    GamificationScreen(),
    SizedBox(),
    StatisticsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FitnessService>().addListener(_onFitnessUpdate);
      _onFitnessUpdate(); // catch badges that arrived before listener attached
    });
  }

  @override
  void dispose() {
    context.read<FitnessService>().removeListener(_onFitnessUpdate);
    super.dispose();
  }

  void _onFitnessUpdate() {
    if (!mounted) return;
    final svc = context.read<FitnessService>();
    final badge = svc.pendingBadgeToast;
    if (badge != null && _toastBadge == null) {
      svc.consumeBadgeToast();
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        setState(() {
          _toastBadge = badge;
          _toastVisible = true;
        });
      });
    }
  }

  void _dismissToast() {
    setState(() => _toastVisible = false);
    Future.delayed(const Duration(milliseconds: 480), () {
      if (mounted) setState(() => _toastBadge = null);
    });
  }

  void _viewBadge() {
    _dismissToast();
    final badge = _toastBadge;
    if (badge == null) return;
    Future.delayed(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'badge-detail',
        barrierColor: Colors.black.withValues(alpha: 0.85),
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => BadgeDetailScreen(badge: badge),
        transitionBuilder: (_, anim, __, child) {
          final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
          return FadeTransition(
            opacity: anim,
            child: ScaleTransition(
              scale: Tween(begin: 0.82, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      );
    });
  }

  void _onTabTapped(int index) {
    if (index == 2) {
      _showSportSelection();
      return;
    }
    setState(() => _currentIndex = index);
  }

  void _showSportSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SportSelectionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final navBarHeight = 72 + MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex == 2 ? 0 : (_currentIndex > 2 ? _currentIndex - 1 : _currentIndex),
            children: [
              _screens[0],
              _screens[1],
              _screens[3],
              _screens[4],
            ],
          ),
          if (_toastBadge != null)
            Positioned(
              bottom: navBarHeight,
              left: 0,
              right: 0,
              child: AnimatedSlide(
                offset: _toastVisible ? Offset.zero : const Offset(0, 1.4),
                duration: const Duration(milliseconds: 480),
                curve: _toastVisible ? Curves.easeOutBack : Curves.easeIn,
                child: AnimatedOpacity(
                  opacity: _toastVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 280),
                  child: _BadgeToastBanner(
                    badge: _toastBadge!,
                    onDismiss: _dismissToast,
                    onView: _viewBadge,
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _OurFitnessNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

// ── Toast banner ──────────────────────────────────────────────────────────────

class _BadgeToastBanner extends StatefulWidget {
  final Map<String, dynamic> badge;
  final VoidCallback onDismiss;
  final VoidCallback onView;

  const _BadgeToastBanner({
    required this.badge,
    required this.onDismiss,
    required this.onView,
  });

  @override
  State<_BadgeToastBanner> createState() => _BadgeToastBannerState();
}

class _BadgeToastBannerState extends State<_BadgeToastBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _countdown;
  static const _duration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _countdown = AnimationController(vsync: this, duration: _duration)
      ..forward().whenComplete(widget.onDismiss);
  }

  @override
  void dispose() {
    _countdown.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icon  = widget.badge['icon'] as IconData;
    final title = widget.badge['title'] as String;
    final desc  = widget.badge['desc'] as String;

    return GestureDetector(
      onVerticalDragEnd: (d) {
        if (d.primaryVelocity != null && d.primaryVelocity! > 80) widget.onDismiss();
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.accent.withValues(alpha: 0.30), width: 1),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accent.withValues(alpha: 0.18),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                child: Row(
                  children: [
                    // Glowing icon
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.accent.withValues(alpha: 0.12),
                        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.35), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accent.withValues(alpha: 0.25),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                      child: Icon(icon, color: AppTheme.accent, size: 24),
                    ),
                    const SizedBox(width: 12),
                    // Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.auto_awesome_rounded,
                                  size: 10, color: AppTheme.accent.withValues(alpha: 0.7)),
                              const SizedBox(width: 4),
                              Text(
                                'ACHIEVEMENT UNLOCKED',
                                style: TextStyle(
                                  color: AppTheme.accent.withValues(alpha: 0.75),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.4,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            desc,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.45),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Actions
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: widget.onDismiss,
                          child: Icon(Icons.close_rounded,
                              size: 16, color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: widget.onView,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppTheme.accent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'View',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Countdown bar
              ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                child: AnimatedBuilder(
                  animation: _countdown,
                  builder: (_, __) => LinearProgressIndicator(
                    value: 1.0 - _countdown.value,
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.accent.withValues(alpha: 0.55),
                    ),
                    minHeight: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OurFitnessNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _OurFitnessNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72 + MediaQuery.of(context).padding.bottom,
      decoration: const BoxDecoration(
        color: Color(0xFF141414),
        border: Border(
          top: BorderSide(color: AppTheme.surfaceLight, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              isActive: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              icon: Icons.verified_user_outlined,
              isActive: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            // Center Running Button
            GestureDetector(
              onTap: () => onTap(2),
              child: Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Color(0xFF2C2C2E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_run_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            _NavItem(
              icon: Icons.insert_chart_outlined_rounded,
              isActive: currentIndex == 3,
              onTap: () => onTap(3),
            ),
            _NavItem(
              icon: Icons.person_outline_rounded,
              isActive: currentIndex == 4,
              onTap: () => onTap(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 48,
        height: 56,
        child: Center(
          child: Icon(
            icon,
            size: 26,
            color: isActive ? AppTheme.accent : const Color(0xFF555555),
          ),
        ),
      ),
    );
  }
}
