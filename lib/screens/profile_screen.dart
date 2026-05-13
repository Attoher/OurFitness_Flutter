import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/fitness_service.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fitnessData = context.watch<FitnessService>();
    final authService = context.watch<AuthService>();
    final user = authService.user;
    final userName = fitnessData.displayName != 'User'
        ? fitnessData.displayName
        : (user?.displayName ?? 'User');
    final weekSummary = fitnessData.snapshotBetween(
      DateTime.now().subtract(const Duration(days: 6)),
      DateTime.now(),
    );

    if (fitnessData.isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            if (fitnessData.errorMessage != null)
              SliverToBoxAdapter(child: _buildErrorBanner(fitnessData.errorMessage!)),
            SliverToBoxAdapter(child: _buildProfileCard(context, userName, fitnessData)),
            SliverToBoxAdapter(child: _buildConnectedDevice(context, fitnessData)),
            SliverToBoxAdapter(child: _buildWeeklyGoals(context, fitnessData, weekSummary)),
            SliverToBoxAdapter(child: _buildDailySummary(context, fitnessData)),
            SliverToBoxAdapter(child: _buildOptions(context, fitnessData, authService)),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Profile', style: Theme.of(context).textTheme.displaySmall),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(message, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, String name, FitnessService fitness) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.accent, width: 2),
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accent.withValues(alpha: 0.3),
                    AppTheme.accentDark.withValues(alpha: 0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(Icons.person_rounded, size: 32, color: AppTheme.accent),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(
                    'Age: ${fitness.age} | Height: ${fitness.height.toInt()}cm | Weight: ${fitness.weight.toInt()}kg',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Timezone: ${fitness.timezone} • Level ${fitness.level}',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedDevice(BuildContext context, FitnessService fitness) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CONNECTED DEVICE',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    fitness.isDeviceConnected ? Icons.watch_rounded : Icons.watch_off_rounded,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fitness.isDeviceConnected ? fitness.deviceName : 'Disconnected',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        fitness.isDeviceConnected
                            ? 'Battery ${fitness.batteryLevel}%'
                            : 'Connect a wearable for real-time data',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: fitness.isDeviceConnected
                        ? AppTheme.accent.withValues(alpha: 0.15)
                        : AppTheme.textMuted.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    fitness.isDeviceConnected ? 'Connected' : 'Disconnected',
                    style: TextStyle(
                      color: fitness.isDeviceConnected ? AppTheme.accent : AppTheme.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyGoals(
    BuildContext context,
    FitnessService data,
    ProgressSnapshot weekSummary,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'WEEKLY PROGRESS',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _GoalItem(
                  icon: Icons.directions_walk_rounded,
                  value: '${weekSummary.totalSteps}',
                  label: 'Steps',
                ),
                _GoalItem(
                  icon: Icons.local_fire_department_rounded,
                  value: '${weekSummary.totalCalories} kcal',
                  label: 'Calories',
                ),
                _GoalItem(
                  icon: Icons.timer_rounded,
                  value: '${weekSummary.totalMoveMinutes} min',
                  label: 'Active',
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.track_changes_rounded, color: AppTheme.accent, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tracking status: ${weekSummary.trackingStatus}',
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                  Text(
                    '${(weekSummary.goalCompletionRate * 100).round()}%',
                    style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailySummary(BuildContext context, FitnessService data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'DAILY SUMMARY',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                Icon(Icons.sunny, color: AppTheme.accent, size: 18),
              ],
            ),
            const SizedBox(height: 14),
            _DailySummaryRow(
              icon: Icons.directions_walk_rounded,
              color: AppTheme.ringSteps,
              rawValue: data.steps,
              unit: 'steps',
              progress: data.stepsProgress,
            ),
            const SizedBox(height: 10),
            _DailySummaryRow(
              icon: Icons.local_fire_department_rounded,
              color: AppTheme.ringCalories,
              rawValue: data.calories,
              unit: 'kcal',
              progress: data.caloriesProgress,
            ),
            const SizedBox(height: 10),
            _DailySummaryRow(
              icon: Icons.timer_rounded,
              color: AppTheme.ringMove,
              rawValue: data.moveMinutes,
              unit: 'min active',
              progress: data.moveMinutesProgress,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptions(BuildContext context, FitnessService fitnessData, AuthService authService) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Column(
        children: [
          _OptionTile(
            icon: Icons.person_outline_rounded,
            label: 'Edit Personal Details',
            onTap: () => _showEditProfileDialog(context, fitnessData),
          ),
          const SizedBox(height: 10),
          _OptionTile(
            icon: Icons.notifications_active_outlined,
            label: 'Daily Reminder Settings',
            onTap: () => _showReminderSettingsDialog(context, fitnessData),
          ),
          const SizedBox(height: 10),
          _OptionTile(
            icon: Icons.lock_outline_rounded,
            label: 'Change Password',
            onTap: () => _showChangePasswordDialog(context, authService),
          ),
          const SizedBox(height: 10),
          _OptionTile(
            icon: Icons.logout_rounded,
            label: 'Sign Out',
            onTap: () async {
              final auth = context.read<AuthService>();
              await auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showEditProfileDialog(BuildContext context, FitnessService fitness) async {
    final nameController = TextEditingController(text: fitness.displayName);
    final ageController = TextEditingController(text: fitness.age.toString());
    final heightController = TextEditingController(text: fitness.height.toInt().toString());
    final weightController = TextEditingController(text: fitness.weight.toInt().toString());

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameController, 'Display Name'),
              const SizedBox(height: 12),
              _buildTextField(ageController, 'Age', isNumber: true),
              const SizedBox(height: 12),
              _buildTextField(heightController, 'Height (cm)', isNumber: true),
              const SizedBox(height: 12),
              _buildTextField(weightController, 'Weight (kg)', isNumber: true),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final error = await fitness.updateProfile(
                name: nameController.text,
                age: int.tryParse(ageController.text),
                height: double.tryParse(heightController.text),
                weight: double.tryParse(weightController.text),
              );
              if (!dialogContext.mounted) {
                return;
              }
              if (error != null) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text(error)));
                return;
              }
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showReminderSettingsDialog(BuildContext context, FitnessService fitness) async {
    var settings = fitness.reminderSettings;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setState) => Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              24,
              20,
              MediaQuery.of(sheetContext).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily reminder',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  value: settings.enabled,
                  activeColor: AppTheme.accent,
                  onChanged: (value) => setState(() => settings = settings.copyWith(enabled: value)),
                  title: const Text('Enable reminder', style: TextStyle(color: Colors.white)),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Reminder time', style: TextStyle(color: Colors.white)),
                  subtitle: Text(settings.formattedTime, style: const TextStyle(color: AppTheme.textSecondary)),
                  trailing: const Icon(Icons.schedule_rounded, color: AppTheme.accent),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: sheetContext,
                      initialTime: TimeOfDay(hour: settings.hour, minute: settings.minute),
                    );
                    if (picked != null) {
                      setState(() {
                        settings = settings.copyWith(hour: picked.hour, minute: picked.minute);
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),
                const Text('Reminder type', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    _ChoiceChip(
                      label: 'Workout',
                      selected: settings.type == 'workout',
                      onTap: () => setState(() => settings = settings.copyWith(type: 'workout')),
                    ),
                    _ChoiceChip(
                      label: 'Recovery',
                      selected: settings.type == 'recovery',
                      onTap: () => setState(() => settings = settings.copyWith(type: 'recovery')),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Active days', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(7, (index) {
                    final weekday = index + 1;
                    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                    final isSelected = settings.days.contains(weekday);
                    return _ChoiceChip(
                      label: labels[index],
                      selected: isSelected,
                      onTap: () {
                        final days = {...settings.days};
                        if (isSelected) {
                          days.remove(weekday);
                        } else {
                          days.add(weekday);
                        }
                        setState(() => settings = settings.copyWith(days: days));
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  value: settings.notifyAchievements,
                  activeColor: AppTheme.accent,
                  onChanged: (value) => setState(() => settings = settings.copyWith(notifyAchievements: value)),
                  title: const Text('Achievement notifications', style: TextStyle(color: Colors.white)),
                ),
                SwitchListTile(
                  value: settings.notifyWorkouts,
                  activeColor: AppTheme.accent,
                  onChanged: (value) => setState(() => settings = settings.copyWith(notifyWorkouts: value)),
                  title: const Text('Workout notifications', style: TextStyle(color: Colors.white)),
                ),
                SwitchListTile(
                  value: settings.notifyReminders,
                  activeColor: AppTheme.accent,
                  onChanged: (value) => setState(() => settings = settings.copyWith(notifyReminders: value)),
                  title: const Text('Reminder notifications', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final error = await fitness.updateReminderSettings(settings);
                      if (!sheetContext.mounted) {
                        return;
                      }
                      if (error != null) {
                        ScaffoldMessenger.of(sheetContext).showSnackBar(SnackBar(content: Text(error)));
                        return;
                      }
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reminder settings updated')),
                      );
                    },
                    child: const Text('Save reminder settings'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showChangePasswordDialog(BuildContext context, AuthService auth) async {
    final passwordController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Change Password', style: TextStyle(color: Colors.white)),
        content: _buildTextField(passwordController, 'New Password', isPassword: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final error = await auth.changePassword(passwordController.text);
              if (!dialogContext.mounted) {
                return;
              }
              if (error != null) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text(error)));
                return;
              }
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password updated successfully')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textSecondary),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppTheme.surfaceLight),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppTheme.accent),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _DailySummaryRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int rawValue;
  final String unit;
  final double progress;

  const _DailySummaryRow({
    required this.icon,
    required this.color,
    required this.rawValue,
    required this.unit,
    required this.progress,
  });

  String _fmt(int val) => val >= 1000 ? '${(val / 1000).toStringAsFixed(1)}k' : '$val';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              _fmt(rawValue),
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 5),
            Text(unit, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const Spacer(),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                color: progress >= 1.0 ? color : AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}

class _GoalItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _GoalItem({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 22, color: AppTheme.accent),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _OptionTile({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.textSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: Theme.of(context).textTheme.titleMedium)),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accent.withValues(alpha: 0.15) : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppTheme.accent.withValues(alpha: 0.3) : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppTheme.accent : AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
