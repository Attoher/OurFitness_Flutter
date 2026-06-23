import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/fitness_service.dart';
import '../utils/password_validator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _isPasswordHidden = true;
  String _passwordInput = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _showForgotPasswordDialog() {
    final emailCtrl = TextEditingController(text: _emailController.text.trim());
    showDialog(
      context: context,
      builder: (ctx) {
        bool sending = false;
        return StatefulBuilder(builder: (ctx, setSt) {
          return AlertDialog(
            backgroundColor: AppTheme.surface,
            title: const Text('Reset Password', style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Masukkan email Anda. Kami akan mengirim link reset password.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: AppTheme.textSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.surfaceLight),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.accent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: sending
                    ? null
                    : () async {
                        if (emailCtrl.text.trim().isEmpty) return;
                        setSt(() => sending = true);
                        final auth = context.read<AuthService>();
                        final email = emailCtrl.text.trim();
                        final err = await auth.resetPassword(email);
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        if (!ctx.mounted) return;
                        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                          content: Text(err ?? 'Link reset dikirim ke $email'),
                          backgroundColor: err != null ? Colors.redAccent : Colors.green,
                        ));
                      },
                child: sending
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Kirim'),
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _submit() async {
    final auth = context.read<AuthService>();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty || (!_isLogin && name.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    String? error;
    if (_isLogin) {
      error = await auth.signIn(email, password);
    } else {
      // Store name before sign-up so _createInitialProfile picks it up correctly
      context.read<FitnessService>().setPendingRegistrationName(name);
      error = await auth.signUp(email, password, name);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Background Gradient Decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accent.withValues(alpha: 0.1),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  // App Logo/Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accent.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(Icons.fitness_center_rounded, color: AppTheme.background, size: 30),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    _isLogin ? 'Welcome\nBack' : 'Create\nAccount',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isLogin 
                        ? 'Sign in to continue your fitness journey' 
                        : 'Join OurFitness and reach your goals',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 50),
                  // Form Fields
                  if (!_isLogin) ...[
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 20),
                  ],
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Password',
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                    onChanged: (v) => setState(() => _passwordInput = v),
                  ),
                  if (!_isLogin && _passwordInput.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: _PasswordStrengthBar(password: _passwordInput),
                    ),
                  if (_isLogin)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showForgotPasswordDialog,
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(color: AppTheme.accent.withValues(alpha: 0.8), fontSize: 13),
                        ),
                      ),
                    ),
                  const SizedBox(height: 30),
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: AppTheme.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.background),
                            )
                          : Text(
                              _isLogin ? 'Sign In' : 'Get Started',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Toggle Login/Sign-up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLogin ? "Don't have an account? " : "Already have an account? ",
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _isLogin = !_isLogin),
                        child: Text(
                          _isLogin ? 'Sign Up' : 'Sign In',
                          style: TextStyle(
                            color: AppTheme.accent,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _isPasswordHidden : false,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          prefixIcon: Icon(icon, color: AppTheme.accent.withValues(alpha: 0.7), size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordHidden ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _isPasswordHidden = !_isPasswordHidden),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}

class _PasswordStrengthBar extends StatelessWidget {
  final String password;
  const _PasswordStrengthBar({required this.password});

  @override
  Widget build(BuildContext context) {
    final checks = PasswordValidator.validateAll(password);
    final passed = checks.values.where((v) => v).length;
    final fraction = passed / checks.length;

    Color barColor;
    String label;
    if (passed <= 1) {
      barColor = Colors.redAccent;
      label = 'Sangat Lemah';
    } else if (passed == 2) {
      barColor = Colors.orange;
      label = 'Lemah';
    } else if (passed == 3) {
      barColor = Colors.yellow.shade700;
      label = 'Cukup';
    } else if (passed == 4) {
      barColor = Colors.lightGreen;
      label = 'Kuat';
    } else {
      barColor = Colors.green;
      label = 'Sangat Kuat';
    }

    final criteria = [
      ('Min. 8 karakter', checks['minLength']!),
      ('Huruf besar', checks['uppercase']!),
      ('Huruf kecil', checks['lowercase']!),
      ('Angka', checks['digit']!),
      ('Karakter spesial', checks['special']!),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: fraction,
                  backgroundColor: AppTheme.surfaceLight,
                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(color: barColor, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: criteria.map((c) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                c.$2 ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                size: 12,
                color: c.$2 ? Colors.green : AppTheme.textMuted,
              ),
              const SizedBox(width: 3),
              Text(c.$1, style: TextStyle(
                fontSize: 10,
                color: c.$2 ? Colors.white70 : AppTheme.textMuted,
              )),
            ],
          )).toList(),
        ),
      ],
    );
  }
}
