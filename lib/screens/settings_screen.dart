import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/fitness_service.dart';
import '../services/theme_service.dart';
import 'notifications_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeService>();
    final auth = context.watch<AuthService>();
    final fitness = context.watch<FitnessService>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pengaturan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          const SizedBox(height: 8),
          _sectionLabel('AKUN'),
          const SizedBox(height: 10),
          _infoTile(
            icon: Icons.person_rounded,
            label: 'Nama',
            value: fitness.displayName,
          ),
          const SizedBox(height: 8),
          _infoTile(
            icon: Icons.email_rounded,
            label: 'Email',
            value: auth.user?.email ?? '-',
          ),
          const SizedBox(height: 8),
          _actionTile(
            icon: Icons.lock_reset_rounded,
            label: 'Ubah Password',
            onTap: () => _showChangePasswordDialog(context, auth),
          ),
          const SizedBox(height: 20),
          _sectionLabel('NOTIFIKASI'),
          const SizedBox(height: 10),
          _actionTile(
            icon: Icons.notifications_rounded,
            label: 'Riwayat Notifikasi',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
          const SizedBox(height: 20),
          _sectionLabel('TENTANG'),
          const SizedBox(height: 10),
          _infoTile(icon: Icons.info_outline_rounded, label: 'Versi Aplikasi', value: '1.0.0'),
          _infoTile(icon: Icons.build_rounded, label: 'Build', value: 'Production'),
          const SizedBox(height: 20),
          _sectionLabel('KELUAR'),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: AppTheme.surface,
                  title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                  content: const Text(
                    'Yakin ingin keluar dari akun ini?',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Keluar'),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                await context.read<AuthService>().signOut();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/onboarding', (r) => false);
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Keluar dari Akun',
                    style: TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(
        label,
        style: const TextStyle(
          color: AppTheme.textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      );

  Widget _infoTile({required IconData icon, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.accent, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14))),
          Text(value, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _actionTile({required IconData icon, required String label, required VoidCallback onTap}) {
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
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.accent, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14))),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, AuthService auth) {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    bool oldHidden = true;
    bool newHidden = true;
    bool loading = false;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, setSt) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          title: const Text('Ubah Password', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _pwField(oldCtrl, 'Password Lama', oldHidden, () => setSt(() => oldHidden = !oldHidden)),
              const SizedBox(height: 12),
              _pwField(newCtrl, 'Password Baru', newHidden, () => setSt(() => newHidden = !newHidden)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      if (oldCtrl.text.isEmpty || newCtrl.text.isEmpty) return;
                      setSt(() => loading = true);
                      final err = await auth.changePasswordWithAuth(oldCtrl.text, newCtrl.text);
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(err ?? 'Password berhasil diubah'),
                        backgroundColor: err != null ? Colors.redAccent : Colors.green,
                      ));
                    },
              child: loading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Simpan'),
            ),
          ],
        );
      }),
    );
  }

  Widget _pwField(TextEditingController ctrl, String label, bool hidden, VoidCallback toggle) {
    return TextField(
      controller: ctrl,
      obscureText: hidden,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textSecondary),
        suffixIcon: IconButton(
          icon: Icon(hidden ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: AppTheme.textSecondary, size: 18),
          onPressed: toggle,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppTheme.surfaceLight),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppTheme.accent),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
