import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:islamic_app/config/app_config.dart';
import 'package:islamic_app/features/auth/auth_provider.dart';
import 'package:islamic_app/models/ramadan_fast_model.dart';
import 'package:islamic_app/services/supabase_service.dart';

class RamadanState {
  final bool isLoading;
  final List<RamadanFastModel> ramadanDays;
  final int totalFastsKept;
  final int totalQuranPages;
  final double totalCharity;

  RamadanState({
    required this.isLoading,
    required this.ramadanDays,
    this.totalFastsKept = 0,
    this.totalQuranPages = 0,
    this.totalCharity = 0.0,
  });

  RamadanState copyWith({
    bool? isLoading,
    List<RamadanFastModel>? ramadanDays,
    int? totalFastsKept,
    int? totalQuranPages,
    double? totalCharity,
  }) {
    return RamadanState(
      isLoading: isLoading ?? this.isLoading,
      ramadanDays: ramadanDays ?? this.ramadanDays,
      totalFastsKept: totalFastsKept ?? this.totalFastsKept,
      totalQuranPages: totalQuranPages ?? this.totalQuranPages,
      totalCharity: totalCharity ?? this.totalCharity,
    );
  }
}

final ramadanProvider = StateNotifierProvider<RamadanNotifier, RamadanState>((ref) {
  final authState = ref.watch(authProvider);
  return RamadanNotifier(authState);
});

class RamadanNotifier extends StateNotifier<RamadanState> {
  final AuthState authState;

  RamadanNotifier(this.authState) : super(RamadanState(isLoading: true, ramadanDays: [])) {
    loadRamadanData();
  }

  Future<void> loadRamadanData() async {
    state = state.copyWith(isLoading: true);
    try {
      final box = await Hive.openBox(AppConfig.ramadanTrackerBoxName);
      final List<RamadanFastModel> days = [];

      if (box.isEmpty) {
        // Initialize 30 Days of Ramadan
        final startDate = DateTime.now(); // local starting backup
        for (int i = 1; i <= 30; i++) {
          final dayDate = startDate.add(Duration(days: i - 1));
          final newDay = RamadanFastModel(
            fastDay: i,
            date: DateFormat('yyyy-MM-dd').format(dayDate),
            isFasting: true,
            quranPagesRead: 0,
            charityAmount: 0.0,
            sehriReminder: true,
            iftarReminder: true,
          );
          days.add(newDay);
          await box.put('day_$i', json.encode(newDay.toJson()));
        }
      } else {
        for (int i = 1; i <= 30; i++) {
          final dayJson = box.get('day_$i');
          if (dayJson != null) {
            days.add(RamadanFastModel.fromJson(
                Map<String, dynamic>.from(json.decode(dayJson))));
          }
        }
      }

      _calculateTotals(days);

      if (authState.status == AuthStatus.authenticated) {
        _syncWithSupabase();
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void _calculateTotals(List<RamadanFastModel> days) {
    int fasts = days.where((d) => d.isFasting).length;
    int pages = days.fold(0, (sum, d) => sum + d.quranPagesRead);
    double charity = days.fold(0.0, (sum, d) => sum + d.charityAmount);

    state = state.copyWith(
      isLoading: false,
      ramadanDays: days,
      totalFastsKept: fasts,
      totalQuranPages: pages,
      totalCharity: charity,
    );
  }

  Future<void> updateDay(RamadanFastModel updatedDay) async {
    try {
      final box = await Hive.openBox(AppConfig.ramadanTrackerBoxName);
      await box.put('day_${updatedDay.fastDay}', json.encode(updatedDay.toJson()));

      final updatedList = List<RamadanFastModel>.from(state.ramadanDays);
      final idx = updatedList.indexWhere((element) => element.fastDay == updatedDay.fastDay);
      if (idx != -1) {
        updatedList[idx] = updatedDay;
      }

      _calculateTotals(updatedList);

      if (authState.status == AuthStatus.authenticated) {
        _syncDayToSupabase(updatedDay);
      }
    } catch (_) {}
  }

  Future<void> _syncDayToSupabase(RamadanFastModel day) async {
    try {
      if (!SupabaseService.instance.isInitialized) return;
      final client = SupabaseService.instance.client;
      await client.from('ramadan_tracker').upsert({
        'user_id': authState.user?.id,
        'year': 1447, // Current Hijri Year estimation
        'fast_day': day.fastDay,
        'fast_date': day.date,
        'is_fasting': day.isFasting,
        'sehri_reminder': day.sehriReminder,
        'iftar_reminder': day.iftarReminder,
        'quran_pages_read': day.quranPagesRead,
        'charity_amount': day.charityAmount,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  Future<void> _syncWithSupabase() async {
    try {
      if (!SupabaseService.instance.isInitialized) return;
      final client = SupabaseService.instance.client;
      final userId = authState.user?.id;
      if (userId == null) return;

      final response = await client
          .from('ramadan_tracker')
          .select()
          .eq('user_id', userId)
          .eq('year', 1447);

      if (response != null && response is List && response.isNotEmpty) {
        final box = await Hive.openBox(AppConfig.ramadanTrackerBoxName);
        final List<RamadanFastModel> updatedDays = List.from(state.ramadanDays);

        for (var row in response) {
          final fastDayNum = row['fast_day'] as int;
          final syncedDay = RamadanFastModel(
            fastDay: fastDayNum,
            date: row['fast_date'],
            isFasting: row['is_fasting'],
            quranPagesRead: row['quran_pages_read'],
            charityAmount: (row['charity_amount'] ?? 0.0).toDouble(),
            sehriReminder: row['sehri_reminder'],
            iftarReminder: row['iftar_reminder'],
          );

          final idx = updatedDays.indexWhere((element) => element.fastDay == fastDayNum);
          if (idx != -1) {
            updatedDays[idx] = syncedDay;
          }
          await box.put('day_$fastDayNum', json.encode(syncedDay.toJson()));
        }

        _calculateTotals(updatedDays);
      }
    } catch (_) {}
  }
}
