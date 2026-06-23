import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/fitness_service.dart';
import '../services/theme_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  int _metricIndex = 0; // 0=Steps, 1=Calories, 2=Move
  late final AnimationController _entrance;

  // Semantic color per metric — matches home stat cards & activity rings.
  Color get _metricColor => _metricIndex == 0
      ? AppTheme.ringSteps
      : _metricIndex == 1
          ? AppTheme.ringCalories
          : AppTheme.ringMove;

  static const _days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  static const _baseSteps    = [8420.0, 6150.0, 9780.0, 7340.0, 10250.0, 5680.0, 4200.0];
  static const _baseCalories = [  430.0,  310.0,  510.0,  380.0,   550.0,  280.0,  210.0];
  static const _baseMove     = [   42.0,   30.0,   55.0,   38.0,    62.0,   25.0,   18.0];

  List<double> _placeholder(List<double> base, int todayIdx) =>
      List.generate(7, (i) {
        if (i < todayIdx) return base[i];
        if (i == todayIdx) return (base[i] * 0.48).roundToDouble();
        return 0.0;
      });

  bool _allZero(List<double> d) => d.every((v) => v == 0.0);

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  Widget _in(Widget child, double from, double to) {
    final fade = CurvedAnimation(parent: _entrance, curve: Interval(from, to, curve: Curves.easeOut));
    return FadeTransition(opacity: fade, child: SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
          .animate(CurvedAnimation(parent: _entrance, curve: Interval(from, to, curve: Curves.easeOut))),
      child: child,
    ));
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeService>();
    final data = context.watch<FitnessService>();
    final todayIdx = DateTime.now().weekday - 1;

    final rawData = _metricIndex == 0
        ? data.weeklySteps
        : _metricIndex == 1
            ? data.weeklyCalories
            : List<double>.filled(7, 0.0);
    final isDemo  = _allZero(rawData);
    final base    = _metricIndex == 0 ? _baseSteps : _metricIndex == 1 ? _baseCalories : _baseMove;
    final weekData = isDemo ? _placeholder(base, todayIdx) : rawData;

    final total = weekData.fold(0.0, (a, b) => a + b);
    final avg   = total / (todayIdx + 1).clamp(1, 7);
    final best  = weekData.isEmpty ? 0.0 : weekData.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _in(_buildHeader(context), 0.0, 0.4)),
            SliverToBoxAdapter(child: _in(_buildStreakBar(context, data), 0.05, 0.45)),
            SliverToBoxAdapter(child: _in(_buildTodaySection(context, data), 0.1, 0.5)),
            SliverToBoxAdapter(child: _in(_buildMetricSelector(context), 0.2, 0.6)),
            SliverToBoxAdapter(child: _in(_buildWeeklyChart(context, weekData, todayIdx, isDemo), 0.25, 0.7)),
            SliverToBoxAdapter(child: _in(_buildSummaryRow(context, total, avg, best, isDemo), 0.3, 0.75)),
            SliverToBoxAdapter(child: _in(_buildRecentWorkouts(context, data), 0.4, 0.85)),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(child: Text('Statistik', style: Theme.of(context).textTheme.displaySmall)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.accent.withValues(alpha: 0.25)),
            ),
            child: Text(
              _weekLabel(),
              style: TextStyle(color: AppTheme.accent, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _weekLabel() {
    final now = DateTime.now();
    final mon = now.subtract(Duration(days: now.weekday - 1));
    final sun = mon.add(const Duration(days: 6));
    return '${mon.day}–${sun.day} ${_monthShort(mon.month)}';
  }

  String _monthShort(int m) => ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agt','Sep','Okt','Nov','Des'][m - 1];

  Widget _buildStreakBar(BuildContext context, FitnessService data) {
    final streak = data.streak;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.streakOrange.withValues(alpha: 0.2), AppTheme.streakOrange.withValues(alpha: 0.06)],
            begin: Alignment.centerLeft, end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.streakOrange.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            const Icon(Icons.local_fire_department_rounded, color: AppTheme.streakOrange, size: 28),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: streak.toDouble()),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  builder: (_, val, __) => Text(
                    '${val.toInt()} Hari Streak',
                    style: const TextStyle(color: AppTheme.streakOrange, fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
                const Text('Kamu konsisten! Pertahankan ✓',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
              ],
            ),
            const Spacer(),
            // 7-day dots
            Row(
              children: List.generate(7, (i) {
                final active = i < (streak % 7 == 0 && streak > 0 ? 7 : streak % 7);
                return Container(
                  width: 8, height: 8,
                  margin: const EdgeInsets.only(left: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active ? AppTheme.streakOrange : AppTheme.surfaceLight,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentWorkouts(BuildContext context, FitnessService data) {
    final workouts = data.recentWorkouts;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('RIWAYAT WORKOUT', style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
              if (workouts.isNotEmpty)
                Text('${workouts.length} sesi terakhir',
                    style: TextStyle(color: AppTheme.accent, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          if (workouts.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.directions_run_rounded, color: AppTheme.textMuted, size: 32),
                    const SizedBox(height: 8),
                    const Text('Belum ada workout', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    const SizedBox(height: 4),
                    const Text('Mulai olahraga untuk melihat riwayat',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                  ],
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: workouts.asMap().entries.map((entry) {
                  final i = entry.key;
                  final w = entry.value;
                  final isLast = i == workouts.length - 1;
                  final date = w['date'] is Timestamp
                      ? (w['date'] as Timestamp).toDate()
                      : DateTime.now();
                  final duration = w['durationMinutes'] as int? ?? 0;
                  final calories = w['calories'] as int? ?? 0;
                  final steps = w['steps'] as int? ?? 0;
                  final distKm = (steps / 1300).toStringAsFixed(1);
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Workout Selesai', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                                      Text(_relativeDate(date), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      _WorkoutChip(icon: Icons.timer_rounded, value: '${duration}m'),
                                      const SizedBox(width: 10),
                                      _WorkoutChip(icon: Icons.local_fire_department_rounded, value: '${calories} kcal'),
                                      const SizedBox(width: 10),
                                      _WorkoutChip(icon: Icons.route_rounded, value: '${distKm} km'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isLast) Divider(height: 1, thickness: 0.5, color: AppTheme.surfaceLight, indent: 66),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  String _relativeDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays == 0) return 'Hari ini';
    if (diff.inDays == 1) return 'Kemarin';
    if (diff.inDays < 7) return '${diff.inDays}h lalu';
    return '${dt.day}/${dt.month}';
  }

  Widget _buildTodaySection(BuildContext context, FitnessService data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TODAY',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textMuted,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _TodayTile(
                icon: Icons.directions_walk_rounded,
                color: AppTheme.ringSteps,
                rawValue: data.steps,
                unit: 'steps',
                progress: data.stepsProgress,
                goal: _fmt(data.stepsGoal),
              )),
              const SizedBox(width: 10),
              Expanded(child: _TodayTile(
                icon: Icons.local_fire_department_rounded,
                color: AppTheme.ringCalories,
                rawValue: data.calories,
                unit: 'kcal',
                progress: data.caloriesProgress,
                goal: _fmt(data.caloriesGoal),
              )),
              const SizedBox(width: 10),
              Expanded(child: _TodayTile(
                icon: Icons.timer_rounded,
                color: AppTheme.ringMove,
                rawValue: data.moveMinutes,
                unit: 'min',
                progress: data.moveMinutesProgress,
                goal: '${data.moveMinutesGoal}',
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        height: 38,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            _SegTab(label: 'Langkah', color: AppTheme.ringSteps, selected: _metricIndex == 0, onTap: () => setState(() => _metricIndex = 0)),
            _SegTab(label: 'Kalori', color: AppTheme.ringCalories, selected: _metricIndex == 1, onTap: () => setState(() => _metricIndex = 1)),
            _SegTab(label: 'Aktif', color: AppTheme.ringMove, selected: _metricIndex == 2, onTap: () => setState(() => _metricIndex = 2)),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context, List<double> weekData, int todayIdx, bool isDemo) {
    final mc = _metricColor;
    double maxVal = weekData.isEmpty ? 1000 : weekData.reduce((a, b) => a > b ? a : b);
    if (maxVal == 0) maxVal = 1000;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 18, 12, 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _metricIndex == 0 ? 'Langkah Mingguan' : _metricIndex == 1 ? 'Kalori Mingguan' : 'Menit Aktif',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  maxY: maxVal * 1.3,
                  minY: 0,
                  barTouchData: BarTouchData(
                    enabled: !isDemo,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => AppTheme.surfaceLight,
                      getTooltipItem: (group, _, rod, __) {
                        final label = _metricIndex == 0
                            ? '${rod.toY.toInt()} langkah'
                            : _metricIndex == 1
                                ? '${rod.toY.toInt()} kcal'
                                : '${rod.toY.toInt()} menit';
                        return BarTooltipItem(
                          label,
                          const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        getTitlesWidget: (val, _) {
                          final i = val.toInt();
                          if (i < 0 || i >= _days.length) return const SizedBox.shrink();
                          final isToday = i == todayIdx;
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              _days[i],
                              style: TextStyle(
                                color: isToday ? mc : AppTheme.textMuted,
                                fontSize: 10,
                                fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxVal / 3,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.white.withValues(alpha: 0.05),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(weekData.length, (i) {
                    final isToday = i == todayIdx;
                    final isFuture = i > todayIdx;
                    final val = weekData[i];

                    if (isFuture || val == 0) {
                      return BarChartGroupData(x: i, barRods: [
                        BarChartRodData(
                          toY: maxVal * 0.08,
                          color: Colors.white.withValues(alpha: 0.05),
                          width: 22,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        ),
                      ]);
                    }

                    return BarChartGroupData(x: i, barRods: [
                      BarChartRodData(
                        toY: val,
                        gradient: isDemo
                            ? LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: isToday
                                    ? [
                                        mc.withValues(alpha: 0.55),
                                        mc.withValues(alpha: 0.85),
                                      ]
                                    : [
                                        mc.withValues(alpha: 0.20),
                                        mc.withValues(alpha: 0.40),
                                      ],
                              )
                            : LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: isToday
                                    ? [mc, mc.withValues(alpha: 0.85)]
                                    : [
                                        mc.withValues(alpha: 0.30),
                                        mc.withValues(alpha: 0.55),
                                      ],
                              ),
                        width: 22,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ]);
                  }),
                ),
              ),
            ),
            if (isDemo) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline_rounded, size: 11, color: AppTheme.textMuted.withValues(alpha: 0.5)),
                  const SizedBox(width: 4),
                  Text(
                    'Mulai workout untuk melihat data aslimu',
                    style: TextStyle(
                      color: AppTheme.textMuted.withValues(alpha: 0.5),
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, double total, double avg, double best, bool isDemo) {
    final unit = _metricIndex == 0 ? '' : _metricIndex == 1 ? ' kcal' : ' min';
    String fmtBig(double v) {
      if (_metricIndex == 0 && v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
      return v.toInt().toString();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          Expanded(child: _SummaryCard(label: 'Total', value: '${fmtBig(total)}$unit', dimmed: isDemo)),
          const SizedBox(width: 10),
          Expanded(child: _SummaryCard(label: 'Rata-rata', value: '${fmtBig(avg)}$unit', dimmed: isDemo)),
          const SizedBox(width: 10),
          Expanded(child: _SummaryCard(label: 'Terbaik', value: '${fmtBig(best)}$unit', dimmed: isDemo)),
        ],
      ),
    );
  }

  String _fmt(int val) => val >= 1000 ? '${(val / 1000).toStringAsFixed(1)}k' : '$val';
}

class _WorkoutChip extends StatelessWidget {
  final IconData icon;
  final String value;
  const _WorkoutChip({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: AppTheme.accent),
        const SizedBox(width: 3),
        Text(value, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
      ],
    );
  }
}

class _TodayTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int rawValue;
  final String unit;
  final double progress;
  final String goal;

  const _TodayTile({
    required this.icon,
    required this.color,
    required this.rawValue,
    required this.unit,
    required this.progress,
    required this.goal,
  });

  String _fmt(int val) => val >= 1000 ? '${(val / 1000).toStringAsFixed(1)}k' : '$val';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 8),
          rawValue == 0
              ? const Text('--', style: TextStyle(color: AppTheme.textSecondary, fontSize: 17, fontWeight: FontWeight.w700))
              : TweenAnimationBuilder<double>(
                  key: ValueKey(rawValue),
                  tween: Tween(begin: 0, end: rawValue.toDouble()),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOut,
                  builder: (_, val, __) => Text(
                    _fmt(val.toInt()),
                    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
          Text(unit, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'goal $goal',
            style: TextStyle(color: color.withValues(alpha: 0.6), fontSize: 9),
          ),
        ],
      ),
    );
  }
}

class _SegTab extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _SegTab({required this.label, required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected) ...[
                  Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? color : AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final bool dimmed;

  const _SummaryCard({required this.label, required this.value, this.dimmed = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              color: dimmed ? Colors.white.withValues(alpha: 0.45) : Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

