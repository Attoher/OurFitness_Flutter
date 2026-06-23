import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/fitness_service.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _heightCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _caloriesCtrl;
  late final TextEditingController _stepsCtrl;
  late final TextEditingController _moveCtrl;

  bool _isSaving = false;
  bool _photoChanged = false;
  String? _pendingBase64;

  @override
  void initState() {
    super.initState();
    final f = context.read<FitnessService>();
    _nameCtrl = TextEditingController(text: f.displayName);
    _ageCtrl = TextEditingController(text: f.age.toString());
    _heightCtrl = TextEditingController(text: f.height.toInt().toString());
    _weightCtrl = TextEditingController(text: f.weight.toInt().toString());
    _caloriesCtrl = TextEditingController(text: f.caloriesGoal.toString());
    _stepsCtrl = TextEditingController(text: f.stepsGoal.toString());
    _moveCtrl = TextEditingController(text: f.moveMinutesGoal.toString());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _caloriesCtrl.dispose();
    _stepsCtrl.dispose();
    _moveCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final source = await _showPhotoSourceSheet();
    if (source == null) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 300,
      maxHeight: 300,
      imageQuality: 75,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _pendingBase64 = base64Encode(bytes);
      _photoChanged = true;
    });
  }

  Future<ImageSource?> _showPhotoSourceSheet() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.textMuted.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppTheme.surfaceLight, shape: BoxShape.circle),
                child: Icon(Icons.photo_library_rounded, color: AppTheme.accent, size: 20),
              ),
              title: const Text('Pilih dari Galeri', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppTheme.surfaceLight, shape: BoxShape.circle),
                child: Icon(Icons.camera_alt_rounded, color: AppTheme.accent, size: 20),
              ),
              title: const Text('Ambil Foto', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    final fitness = context.read<FitnessService>();
    try {
      await fitness.updateProfile(
        name: _nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : null,
        age: int.tryParse(_ageCtrl.text),
        height: double.tryParse(_heightCtrl.text),
        weight: double.tryParse(_weightCtrl.text),
      );
      await fitness.updateGoals(
        caloriesGoal: int.tryParse(_caloriesCtrl.text),
        stepsGoal: int.tryParse(_stepsCtrl.text),
        moveMinutesGoal: int.tryParse(_moveCtrl.text),
      );
      if (_photoChanged && _pendingBase64 != null) {
        await fitness.updatePhoto(_pendingBase64!);
      }
      if (mounted) {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profil berhasil disimpan!'),
            backgroundColor: AppTheme.accent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    bool hideOld = true, hideNew = true, loading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Ubah Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PasswordField(ctrl: oldCtrl, label: 'Password Lama', hidden: hideOld, onToggle: () => setDlg(() => hideOld = !hideOld)),
              const SizedBox(height: 12),
              _PasswordField(ctrl: newCtrl, label: 'Password Baru', hidden: hideNew, onToggle: () => setDlg(() => hideNew = !hideNew)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary))),
            ElevatedButton(
              onPressed: loading ? null : () async {
                if (oldCtrl.text.isEmpty || newCtrl.text.isEmpty) return;
                setDlg(() => loading = true);
                final auth = context.read<AuthService>();
                final err = await auth.changePasswordWithAuth(oldCtrl.text, newCtrl.text);
                if (ctx.mounted) {
                  setDlg(() => loading = false);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(err ?? 'Password berhasil diubah!'),
                    backgroundColor: err != null ? Colors.redAccent : Colors.green,
                  ));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: ThemeService.isLightColor(AppTheme.accent) ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fitness = context.watch<FitnessService>();
    final displayBase64 = _pendingBase64 ?? (fitness.photoBase64.isNotEmpty ? fitness.photoBase64 : null);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Simpan', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // ── Photo section ─────────────────────────────────────────────
            Center(
              child: GestureDetector(
                onTap: _pickPhoto,
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.accent, width: 2.5),
                        color: AppTheme.surface,
                      ),
                      child: ClipOval(
                        child: displayBase64 != null
                            ? Image.memory(
                                base64Decode(displayBase64),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _defaultAvatar(),
                              )
                            : _defaultAvatar(),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppTheme.accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.background, width: 2),
                        ),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          size: 15,
                          color: ThemeService.isLightColor(AppTheme.accent) ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text('Tap untuk ganti foto', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            ),

            const SizedBox(height: 28),

            // ── Informasi Pribadi ─────────────────────────────────────────
            _sectionLabel('INFORMASI PRIBADI'),
            const SizedBox(height: 12),
            _Field(ctrl: _nameCtrl, label: 'Nama Lengkap', icon: Icons.person_rounded),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _Field(ctrl: _ageCtrl, label: 'Umur', icon: Icons.cake_rounded, isNumber: true, suffix: 'thn')),
                const SizedBox(width: 12),
                Expanded(child: _Field(ctrl: _heightCtrl, label: 'Tinggi', icon: Icons.height_rounded, isNumber: true, suffix: 'cm')),
                const SizedBox(width: 12),
                Expanded(child: _Field(ctrl: _weightCtrl, label: 'Berat', icon: Icons.monitor_weight_rounded, isNumber: true, suffix: 'kg')),
              ],
            ),

            const SizedBox(height: 28),

            // ── Target Harian ─────────────────────────────────────────────
            _sectionLabel('TARGET HARIAN'),
            const SizedBox(height: 12),
            _Field(ctrl: _caloriesCtrl, label: 'Target Kalori', icon: Icons.local_fire_department_rounded, isNumber: true, suffix: 'kcal'),
            const SizedBox(height: 12),
            _Field(ctrl: _stepsCtrl, label: 'Target Langkah', icon: Icons.directions_walk_rounded, isNumber: true, suffix: 'steps'),
            const SizedBox(height: 12),
            _Field(ctrl: _moveCtrl, label: 'Target Aktif', icon: Icons.timer_rounded, isNumber: true, suffix: 'menit'),

            const SizedBox(height: 28),

            // ── Keamanan ──────────────────────────────────────────────────
            _sectionLabel('KEAMANAN'),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _showChangePasswordDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.lock_rounded, color: Colors.orange, size: 18),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ubah Password', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                          SizedBox(height: 2),
                          Text('Perbarui password akun kamu', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Save FAB ──────────────────────────────────────────────────────
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          child: FloatingActionButton.extended(
            onPressed: _isSaving ? null : _save,
            backgroundColor: AppTheme.accent,
            foregroundColor: ThemeService.isLightColor(AppTheme.accent) ? Colors.black : Colors.white,
            elevation: 4,
            icon: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.check_rounded),
            label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Perubahan', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _defaultAvatar() => Center(child: Icon(Icons.person_rounded, size: 44, color: AppTheme.accent));

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2),
  );
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final bool isNumber;
  final String? suffix;

  const _Field({required this.ctrl, required this.label, required this.icon, this.isNumber = false, this.suffix});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, color: AppTheme.accent, size: 18),
        suffixText: suffix,
        suffixStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        filled: true,
        fillColor: AppTheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppTheme.surfaceLight),
          borderRadius: BorderRadius.circular(14),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppTheme.accent, width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final bool hidden;
  final VoidCallback onToggle;

  const _PasswordField({required this.ctrl, required this.label, required this.hidden, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      obscureText: hidden,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textSecondary),
        filled: true,
        fillColor: AppTheme.surfaceLight,
        suffixIcon: IconButton(
          icon: Icon(hidden ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: AppTheme.textSecondary, size: 18),
          onPressed: onToggle,
        ),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.surfaceLight), borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.accent), borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
