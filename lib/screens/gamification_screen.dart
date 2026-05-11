import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/fitness_service.dart';

class GamificationScreen extends StatelessWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              Text('Achievements', style: Theme.of(context).textTheme.displaySmall),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Level ${data.level}',
                    style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    '${data.xp}/${data.xpNextLevel} XP',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Keep pushing your limits!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: data.levelProgress,
              backgroundColor: AppTheme.surface,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
              minHeight: 4,
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
          gradient: LinearGradient(
            colors: [
              AppTheme.accent.withValues(alpha: 0.9),
              AppTheme.accentDark,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.local_fire_department_rounded, color: AppTheme.background, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Current Streak',
                      style: TextStyle(
                        color: AppTheme.background,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${data.streak} Weeks',
                  style: const TextStyle(
                    color: AppTheme.background,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${data.streak * 7} days in a row!',
                  style: TextStyle(
                    color: AppTheme.background.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.background.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.workspace_premium_rounded, color: AppTheme.accent, size: 40),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesSection(BuildContext context, FitnessService data) {
    final badges = data.badges;

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
            children: badges.map((b) => _BadgeCard(badge: b)).toList(),
          ),
        ],
      ),
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
            title: 'Weekly Steps Goal',
            progress: data.stepsProgress,
            current: '${data.steps} steps',
            goal: '${data.stepsGoal} steps',
          ),
          const SizedBox(height: 10),
          _ChallengeCard(
            icon: Icons.local_fire_department_rounded,
            title: 'Weekly Calories Goal',
            progress: data.caloriesProgress,
            current: '${data.calories} kcal',
            goal: '${data.caloriesGoal} kcal',
          ),
          const SizedBox(height: 10),
          _ChallengeCard(
            icon: Icons.timer_rounded,
            title: 'Move Minutes Goal',
            progress: data.moveMinutesProgress,
            current: '${data.moveMinutes} min',
            goal: '${data.moveMinutesGoal} min',
          ),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final Map<String, dynamic> badge;

  const _BadgeCard({required this.badge});

  @override
  Widget build(BuildContext context) {
    final isDone = badge['done'] as bool;
    return Container(
      decoration: BoxDecoration(
        color: isDone ? AppTheme.surface : AppTheme.surfaceLight.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: isDone
            ? Border.all(color: AppTheme.accent.withValues(alpha: 0.3), width: 1)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            badge['icon'] as IconData,
            size: 32,
            color: isDone ? AppTheme.accent : AppTheme.textMuted,
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
          ),
          const SizedBox(height: 2),
          Text(
            badge['desc'] as String,
            style: TextStyle(
              fontSize: 9,
              color: isDone ? AppTheme.accent : AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final double progress;
  final String current;
  final String goal;

  const _ChallengeCard({
    required this.icon,
    required this.title,
    required this.progress,
    required this.current,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                style: const TextStyle(
                  color: AppTheme.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.surfaceLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
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
    );
  }
}

