import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  late Map<String, String> _localizedStrings;

  Future<bool> load() async {
    String jsonString =
        await rootBundle.loadString('assets/locales/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  String translate(String key, {Map<String, String>? arguments}) {
    String value = _localizedStrings[key] ?? key;
    if (arguments != null) {
      arguments.forEach((key, val) {
        value = value.replaceAll('{$key}', val);
      });
    }
    return value;
  }

  bool get isRTL => locale.languageCode == 'ar' || locale.languageCode == 'ur';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ur', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// Simple extension helper for easy usage in widgets: context.translate('key')
extension LocalizationExtension on BuildContext {
  String translate(String key, {Map<String, String>? arguments}) {
    return AppLocalizations.of(this)?.translate(key, arguments: arguments) ?? key;
  }

  bool get isRTL {
    return AppLocalizations.of(this)?.isRTL ?? false;
  }
}
