import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainWrapper extends StatelessWidget {
  const MainWrapper({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const _darkGreen = Color(0xFF1B3A2D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        child: SizedBox(
          height: 72,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                height: 64,
                decoration: BoxDecoration(
                  color: _darkGreen.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _NavIcon(
                      icon: Icons.info_outline_rounded,
                      index: 0,
                      currentIndex: navigationShell.currentIndex,
                      onTap: () => _goBranch(0),
                    ),
                    _NavIcon(
                      icon: Icons.storefront_rounded,
                      index: 1,
                      currentIndex: navigationShell.currentIndex,
                      onTap: () => _goBranch(1),
                    ),
                    const SizedBox(width: 64),
                    _NavIcon(
                      icon: Icons.calculate_rounded,
                      index: 3,
                      currentIndex: navigationShell.currentIndex,
                      onTap: () => _goBranch(3),
                    ),
                    _NavIcon(
                      icon: Icons.more_horiz_rounded,
                      index: 4,
                      currentIndex: navigationShell.currentIndex,
                      onTap: () => _goBranch(4),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -10,
                child: GestureDetector(
                  onTap: () => _goBranch(2),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0A6847), Color(0xFF059669)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: _darkGreen,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0A6847).withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.home_rounded,
                      color: Colors.white,
                      size: navigationShell.currentIndex == 2 ? 30 : 26,
                    ),
                  ),
                ),
              ),
            ],
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

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  final IconData icon;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 52,
        height: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color:
                  isActive ? Colors.white : Colors.white.withValues(alpha: 0.4),
              size: 24,
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 4 : 0,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ]
                    : [],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
