import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/fitness_service.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import '../widgets/pressable.dart';
import 'social_screen.dart';
import 'diet_screen.dart';
import 'tutorial_screen.dart';
import 'fun_facts_screen.dart';
import 'settings_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeService>();
    final fitness = context.watch<FitnessService>();
    final auth = context.watch<AuthService>();
    final userName = fitness.displayName != 'User'
        ? fitness.displayName
        : (auth.user?.displayName ?? 'User');

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeroCard(context, userName, fitness)),
            SliverToBoxAdapter(child: _buildQuickAccess(context)),
            SliverToBoxAdapter(child: _buildThemePicker()),
            SliverToBoxAdapter(child: _buildAccountSection(context, auth)),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  // ── Hero profile card ──────────────────────────────────────────────────────

  Widget _buildHeroCard(BuildContext context, String name, FitnessService fitness) {
    final photoB64 = fitness.photoBase64;
    final hasPhoto = photoB64.isNotEmpty;

    return Pressable(
      onTap: () => Navigator.push(
        context,
        _slideRoute(const EditProfileScreen()),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.accent.withValues(alpha: 0.18), AppTheme.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppTheme.accent.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.accent, width: 2),
                    color: AppTheme.surfaceLight,
                  ),
                  child: ClipOval(
                    child: hasPhoto
                        ? Image.memory(
                            base64Decode(photoB64),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _defaultAvatar(large: true),
                          )
                        : _defaultAvatar(large: true),
                  ),
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.background, width: 1.5),
                    ),
                    child: Icon(Icons.edit_rounded, size: 11,
                        color: ThemeService.isLightColor(AppTheme.accent) ? Colors.black : Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    'Level ${fitness.level} • ${fitness.streak} hari streak',
                    style: TextStyle(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  // XP bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: fitness.levelProgress),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOutCubic,
                      builder: (_, val, __) => LinearProgressIndicator(
                        value: val,
                        backgroundColor: AppTheme.surfaceLight,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accent),
                        minHeight: 4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${fitness.xp} / ${fitness.xpNextLevel} XP',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: AppTheme.accent.withValues(alpha: 0.7), size: 22),
          ],
        ),
      ),
    );
  }

  Widget _defaultAvatar({bool large = false}) =>
      Center(child: Icon(Icons.person_rounded, size: large ? 36 : 24, color: AppTheme.accent));

  // ── Quick access 2x2 grid ────────────────────────────────────────────────

  Widget _buildQuickAccess(BuildContext context) {
    final items = [
      _QuickItem(icon: Icons.group_rounded, label: 'Komunitas', color: Colors.greenAccent,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SocialScreen()))),
      _QuickItem(icon: Icons.restaurant_menu_rounded, label: 'Diet & Nutrisi', color: Colors.orange,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DietScreen()))),
      _QuickItem(icon: Icons.tips_and_updates_rounded, label: 'Tips & Event', color: Colors.amberAccent,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FunFactsScreen()))),
      _QuickItem(icon: Icons.menu_book_rounded, label: 'Panduan', color: Colors.lightBlue,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TutorialScreen()))),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('FITUR'),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.4,
            children: items.map((item) => _QuickCard(item: item)).toList(),
          ),
        ],
      ),
    );
  }

  // ── Theme picker ─────────────────────────────────────────────────────────

  Widget _buildThemePicker() => const Padding(
    padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
    child: _ThemePicker(),
  );

  // ── Account section ───────────────────────────────────────────────────────

  Widget _buildAccountSection(BuildContext context, AuthService auth) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('AKUN'),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(18)),
            child: Column(
              children: [
                _AccountTile(
                  icon: Icons.settings_rounded,
                  label: 'Pengaturan',
                  subtitle: 'Akun, keamanan & info aplikasi',
                  color: Colors.blueGrey,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                  isFirst: true,
                ),
                _divider(),
                _AccountTile(
                  icon: Icons.logout_rounded,
                  label: 'Keluar',
                  color: Colors.redAccent,
                  isDestructive: true,
                  isLast: true,
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: AppTheme.surface,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: const Text('Keluar?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        content: const Text('Yakin ingin keluar dari akun ini?', style: TextStyle(color: AppTheme.textSecondary)),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Keluar', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      await context.read<AuthService>().signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil('/onboarding', (route) => false);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2));

  Widget _divider() => Divider(height: 1, thickness: 0.5, color: AppTheme.surfaceLight, indent: 64);
}

PageRouteBuilder _slideRoute(Widget page) => PageRouteBuilder(
  pageBuilder: (_, __, ___) => page,
  transitionsBuilder: (_, anim, __, child) {
    final curved = CurvedAnimation(parent: anim, curve: Curves.easeOut);
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(curved),
      child: child,
    );
  },
  transitionDuration: const Duration(milliseconds: 280),
);

// ── Quick access card ────────────────────────────────────────────────────────

class _QuickItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickItem({required this.icon, required this.label, required this.color, required this.onTap});
}

class _QuickCard extends StatelessWidget {
  final _QuickItem item;
  const _QuickCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: item.color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(item.label,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Account tile ──────────────────────────────────────────────────────────────

class _AccountTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isFirst;
  final bool isLast;

  const _AccountTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.subtitle,
    this.isDestructive = false,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(16, isFirst ? 14 : 12, 16, isLast ? 14 : 12),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                        color: isDestructive ? Colors.redAccent : Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      )),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(subtitle!, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Theme picker ──────────────────────────────────────────────────────────────

class _ThemePicker extends StatelessWidget {
  const _ThemePicker();

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeService>();
    const presets = [
      (name: 'Lime', color: Color(0xFFCDDC39)),
      (name: 'Ocean', color: Color(0xFF29B6F6)),
      (name: 'Violet', color: Color(0xFFCE93D8)),
      (name: 'Ember', color: Color(0xFFFF7043)),
      (name: 'Mint', color: Color(0xFF4DB6AC)),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TEMA WARNA', style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(presets.length, (i) {
              final preset = presets[i];
              final isActive = theme.currentIndex == i;
              return GestureDetector(
                onTap: () => theme.setTheme(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isActive ? 40 : 34,
                  height: isActive ? 40 : 34,
                  decoration: BoxDecoration(
                    color: preset.color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive ? Colors.white : Colors.transparent,
                      width: 2.5,
                    ),
                    boxShadow: isActive ? [BoxShadow(color: preset.color.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 1)] : null,
                  ),
                  child: isActive
                      ? Icon(Icons.check_rounded, size: 16, color: ThemeService.isLightColor(preset.color) ? Colors.black : Colors.white)
                      : null,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
