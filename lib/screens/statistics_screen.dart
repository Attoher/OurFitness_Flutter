import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _selectedTab = 0;
  final List<String> _tabs = ['This week', 'This Month', 'All Time'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(child: _buildTabBar()),
            SliverToBoxAdapter(child: _buildTopMetrics(context)),
            SliverToBoxAdapter(child: _buildWeeklyChart(context)),
            SliverToBoxAdapter(child: _buildMonthlySection(context)),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
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

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: List.generate(_tabs.length, (i) {
            final isSelected = i == _selectedTab;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      _tabs[i],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppTheme.background : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTopMetrics(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _MetricCard(
              label: 'Distance',
              value: '0.00 mi',
              icon: Icons.route_rounded,
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _MetricCard(
              label: 'Duration',
              value: '2h 10m',
              icon: Icons.timer_rounded,
              color: const Color(0xFF4CD8D8),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _MetricCard(
              label: 'Elevation',
              value: '0 ft',
              icon: Icons.landscape_rounded,
              color: const Color(0xFF7B5FDB),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This week',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: CustomPaint(
                size: const Size(double.infinity, 120),
                painter: _WeeklyChartPainter(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                  .map((d) => Text(
                        d,
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlySection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('This Month', style: Theme.of(context).textTheme.titleLarge),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'PR',
                    style: TextStyle(
                      color: AppTheme.background,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Your training added up over time.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: CustomPaint(
                size: const Size(double.infinity, 100),
                painter: _MonthlyChartPainter(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['Oct 1', 'Oct 8', 'Oct 15', 'Oct 22', 'Today']
                  .map((d) => Text(
                        d,
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 10,
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _WeeklyChartPainter extends CustomPainter {
  final List<double> values = [0.2, 0.6, 0.4, 0.8, 0.3, 0.5, 0.7];
  final int activeIndex = 3; // Thursday

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = size.width / values.length;
    final maxBarHeight = size.height - 20;

    for (int i = 0; i < values.length; i++) {
      final isActive = i == activeIndex;
      final paint = Paint()
        ..color = isActive ? AppTheme.accent : AppTheme.surfaceLight
        ..style = PaintingStyle.fill;

      final barHeight = maxBarHeight * values[i];
      final x = i * barWidth + barWidth * 0.2;
      final y = size.height - barHeight;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth * 0.6, barHeight),
        const Radius.circular(6),
      );
      canvas.drawRRect(rect, paint);

      if (isActive) {
        // Draw dot on top
        canvas.drawCircle(
          Offset(x + barWidth * 0.3, y - 8),
          5,
          Paint()..color = AppTheme.accent,
        );
      }
    }

    // Draw line connecting dots
    final linePaint = Paint()
      ..color = AppTheme.accent.withValues(alpha: 0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final barHeight = maxBarHeight * values[i];
      final x = i * barWidth + barWidth * 0.5;
      final y = size.height - barHeight - 8;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MonthlyChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppTheme.accent.withValues(alpha: 0.3),
          AppTheme.accent.withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Upward trending line
    final points = List.generate(20, (i) {
      final progress = i / 19;
      final noise = math.sin(i * 2.5) * 8;
      final trend = size.height * (1 - progress * 0.8);
      return Offset(progress * size.width, trend + noise);
    });

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final cp1 = Offset(
        (points[i - 1].dx + points[i].dx) / 2,
        points[i - 1].dy,
      );
      final cp2 = Offset(
        (points[i - 1].dx + points[i].dx) / 2,
        points[i].dy,
      );
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i].dx, points[i].dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // End dot
    canvas.drawCircle(
      points.last,
      5,
      Paint()..color = AppTheme.accent,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
