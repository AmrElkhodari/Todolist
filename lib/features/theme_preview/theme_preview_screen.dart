import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_dimens.dart';

/// A preview screen to visually validate the design system.
/// Remove or replace this with the real home screen in Phase 3.
class ThemePreviewScreen extends StatelessWidget {
  const ThemePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System Preview'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('Colors'),
            const SizedBox(height: AppDimens.sm),
            _ColorRow(),
            const SizedBox(height: AppDimens.lg),

            _SectionTitle('Typography'),
            const SizedBox(height: AppDimens.sm),
            _TypographyRow(),
            const SizedBox(height: AppDimens.lg),

            _SectionTitle('Cards & Shadows'),
            const SizedBox(height: AppDimens.sm),
            _CardRow(),
            const SizedBox(height: AppDimens.lg),

            _SectionTitle('Buttons'),
            const SizedBox(height: AppDimens.sm),
            _ButtonRow(),
            const SizedBox(height: AppDimens.lg),

            _SectionTitle('Input Fields'),
            const SizedBox(height: AppDimens.sm),
            _InputRow(),
            const SizedBox(height: AppDimens.xxl),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section helpers
// ─────────────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.headlineSmall);
  }
}

class _ColorRow extends StatelessWidget {
  final _swatches = const [
    (AppColors.primaryLight, 'Primary'),
    (AppColors.accentMint, 'Mint'),
    (AppColors.accentPink, 'Pink'),
    (AppColors.accentBlue, 'Blue'),
    (AppColors.accentOrange, 'Orange'),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimens.sm,
      runSpacing: AppDimens.sm,
      children: _swatches.map((s) {
        return Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: s.$1,
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                boxShadow: AppShadows.card,
              ),
            ),
            const SizedBox(height: 4),
            Text(s.$2, style: AppTextStyles.caption),
          ],
        );
      }).toList(),
    );
  }
}

class _TypographyRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Display Large', style: theme.textTheme.displayLarge),
        Text('Heading Medium', style: theme.textTheme.headlineMedium),
        Text('Body Large — clean and readable.', style: theme.textTheme.bodyLarge),
        Text('Body Small — secondary information.', style: theme.textTheme.bodySmall),
        Text('LABEL / CAPTION', style: theme.textTheme.labelSmall),
      ],
    );
  }
}

class _CardRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 90,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              boxShadow: AppShadows.card,
            ),
            alignment: Alignment.center,
            child: const Text('Card Shadow', style: AppTextStyles.label),
          ),
        ),
        const SizedBox(width: AppDimens.md),
        Expanded(
          child: Container(
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              boxShadow: AppShadows.floating,
            ),
            alignment: Alignment.center,
            child: const Text(
              'Floating Shadow',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ButtonRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimens.sm,
      runSpacing: AppDimens.sm,
      children: [
        ElevatedButton(onPressed: () {}, child: const Text('Primary')),
        OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
        TextButton(onPressed: () {}, child: const Text('Text Button')),
      ],
    );
  }
}

class _InputRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            hintText: 'Email address',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: AppDimens.md),
        TextField(
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Password',
            prefixIcon: Icon(Icons.lock_outlined),
            suffixIcon: Icon(Icons.visibility_outlined),
          ),
        ),
      ],
    );
  }
}
