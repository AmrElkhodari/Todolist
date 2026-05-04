import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart' as app_auth;
import '../../core/providers/theme_provider.dart';
import '../../core/services/user_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/constants/app_dimens.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<app_auth.AuthProvider>();
    final theme = context.watch<ThemeProvider>();
    final name = auth.user?.displayName ?? 'User';
    final email = auth.user?.email ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileCard(name: name, email: email, uid: auth.user?.uid ?? ''),
            const SizedBox(height: AppDimens.lg),

            _SectionLabel('Account'),
            const SizedBox(height: AppDimens.sm),
            _SettingsTile(
              icon: Icons.person_outlined,
              color: AppColors.accentMint,
              label: 'My Profile',
              subtitle: 'Edit name and bio',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => EditProfileScreen(uid: auth.user?.uid ?? '')),
              ),
            ),

            const SizedBox(height: AppDimens.md),
            _SectionLabel('Preferences'),
            const SizedBox(height: AppDimens.sm),
            _ThemeTile(isDark: theme.isDark, onToggle: theme.toggleTheme),

            const SizedBox(height: AppDimens.md),
            _SectionLabel('Security'),
            const SizedBox(height: AppDimens.sm),
            _SettingsTile(
              icon: Icons.lock_outlined,
              color: AppColors.accentBlue,
              label: 'Change Password',
              subtitle: 'Update your password',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
              ),
            ),

            const SizedBox(height: AppDimens.lg),
            _SignOutTile(
              onTap: () async {
                // Capture navigator before async gap.
                final navigator = Navigator.of(context);
                await context.read<app_auth.AuthProvider>().signOut();
                // Pop all routes back to _AuthGate (which will show LoginScreen).
                navigator.popUntil((route) => route.isFirst);
              },
            ),
            const SizedBox(height: AppDimens.xxl),
          ],
        ),
      ),
    );
  }
}

// ── Profile Card ──────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.name, required this.email, required this.uid});
  final String name;
  final String email;
  final String uid;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initials = name.trim().split(' ')
        .map((p) => p.isNotEmpty ? p[0] : '')
        .take(2).join().toUpperCase();

    return Container(
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        boxShadow: isDark ? AppShadows.cardDark : AppShadows.card,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primaryPastel,
            child: Text(initials,
                style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    fontFamily: 'Poppins')),
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 2),
                Text(email, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primaryLight),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => EditProfileScreen(uid: uid)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4),
    child: Text(label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: 1.2, fontWeight: FontWeight.w600)),
  );
}

// ── Settings Tile ─────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon, required this.color,
    required this.label, required this.subtitle, required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimens.xs),
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.md, vertical: AppDimens.sm + 2),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          boxShadow: isDark ? AppShadows.cardDark : AppShadows.card,
        ),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: AppDimens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.labelLarge),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

// ── Theme Tile ────────────────────────────────────────────────────────────────

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({required this.isDark, required this.onToggle});
  final bool isDark;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isDarkBg = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.xs),
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.md, vertical: AppDimens.sm + 2),
      decoration: BoxDecoration(
        color: isDarkBg ? AppColors.cardDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        boxShadow: isDarkBg ? AppShadows.cardDark : AppShadows.card,
      ),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: AppColors.primaryPastel,
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            ),
            child: Icon(
              isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              color: AppColors.primaryLight, size: 20,
            ),
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Theme', style: Theme.of(context).textTheme.labelLarge),
                Text(isDark ? 'Dark Mode' : 'Light Mode',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Switch(
            value: isDark,
            onChanged: (_) => onToggle(),
            activeThumbColor: AppColors.primaryLight,
          ),
        ],
      ),
    );
  }
}

// ── Sign Out Tile ─────────────────────────────────────────────────────────────

class _SignOutTile extends StatelessWidget {
  const _SignOutTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.md, vertical: AppDimens.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.logout_outlined, color: AppColors.error, size: 20),
          const SizedBox(width: AppDimens.sm),
          Text('Sign Out',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.error)),
        ],
      ),
    ),
  );
}

// ════════════════════════════════════════════════════════════════════════════════
// Edit Profile Screen
// ════════════════════════════════════════════════════════════════════════════════

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.uid});
  final String uid;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _firstCtrl  = TextEditingController();
  final _lastCtrl   = TextEditingController();
  final _bioCtrl    = TextEditingController();
  final _userService = UserService();
  bool _loading = true;
  bool _saving  = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = await _userService.getUser(widget.uid);
    if (user != null && mounted) {
      _firstCtrl.text = user.firstName;
      _lastCtrl.text  = user.lastName;
      _bioCtrl.text   = user.bio;
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final firstName = _firstCtrl.text.trim();
    final lastName  = _lastCtrl.text.trim();
    final bio       = _bioCtrl.text.trim();

    await _userService.updateUser(widget.uid,
        firstName: firstName, lastName: lastName, bio: bio);

    // Update Firebase Auth display name.
    await FirebaseAuth.instance.currentUser
        ?.updateDisplayName('$firstName $lastName'.trim());

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated!'),
            behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.lg),
              child: Column(
                children: [
                  Row(children: [
                    Expanded(child: TextField(
                      controller: _firstCtrl,
                      decoration: const InputDecoration(
                          labelText: 'First Name',
                          prefixIcon: Icon(Icons.person_outlined)),
                    )),
                    const SizedBox(width: AppDimens.md),
                    Expanded(child: TextField(
                      controller: _lastCtrl,
                      decoration: const InputDecoration(labelText: 'Last Name'),
                    )),
                  ]),
                  const SizedBox(height: AppDimens.md),
                  TextField(
                    controller: _bioCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      hintText: 'Tell us about yourself…',
                      prefixIcon: Icon(Icons.info_outline),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: AppDimens.xl),
                  SizedBox(
                    width: double.infinity, height: 52,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(width: 22, height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5, color: AppColors.white))
                          : const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// Change Password Screen
// ════════════════════════════════════════════════════════════════════════════════

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _newCtrl   = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscureNew     = true;
  bool _obscureConfirm = true;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _saving = true; _error = null; });
    try {
      await FirebaseAuth.instance.currentUser
          ?.updatePassword(_newCtrl.text);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully!'),
              behavior: SnackBarBehavior.floating),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.code == 'requires-recent-login'
            ? 'Please sign out and sign back in before changing your password.'
            : e.message ?? 'Something went wrong.';
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.lg),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_error != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimens.md),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Text(_error!,
                      style: const TextStyle(color: AppColors.error,
                          fontFamily: 'Poppins', fontSize: 13)),
                ),
                const SizedBox(height: AppDimens.md),
              ],
              TextFormField(
                controller: _newCtrl,
                obscureText: _obscureNew,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureNew
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                validator: (v) =>
                    (v ?? '').length < 6 ? 'At least 6 characters' : null,
              ),
              const SizedBox(height: AppDimens.md),
              TextFormField(
                controller: _confirmCtrl,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (v) => v != _newCtrl.text ? 'Passwords do not match' : null,
              ),
              const SizedBox(height: AppDimens.xl),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: AppColors.white))
                      : const Text('Update Password'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
