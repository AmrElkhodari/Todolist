import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_dimens.dart';
import '../../shared/widgets/auth_widgets.dart';
import 'email_verification_screen.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.signUp(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
    );
    if (ok && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const EmailVerificationScreen()),
      );
    }
  }

  Future<void> _googleSignUp() async {
    final auth = context.read<AuthProvider>();
    await auth.signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.lg,
            vertical: AppDimens.xl,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppDimens.xl),

                // ── Header ───────────────────────────────────────────────
                _AppLogo(),
                const SizedBox(height: AppDimens.lg),
                Text('Create Account',
                    style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: AppDimens.xs),
                Text('Sign up to get started',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: AppDimens.xl),

                // ── Error Banner ─────────────────────────────────────────
                if (auth.errorMessage != null) ...[
                  ErrorBanner(message: auth.errorMessage!),
                  const SizedBox(height: AppDimens.md),
                ],

                // ── Fields ───────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        hint: 'First Name',
                        controller: _firstNameCtrl,
                        prefixIcon: Icons.person_outlined,
                        textInputAction: TextInputAction.next,
                        validator: (v) =>
                            v!.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: AppDimens.md),
                    Expanded(
                      child: AppTextField(
                        hint: 'Last Name',
                        controller: _lastNameCtrl,
                        textInputAction: TextInputAction.next,
                        validator: (v) =>
                            v!.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.md),
                AppTextField(
                  hint: 'Email address',
                  controller: _emailCtrl,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v!.trim().isEmpty) return 'Required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: AppDimens.md),
                AppTextField(
                  hint: 'Password',
                  controller: _passwordCtrl,
                  prefixIcon: Icons.lock_outlined,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) =>
                      v!.length < 6 ? 'At least 6 characters' : null,
                ),
                const SizedBox(height: AppDimens.lg),

                // ── Submit ───────────────────────────────────────────────
                AppPrimaryButton(
                  label: 'Create Account',
                  onPressed: _submit,
                  isLoading: auth.isLoading,
                ),
                const SizedBox(height: AppDimens.md),
                const OrDivider(),
                const SizedBox(height: AppDimens.md),
                GoogleSignInButton(
                  label: 'Sign up with Google',
                  onPressed: _googleSignUp,
                  isLoading: auth.isLoading,
                ),
                const SizedBox(height: AppDimens.xl),

                // ── Footer ───────────────────────────────────────────────
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        children: const [
                          TextSpan(text: 'Already have an account? '),
                          TextSpan(
                            text: 'Login',
                            style: TextStyle(
                              color: AppColors.primaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
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

// ── Small Logo Widget ─────────────────────────────────────────────────────────

class _AppLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryLight, AppColors.accentMint],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      child: const Icon(Icons.check_rounded, color: AppColors.white, size: 32),
    );
  }
}
