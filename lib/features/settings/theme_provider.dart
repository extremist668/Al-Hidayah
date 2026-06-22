import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:islamic_app/config/app_config.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadSavedThemeMode();
  }

  Future<void> _loadSavedThemeMode() async {
    try {
      final box = await Hive.openBox(AppConfig.settingsBoxName);
      final String? savedMode = box.get('theme_mode');
      if (savedMode != null) {
        state = ThemeMode.values.firstWhere(
          (e) => e.name == savedMode,
          orElse: () => ThemeMode.system,
        );
      }
    } catch (_) {}
  }

  Future<void> changeThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      final box = await Hive.openBox(AppConfig.settingsBoxName);
      await box.put('theme_mode', mode.name);
    } catch (_) {}
  }
}
