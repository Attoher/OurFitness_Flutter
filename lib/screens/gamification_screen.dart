import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/fitness_service.dart';
import '../services/theme_service.dart';

class GamificationScreen extends StatelessWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeService>();
    final fitnessData = context.watch<FitnessService>();
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, fitnessData)),
            SliverToBoxAdapter(child: _buildStreakCard(context, fitnessData)),
            SliverToBoxAdapter(child: _buildBadgesSection(context, fitnessData)),
            SliverToBoxAdapter(child: _buildChallengesSection(context, fitnessData)),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, FitnessService data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pencapaian', style: Theme.of(context).textTheme.displaySmall),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.xpGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.xpGold.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: AppTheme.xpGold, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Level ${data.level}',
                          style: const TextStyle(color: AppTheme.xpGold, fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      ],
                    ),
                    Text(
                      '${data.xp}/${data.xpNextLevel} XP',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Terus dorong batasmu!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              key: ValueKey(data.levelProgress),
              tween: Tween(begin: 0.0, end: data.levelProgress),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (_, val, __) => LinearProgressIndicator(
                value: val,
                backgroundColor: AppTheme.surface,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.xpGold),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, FitnessService data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.streakOrange, Color(0xFFFF6D00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.streakOrange.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Streak Saat Ini',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TweenAnimationBuilder<double>(
                    key: ValueKey(data.streak),
                    tween: Tween(begin: 0, end: data.streak.toDouble()),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutCubic,
                    builder: (_, val, __) => Text(
                      '${val.toInt()} Hari',
                      style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800, height: 1),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.streak > 0 ? 'Berturut-turut tanpa absen! 🔥' : 'Mulai streak pertamamu hari ini!',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 40),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _placeholderBadge = {
    'icon': Icons.rocket_launch_rounded,
    'title': 'First Step',
    'desc': 'Welcome to OurFitness!',
    'done': true,
    'detail': 'You took the first step toward a healthier life. Every legend starts somewhere — this is your origin story.',
    'earnedOn': 'Today',
    'placeholder': true,
  };

  Widget _buildBadgesSection(BuildContext context, FitnessService data) {
    final realBadges = data.badges;
    final badges = realBadges.isEmpty
        ? [_placeholderBadge]
        : realBadges;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Badges', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 14),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: badges.map((b) => _BadgeCard(
              badge: b,
              onTap: (b['done'] as bool)
                  ? () => _openBadgeDetail(context, b)
                  : null,
            )).toList(),
          ),
        ],
      ),
    );
  }

  void _openBadgeDetail(BuildContext context, Map<String, dynamic> badge) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'badge-detail',
      barrierColor: Colors.black.withValues(alpha: 0.85),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => BadgeDetailScreen(badge: badge),
      transitionBuilder: (ctx, anim, _, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(scale: Tween(begin: 0.82, end: 1.0).animate(curved), child: child),
        );
      },
    );
  }

  Widget _buildChallengesSection(BuildContext context, FitnessService data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Challenges', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 14),
          _ChallengeCard(
            icon: Icons.directions_walk_rounded,
            title: 'Daily Steps Goal',
            progress: data.stepsProgress,
            current: '${data.steps} steps',
            goal: '${data.stepsGoal} steps',
            onEdit: () => _showEditGoalDialog(context, 'Steps Goal', data.stepsGoal, 'steps',
              (val) => data.updateGoals(stepsGoal: val),
            ),
          ),
          const SizedBox(height: 10),
          _ChallengeCard(
            icon: Icons.local_fire_department_rounded,
            title: 'Daily Calories Goal',
            progress: data.caloriesProgress,
            current: '${data.calories} kcal',
            goal: '${data.caloriesGoal} kcal',
            onEdit: () => _showEditGoalDialog(context, 'Calories Goal', data.caloriesGoal, 'kcal',
              (val) => data.updateGoals(caloriesGoal: val),
            ),
          ),
          const SizedBox(height: 10),
          _ChallengeCard(
            icon: Icons.timer_rounded,
            title: 'Move Minutes Goal',
            progress: data.moveMinutesProgress,
            current: '${data.moveMinutes} min',
            goal: '${data.moveMinutesGoal} min',
            onEdit: () => _showEditGoalDialog(context, 'Move Minutes Goal', data.moveMinutesGoal, 'min',
              (val) => data.updateGoals(moveMinutesGoal: val),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditGoalDialog(
    BuildContext context,
    String title,
    int currentGoal,
    String unit,
    Future<void> Function(int) onSave,
  ) {
    final controller = TextEditingController(text: currentGoal.toString());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit $title', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: InputDecoration(
                suffixText: unit,
                suffixStyle: const TextStyle(color: AppTheme.textSecondary),
                filled: true,
                fillColor: AppTheme.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final val = int.tryParse(controller.text);
                  if (val != null && val > 0) {
                    onSave(val);
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Save Goal'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final Map<String, dynamic> badge;
  final VoidCallback? onTap;

  const _BadgeCard({required this.badge, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDone = badge['done'] as bool;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDone ? AppTheme.surface : AppTheme.surfaceLight.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: isDone
              ? Border.all(color: AppTheme.accent.withValues(alpha: 0.35), width: 1)
              : null,
          boxShadow: isDone
              ? [BoxShadow(color: AppTheme.accent.withValues(alpha: 0.08), blurRadius: 12, spreadRadius: 0)]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (isDone)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.accent.withValues(alpha: 0.10),
                    ),
                  ),
                Icon(
                  badge['icon'] as IconData,
                  size: 28,
                  color: isDone ? AppTheme.accent : AppTheme.textMuted,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              badge['title'] as String,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDone ? AppTheme.textPrimary : AppTheme.textMuted,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            const SizedBox(height: 2),
            if (isDone)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.touch_app_rounded, size: 8, color: AppTheme.accent.withValues(alpha: 0.5)),
                  const SizedBox(width: 2),
                  Text(
                    'tap to view',
                    style: TextStyle(fontSize: 8, color: AppTheme.accent.withValues(alpha: 0.5)),
                  ),
                ],
              )
            else
              Text(
                badge['desc'] as String,
                style: const TextStyle(fontSize: 9, color: AppTheme.textMuted),
              ),
          ],
        ),
      ),
    );
  }
}

