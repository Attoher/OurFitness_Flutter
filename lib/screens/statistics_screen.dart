import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/fitness_service.dart';
import '../theme/app_theme.dart';

enum _StatsRangeMode { week, month, custom }

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _metricIndex = 0;
  _StatsRangeMode _rangeMode = _StatsRangeMode.week;
  DateTimeRange? _customRange;

  DateTimeRange _effectiveRange() {
    final now = DateTime.now();
    switch (_rangeMode) {
      case _StatsRangeMode.week:
        return DateTimeRange(
          start: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6)),
          end: DateTime(now.year, now.month, now.day),
        );
      case _StatsRangeMode.month:
        return DateTimeRange(
          start: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 29)),
          end: DateTime(now.year, now.month, now.day),
        );
      case _StatsRangeMode.custom:
        return _customRange ?? DateTimeRange(
          start: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 13)),
          end: DateTime(now.year, now.month, now.day),
        );
    }
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
      initialDateRange: _customRange ?? DateTimeRange(
        start: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 13)),
        end: DateTime(now.year, now.month, now.day),
      ),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.accent,
            surface: AppTheme.surface,
          ),
        ),
        child: child ?? const SizedBox.shrink(),
      ),
    );
    if (selected != null) {
      setState(() {
        _rangeMode = _StatsRangeMode.custom;
        _customRange = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<FitnessService>();
    if (data.isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
      );
    }

    final range = _effectiveRange();
    final records = data.recordsBetween(range.start, range.end);
    final summary = data.snapshotBetween(range.start, range.end);
    final hasData = records.any((record) => record.hasActivity);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, data.errorMessage)),
            SliverToBoxAdapter(child: _buildTodaySection(context, data)),
            SliverToBoxAdapter(child: _buildMetricSelector()),
            SliverToBoxAdapter(child: _buildRangeSelector(context, range)),
            if (!hasData)
              SliverToBoxAdapter(child: _buildEmptyState())
            else ...[
              SliverToBoxAdapter(child: _buildChart(context, records)),
              SliverToBoxAdapter(child: _buildSummaryRow(summary)),
              SliverToBoxAdapter(child: _buildProgressInsight(summary)),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String? errorMessage) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Statistics', style: Theme.of(context).textTheme.displaySmall),
          if (errorMessage != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
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
              Expanded(
                child: _TodayTile(
                  icon: Icons.directions_walk_rounded,
                  color: AppTheme.ringSteps,
                  rawValue: data.steps,
                  unit: 'steps',
                  progress: data.stepsProgress,
                  goal: _compact(data.stepsGoal),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TodayTile(
                  icon: Icons.local_fire_department_rounded,
                  color: AppTheme.ringCalories,
                  rawValue: data.calories,
                  unit: 'kcal',
                  progress: data.caloriesProgress,
                  goal: _compact(data.caloriesGoal),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TodayTile(
                  icon: Icons.timer_rounded,
                  color: AppTheme.ringMove,
                  rawValue: data.moveMinutes,
                  unit: 'min',
                  progress: data.moveMinutesProgress,
                  goal: '${data.moveMinutesGoal}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricSelector() {
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
            _SegTab(
              label: 'Steps',
              selected: _metricIndex == 0,
              onTap: () => setState(() => _metricIndex = 0),
            ),
            _SegTab(
              label: 'Calories',
              selected: _metricIndex == 1,
              onTap: () => setState(() => _metricIndex = 1),
            ),
            _SegTab(
              label: 'Move',
              selected: _metricIndex == 2,
              onTap: () => setState(() => _metricIndex = 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeSelector(BuildContext context, DateTimeRange range) {
    final formatter = DateFormat('dd MMM');
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _RangeChip(
                      label: '7D',
                      selected: _rangeMode == _StatsRangeMode.week,
                      onTap: () => setState(() => _rangeMode = _StatsRangeMode.week),
                    ),
                    _RangeChip(
                      label: '30D',
                      selected: _rangeMode == _StatsRangeMode.month,
                      onTap: () => setState(() => _rangeMode = _StatsRangeMode.month),
                    ),
                    _RangeChip(
                      label: 'Custom',
                      selected: _rangeMode == _StatsRangeMode.custom,
                      onTap: _pickCustomRange,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${formatter.format(range.start)} - ${formatter.format(range.end)}',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context, List<DailyStatRecord> records) {
    final values = records.map(_metricValue).toList();
    var maxVal = values.fold<double>(0, (max, value) => value > max ? value : max);
    if (maxVal <= 0) {
      maxVal = 1;
    }
    final formatter = DateFormat(records.length > 14 ? 'd/M' : 'E');

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
                  _chartTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  'Synced from daily stats',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 190,
              child: BarChart(
                BarChartData(
                  maxY: maxVal * 1.25,
                  minY: 0,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => AppTheme.surfaceLight,
                      getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                        '${rod.toY.toStringAsFixed(_metricIndex == 2 ? 0 : 0)} ${_metricUnit}',
                        const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 26,
                        getTitlesWidget: (value, _) {
                          final index = value.toInt();
                          if (index < 0 || index >= records.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              formatter.format(records[index].date),
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
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
                  barGroups: List.generate(records.length, (index) {
                    final isToday = DateUtils.isSameDay(records[index].date, DateTime.now());
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: values[index],
                          width: records.length > 20 ? 10 : 18,
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: isToday
                                ? [_metricColor, _metricColor.withValues(alpha: 0.75)]
                                : [
                                    _metricColor.withValues(alpha: 0.25),
                                    _metricColor.withValues(alpha: 0.55),
                                  ],
                          ),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(ProgressSnapshot summary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              label: 'Total',
              value: _summaryValue(summary),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryCard(
              label: 'Goal Rate',
              value: '${(summary.goalCompletionRate * 100).round()}%',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryCard(
              label: 'Consistency',
              value: '${(summary.consistencyScore * 100).round()}%',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressInsight(ProgressSnapshot summary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.insights_rounded, color: AppTheme.accent, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Progress tracking',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _trackingStatusColor(summary).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    summary.trackingStatus,
                    style: TextStyle(
                      color: _trackingStatusColor(summary),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _InsightStat(label: 'Workouts', value: '${summary.totalWorkouts}')),
                Expanded(child: _InsightStat(label: 'Active days', value: '${summary.activeDays}')),
                Expanded(
                  child: _InsightStat(
                    label: 'Distance',
                    value: '${summary.totalDistanceKm.toStringAsFixed(1)} km',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Status ini dihitung dari goal completion rate dan consistency score agar progres terasa nyata, bukan hanya tampilan.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 12, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(Icons.bar_chart_rounded, size: 42, color: AppTheme.textMuted.withValues(alpha: 0.55)),
            const SizedBox(height: 14),
            const Text(
              'Belum ada statistik untuk rentang ini',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Selesaikan workout terlebih dahulu agar chart, KPI, dan progress tracking terisi otomatis.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  double _metricValue(DailyStatRecord record) {
    switch (_metricIndex) {
      case 0:
        return record.steps.toDouble();
      case 1:
        return record.calories.toDouble();
      case 2:
        return record.moveMinutes.toDouble();
      default:
        return 0;
    }
  }

  String get _chartTitle {
    switch (_metricIndex) {
      case 0:
        return 'Steps trend';
      case 1:
        return 'Calories trend';
      case 2:
        return 'Active minutes trend';
      default:
        return 'Trend';
    }
  }

  String get _metricUnit {
    switch (_metricIndex) {
      case 0:
        return 'steps';
      case 1:
        return 'kcal';
      case 2:
        return 'min';
      default:
        return '';
    }
  }

  Color get _metricColor {
    switch (_metricIndex) {
      case 0:
        return AppTheme.ringSteps;
      case 1:
        return AppTheme.ringCalories;
      case 2:
        return AppTheme.ringMove;
      default:
        return AppTheme.accent;
    }
  }

  String _summaryValue(ProgressSnapshot summary) {
    switch (_metricIndex) {
      case 0:
        return _compact(summary.totalSteps);
      case 1:
        return '${summary.totalCalories}';
      case 2:
        return '${summary.totalMoveMinutes}';
      default:
        return '0';
    }
  }

  Color _trackingStatusColor(ProgressSnapshot summary) {
    switch (summary.trackingStatus) {
      case 'On track':
        return AppTheme.accent;
      case 'Needs focus':
        return Colors.orangeAccent;
      default:
        return Colors.redAccent;
    }
  }

  String _compact(int value) => value >= 1000 ? '${(value / 1000).toStringAsFixed(1)}k' : '$value';
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
          Text(
            _fmt(rawValue),
            style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
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

  const _SummaryCard({required this.label, required this.value});

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
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _InsightStat extends StatelessWidget {
  final String label;
  final String value;

  const _InsightStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _RangeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RangeChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accent.withValues(alpha: 0.15) : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.accent.withValues(alpha: 0.28) : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppTheme.accent : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
