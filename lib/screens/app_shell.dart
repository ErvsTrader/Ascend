import 'package:flutter/material.dart';

import '../core/design_system.dart';
import '../services/habit_service.dart';
import '../services/premium_service.dart';
import '../widgets/widgets.dart';
import 'screens.dart';

// ---------------------------------------------------------------------------
// AppShell – bottom navigation with 4 tabs + FAB
// ---------------------------------------------------------------------------

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  // Placeholder screens for tabs not yet built.
  static const _screens = <Widget>[
    HomeScreen(),
    _PlaceholderScreen(title: 'Statistics', icon: Icons.bar_chart_rounded),
    _PlaceholderScreen(title: 'Mood', icon: Icons.sentiment_satisfied_alt_rounded),
    _PlaceholderScreen(title: 'Settings', icon: Icons.settings_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      // ── FAB (visible on Home tab) ──────────────────────────────────
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                final habitService = context.read<HabitService>();
                final premiumService = context.read<PremiumService>();

                if (habitService.totalCount >= 5 && !premiumService.isPremium) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const PremiumUpgradePrompt(),
                  );
                } else {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const AddHabitScreen(),
                  );
                }
              },
              backgroundColor: AppColors.primary,
              elevation: 4,
              shape: const CircleBorder(),
              child: const Icon(
                Icons.add_rounded,
                size: 28,
                color: AppColors.textOnPrimary,
              ),
            )
          : null,

      // ── Bottom nav ─────────────────────────────────────────────────
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ad banner above bottom nav (hides when premium)
          const AdBanner(),

          // Nav bar with shadow
          Container(
            decoration: const BoxDecoration(
              color: AppColors.navBar,
              boxShadow: AppShadows.navBar,
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: AppSpacing.navBarHeight,
                child: Row(
                  children: [
                    _NavItem(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      isActive: _currentIndex == 0,
                      onTap: () => setState(() => _currentIndex = 0),
                    ),
                    _NavItem(
                      icon: Icons.bar_chart_rounded,
                      label: 'Stats',
                      isActive: _currentIndex == 1,
                      onTap: () => setState(() => _currentIndex = 1),
                    ),
                    _NavItem(
                      icon: Icons.sentiment_satisfied_alt_rounded,
                      label: 'Mood',
                      isActive: _currentIndex == 2,
                      onTap: () => setState(() => _currentIndex = 2),
                    ),
                    _NavItem(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      isActive: _currentIndex == 3,
                      onTap: () => setState(() => _currentIndex = 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _NavItem – single bottom nav tab
// ---------------------------------------------------------------------------

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppComponents.navIconSize,
              color: isActive ? AppColors.primary : AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: isActive
                  ? AppTypography.navLabelActive
                  : AppTypography.navLabel,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _PlaceholderScreen – temporary placeholder for unbuilt tabs
// ---------------------------------------------------------------------------

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PlaceholderScreen({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: AppColors.textTertiary),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: AppTypography.headlineMedium),
            const SizedBox(height: AppSpacing.sm),
            Text('Coming soon', style: AppTypography.bodyMedium),
          ],
        ),
      ),
    );
  }
}
