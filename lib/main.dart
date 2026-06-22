import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'package:islamic_app/config/app_config.dart';
import 'package:islamic_app/core/theme.dart';
import 'package:islamic_app/features/auth/auth_provider.dart';
import 'package:islamic_app/features/auth/auth_screen.dart';
import 'package:islamic_app/features/dashboard/main_navigation_scaffold.dart';
import 'package:islamic_app/features/settings/theme_provider.dart';
import 'package:islamic_app/localization/app_localizations.dart';
import 'package:islamic_app/localization/locale_provider.dart';
import 'package:islamic_app/services/notifications_service.dart';
import 'package:islamic_app/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Hive Local Storage Databases
  await Hive.initFlutter();
  await Hive.openBox(AppConfig.settingsBoxName);
  await Hive.openBox(AppConfig.prayerTimesBoxName);
  await Hive.openBox(AppConfig.prayerTrackerBoxName);
  await Hive.openBox(AppConfig.quranProgressBoxName);
  await Hive.openBox(AppConfig.ramadanTrackerBoxName);
  await Hive.openBox(AppConfig.zakatHistoryBoxName);

  // 2. Initialize Notifications & Background Alarms Services (Web-safe)
  await NotificationsService.instance.initialize();

  // 3. Register Workmanager background tasks (Non-web platforms only)
  if (!kIsWeb) {
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  // 4. Initialize Supabase Backend connection with safe error check
  await SupabaseService.instance.initialize();

  runApp(
    const ProviderScope(
      child: AlHidayahApp(),
    ),
  );
}

class AlHidayahApp extends ConsumerWidget {
  const AlHidayahApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeLocale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Al-Hidayah',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // Locales setup & Multi-language delegates
      locale: activeLocale,
      supportedLocales: const [
        Locale('en', ''),
        Locale('ur', ''),
        Locale('ar', ''),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Navigation & Initial Auth Gatekeeper
      home: _getHomeScreen(authState.status),
    );
  }

  Widget _getHomeScreen(AuthStatus status) {
    switch (status) {
      case AuthStatus.loading:
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryEmerald,
            ),
          ),
        );
      case AuthStatus.authenticated:
      case AuthStatus.guest:
        return const MainNavigationScaffold();
      case AuthStatus.unauthenticated:
      default:
        return const AuthScreen();
    }
  }
}
