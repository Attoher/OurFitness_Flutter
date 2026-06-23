import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/fitness_service.dart';
import '../services/theme_service.dart';
import '../theme/app_theme.dart';
import '../widgets/pressable.dart';
import 'notification_detail_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeService>();
    final fitnessData = context.watch<FitnessService>();
    final notifications = fitnessData.notifications;
    final newCount = notifications.where((n) => n['isNew'] as bool? ?? false).length;

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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Notifikasi',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
            if (newCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$newCount',
                  style: TextStyle(
                    color: ThemeService.isLightColor(AppTheme.accent) ? Colors.black : Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
        centerTitle: true,
      ),
      body: notifications.isEmpty ? _buildEmpty() : _buildList(context, notifications),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: AppTheme.surface, shape: BoxShape.circle),
            child: Icon(Icons.notifications_none_rounded, size: 40, color: AppTheme.textMuted.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 16),
          const Text('Belum ada notifikasi',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text('Aktivitas dan pencapaian akan muncul di sini',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Map<String, dynamic>> notifications) {
    final newItems = notifications.where((n) => n['isNew'] as bool? ?? false).toList();
    final oldItems = notifications.where((n) => !(n['isNew'] as bool? ?? false)).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        if (newItems.isNotEmpty) ...[
          _sectionLabel('BARU'),
          const SizedBox(height: 8),
          ...newItems.map((n) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _NotificationTile(notif: n),
          )),
        ],
        if (oldItems.isNotEmpty) ...[
          if (newItems.isNotEmpty) const SizedBox(height: 8),
          _sectionLabel('SEBELUMNYA'),
          const SizedBox(height: 8),
          ...oldItems.map((n) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _NotificationTile(notif: n),
          )),
        ],
      ],
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
    child: Text(text,
        style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.1)),
  );
}

class _NotificationTile extends StatelessWidget {
  final Map<String, dynamic> notif;
  const _NotificationTile({required this.notif});

  String _resolveType(Map<String, dynamic> n) {
    final explicit = n['type'] as String?;
    if (explicit != null && explicit.isNotEmpty) return explicit;
    switch (n['iconName'] as String?) {
      case 'directions_run':
      case 'fitness_center': return 'workout';
      case 'local_fire_department': return 'streak';
      case 'workspace_premium':
      case 'rocket_launch': return 'badge';
      case 'bedtime': return 'sleep';
      case 'directions_walk':
      case 'bolt': return 'steps';
      default: return 'info';
    }
  }

  Color _colorForType(String type) {
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

  @override
  Widget build(BuildContext context) {
    final icon = notif['icon'] as IconData? ?? Icons.notifications_rounded;
    final title = notif['title'] as String? ?? '';
    final body = notif['body'] as String? ?? '';
    final time = notif['time'] as String? ?? '';
    final isNew = notif['isNew'] as bool? ?? false;
    final color = _colorForType(_resolveType(notif));

    return Pressable(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => NotificationDetailScreen(notification: notif),
            transitionsBuilder: (_, anim, __, child) => SlideTransition(
              position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                  .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: child,
            ),
            transitionDuration: const Duration(milliseconds: 260),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: isNew ? Border.all(color: color.withValues(alpha: 0.3), width: 1) : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(child: Icon(icon, size: 22, color: color)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: isNew ? AppTheme.textPrimary : AppTheme.textSecondary,
                            fontSize: 14,
                            fontWeight: isNew ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isNew)
                        Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(time, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                      const Spacer(),
                      const Text('Lihat detail',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 2),
                      const Icon(Icons.chevron_right_rounded, size: 14, color: AppTheme.textMuted),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
