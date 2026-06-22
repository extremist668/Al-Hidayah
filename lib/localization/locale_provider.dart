import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:islamic_app/config/app_config.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    try {
      final box = await Hive.openBox(AppConfig.settingsBoxName);
      final String? langCode = box.get('language_code');
      if (langCode != null) {
        state = Locale(langCode);
      }
    } catch (e) {
      // Default to english in case of hive issues
      state = const Locale('en');
    }
  }

  Future<void> changeLocale(String languageCode) async {
    if (!['en', 'ur', 'ar'].contains(languageCode)) return;
    state = Locale(languageCode);
    try {
      final box = await Hive.openBox(AppConfig.settingsBoxName);
      await box.put('language_code', languageCode);
    } catch (_) {}
  }
}
