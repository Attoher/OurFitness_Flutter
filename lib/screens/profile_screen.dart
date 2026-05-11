import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/fitness_service.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fitnessData = context.watch<FitnessService>();
    final authService = context.watch<AuthService>();
    final user = authService.user;
    final userName = user?.displayName ?? fitnessData.displayName;
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(child: _buildProfileCard(context, userName, fitnessData)),
            SliverToBoxAdapter(child: _buildConnectedDevice(context, fitnessData)),
            SliverToBoxAdapter(child: _buildWeeklyGoals(context, fitnessData)),
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.settings_outlined, color: AppTheme.textSecondary, size: 20),
          ),
        ],
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
            // Avatar
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.accent, width: 2),
                gradient: LinearGradient(
                  colors: [AppTheme.accent.withValues(alpha: 0.3), AppTheme.accentDark.withValues(alpha: 0.5)],
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
                  Text(
                    name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Age: ${fitness.age} | Height: ${fitness.height.toInt()}cm | Weight: ${fitness.weight.toInt()}kg',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
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
                      if (fitness.isDeviceConnected)
                        Row(
                          children: [
                            const Icon(Icons.battery_4_bar_rounded, color: AppTheme.accent, size: 14),
                            const SizedBox(width: 4),
                            Text('${fitness.batteryLevel}%', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.accent, fontSize: 11,
                            )),
                          ],
                        )
                      else
                        Text('Tap to connect', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11)),
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

  Widget _buildWeeklyGoals(BuildContext context, FitnessService data) {
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
              'WEEKLY GOALS',
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
                const _GoalItem(icon: Icons.location_on_rounded, value: '5.5 km', label: 'Distance'),
                _GoalItem(icon: Icons.local_fire_department_rounded, value: '${data.caloriesGoal * 7} kcal', label: 'Calories'),
                const _GoalItem(icon: Icons.timer_rounded, value: '4h 46m', label: 'Duration'),
              ],
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
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.directions_walk_rounded, color: AppTheme.accent, size: 20),
                const SizedBox(width: 8),
                Text(data.steps.toString(), style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(width: 4),
                const Text('steps', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: data.stepsProgress,
                backgroundColor: AppTheme.surfaceLight,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                minHeight: 6,
              ),
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
            icon: Icons.lock_outline_rounded,
            label: 'Change Password & Privacy',
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
  void _showEditProfileDialog(BuildContext context, FitnessService fitness) {
    final nameController = TextEditingController(text: fitness.displayName);
    final ageController = TextEditingController(text: fitness.age.toString());
    final heightController = TextEditingController(text: fitness.height.toInt().toString());
    final weightController = TextEditingController(text: fitness.weight.toInt().toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await fitness.updateProfile(
                name: nameController.text,
                age: int.tryParse(ageController.text),
                height: double.tryParse(heightController.text),
                weight: double.tryParse(weightController.text),
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, AuthService auth) {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Change Password', style: TextStyle(color: Colors.white)),
        content: _buildTextField(passwordController, 'New Password', isPassword: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final error = await auth.changePassword(passwordController.text);
              if (context.mounted) {
                if (error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated!')));
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false, bool isPassword = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textSecondary),
        enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppTheme.surfaceLight), borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppTheme.accent), borderRadius: BorderRadius.circular(12)),
      ),
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
        Text(value, style: Theme.of(context).textTheme.titleMedium),
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
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.titleMedium),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
