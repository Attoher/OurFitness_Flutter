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
    final userName = fitnessData.displayName != 'User' ? fitnessData.displayName : (user?.displayName ?? 'User');

    if (fitnessData.isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, userName, fitnessData)),
            if (fitnessData.errorMessage != null)
              SliverToBoxAdapter(child: _buildErrorBanner(fitnessData.errorMessage!)),
            SliverToBoxAdapter(child: _buildStreakSection(context, fitnessData.streak, fitnessData.longestStreak)),
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
                if (fitness.notifications.any((item) => (item['isNew'] ?? false) as bool))
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

  Widget _buildErrorBanner(String message) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(message, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ),
    );
  }

  Widget _buildStreakSection(BuildContext context, int streak, int longestStreak) {
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
                  '$streak days',
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
          Row(
            children: [
              Expanded(child: WeekDayStrip(currentDay: DateTime.now().weekday - 1)),
              const SizedBox(width: 12),
              Text(
                'Best $longestStreak days',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
            ],
          ),
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
            label: 'Calories',
            value: data.calories,
            unit: 'kcal / ${data.caloriesGoal}',
          ),
          _StatBadge(
            color: AppTheme.ringSteps,
            label: 'Steps',
            value: data.steps,
            unit: '/ ${data.stepsGoal}',
          ),
          _StatBadge(
            color: AppTheme.ringMove,
            label: 'Move',
            value: data.moveMinutes,
            unit: '/ ${data.moveMinutesGoal} min',
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

// Pulsing live-tracking dot
class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.35, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
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
      builder: (_, __) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: _anim.value),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: _anim.value * 0.5),
              blurRadius: 6 * _anim.value,
              spreadRadius: 1.5 * _anim.value,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final Color color;
  final String label;
  final int value;
  final String unit;

  const _StatBadge({
    required this.color,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _PulseDot(color: color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TweenAnimationBuilder<double>(
              key: ValueKey(value),
              tween: Tween(begin: 0, end: value.toDouble()),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOut,
              builder: (_, val, __) => Text(
                val.toInt().toString(),
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(unit, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
          ],
        ),
      ],
    );
  }
}

class _HeartRateCard extends StatefulWidget {
  final int heartRate;
  const _HeartRateCard({required this.heartRate});

  @override
  State<_HeartRateCard> createState() => _HeartRateCardState();
}

class _HeartRateCardState extends State<_HeartRateCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bpm = widget.heartRate;
    final String zone = bpm < 60 ? 'Resting' : bpm < 100 ? 'Normal' : 'Active';
    final Color zoneColor = bpm < 60
        ? const Color(0xFF4CD8D8)
        : bpm < 100
            ? AppTheme.heartRate
            : Colors.orangeAccent;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulse,
                builder: (_, __) => Icon(
                  Icons.favorite_rounded,
                  color: AppTheme.heartRate.withValues(alpha: _pulse.value),
                  size: 16,
                ),
              ),
              const SizedBox(width: 6),
              Text('Heart rate', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$bpm',
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, height: 1),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text('bpm  ', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: zoneColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(zone, style: TextStyle(color: zoneColor, fontSize: 10, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class _SleepCard extends StatelessWidget {
  final String duration;
  const _SleepCard({required this.duration});

  String _sleepQuality(String dur) {
    final parts = dur.replaceAll('h', '').replaceAll('m', '').trim().split(' ');
    final hours = int.tryParse(parts[0]) ?? 0;
    if (hours >= 8) return 'Great';
    if (hours >= 6) return 'Good';
    return 'Low';
  }

  @override
  Widget build(BuildContext context) {
    const sleepColor = Color(0xFF7B5FDB);
    final quality = _sleepQuality(duration);
    final Color qualityColor = quality == 'Great'
        ? const Color(0xFF4CD8D8)
        : quality == 'Good'
            ? sleepColor
            : Colors.orangeAccent;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bedtime_rounded, color: sleepColor, size: 16),
              const SizedBox(width: 6),
              Text('Sleep', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            duration,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text('last night  ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: qualityColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(quality, style: TextStyle(color: qualityColor, fontSize: 10, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

