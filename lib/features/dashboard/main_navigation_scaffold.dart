import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/core/theme.dart';
import 'package:islamic_app/features/dashboard/dashboard_screen.dart';
import 'package:islamic_app/features/prayer_times/prayer_times_screen.dart';
import 'package:islamic_app/features/prayer_tracker/prayer_tracker_screen.dart';
import 'package:islamic_app/features/qibla/qibla_screen.dart';
import 'package:islamic_app/features/quran/quran_screen.dart';
import 'package:islamic_app/features/ramadan/ramadan_screen.dart';
import 'package:islamic_app/features/zakat/zakat_screen.dart';
import 'package:islamic_app/features/settings/settings_screen.dart';
import 'package:islamic_app/localization/app_localizations.dart';

class MainNavigationScaffold extends ConsumerStatefulWidget {
  const MainNavigationScaffold({super.key});

  @override
  ConsumerState<MainNavigationScaffold> createState() =>
      _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends ConsumerState<MainNavigationScaffold> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Dynamic lists of screens
    final List<Widget> screens = [
      DashboardScreen(onTabChange: (idx) {
        setState(() {
          _currentIndex = idx;
        });
      }),
      const PrayerTrackerScreen(),
      const QuranScreen(),
      const RamadanScreen(),
      const ZakatScreen(),
      const QiblaScreen(),
      const SettingsScreen(),
    ];

    final isRtl = context.isRTL;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex > 4 ? 0 : _currentIndex, // Keep selected within primary bar
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.dashboard_outlined),
              selectedIcon: const Icon(Icons.dashboard, color: AppTheme.primaryEmerald),
              label: context.translate('home'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.check_box_outlined),
              selectedIcon: const Icon(Icons.check_box, color: AppTheme.primaryEmerald),
              label: context.translate('tracker'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.menu_book_outlined),
              selectedIcon: const Icon(Icons.menu_book, color: AppTheme.primaryEmerald),
              label: context.translate('quran'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.nights_stay_outlined),
              selectedIcon: const Icon(Icons.nights_stay, color: AppTheme.primaryEmerald),
              label: context.translate('ramadan'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.calculate_outlined),
              selectedIcon: const Icon(Icons.calculate, color: AppTheme.primaryEmerald),
              label: context.translate('zakat'),
            ),
          ],
        ),
        // Drawers or floating actions can give quick access to Qibla & Settings
        drawer: Drawer(
          child: Column(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: AppTheme.primaryEmerald),
                child: Center(
                  child: Text(
                    context.translate('app_title'),
                    style: const TextStyle(
                      color: AppTheme.goldAccent,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.explore_outlined, color: AppTheme.primaryEmerald),
                title: Text(context.translate('qibla')),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _currentIndex = 5; // Navigate to Qibla Finder
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined, color: AppTheme.primaryEmerald),
                title: Text(context.translate('settings')),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _currentIndex = 6; // Navigate to Settings Screen
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
