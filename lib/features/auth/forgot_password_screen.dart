import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../shared/widgets/auth_widgets.dart';

/// Three-step forgot password flow:
///   Step 1 → Enter email → Firebase sends reset link
///   Step 2 → Success confirmation (user checks email)
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  bool _emailSent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await context.read<AuthProvider>().sendPasswordReset(
          _emailCtrl.text.trim(),
        );
    if (ok && mounted) {
      setState(() => _emailSent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Reset Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.lg,
            vertical: AppDimens.xl,
          ),
          child: _emailSent ? _SuccessView(email: _emailCtrl.text.trim()) : _FormView(
            formKey: _formKey,
            emailCtrl: _emailCtrl,
            onSubmit: _sendReset,
          ),
        ),
      ),
    );
  }
}

// ── Step 1: Email Input ───────────────────────────────────────────────────────

class _FormView extends StatelessWidget {
  const _FormView({
    required this.formKey,
    required this.emailCtrl,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Icon ─────────────────────────────────────────────────────
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.accentOrangePastel,
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            ),
            child: const Icon(
              Icons.lock_reset_outlined,
              size: 40,
              color: AppColors.accentOrange,
            ),
          ),
          const SizedBox(height: AppDimens.lg),

          Text('Forgot Password?',
              style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: AppDimens.xs),
          Text(
            'Enter your email and we\'ll send you a link to reset your password.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppDimens.xl),

          if (auth.errorMessage != null) ...[
            ErrorBanner(message: auth.errorMessage!),
            const SizedBox(height: AppDimens.md),
          ],

          AppTextField(
            hint: 'Email address',
            controller: emailCtrl,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSubmit(),
            validator: (v) {
              if (v!.trim().isEmpty) return 'Required';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: AppDimens.lg),

          AppPrimaryButton(
            label: 'Send Reset Link',
            onPressed: onSubmit,
            isLoading: auth.isLoading,
          ),
        ],
      ),
    );
  }
}

// ── Step 2: Success ───────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: AppDimens.xxl),
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: AppColors.accentMintPastel,
            borderRadius: BorderRadius.circular(AppDimens.radiusXl),
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            size: 48,
            color: AppColors.accentMint,
          ),
        ),
        const SizedBox(height: AppDimens.lg),
        Text('Check your inbox',
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center),
        const SizedBox(height: AppDimens.sm),
        Text(
          'A reset link has been sent to\n$email',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.xl),
        AppPrimaryButton(
          label: 'Back to Login',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
