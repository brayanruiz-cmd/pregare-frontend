import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/state/async_state.dart';
import '../../../../core/ui/primitives/primitives.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthProvider>().register(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
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
                  'Create your account',
                  style: PType.greeting.copyWith(fontSize: 24, height: 1.2),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),

                // Name input
                _buildField(
                  controller: _nameController,
                  hintText: 'Name',
                  validator: (v) => v == null || v.isEmpty ? 'Enter your name' : null,
                ),
                const SizedBox(height: 14),

                // Email input
                _buildField(
                  controller: _emailController,
                  hintText: 'Email address',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter your email';
                    if (!v.contains('@')) return 'Invalid email';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Password input
                _buildField(
                  controller: _passwordController,
                  hintText: 'Password',
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: PColors.bone45,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter a password';
                    if (v.length < 8) return 'Minimum 8 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Confirm password input
                _buildField(
                  controller: _confirmController,
                  hintText: 'Confirm password',
                  obscureText: true,
                  validator: (v) {
                    if (v != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
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
                        : Text('Create account', style: PType.uiStrong.copyWith(color: PColors.ink)),
                  ),
                ),
                const SizedBox(height: 20),

                // Link to login
                GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: Text(
                    'Already have an account? Log in',
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

  Widget _buildField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: PColors.glassFill,
        borderRadius: BorderRadius.circular(PRadius.tile),
        border: Border.all(color: PColors.hairline),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: PType.body.copyWith(color: PColors.bone),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: PType.meta.copyWith(color: PColors.bone45),
          border: InputBorder.none,
          suffixIcon: suffixIcon,
        ),
        validator: validator,
      ),
    );
  }
}
