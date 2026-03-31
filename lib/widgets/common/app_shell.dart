import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  static const _tabs = [
    _TabItem(path: '/home', icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Học'),
    _TabItem(path: '/course', icon: Icons.map_outlined, activeIcon: Icons.map, label: 'Khóa học'),
    _TabItem(path: '/review', icon: Icons.refresh_outlined, activeIcon: Icons.refresh, label: 'Ôn tập'),
    _TabItem(path: '/community', icon: Icons.people_outline, activeIcon: Icons.people, label: 'Cộng đồng'),
    _TabItem(path: '/profile', icon: Icons.person_outline, activeIcon: Icons.person, label: 'Hồ sơ'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 56,
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final tab = _tabs[i];
                final isActive = i == currentIndex;
                return Expanded(
                  child: InkWell(
                    onTap: () => context.go(tab.path),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isActive ? tab.activeIcon : tab.icon,
                          color: isActive ? AppColors.primary : AppColors.textMuted,
                          size: 22,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tab.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                            color: isActive ? AppColors.primary : AppColors.textMuted,
                          ),
                        ),
                      ],
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
}

class _TabItem {
  final String path;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _TabItem({
    required this.path,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
