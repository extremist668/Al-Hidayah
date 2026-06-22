import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/core/theme.dart';
import 'package:islamic_app/features/auth/auth_provider.dart';
import 'package:islamic_app/features/prayer_times/prayer_times_provider.dart';
import 'package:islamic_app/features/prayer_tracker/prayer_tracker_provider.dart';
import 'package:islamic_app/localization/app_localizations.dart';

class DashboardScreen extends ConsumerWidget {
  final Function(int) onTabChange;
  const DashboardScreen({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerTimesState = ref.watch(prayerTimesProvider);
    final trackerState = ref.watch(prayerTrackerProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Beautiful Header banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 32),
              decoration: const BoxDecoration(
                color: AppTheme.primaryEmerald,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assalamu Alaikum,',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            authState.user?.userMetadata?['full_name'] ?? 'Guest User',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.mosque_rounded,
                        color: AppTheme.goldAccent,
                        size: 40,
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Countdown Card to Next Prayer
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${context.translate('next_prayer')}: ${prayerTimesState.nextPrayerName}',
                              style: const TextStyle(
                                color: AppTheme.goldAccent,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.translate(
                                'hours_minutes',
                                arguments: {
                                  'hours': prayerTimesState.timeRemainingToNextPrayer.inHours.toString(),
                                  'minutes': (prayerTimesState.timeRemainingToNextPrayer.inMinutes % 60).toString(),
                                },
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.access_time,
                          color: Colors.white70,
                          size: 32,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Summary metrics row
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          context,
                          title: 'Prayer Streak',
                          value: '${trackerState.currentStreak} Days',
                          icon: Icons.local_fire_department,
                          iconColor: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricCard(
                          context,
                          title: 'Qaza Recoverable',
                          value: '${trackerState.qazaCount} Prayers',
                          icon: Icons.history,
                          iconColor: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'Quick Modules',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Module Grid Layout
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _buildQuickModuleItem(
                        context,
                        title: context.translate('tracker'),
                        desc: 'Mark daily prayers',
                        icon: Icons.check_circle_outline,
                        color: Colors.teal,
                        onTap: () => onTabChange(1), // Navigates to Tracker Tab
                      ),
                      _buildQuickModuleItem(
                        context,
                        title: context.translate('quran'),
                        desc: 'Track reading habits',
                        icon: Icons.menu_book,
                        color: Colors.indigo,
                        onTap: () => onTabChange(2), // Navigates to Quran Tab
                      ),
                      _buildQuickModuleItem(
                        context,
                        title: context.translate('ramadan'),
                        desc: 'Roza, Sehri & Iftar',
                        icon: Icons.nights_stay_outlined,
                        color: Colors.deepPurple,
                        onTap: () => onTabChange(3), // Navigates to Ramadan Tab
                      ),
                      _buildQuickModuleItem(
                        context,
                        title: context.translate('zakat'),
                        desc: 'Nisab & Assets',
                        icon: Icons.calculate_outlined,
                        color: Colors.amber.shade800,
                        onTap: () => onTabChange(4), // Navigates to Zakat Tab
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickModuleItem(
    BuildContext context, {
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        color: color.withOpacity(0.05),
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: color.withOpacity(0.15), width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 36),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
