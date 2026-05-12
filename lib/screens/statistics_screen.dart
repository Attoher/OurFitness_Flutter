import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/fitness_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _metricIndex = 0; // 0=Steps, 1=Calories

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static const _baseSteps    = [8420.0, 6150.0, 9780.0, 7340.0, 10250.0, 5680.0, 4200.0];
  static const _baseCalories = [  430.0,  310.0,  510.0,  380.0,   550.0,  280.0,  210.0];

  List<double> _placeholder(List<double> base, int todayIdx) =>
      List.generate(7, (i) {
        if (i < todayIdx) return base[i];
        if (i == todayIdx) return (base[i] * 0.48).roundToDouble();
        return 0.0;
      });

  bool _allZero(List<double> d) => d.every((v) => v == 0.0);

  @override
  Widget build(BuildContext context) {
    final data = context.watch<FitnessService>();
    final todayIdx = DateTime.now().weekday - 1;

    final rawData   = _metricIndex == 0 ? data.weeklySteps : data.weeklyCalories;
    final isDemo    = _allZero(rawData);
    final base      = _metricIndex == 0 ? _baseSteps : _baseCalories;
    final weekData  = isDemo ? _placeholder(base, todayIdx) : rawData;

    final total = weekData.fold(0.0, (a, b) => a + b);
    final avg   = total / (todayIdx + 1).clamp(1, 7);
    final best  = weekData.isEmpty ? 0.0 : weekData.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(child: _buildTodaySection(context, data)),
            SliverToBoxAdapter(child: _buildMetricSelector(context)),
            SliverToBoxAdapter(child: _buildWeeklyChart(context, weekData, todayIdx, isDemo)),
            SliverToBoxAdapter(child: _buildSummaryRow(context, total, avg, best, isDemo)),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Text('Statistics', style: Theme.of(context).textTheme.displaySmall),
    );
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        height: 38,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            _SegTab(label: 'Steps', selected: _metricIndex == 0, onTap: () => setState(() => _metricIndex = 0)),
            _SegTab(label: 'Calories', selected: _metricIndex == 1, onTap: () => setState(() => _metricIndex = 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context, List<double> weekData, int todayIdx, bool isDemo) {
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
                  _metricIndex == 0 ? 'Weekly Steps' : 'Weekly Calories',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                if (isDemo)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.accent.withValues(alpha: 0.25), width: 0.8),
                    ),
                    child: Text(
                      'Sample',
                      style: TextStyle(
                        color: AppTheme.accent.withValues(alpha: 0.75),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  )
                else
                  Text(
                    'This week',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textMuted),
                  ),
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
                            ? '${rod.toY.toInt()} steps'
                            : '${rod.toY.toInt()} kcal';
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
                                color: isToday ? AppTheme.accent : AppTheme.textMuted,
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
                                        AppTheme.accent.withValues(alpha: 0.55),
                                        AppTheme.accent.withValues(alpha: 0.85),
                                      ]
                                    : [
                                        AppTheme.accent.withValues(alpha: 0.20),
                                        AppTheme.accent.withValues(alpha: 0.40),
                                      ],
                              )
                            : LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: isToday
                                    ? [AppTheme.accent, AppTheme.accent.withValues(alpha: 0.85)]
                                    : [
                                        AppTheme.accent.withValues(alpha: 0.30),
                                        AppTheme.accent.withValues(alpha: 0.55),
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
                    'Start a workout to see your real stats',
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
    final isSteps = _metricIndex == 0;
    final unit    = isSteps ? '' : ' kcal';

    String fmtBig(double v) {
      if (isSteps && v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
      return v.toInt().toString();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          Expanded(child: _SummaryCard(label: 'Total', value: '${fmtBig(total)}$unit', dimmed: isDemo)),
          const SizedBox(width: 10),
          Expanded(child: _SummaryCard(label: 'Daily Avg', value: '${fmtBig(avg)}$unit', dimmed: isDemo)),
          const SizedBox(width: 10),
          Expanded(child: _SummaryCard(label: 'Best Day', value: '${fmtBig(best)}$unit', dimmed: isDemo)),
        ],
      ),
    );
  }

  String _fmt(int val) => val >= 1000 ? '${(val / 1000).toStringAsFixed(1)}k' : '$val';
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
  final bool selected;
  final VoidCallback onTap;

  const _SegTab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: selected ? AppTheme.surfaceLight : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? AppTheme.textPrimary : AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
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

