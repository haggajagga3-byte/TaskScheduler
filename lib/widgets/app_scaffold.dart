import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const AppScaffold({required this.navigationShell, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: _AppBottomNav(navigationShell: navigationShell),
    );
  }
}

class _AppBottomNav extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const _AppBottomNav({required this.navigationShell});

  static const _tabs = [
    _TabItem(icon: Icons.home_rounded, label: 'Home'),
    _TabItem(icon: Icons.menu_book_rounded, label: 'Study'),
    _TabItem(icon: Icons.fitness_center_rounded, label: 'Workout'),
    _TabItem(icon: Icons.block_rounded, label: 'Block'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentIndex = navigationShell.currentIndex;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(60),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: List.generate(_tabs.length, (index) {
              final isActive = currentIndex == index;
              final tab = _tabs[index];
              return Expanded(
                child: GestureDetector(
                  onTap: () => navigationShell.goBranch(
                    index,
                    initialLocation: index == currentIndex,
                  ),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isActive
                          ? theme.colorScheme.primary.withAlpha(55)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          tab.icon,
                          size: 22,
                          color: isActive
                              ? theme.colorScheme.primary
                              : Colors.white.withAlpha(140),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tab.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isActive
                                ? theme.colorScheme.primary
                                : Colors.white.withAlpha(120),
                          ),
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
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  const _TabItem({required this.icon, required this.label});
}
