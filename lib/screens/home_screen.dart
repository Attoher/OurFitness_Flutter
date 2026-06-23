import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/activity_rings.dart';
import '../widgets/pressable.dart';
import '../services/fitness_service.dart';
import '../services/theme_service.dart';
import 'notifications_screen.dart';
import 'sport_selection_screen.dart';
import '../widgets/week_day_strip.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  Widget _in(Widget child, {required double from, required double to}) {
    final fade = CurvedAnimation(
      parent: _entrance,
      curve: Interval(from, to, curve: Curves.easeOut),
    );
    final slide = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _entrance,
      curve: Interval(from, to, curve: Curves.easeOut),
    ));
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeService>();
    final fitnessData = context.watch<FitnessService>();
    final authService = context.watch<AuthService>();
    final user = authService.user;
    final userName = fitnessData.displayName != 'User'
        ? fitnessData.displayName
        : (user?.displayName ?? 'User');

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _in(_buildHeader(context, userName, fitnessData), from: 0.0, to: 0.45)),
            SliverToBoxAdapter(child: _in(_buildStreakSection(context, fitnessData.streak), from: 0.1, to: 0.55)),
            SliverToBoxAdapter(child: _in(_buildActivityRings(context, fitnessData), from: 0.2, to: 0.65)),
            SliverToBoxAdapter(child: _in(_buildStats(context, fitnessData), from: 0.3, to: 0.75)),
            SliverToBoxAdapter(child: _in(_buildHealthCards(context, fitnessData), from: 0.4, to: 0.85)),
            SliverToBoxAdapter(child: _in(_buildQuickStartCard(context), from: 0.5, to: 1.0)),
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
                    'Halo, ${name.split(' ')[0]}! ',
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
                      color: fitness.isDeviceConnected ? AppTheme.ringSteps : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    fitness.isDeviceConnected
                      ? 'Terhubung dengan ${fitness.deviceName}'
                      : 'Belum ada perangkat',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            ],
          ),
          Pressable(
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const NotificationsScreen(),
                  transitionDuration: const Duration(milliseconds: 300),
                  transitionsBuilder: (_, anim, __, child) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween(begin: const Offset(0, 0.06), end: Offset.zero)
                          .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                      child: child,
                    ),
                  ),
                ),
              );
            },
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
                if (fitness.notifications.where((n) => n['isNew'] as bool? ?? false).isNotEmpty)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.heartRate,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.background, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          '${fitness.notifications.where((n) => n['isNew'] as bool? ?? false).length}',
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800, height: 1),
                        ),
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
              const Icon(Icons.local_fire_department_rounded, size: 18, color: AppTheme.streakOrange),
              const SizedBox(width: 6),
              Text(
                'Streak harian',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.streakOrange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$streak hari berturut',
                  style: const TextStyle(
                    color: AppTheme.streakOrange,
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(child: _StatCard(
            color: AppTheme.ringCalories,
            icon: Icons.local_fire_department_rounded,
            label: 'Kalori',
            description: 'terbakar hari ini',
            value: data.calories,
            goal: data.caloriesGoal,
            unit: 'kcal',
            progress: data.caloriesProgress,
          )),
          const SizedBox(width: 8),
          Expanded(child: _StatCard(
            color: AppTheme.ringSteps,
            icon: Icons.directions_walk_rounded,
            label: 'Langkah',
            description: 'langkah hari ini',
            value: data.steps,
            goal: data.stepsGoal,
            unit: '',
            progress: data.stepsProgress,
          )),
          const SizedBox(width: 8),
          Expanded(child: _StatCard(
            color: AppTheme.ringMove,
            icon: Icons.timer_rounded,
            label: 'Aktif',
            description: 'menit bergerak',
            value: data.moveMinutes,
            goal: data.moveMinutesGoal,
            unit: 'mnt',
            progress: data.moveMinutesProgress,
          )),
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
            Icon(Icons.psychology_rounded, size: 22, color: AppTheme.accent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Mau olahraga apa hari ini?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Pressable(
              onTap: () {
                HapticFeedback.mediumImpact();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const SportSelectionSheet(),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accent.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      'Mulai',
                      style: TextStyle(
                        color: ThemeService.isLightColor(AppTheme.accent) ? Colors.black : Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: ThemeService.isLightColor(AppTheme.accent) ? Colors.black : Colors.white,
                      size: 16,
                    ),
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

class _StatCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final String description;
  final int value;
  final int goal;
  final String unit;
  final double progress;

  const _StatCard({
    required this.color,
    required this.icon,
    required this.label,
    required this.description,
    required this.value,
    required this.goal,
    required this.unit,
    required this.progress,
  });

  String _fmt(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(n >= 10000 ? 0 : 1)}k';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).clamp(0.0, 100.0).round();
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 13),
              const SizedBox(width: 3),
              Expanded(child: Text(
                label,
                style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                overflow: TextOverflow.ellipsis,
              )),
            ],
          ),
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            key: ValueKey(value),
            tween: Tween(begin: 0, end: value.toDouble()),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOut,
            builder: (_, val, __) => Text(
              _fmt(val.toInt()),
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w800, height: 1.1),
            ),
          ),
          if (unit.isNotEmpty)
            Text(unit, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9)),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(color: AppTheme.textMuted, fontSize: 9), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: TweenAnimationBuilder<double>(
              key: ValueKey(progress),
              tween: Tween(begin: 0.0, end: progress.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (_, val, __) => LinearProgressIndicator(
                value: val,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 4,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text('$pct% dari $goal', style: const TextStyle(color: AppTheme.textMuted, fontSize: 9)),
        ],
      ),
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
    final String zone = bpm < 60 ? 'Istirahat' : bpm < 100 ? 'Normal' : 'Aktif';
    final Color zoneColor = bpm < 60
        ? AppTheme.ringSteps
        : bpm < 100
            ? AppTheme.heartRate
            : AppTheme.streakOrange;

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
              Text('Detak jantung', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13)),
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
              const Text('bpm  ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
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
    const sleepColor = AppTheme.sleepBlue;
    final quality = _sleepQuality(duration);
    final Color qualityColor = quality == 'Great'
        ? AppTheme.ringSteps
        : quality == 'Good'
            ? sleepColor
            : AppTheme.streakOrange;

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
              Text('Tidur', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13)),
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
              const Text('tadi malam  ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
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

