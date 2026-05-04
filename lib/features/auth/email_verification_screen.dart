import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_dimens.dart';
import '../../shared/widgets/auth_widgets.dart';
import 'login_screen.dart';

/// Shown after sign-up. Waits for email verification.
/// On detection (or manual confirmation), signs the user OUT
/// and redirects to LoginScreen — forcing a clean fresh login.
class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _checkTimer;
  bool _canResend = true;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    // Poll every 5 seconds to detect verification.
    _checkTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _autoCheck(),
    );
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  /// Auto-polls Firebase. On success, sign out and go to Login.
  Future<void> _autoCheck() async {
    if (_checking || !mounted) return;
    _checking = true;
    final verified = await context.read<AuthProvider>().checkEmailVerified();
    if (verified && mounted) {
      _checkTimer?.cancel();
      await _signOutAndGoToLogin();
    }
    _checking = false;
  }

  /// Manual button — user says "I've verified, take me to login".
  Future<void> _manualContinue() async {
    final verified = await context.read<AuthProvider>().checkEmailVerified();
    if (!mounted) return;
    if (verified) {
      await _signOutAndGoToLogin();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email not verified yet. Please check your inbox.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _signOutAndGoToLogin() async {
    await context.read<AuthProvider>().signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Future<void> _resend() async {
    if (!_canResend) return;
    await context.read<AuthProvider>().resendVerificationEmail();
    setState(() {
      _canResend = false;
      _resendCooldown = 30;
    });
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _resendCooldown--);
      if (_resendCooldown <= 0) {
        t.cancel();
        setState(() => _canResend = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final email = auth.user?.email ?? 'your email';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.lg,
            vertical: AppDimens.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppDimens.xxl),

              // ── Icon ────────────────────────────────────────────────
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.accentBluePastel,
                  borderRadius: BorderRadius.circular(AppDimens.radiusXl),
                ),
                child: const Icon(
                  Icons.mark_email_unread_outlined,
                  size: 48,
                  color: AppColors.accentBlue,
                ),
              ),
              const SizedBox(height: AppDimens.lg),

              // ── Text ─────────────────────────────────────────────────
              Text(
                'Verify your email',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimens.sm),
              Text(
                'We sent a verification link to\n$email',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimens.xs),
              Text(
                'After clicking the link, come back and tap the button below.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimens.xl),

              // ── Checking indicator ───────────────────────────────────
              const _CheckingIndicator(),
              const SizedBox(height: AppDimens.xl),

              // ── "I've Verified" primary button ───────────────────────
              AppPrimaryButton(
                label: "I've Verified My Email",
                onPressed: _manualContinue,
                isLoading: auth.isLoading,
              ),
              const SizedBox(height: AppDimens.md),

              // ── Resend ───────────────────────────────────────────────
              OutlinedButton(
                onPressed: _canResend ? _resend : null,
                child: Text(
                  _canResend
                      ? 'Resend Email'
                      : 'Resend in ${_resendCooldown}s',
                ),
              ),
              const SizedBox(height: AppDimens.md),

              // ── Wrong email ──────────────────────────────────────────
              TextButton(
                onPressed: _signOutAndGoToLogin,
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    children: const [
                      TextSpan(text: 'Wrong email? '),
                      TextSpan(
                        text: 'Go back',
                        style: TextStyle(
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Animated checking indicator ───────────────────────────────────────────────

class _CheckingIndicator extends StatefulWidget {
  const _CheckingIndicator();

  @override
  State<_CheckingIndicator> createState() => _CheckingIndicatorState();
}

class _CheckingIndicatorState extends State<_CheckingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: AppDimens.sm),
          Text(
            'Checking automatically…',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
