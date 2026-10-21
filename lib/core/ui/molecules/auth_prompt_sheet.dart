import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../features/onboarding/presentation/providers/onboarding_provider.dart';
import '../../../features/streaks/presentation/providers/streaks_provider.dart';
import '../../../features/bible/presentation/providers/bible_provider.dart';
import '../../theme/tokens.dart';
import '../../state/async_state.dart';
import '../primitives/p_interactive.dart';

class AuthPromptSheet extends StatefulWidget {
  final bool isLoginOnly;
  final VoidCallback? onSuccess;

  const AuthPromptSheet({
    super.key,
    this.isLoginOnly = false,
    this.onSuccess,
  });

  static Future<void> show(
    BuildContext context, {
    bool isLoginOnly = false,
    VoidCallback? onSuccess,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AuthPromptSheet(
        isLoginOnly: isLoginOnly,
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  State<AuthPromptSheet> createState() => _AuthPromptSheetState();
}

class _AuthPromptSheetState extends State<AuthPromptSheet> {
  late bool _isLogin;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _localError;

  @override
  void initState() {
    super.initState();
    _isLogin = widget.isLoginOnly;
    final onboarding = context.read<OnboardingProvider>();
    _nameController.text = onboarding.name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    HapticFeedback.lightImpact();
    final auth = context.read<AuthProvider>();
    final onboarding = context.read<OnboardingProvider>();

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _localError = 'Please fill in all fields.');
      return;
    }

    if (!_isLogin && _nameController.text.trim().isEmpty) {
      setState(() => _localError = 'Please enter your name.');
      return;
    }

    setState(() => _localError = null);

    if (_isLogin) {
      await auth.login(email: email, password: password);
    } else {
      final name = _nameController.text.trim();
      onboarding.setName(name);

      await auth.register(
        name: name,
        email: email,
        password: password,
        gender: onboarding.gender,
        selectedTopics: onboarding.selectedTopics,
        notificationTime: onboarding.reminderTime == '6:15 AM' ? '06:15:00' : '07:00:00',
      );
    }

    if (!mounted) return;

    if (auth.isAuthenticated) {
      HapticFeedback.mediumImpact();
      if (context.mounted) {
        context.read<StreaksProvider>().loadStreak();
        context.read<StreaksProvider>().loadBadges();
        context.read<BibleProvider>().loadHighlights();
      }
      Navigator.of(context).pop();
      widget.onSuccess?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isLogin ? 'Welcome back!' : 'Account created successfully!'),
          backgroundColor: PColors.ink,
        ),
      );
    } else if (auth.error != null) {
      setState(() => _localError = auth.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isLoading = auth.session is AsyncLoading;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(28, 16, 28, 36),
        decoration: BoxDecoration(
          color: PColors.ink,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: PColors.hairline, width: 0.8),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: PColors.bone.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isLogin ? 'Sign In' : 'Save Your Journey',
                    style: PType.cardTitle.copyWith(
                      color: PColors.bone,
                      fontSize: 24,
                    ),
                  ),
                  PInteractive(
                    onTap: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: PColors.glassFill,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: PColors.bone70,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _isLogin
                    ? 'Sign in to sync your declarations, devotionals and streaks.'
                    : 'Create an account to backup your declarations, devotionals, and streaks across all your devices.',
                style: PType.body.copyWith(
                  color: PColors.bone70,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),

              if (_localError != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0x33B00020),
                    borderRadius: BorderRadius.circular(PRadius.chip),
                    border: Border.all(color: const Color(0x66B00020)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Color(0xFFFF8A80), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _localError!,
                          style: PType.meta.copyWith(color: const Color(0xFFFF8A80)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Name field (Registration only)
              if (!_isLogin) ...[
                _buildTextField(
                  controller: _nameController,
                  label: 'Name',
                  hint: 'Your name',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 14),
              ],

              // Email field
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'example@email.com',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),

              // Password field
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Minimum 8 characters',
                icon: Icons.lock_outline_rounded,
                obscureText: true,
              ),
              const SizedBox(height: 24),

              // Submit Button
              PInteractive(
                onTap: isLoading ? null : _submit,
                pressedScale: 0.985,
                child: Container(
                  width: double.infinity,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: PColors.bone,
                    borderRadius: BorderRadius.circular(PRadius.pill),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: PColors.ink,
                          ),
                        )
                      : Text(
                          _isLogin ? 'Sign In' : 'Create Account & Sync',
                          style: PType.uiStrong.copyWith(
                            color: PColors.ink,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Toggle between Login & Register
              Center(
                child: PInteractive(
                  onTap: () {
                    setState(() {
                      _isLogin = !_isLogin;
                      _localError = null;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text(
                      _isLogin
                          ? "Don't have an account? Sign up"
                          : 'Already have an account? Sign in',
                      style: PType.uiStrong.copyWith(
                        color: PColors.bone70,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: PColors.glassFill,
        borderRadius: BorderRadius.circular(PRadius.chip),
        border: Border.all(color: PColors.hairline),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: PType.body.copyWith(color: PColors.bone),
        cursorColor: PColors.bone,
        decoration: InputDecoration(
          icon: Icon(icon, color: PColors.bone45, size: 20),
          labelText: label,
          labelStyle: PType.meta.copyWith(color: PColors.bone45),
          hintText: hint,
          hintStyle: PType.body.copyWith(color: PColors.bone45, fontSize: 13),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }
}
