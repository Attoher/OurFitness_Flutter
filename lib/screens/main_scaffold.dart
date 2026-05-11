import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
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

  final List<Widget> _screens = const [
    HomeScreen(),
    GamificationScreen(),
    SizedBox(), // Placeholder for Quick Access (FAB)
    StatisticsScreen(),
    ProfileScreen(),
  ];

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
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(
        index: _currentIndex == 2 ? 0 : (_currentIndex > 2 ? _currentIndex - 1 : _currentIndex),
        children: [
          _screens[0],
          _screens[1],
          _screens[3],
          _screens[4],
        ],
      ),
      bottomNavigationBar: _OurFitnessNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
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
