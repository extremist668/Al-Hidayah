import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:islamic_app/core/theme.dart';
import 'package:islamic_app/features/prayer_tracker/prayer_tracker_provider.dart';
import 'package:islamic_app/localization/app_localizations.dart';

class PrayerTrackerScreen extends ConsumerWidget {
  const PrayerTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(prayerTrackerProvider);
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final todayLogs = state.dailyLogs[todayStr] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Log Tracker'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Streak & Missed stats Banner
                  Row(
                    children: [
                      Expanded(
                        child: _buildBannerCard(
                          context,
                          title: 'Current Streak',
                          value: '${state.currentStreak} Days',
                          color: Colors.orange,
                          icon: Icons.local_fire_department,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildBannerCard(
                          context,
                          title: 'Unpaid Qaza',
                          value: '${state.qazaCount} Prayers',
                          color: Colors.redAccent,
                          icon: Icons.help_outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  Text(
                    "Today's Prayers",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: ListView.builder(
                      itemCount: todayLogs.length,
                      itemBuilder: (context, index) {
                        final log = todayLogs[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  log.prayerName.toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Row(
                                  children: [
                                    _buildStatusButton(
                                      context,
                                      label: 'Completed',
                                      isActive: log.status == 'completed',
                                      activeColor: AppTheme.primaryEmerald,
                                      onTap: () {
                                        ref.read(prayerTrackerProvider.notifier).updatePrayerStatus(
                                              todayStr,
                                              log.prayerName,
                                              'completed',
                                            );
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    _buildStatusButton(
                                      context,
                                      label: 'Missed',
                                      isActive: log.status == 'missed',
                                      activeColor: Colors.redAccent,
                                      onTap: () {
                                        ref.read(prayerTrackerProvider.notifier).updatePrayerStatus(
                                              todayStr,
                                              log.prayerName,
                                              'missed',
                                            );
                                      },
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildBannerCard(
    BuildContext context, {
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(
    BuildContext context, {
    required String label,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          border: Border.all(color: isActive ? activeColor : Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey.shade700,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
