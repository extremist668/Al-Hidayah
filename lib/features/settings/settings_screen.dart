import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/core/theme.dart';
import 'package:islamic_app/features/auth/auth_provider.dart';
import 'package:islamic_app/features/settings/theme_provider.dart';
import 'package:islamic_app/localization/locale_provider.dart';
import 'package:islamic_app/localization/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeLocale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.translate('settings'),
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppTheme.primaryEmerald.withOpacity(0.1),
                      child: const Icon(
                        Icons.person,
                        size: 32,
                        color: AppTheme.primaryEmerald,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authState.user?.userMetadata?['full_name'] ?? 'Guest User',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            authState.user?.email ?? 'Using Offline Guest Mode',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'App Configuration',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Language switching list tile
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.language, color: AppTheme.primaryEmerald),
                    title: Text(context.translate('select_language')),
                    trailing: DropdownButton<String>(
                      value: activeLocale.languageCode,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(value: 'ur', child: Text('اردو (Urdu)')),
                        DropdownMenuItem(value: 'ar', child: Text('العربية (Arabic)')),
                      ],
                      onChanged: (langCode) {
                        if (langCode != null) {
                          ref.read(localeProvider.notifier).changeLocale(langCode);
                        }
                      },
                    ),
                  ),
                  const Divider(height: 1),

                  // Theme Selector Tile
                  ListTile(
                    leading: const Icon(Icons.palette, color: AppTheme.primaryEmerald),
                    title: Text(context.translate('theme_mode')),
                    trailing: DropdownButton<ThemeMode>(
                      value: themeMode,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                        DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                        DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                      ],
                      onChanged: (mode) {
                        if (mode != null) {
                          ref.read(themeModeProvider.notifier).changeThemeMode(mode);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Logout Action Trigger
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  ref.read(authProvider.notifier).signOut();
                },
                child: Text(
                  authState.status == AuthStatus.guest
                      ? 'Exit Guest Mode / Login'
                      : context.translate('logout'),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
