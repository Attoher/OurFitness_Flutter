import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/activity_rings.dart';
import '../services/fitness_service.dart';
import 'notifications_screen.dart';
import 'sport_selection_screen.dart';
import '../widgets/week_day_strip.dart';

import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fitnessData = context.watch<FitnessService>();
    final authService = context.watch<AuthService>();
    final user = authService.user;
    final userName = user?.displayName ?? fitnessData.displayName;
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, userName, fitnessData)),
            SliverToBoxAdapter(child: _buildStreakSection(context, fitnessData.streak)),
            SliverToBoxAdapter(child: _buildActivityRings(context, fitnessData)),
            SliverToBoxAdapter(child: _buildStats(context, fitnessData)),
            SliverToBoxAdapter(child: _buildHealthCards(context, fitnessData)),
            SliverToBoxAdapter(child: _buildQuickStartCard(context)),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name, FitnessService fitness) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Hello, ${name.split(' ')[0]}! ',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Icon(Icons.waving_hand_rounded, size: 22),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: fitness.isDeviceConnected ? const Color(0xFF4CD8D8) : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    fitness.isDeviceConnected 
                      ? 'Connected with ${fitness.deviceName}'
                      : 'No device connected',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
            child: Stack(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: AppTheme.textPrimary,
                    size: 22,
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakSection(BuildContext context, int streak) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department_rounded, size: 18),
              const SizedBox(width: 6),
              Text(
                'Your streak',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$streak weeks',
                  style: const TextStyle(
                    color: AppTheme.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          WeekDayStrip(currentDay: DateTime.now().weekday - 1), 
        ],
      ),
    );
  }

  Widget _buildActivityRings(BuildContext context, FitnessService data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Center(
        child: ActivityRingsWidget(
          caloriesProgress: data.caloriesProgress,
          stepsProgress: data.stepsProgress,
          moveProgress: data.moveMinutesProgress,
          size: 190,
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context, FitnessService data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatBadge(
            color: AppTheme.ringCalories,
            icon: Icons.local_fire_department_rounded,
            label: 'Calories',
            value: data.calories.toString(),
            unit: 'KCAL/${data.caloriesGoal}',
          ),
          _StatBadge(
            color: AppTheme.ringSteps,
            icon: Icons.directions_walk_rounded,
            label: 'Steps',
            value: data.steps.toString(),
            unit: data.stepsGoal.toString(),
          ),
          _StatBadge(
            color: AppTheme.ringMove,
            icon: Icons.timer_rounded,
            label: 'Move',
            value: data.moveMinutes.toString(),
            unit: '${data.moveMinutesGoal}MIN',
          ),
        ],
      ),
    );
  }

  Widget _buildHealthCards(BuildContext context, FitnessService data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(child: _HeartRateCard(heartRate: data.heartRate)),
          const SizedBox(width: 12),
          Expanded(child: _SleepCard(duration: data.sleepDuration)),
        ],
      ),
    );
  }

  Widget _buildQuickStartCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.psychology_rounded, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'What are we doing today?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            GestureDetector(
              onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const SportSelectionSheet(),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      'Running',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                          ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final String value;
  final String unit;

  const _StatBadge({
    required this.color,
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              unit,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeartRateCard extends StatelessWidget {
  final int heartRate;

  const _HeartRateCard({required this.heartRate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite_rounded, color: AppTheme.heartRate, size: 16),
              const SizedBox(width: 6),
              Text(
                'Heart rate',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: CustomPaint(painter: _HeartRateLinePainter()),
          ),
          const SizedBox(height: 6),
          Text(
            '$heartRate bpm',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _HeartRateLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.heartRate
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final points = [0.2, 0.5, 0.3, 0.7, 0.2, 0.9, 0.1, 0.6, 0.4, 0.3, 0.5];
    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final x = i / (points.length - 1) * size.width;
      final y = (1 - points[i]) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SleepCard extends StatelessWidget {
  final String duration;

  const _SleepCard({required this.duration});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bedtime_rounded, color: Color(0xFF7B5FDB), size: 16),
              const SizedBox(width: 6),
              Text(
                'Sleep',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: CustomPaint(painter: _SleepBarPainter()),
          ),
          const SizedBox(height: 6),
          Text(
            duration,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _SleepBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF7B5FDB)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final heights = [0.4, 0.6, 0.9, 0.7, 0.5, 0.8, 0.6, 0.4, 0.7, 0.5];
    final barWidth = size.width / heights.length;

    for (int i = 0; i < heights.length; i++) {
      final x = i * barWidth + barWidth / 2;
      final barHeight = size.height * heights[i];
      final y = size.height - barHeight;
      canvas.drawLine(Offset(x, size.height), Offset(x, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