class BadgeDetailScreen extends StatelessWidget {
  final Map<String, dynamic> badge;

  const BadgeDetailScreen({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    final icon    = badge['icon'] as IconData;
    final title   = badge['title'] as String;
    final desc    = badge['desc'] as String;
    final detail  = badge['detail'] as String? ?? desc;
    final earned  = badge['earnedOn'] as String? ?? 'Recently';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(color: Color(0xFF0A0A0A)),
          ),
          // Radial glow
          Center(
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.accent.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
          // Sparkle decorations
          const _SparkleLayer(),
          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white54, size: 18),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // "ACHIEVEMENT UNLOCKED" pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3), width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome_rounded, size: 12, color: AppTheme.accent.withValues(alpha: 0.8)),
                      const SizedBox(width: 6),
                      Text(
                        'ACHIEVEMENT UNLOCKED',
                        style: TextStyle(
                          color: AppTheme.accent.withValues(alpha: 0.85),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.8,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.auto_awesome_rounded, size: 12, color: AppTheme.accent.withValues(alpha: 0.8)),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                // Badge icon with glow rings
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer glow ring
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.12), width: 1),
                      ),
                    ),
                    // Mid ring
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.22), width: 1),
                      ),
                    ),
                    // Icon circle
                    Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.surfaceLight,
                        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.45), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accent.withValues(alpha: 0.35),
                            blurRadius: 28,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(icon, size: 52, color: AppTheme.accent),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Badge title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 14),
                // Detail description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 44),
                  child: Text(
                    detail,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 28),
                // Earned on chip
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 11, color: Colors.white.withValues(alpha: 0.3)),
                    const SizedBox(width: 5),
                    Text(
                      'Earned $earned',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Bottom branding
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 24,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fitness_center_rounded, size: 13, color: Colors.white.withValues(alpha: 0.2)),
                const SizedBox(width: 6),
                Text(
                  'OurFitness',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.2),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SparkleLayer extends StatefulWidget {
  const _SparkleLayer();

  @override
  State<_SparkleLayer> createState() => _SparkleLayerState();
}

class _SparkleLayerState extends State<_SparkleLayer> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  static final _rng = math.Random(42);
  static final _sparkles = List.generate(18, (_) => (
    x: _rng.nextDouble(),
    y: _rng.nextDouble(),
    size: 6.0 + _rng.nextDouble() * 10,
    phase: _rng.nextDouble() * math.pi * 2,
    speed: 0.6 + _rng.nextDouble() * 0.8,
  ));

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return CustomPaint(
          painter: _SparklePainter(_ctrl.value, _sparkles, AppTheme.accent),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _SparklePainter extends CustomPainter {
  final double t;
  final List<({double x, double y, double size, double phase, double speed})> sparkles;
  final Color accent;

  _SparklePainter(this.t, this.sparkles, this.accent);

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in sparkles) {
      final pulse = (math.sin(t * math.pi * 2 * s.speed + s.phase) + 1) / 2;
      final alpha = (0.08 + pulse * 0.28).clamp(0.0, 1.0);
      final sz    = s.size * (0.6 + pulse * 0.4);
      final paint = Paint()..color = accent.withValues(alpha: alpha);
      final cx = s.x * size.width;
      final cy = s.y * size.height;
      // Draw ✦ as 4-pointed star via path
      final path = Path();
      final r  = sz / 2;
      final r2 = r * 0.22;
      for (int i = 0; i < 8; i++) {
        final angle = i * math.pi / 4;
        final radius = i.isEven ? r : r2;
        final px = cx + radius * math.cos(angle - math.pi / 2);
        final py = cy + radius * math.sin(angle - math.pi / 2);
        i == 0 ? path.moveTo(px, py) : path.lineTo(px, py);
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SparklePainter old) => old.t != t;
}

class _ChallengeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final double progress;
  final String current;
  final String goal;
  final VoidCallback? onEdit;

  const _ChallengeCard({
    required this.icon,
    required this.title,
    required this.progress,
    required this.current,
    required this.goal,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: AppTheme.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (onEdit != null) ...[
                const SizedBox(width: 8),
                const Icon(Icons.edit_rounded, size: 14, color: AppTheme.textMuted),
              ],
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.surfaceLight,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accent),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(current, style: Theme.of(context).textTheme.bodySmall),
              Text(goal, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    ));
  }
}

