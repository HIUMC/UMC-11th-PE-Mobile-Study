import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  Widget _icon(String asset, Color color) {
    return SvgPicture.asset(
      asset,
      width: 23,
      height: 23,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: [
          NavigationDestination(
            icon: _icon('assets/icons/home.svg', AppColors.textSecondary),
            selectedIcon: _icon('assets/icons/home.svg', AppColors.primary),
            label: '홈',
          ),
          NavigationDestination(
            icon: _icon('assets/icons/movie.svg', AppColors.textSecondary),
            selectedIcon: _icon('assets/icons/movie.svg', AppColors.primary),
            label: '영화',
          ),
          NavigationDestination(
            icon: _icon('assets/icons/person.svg', AppColors.textSecondary),
            selectedIcon: _icon('assets/icons/person.svg', AppColors.primary),
            label: '마이',
          ),
        ],
      ),
    );
  }
}
