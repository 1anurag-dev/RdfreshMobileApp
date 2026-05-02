import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class MainWrapper extends StatelessWidget {
  const MainWrapper({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
            child: Row(
              children: [
                _NavItem(
                  label: 'Home',
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  index: 0,
                  currentIndex: navigationShell.currentIndex,
                  onTap: _goBranch,
                ),
                _NavItem(
                  label: 'Products',
                  icon: Icons.storefront_outlined,
                  activeIcon: Icons.storefront_rounded,
                  index: 1,
                  currentIndex: navigationShell.currentIndex,
                  onTap: _goBranch,
                ),
                _NavItem(
                  label: 'Calculator',
                  icon: Icons.calculate_outlined,
                  activeIcon: Icons.calculate_rounded,
                  index: 2,
                  currentIndex: navigationShell.currentIndex,
                  onTap: _goBranch,
                ),
                _NavItem(
                  label: 'More',
                  icon: Icons.more_horiz_outlined,
                  activeIcon: Icons.more_horiz_rounded,
                  index: 3,
                  currentIndex: navigationShell.currentIndex,
                  onTap: _goBranch,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;

    return Expanded(
      child: InkWell(
        borderRadius: AppRadius.mdBr,
        onTap: () => onTap(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: AppDurations.fast,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primaryGreen.withValues(alpha: 0.1)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isActive ? activeIcon : icon,
                  color: isActive
                      ? AppColors.primaryGreen
                      : context.textTertiary,
                  size: 24,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTypography.small.copyWith(
                  color: isActive
                      ? AppColors.primaryGreen
                      : context.textTertiary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: AppDurations.fast,
                width: isActive ? 20 : 0,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: AppRadius.pillBr,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
