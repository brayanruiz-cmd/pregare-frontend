import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/state/async_state.dart';
import '../../../../core/ui/primitives/primitives.dart';
import '../providers/auth_provider.dart';
import '../../../streaks/presentation/providers/streaks_provider.dart';
import '../../../bible/presentation/providers/bible_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      await context.read<AuthProvider>().login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      if (mounted && context.read<AuthProvider>().isAuthenticated) {
        context.read<StreaksProvider>().loadStreak();
        context.read<StreaksProvider>().loadBadges();
        context.read<BibleProvider>().loadHighlights();
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isLoading = auth.session is AsyncLoading;

    return PScreen(
      background: const PScreenBackground.photo('assets/photo-welcome.jpg', scrim: PScrims.home),
      hasNav: false,
      padding: const EdgeInsets.symmetric(horizontal: PSpace.gutter),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('PREGARE', style: PType.wordmark.copyWith(fontSize: 24)),
                const SizedBox(height: 10),
                Text(
                  'Begin the day with something steady.',
                  style: PType.greeting.copyWith(fontSize: 24, height: 1.2),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Email input
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: PColors.glassFill,
                    borderRadius: BorderRadius.circular(PRadius.tile),
                    border: Border.all(color: PColors.hairline),
                  ),
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: PType.body.copyWith(color: PColors.bone),
                    decoration: InputDecoration(
                      hintText: 'Email address',
                      hintStyle: PType.meta.copyWith(color: PColors.bone45),
                      border: InputBorder.none,
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter your email';
                      if (!v.contains('@')) return 'Invalid email';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Password input
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: PColors.glassFill,
                    borderRadius: BorderRadius.circular(PRadius.tile),
                    border: Border.all(color: PColors.hairline),
                  ),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: PType.body.copyWith(color: PColors.bone),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: PType.meta.copyWith(color: PColors.bone45),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: PColors.bone45,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter your password';
                      if (v.length < 8) return 'Minimum 8 characters';
                      return null;
                    },
                  ),
                ),

                if (auth.error != null) ...[
                  const SizedBox(height: 12),
                  Text(auth.error!, style: PType.meta.copyWith(color: PColors.bone70)),
                ],
                const SizedBox(height: 28),

                // Submit button
                GestureDetector(
                  onTap: isLoading ? null : _submit,
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
                            child: CircularProgressIndicator(strokeWidth: 2, color: PColors.ink),
                          )
                        : Text('Log in', style: PType.uiStrong.copyWith(color: PColors.ink)),
                  ),
                ),
                const SizedBox(height: 20),

                // Link to register
                GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, '/register'),
                  child: Text(
                    'Don\'t have an account? Sign up',
                    style: PType.meta.copyWith(color: PColors.bone70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
