import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/core/theme.dart';
import 'package:islamic_app/features/prayer_times/prayer_times_provider.dart';
import 'package:islamic_app/localization/app_localizations.dart';

class PrayerTimesScreen extends ConsumerWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(prayerTimesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Prayer Timings',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(prayerTimesProvider.notifier).loadPrayerTimes();
            },
          )
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text(state.error!))
              : Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Madhab & Calculation Settings Summary Panel
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryEmerald.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Calculation Method',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  state.model?.calculationMethod ?? 'ISNA',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Active Timezone',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  state.model?.timezone ?? 'UTC',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Timing list
                      Expanded(
                        child: ListView(
                          children: [
                            _buildPrayerTimeRow(
                              context,
                              name: context.translate('fajr'),
                              time: state.model?.fajr ?? '--:--',
                              isActive: state.nextPrayerName == 'Fajr',
                            ),
                            _buildPrayerTimeRow(
                              context,
                              name: context.translate('sunrise'),
                              time: state.model?.sunrise ?? '--:--',
                              isActive: state.nextPrayerName == 'Sunrise',
                            ),
                            _buildPrayerTimeRow(
                              context,
                              name: context.translate('dhuhr'),
                              time: state.model?.dhuhr ?? '--:--',
                              isActive: state.nextPrayerName == 'Dhuhr',
                            ),
                            _buildPrayerTimeRow(
                              context,
                              name: context.translate('asr'),
                              time: state.model?.asr ?? '--:--',
                              isActive: state.nextPrayerName == 'Asr',
                            ),
                            _buildPrayerTimeRow(
                              context,
                              name: context.translate('maghrib'),
                              time: state.model?.maghrib ?? '--:--',
                              isActive: state.nextPrayerName == 'Maghrib',
                            ),
                            _buildPrayerTimeRow(
                              context,
                              name: context.translate('isha'),
                              time: state.model?.isha ?? '--:--',
                              isActive: state.nextPrayerName == 'Isha',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildPrayerTimeRow(
    BuildContext context, {
    required String name,
    required String time,
    required bool isActive,
  }) {
    return Card(
      color: isActive ? AppTheme.primaryEmerald.withOpacity(0.15) : null,
      shape: RoundedRectangleBorder(
        side: isActive
            ? const BorderSide(color: AppTheme.primaryEmerald, width: 2)
            : BorderSide(color: Colors.grey.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.alarm_on,
                  color: isActive ? AppTheme.primaryEmerald : Colors.grey,
                ),
                const SizedBox(width: 16),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
            Text(
              time,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isActive ? AppTheme.primaryEmerald : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
