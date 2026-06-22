import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:islamic_app/config/app_config.dart';
import 'package:islamic_app/models/prayer_times_model.dart';
import 'package:islamic_app/services/location_service.dart';
import 'package:islamic_app/services/notifications_service.dart';

class PrayerTimesState {
  final bool isLoading;
  final PrayerTimesModel? model;
  final String? error;
  final String nextPrayerName;
  final Duration timeRemainingToNextPrayer;

  PrayerTimesState({
    required this.isLoading,
    this.model,
    this.error,
    this.nextPrayerName = '',
    this.timeRemainingToNextPrayer = Duration.zero,
  });

  PrayerTimesState copyWith({
    bool? isLoading,
    PrayerTimesModel? model,
    String? error,
    String? nextPrayerName,
    Duration? timeRemainingToNextPrayer,
  }) {
    return PrayerTimesState(
      isLoading: isLoading ?? this.isLoading,
      model: model ?? this.model,
      error: error ?? this.error,
      nextPrayerName: nextPrayerName ?? this.nextPrayerName,
      timeRemainingToNextPrayer: timeRemainingToNextPrayer ?? this.timeRemainingToNextPrayer,
    );
  }
}

final prayerTimesProvider =
    StateNotifierProvider<PrayerTimesNotifier, PrayerTimesState>((ref) {
  return PrayerTimesNotifier();
});

class PrayerTimesNotifier extends StateNotifier<PrayerTimesState> {
  PrayerTimesNotifier() : super(PrayerTimesState(isLoading: true)) {
    loadPrayerTimes();
  }

  Future<void> loadPrayerTimes() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final position = await LocationService.getCurrentLocation();
      final dateStr = DateFormat('dd-MM-yyyy').format(DateTime.now());

      // Attempt to load from cache first for offline speed
      final box = await Hive.openBox(AppConfig.prayerTimesBoxName);
      final cachedJson = box.get(dateStr);

      if (cachedJson != null) {
        final cachedModel = PrayerTimesModel.fromJson(
            Map<String, dynamic>.from(json.decode(cachedJson)));
        state = state.copyWith(isLoading: false, model: cachedModel);
        _calculateNextPrayerAndSchedule();
      }

      // Fetch fresh times from API
      // Default to Calculation Method 2 (Islamic Society of North America) or 1 (University of Islamic Sciences, Karachi)
      final url = Uri.parse(
          '${AppConfig.prayerTimesBaseUrl}/timings/$dateStr?latitude=${position.latitude}&longitude=${position.longitude}&method=2');

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final freshModel = PrayerTimesModel.fromAladhan(jsonResponse);

        // Update local cache
        await box.put(dateStr, json.encode(freshModel.toJson()));

        state = state.copyWith(isLoading: false, model: freshModel);
        _calculateNextPrayerAndSchedule();
      } else if (state.model == null) {
        state = state.copyWith(
            isLoading: false, error: 'Failed to retrieve prayer timings.');
      }
    } catch (e) {
      if (state.model == null) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  void _calculateNextPrayerAndSchedule() {
    final model = state.model;
    if (model == null) return;

    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    final Map<String, DateTime> prayerMap = {
      'Fajr': DateTime.parse('$todayStr ${model.fajr}:00'),
      'Sunrise': DateTime.parse('$todayStr ${model.sunrise}:00'),
      'Dhuhr': DateTime.parse('$todayStr ${model.dhuhr}:00'),
      'Asr': DateTime.parse('$todayStr ${model.asr}:00'),
      'Maghrib': DateTime.parse('$todayStr ${model.maghrib}:00'),
      'Isha': DateTime.parse('$todayStr ${model.isha}:00'),
    };

    String nextPrayer = 'Fajr';
    DateTime nextTime = prayerMap['Fajr']!.add(const Duration(days: 1));

    for (var entry in prayerMap.entries) {
      if (entry.value.isAfter(now)) {
        nextPrayer = entry.key;
        nextTime = entry.value;
        break;
      }
    }

    final diff = nextTime.difference(now);
    state = state.copyWith(
      nextPrayerName: nextPrayer,
      timeRemainingToNextPrayer: diff,
    );

    // Schedule background Azan notifications for today's remaining prayers
    _scheduleAzans(prayerMap);
  }

  Future<void> _scheduleAzans(Map<String, DateTime> prayerMap) async {
    final notifService = NotificationsService.instance;
    await notifService.cancelAllNotifications();

    int id = 0;
    prayerMap.forEach((name, time) {
      if (name != 'Sunrise' && time.isAfter(DateTime.now())) {
        notifService.scheduleAzanNotification(
          id: id++,
          title: '$name Azan',
          body: 'It is time for the $name prayer.',
          scheduledDateTime: time,
        );
      }
    });
  }
}
