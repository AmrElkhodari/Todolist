import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../todo/todo_screen.dart';
import '../folders/folders_screen.dart';
import '../calendar/calendar_screen.dart';
import '../messages/messages_screen.dart';
import '../settings/settings_screen.dart';

/// The main scaffold holding the bottom navigation bar.
/// All four primary tabs live here.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Screens are kept alive by IndexedStack so state is preserved across tabs.
  final List<Widget> _screens = const [
    TodoScreen(),
    FoldersScreen(),
    CalendarScreen(),
    MessagesScreen(),
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.check_circle_outline, label: 'My Tasks'),
    _NavItem(icon: Icons.folder_outlined, label: 'Folders'),
    _NavItem(icon: Icons.calendar_month_outlined, label: 'Calendar'),
    _NavItem(icon: Icons.chat_bubble_outline, label: 'Messages'),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // ── App Bar ────────────────────────────────────────────────────────────
      appBar: AppBar(
        title: Text(
          _navItems[_currentIndex].label,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          // Settings
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          // Avatar / profile shortcut
          Padding(
            padding: const EdgeInsets.only(right: AppDimens.sm),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryPastel,
                child: Text(
                  _initials(auth.user?.displayName),
                  style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // ── Body ───────────────────────────────────────────────────────────────
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      // ── Bottom Nav Bar ─────────────────────────────────────────────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: AppDimens.bottomNavHeight,
            child: Row(
              children: List.generate(_navItems.length, (i) {
                final selected = i == _currentIndex;
                final item = _navItems[i];
                return Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _currentIndex = i),
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    child: AnimatedContainer(
                      duration: AppDimens.durationNormal,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: AppDimens.durationNormal,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primaryPastel
                                  : Colors.transparent,
                              borderRadius:
                                  BorderRadius.circular(AppDimens.radiusFull),
                            ),
                            child: Icon(
                              item.icon,
                              size: AppDimens.iconMd,
                              color: selected
                                  ? AppColors.primaryLight
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          AnimatedDefaultTextStyle(
                            duration: AppDimens.durationNormal,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: selected
                                  ? AppColors.primaryLight
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                            ),
                            child: Text(item.label),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  String _initials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}
