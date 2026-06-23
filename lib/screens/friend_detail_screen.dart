import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/theme_service.dart';
import '../services/social_service.dart';

class FriendDetailScreen extends StatefulWidget {
  final Map<String, dynamic> friend;
  const FriendDetailScreen({super.key, required this.friend});

  @override
  State<FriendDetailScreen> createState() => _FriendDetailScreenState();
}

class _FriendDetailScreenState extends State<FriendDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;
  List<Map<String, dynamic>> _workouts = [];
  bool _loadingWorkouts = true;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward();
    _loadWorkouts();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  Future<void> _loadWorkouts() async {
    final uid = widget.friend['uid'] as String? ?? '';
    if (uid.isEmpty) { setState(() => _loadingWorkouts = false); return; }
    final social = context.read<SocialService>();
    final workouts = await social.friendWorkouts(uid);
    if (mounted) setState(() { _workouts = workouts; _loadingWorkouts = false; });
  }

  Future<void> _removeFriend() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Teman?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: const Text('Kamu tidak akan bisa melihat aktivitasnya lagi.',
            style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final uid = widget.friend['uid'] as String;
      await context.read<SocialService>().removeFriend(uid);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeService>();
    final accent = AppTheme.accent;
    final name = widget.friend['displayName'] ?? widget.friend['name'] ?? 'Teman';
    final level = widget.friend['level'] as int? ?? 1;
    final streak = widget.friend['streak'] as int? ?? 0;
    final xp = widget.friend['xp'] as int? ?? 0;
    final xpNext = widget.friend['xpNextLevel'] as int? ?? 1000;
    final photoB64 = widget.friend['photoBase64'] as String? ?? '';
    final hasPhoto = photoB64.isNotEmpty;
    final initial = (name as String).isNotEmpty ? name[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            backgroundColor: AppTheme.background,
            pinned: true,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: AppTheme.surface.withValues(alpha: 0.9), shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary, size: 20),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _removeFriend();
                },
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: AppTheme.surface.withValues(alpha: 0.9), shape: BoxShape.circle),
                  child: const Icon(Icons.person_remove_rounded, color: Colors.redAccent, size: 20),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent.withValues(alpha: 0.25), AppTheme.background],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: accent, width: 2.5),
                          color: AppTheme.surface,
                        ),
                        child: ClipOval(
                          child: hasPhoto
                              ? Image.memory(base64Decode(photoB64), fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _defaultAvatar(accent, initial))
                              : _defaultAvatar(accent, initial),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: const TextStyle(
                                    color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.xpGold.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text('Level $level',
                                      style: const TextStyle(
                                          color: AppTheme.xpGold, fontSize: 11, fontWeight: FontWeight.w700)),
                                ),
                                if (streak > 0) ...[
                                  const SizedBox(width: 8),
                                  const Icon(Icons.local_fire_department_rounded,
                                      size: 13, color: AppTheme.streakOrange),
                                  const SizedBox(width: 3),
                                  Text('$streak hari streak',
                                      style: const TextStyle(
                                          color: AppTheme.streakOrange, fontSize: 11, fontWeight: FontWeight.w600)),
                                ],
                              ],
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
          SliverToBoxAdapter(child: _buildXpBar(accent, xp, xpNext)),
          SliverToBoxAdapter(child: _buildStatsRow(accent)),
          SliverToBoxAdapter(child: _buildWorkouts(accent)),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _defaultAvatar(Color accent, String initial) {
    return Container(
      color: accent.withValues(alpha: 0.15),
      child: Center(
        child: Text(initial,
            style: TextStyle(color: accent, fontSize: 28, fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _buildXpBar(Color accent, int xp, int xpNext) {
    final progress = (xp / xpNext).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star_rounded, size: 14, color: AppTheme.xpGold),
                const SizedBox(width: 6),
                const Text('PROGRESS XP',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
                const Spacer(),
                Text('$xp / $xpNext XP',
                    style: const TextStyle(color: AppTheme.xpGold, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: progress),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutCubic,
                builder: (_, val, __) => LinearProgressIndicator(
                  value: val,
                  backgroundColor: AppTheme.xpGold.withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.xpGold),
                  minHeight: 7,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(Color accent) {
    final total = _workouts.length;
    int totalCal = 0;
    double totalKm = 0;
    for (final w in _workouts) {
      totalCal += (w['calories'] as int? ?? 0);
      totalKm += (w['steps'] as num? ?? 0).toDouble() / 1300;
    }

    final calStr = totalCal >= 1000 ? '${(totalCal / 1000).toStringAsFixed(1)}k' : '$totalCal';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          _StatChip(label: 'Sesi', value: '$total', icon: Icons.fitness_center_rounded, color: AppTheme.ringMove),
          const SizedBox(width: 8),
          _StatChip(label: 'Kalori', value: calStr, icon: Icons.local_fire_department_rounded, color: AppTheme.ringCalories),
          const SizedBox(width: 8),
          _StatChip(label: 'Jarak', value: '${totalKm.toStringAsFixed(1)} km', icon: Icons.route_rounded, color: AppTheme.ringSteps),
        ],
      ),
    );
  }

  Widget _buildWorkouts(Color accent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('AKTIVITAS TERBARU',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
          const SizedBox(height: 12),
          if (_loadingWorkouts)
            Center(child: CircularProgressIndicator(strokeWidth: 2, color: accent))
          else if (_workouts.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
              child: const Center(
                child: Text('Belum ada aktivitas dicatat',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              ),
            )
          else
            Column(
              children: _workouts.map((w) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _WorkoutRow(workout: w, accent: accent),
              )).toList(),
            ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _WorkoutRow extends StatelessWidget {
  final Map<String, dynamic> workout;
  final Color accent;
  const _WorkoutRow({required this.workout, required this.accent});

  @override
  Widget build(BuildContext context) {
    final type = workout['type'] as String? ?? 'Workout Selesai';
    final calories = workout['calories'] as int? ?? 0;
    final steps = (workout['steps'] as num?)?.toDouble() ?? 0;
    final distance = steps > 0 ? steps / 1300 : null;
    final duration = workout['durationMinutes'] as int? ?? 0;
    final date = workout['date'];
    String dateStr = '';
    if (date != null) {
      try {
        DateTime dt;
        if (date is int) {
          dt = DateTime.fromMillisecondsSinceEpoch(date);
        } else {
          dt = (date as dynamic).toDate() as DateTime;
        }
        final diff = DateTime.now().difference(dt);
        if (diff.inDays == 0) {
          dateStr = 'Hari ini';
        } else if (diff.inDays == 1) {
          dateStr = 'Kemarin';
        } else {
          dateStr = '${diff.inDays} hari lalu';
        }
      } catch (_) {}
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppTheme.ringCalories.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.directions_run_rounded, color: AppTheme.ringCalories, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Row(
                  children: [
                    if (distance != null) ...[
                      const Icon(Icons.route_rounded, size: 12, color: AppTheme.textMuted),
                      const SizedBox(width: 2),
                      Text('${distance.toStringAsFixed(1)} km',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                      const SizedBox(width: 8),
                    ],
                    const Icon(Icons.timer_rounded, size: 12, color: AppTheme.textMuted),
                    const SizedBox(width: 2),
                    Text('$duration menit',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department_rounded, size: 13, color: AppTheme.ringCalories),
                  const SizedBox(width: 3),
                  Text('$calories',
                      style: const TextStyle(color: AppTheme.ringCalories, fontSize: 13, fontWeight: FontWeight.w700)),
                ],
              ),
              if (dateStr.isNotEmpty)
                Text(dateStr, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}
