import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/app_logger.dart';
import 'base/base_view_model.dart';

class MainNavViewModel extends BaseViewModel {
  static const _tag = 'MainNavViewModel';

  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  int get selectedIndex => _selectedIndex;
  PageController get pageController => _pageController;

  void onTabTapped(int index) {
    AppLogger.info(_tag, 'onTabTapped called');
    _selectedIndex = index;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    notifyListeners();
  }

  void onPageChanged(int index) {
    AppLogger.info(_tag, 'onPageChanged called');
    _selectedIndex = index;
    notifyListeners();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Navigation items configuration
  List<BottomNavigationBarItem> get navigationItems => [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home_rounded),
      activeIcon: Icon(Icons.home_rounded, color: AppColors.primary),
      label: 'Home',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.quiz_rounded),
      activeIcon: Icon(Icons.quiz_rounded, color: AppColors.primary),
      label: 'Quiz',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.games_rounded),
      activeIcon: Icon(Icons.games_rounded, color: AppColors.primary),
      label: 'Games',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.leaderboard_rounded),
      activeIcon: Icon(Icons.leaderboard_rounded, color: AppColors.primary),
      label: 'Leaderboard',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person_rounded),
      activeIcon: Icon(Icons.person_rounded, color: AppColors.primary),
      label: 'Profile',
    ),
  ];
}

