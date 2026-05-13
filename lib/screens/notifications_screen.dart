import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/fitness_service.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fitnessData = context.watch<FitnessService>();
    final notifications = fitnessData.notifications;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.chevron_left_rounded, size: 28),
        ),
      ),
      body: fitnessData.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
          : notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        size: 64,
                        color: AppTheme.textMuted.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No notifications yet',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = notifications[index];
                    final notificationId = item['id'] as String?;
                    return _NotificationItem(
                      icon: item['icon'] as IconData,
                      title: item['title'] as String,
                      body: item['body'] as String,
                      time: item['time'] as String,
                      isNew: item['isNew'] as bool,
                      onTap: notificationId == null
                          ? () {}
                          : () => fitnessData.markNotificationRead(notificationId),
                    );
                  },
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
  final VoidCallback onTap;

  const _NotificationItem({
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    required this.isNew,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              decoration: const BoxDecoration(
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 6),
                  Text(time, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
