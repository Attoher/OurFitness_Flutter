import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/fitness_service.dart';
import '../services/theme_service.dart';
import 'social_screen.dart';

class NotificationDetailScreen extends StatefulWidget {
  final Map<String, dynamic> notification;
  const NotificationDetailScreen({super.key, required this.notification});

  @override
  State<NotificationDetailScreen> createState() => _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  static const _months = [
    'Januari','Februari','Maret','April','Mei','Juni',
    'Juli','Agustus','September','Oktober','November','Desember'
  ];
  static const _weekdays = ['Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Minggu'];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 650))..forward();
    _fade = CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.7, curve: Curves.easeOut));
    _scale = Tween<double>(begin: 0.82, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.6, curve: Curves.easeOutBack)));

    final id = widget.notification['id'] as String?;
    if (id != null && (widget.notification['isNew'] as bool? ?? false)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<FitnessService>().markNotificationRead(id);
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── Type resolution ────────────────────────────────────────────────────────

  String get _type {
    final explicit = widget.notification['type'] as String?;
    if (explicit != null && explicit.isNotEmpty) return explicit;
    switch (widget.notification['iconName'] as String?) {
      case 'directions_run':
      case 'fitness_center': return 'workout';
      case 'local_fire_department': return 'streak';
      case 'workspace_premium':
      case 'rocket_launch': return 'badge';
      case 'bedtime': return 'sleep';
      case 'directions_walk': return 'steps';
      case 'bolt': return 'steps';
      default: return 'info';
    }
  }

  Color _color(String type) {
    switch (type) {
      case 'workout': return AppTheme.ringCalories;
      case 'badge': return AppTheme.xpGold;
      case 'steps': return AppTheme.ringSteps;
      case 'streak': return AppTheme.streakOrange;
      case 'social': case 'friend': return const Color(0xFF34D399);
      case 'heart': return AppTheme.heartRate;
      case 'sleep': return AppTheme.sleepBlue;
      default: return AppTheme.accent;
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'workout': return 'AKTIVITAS';
      case 'badge': return 'PENCAPAIAN';
      case 'steps': return 'LANGKAH';
      case 'streak': return 'STREAK';
      case 'social': case 'friend': return 'SOSIAL';
      case 'heart': return 'KESEHATAN';
      case 'sleep': return 'ISTIRAHAT';
      default: return 'INFO';
    }
  }

  String _meaning(String type) {
    switch (type) {
      case 'workout':
        return 'Sesi latihanmu berhasil tercatat. Data ini ikut menghitung kalori, langkah, dan menit aktif harianmu, sekaligus menjaga streak tetap menyala.';
      case 'badge':
        return 'Kamu membuka sebuah lencana baru. Lencana adalah penanda pencapaian dalam perjalanan kebugaranmu dan membantumu naik level lebih cepat.';
      case 'streak':
        return 'Streak menghitung berapa hari berturut-turut kamu aktif. Semakin panjang streak, semakin besar bonus motivasi dan XP yang kamu dapat.';
      case 'steps':
        return 'Target langkah harianmu tercapai. Berjalan kaki secara rutin membantu kesehatan jantung dan membakar kalori sepanjang hari.';
      case 'sleep':
        return 'Catatan tidurmu diperbarui. Tidur yang cukup mempercepat pemulihan otot dan meningkatkan performa latihan berikutnya.';
      case 'social': case 'friend':
        return 'Ada aktivitas baru dari lingkaran sosialmu. Berkompetisi dan saling mendukung dengan teman membuat olahraga lebih konsisten.';
      default:
        return 'Pembaruan dari OurFitness untukmu. Buka aplikasi secara rutin agar tidak ketinggalan progres dan pencapaian terbaru.';
    }
  }

  String _tip(String type) {
    switch (type) {
      case 'workout': return 'Lakukan minimal 3 sesi per minggu untuk hasil yang optimal.';
      case 'badge': return 'Kumpulkan semua lencana untuk membuka level tertinggi.';
      case 'streak': return 'Cukup 10 menit aktif untuk menjaga streak tetap hidup.';
      case 'steps': return 'Targetkan 8.000–10.000 langkah setiap hari.';
      case 'sleep': return 'Usahakan tidur 7–9 jam agar pemulihan maksimal.';
      case 'social': case 'friend': return 'Ajak temanmu ikut tantangan mingguan untuk motivasi ekstra.';
      default: return 'Tetap konsisten — perubahan kecil setiap hari berdampak besar.';
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeService>();
    final notif = widget.notification;
    final type = _type;
    final color = _color(type);
    final icon = notif['icon'] as IconData? ?? Icons.notifications_rounded;
    final title = notif['title'] as String? ?? '';
    final body = notif['body'] as String? ?? '';
    final relTime = notif['time'] as String? ?? '';
    final rawTime = notif['rawTime'] as DateTime?;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.surface, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary, size: 20),
          ),
        ),
        title: const Text('Detail Notifikasi',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fade,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              // Type chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(_typeLabel(type),
                    style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
              ),
              const SizedBox(height: 18),
              // Hero icon
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 92, height: 92,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 24, spreadRadius: 2)],
                  ),
                  child: Icon(icon, size: 42, color: color),
                ),
              ),
              const SizedBox(height: 20),
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 21, fontWeight: FontWeight.w800, height: 1.3)),
              const SizedBox(height: 10),
              // Time row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.schedule_rounded, size: 13, color: AppTheme.textMuted),
                  const SizedBox(width: 5),
                  Text(
                    rawTime != null ? '${_fullDate(rawTime)} • $relTime' : relTime,
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Body card
              _card(
                child: Text(body,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15, height: 1.65)),
              ),
              const SizedBox(height: 14),
              // Context detail (metrics / badge / social)
              _buildContextSection(type, notif, color),
              // What it means
              const SizedBox(height: 14),
              _infoBlock(
                icon: Icons.lightbulb_outline_rounded,
                color: color,
                label: 'APA ARTINYA?',
                text: _meaning(type),
              ),
              const SizedBox(height: 14),
              // Tip
              _infoBlock(
                icon: Icons.tips_and_updates_rounded,
                color: AppTheme.xpGold,
                label: 'TIPS',
                text: _tip(type),
              ),
              const SizedBox(height: 24),
              _buildActions(type, color),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sections ───────────────────────────────────────────────────────────────

  Widget _buildContextSection(String type, Map<String, dynamic> notif, Color color) {
    if (type == 'workout') {
      final steps = notif['steps'] as int?;
      final calories = notif['calories'] as int?;
      final distance = (notif['distance'] as num?)?.toDouble();
      final duration = notif['duration'] as int?;

      final chips = <_ContextChip>[];
      if (duration != null) chips.add(_ContextChip(Icons.timer_rounded, '$duration', 'menit', color));
      if (calories != null) chips.add(_ContextChip(Icons.local_fire_department_rounded, '$calories', 'kkal', AppTheme.ringCalories));
      if (steps != null) chips.add(_ContextChip(Icons.directions_walk_rounded, _fmt(steps), 'langkah', AppTheme.ringSteps));
      if (distance != null) chips.add(_ContextChip(Icons.route_rounded, distance.toStringAsFixed(1), 'km', AppTheme.ringMove));

      if (chips.isEmpty) return const SizedBox.shrink();

      return _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('RINGKASAN SESI',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.6,
              children: chips.map(_metricBox).toList(),
            ),
          ],
        ),
      );
    }

    if (type == 'badge') {
      final badgeName = notif['badgeName'] as String? ?? notif['title'] as String? ?? '';
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.xpGold.withValues(alpha: 0.18), AppTheme.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.xpGold.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: AppTheme.xpGold.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emoji_events_rounded, size: 34, color: AppTheme.xpGold),
            ),
            const SizedBox(height: 12),
            Text(badgeName,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Lencana berhasil diperoleh',
                style: TextStyle(color: AppTheme.xpGold, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    if (type == 'social' || type == 'friend') {
      return _card(
        child: Row(
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: Icon(Icons.group_rounded, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Aktivitas Komunitas',
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
                  SizedBox(height: 3),
                  Text('Lihat teman dan pencapaian mereka di Komunitas',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildActions(String type, Color color) {
    final isSocial = type == 'social' || type == 'friend';
    return Column(
      children: [
        if (isSocial)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SocialScreen())),
              icon: const Icon(Icons.group_rounded, size: 18),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: ThemeService.isLightColor(color) ? Colors.black : Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              label: const Text('Buka Komunitas'),
            ),
          ),
        if (isSocial) const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.surface,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Mengerti',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  // ── Small building blocks ──────────────────────────────────────────────────

  Widget _card({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(20)),
        child: child,
      );

  Widget _infoBlock({required IconData icon, required Color color, required String label, required String text}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 7),
              Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
            ],
          ),
          const SizedBox(height: 9),
          Text(text, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, height: 1.55)),
        ],
      ),
    );
  }

  Widget _metricBox(_ContextChip c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: c.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(c.icon, size: 20, color: c.color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(c.value,
                    style: TextStyle(color: c.color, fontSize: 16, fontWeight: FontWeight.w800, height: 1.1),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(c.unit, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fullDate(DateTime dt) {
    final wd = _weekdays[dt.weekday - 1];
    final mo = _months[dt.month - 1];
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$wd, ${dt.day} $mo • $hh:$mm';
  }

  String _fmt(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';
}

class _ContextChip {
  final IconData icon;
  final String value;
  final String unit;
  final Color color;
  const _ContextChip(this.icon, this.value, this.unit, this.color);
}
