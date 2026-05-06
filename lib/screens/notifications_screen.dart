import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.chevron_left_rounded, size: 28),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: const [
          _NotificationItem(
            icon: Icons.workspace_premium_rounded,
            title: 'Streak Level Up: Week 4!',
            body:
                "Consistent and unstoppable! You've officially hit a 4-week winning streak. Let's keep this energy going!",
            time: 'Apr 17',
            isNew: true,
          ),
          SizedBox(height: 10),
          _NotificationItem(
            icon: Icons.local_fire_department_rounded,
            title: 'Save your 3-week streak!',
            body:
                "You're one session away from keeping your streak alive. Complete your workout before the week ends!",
            time: 'Apr 15',
            isNew: false,
          ),
        ],
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String time;
  final bool isNew;

  const _NotificationItem({
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    required this.isNew,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: isNew
            ? Border.all(color: AppTheme.accent.withValues(alpha: 0.3), width: 1)
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              shape: BoxShape.circle,
            ),
            child: Center(child: Icon(icon, size: 22, color: AppTheme.accent)),
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
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (isNew)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 6),
                Text(time, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
