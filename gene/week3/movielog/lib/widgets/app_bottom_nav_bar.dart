import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/theme/app_colors.dart';

enum NavTab { home, movies, my }

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({super.key, required this.current});

  final NavTab current;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTab(
              context,
              tab: NavTab.home,
              icon: Icons.home_rounded,
              label: '홈',
              route: '/home',
            ),
            _buildTab(
              context,
              tab: NavTab.movies,
              icon: Icons.local_movies_outlined,
              label: '영화',
              route: '/movies',
            ),
            _buildTab(
              context,
              tab: NavTab.my,
              icon: Icons.person_outline,
              label: '마이',
              route: '/my',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(
    BuildContext context, {
    required NavTab tab,
    required IconData icon,
    required String label,
    required String route,
  }) {
    final isActive = tab == current;
    return GestureDetector(
      onTap: isActive ? null : () => context.go(route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primaryDark : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 16 / 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
