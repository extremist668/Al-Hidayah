import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:islamic_app/config/app_config.dart';
import 'package:islamic_app/features/auth/auth_provider.dart';
import 'package:islamic_app/models/prayer_log_model.dart';
import 'package:islamic_app/services/supabase_service.dart';

class PrayerTrackerState {
  final bool isLoading;
  final Map<String, List<PrayerLogModel>> dailyLogs; // Key: yyyy-MM-dd
  final int currentStreak;
  final int qazaCount; // total missed/qaza prayers remaining to recover

  PrayerTrackerState({
    required this.isLoading,
    required this.dailyLogs,
    this.currentStreak = 0,
    this.qazaCount = 0,
  });

  PrayerTrackerState copyWith({
    bool? isLoading,
    Map<String, List<PrayerLogModel>>? dailyLogs,
    int? currentStreak,
    int? qazaCount,
  }) {
    return PrayerTrackerState(
      isLoading: isLoading ?? this.isLoading,
      dailyLogs: dailyLogs ?? this.dailyLogs,
      currentStreak: currentStreak ?? this.currentStreak,
      qazaCount: qazaCount ?? this.qazaCount,
    );
  }
}

final prayerTrackerProvider =
    StateNotifierProvider<PrayerTrackerNotifier, PrayerTrackerState>((ref) {
  final authState = ref.watch(authProvider);
  return PrayerTrackerNotifier(authState);
});

class PrayerTrackerNotifier extends StateNotifier<PrayerTrackerState> {
  final AuthState authState;
  
  PrayerTrackerNotifier(this.authState)
      : super(PrayerTrackerState(isLoading: true, dailyLogs: {})) {
    loadTrackerData();
  }

  Future<void> loadTrackerData() async {
    state = state.copyWith(isLoading: true);
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      final box = await Hive.openBox(AppConfig.prayerTrackerBoxName);
      
      // Load offline cached logs
      final Map<String, List<PrayerLogModel>> logs = {};
      int qazaCount = 0;

      for (var key in box.keys) {
        if (key.toString().startsWith('log_')) {
          final cachedJson = box.get(key);
          if (cachedJson != null) {
            final log = PrayerLogModel.fromJson(
                Map<String, dynamic>.from(json.decode(cachedJson)));
            
            logs.putIfAbsent(log.prayerDate, () => []);
            logs[log.prayerDate]!.add(log);

            if (log.status == 'missed' || log.status == 'qaza') {
              qazaCount++;
            }
          }
        }
      }

      // Initialize default prayers for today if they don't exist
      if (!logs.containsKey(todayStr)) {
        final List<PrayerLogModel> todayDefault = [];
        final prayers = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
        
        for (var pr in prayers) {
          final newLog = PrayerLogModel(
            id: const Uuid().v4(),
            userId: authState.user?.id ?? 'guest_user',
            prayerDate: todayStr,
            prayerName: pr,
            status: 'none',
            syncedAt: DateTime.now(),
          );
          todayDefault.add(newLog);
          await box.put('log_${todayStr}_$pr', json.encode(newLog.toJson()));
        }
        logs[todayStr] = todayDefault;
      }

      final streak = box.get('current_streak', defaultValue: 0);

      state = state.copyWith(
        isLoading: false,
        dailyLogs: logs,
        currentStreak: streak,
        qazaCount: qazaCount,
      );

      // Attempt to sync background updates if authenticated
      if (authState.status == AuthStatus.authenticated) {
        _syncWithSupabase();
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> updatePrayerStatus(String dateStr, String prayerName, String newStatus) async {
    try {
      final box = await Hive.openBox(AppConfig.prayerTrackerBoxName);
      final currentList = state.dailyLogs[dateStr] ?? [];
      
      final index = currentList.indexWhere((element) => element.prayerName == prayerName);
      if (index == -1) return;

      final updatedLog = currentList[index].copyWith(
        status: newStatus,
        syncedAt: DateTime.now(),
      );

      // Update Local State
      final updatedList = List<PrayerLogModel>.from(currentList);
      updatedList[index] = updatedLog;

      final Map<String, List<PrayerLogModel>> newDailyLogs = Map.from(state.dailyLogs);
      newDailyLogs[dateStr] = updatedList;

      // Update Hive Box
      await box.put('log_${dateStr}_$prayerName', json.encode(updatedLog.toJson()));

      // Recalculate Streak & Qaza
      int newQazaCount = state.qazaCount;
      if (currentList[index].status == 'missed' && newStatus == 'completed') {
        newQazaCount--;
      } else if (newStatus == 'missed') {
        newQazaCount++;
      }

      // Recalculate Streaks based on complete days (5 prayers completed)
      int streak = _calculateActiveStreak(newDailyLogs);
      await box.put('current_streak', streak);

      state = state.copyWith(
        dailyLogs: newDailyLogs,
        currentStreak: streak,
        qazaCount: newQazaCount,
      );

      // Push update to Supabase
      if (authState.status == AuthStatus.authenticated) {
        _syncLogToSupabase(updatedLog);
      }
    } catch (_) {}
  }

  int _calculateActiveStreak(Map<String, List<PrayerLogModel>> logs) {
    int streak = 0;
    final sortedDates = logs.keys.toList()..sort((a, b) => b.compareTo(a));

    for (var date in sortedDates) {
      final dayLogs = logs[date] ?? [];
      final completedCount = dayLogs.where((l) => l.status == 'completed').length;
      if (completedCount == 5) {
        streak++;
      } else if (date != DateFormat('yyyy-MM-dd').format(DateTime.now())) {
        // If it's not today and they missed some prayers, break the streak
        break;
      }
    }
    return streak;
  }

  Future<void> _syncLogToSupabase(PrayerLogModel log) async {
    try {
      if (!SupabaseService.instance.isInitialized) return;
      final client = SupabaseService.instance.client;
      
      await client.from('prayer_logs').upsert({
        'id': log.id,
        'user_id': authState.user?.id,
        'prayer_date': log.prayerDate,
        'prayer_name': log.prayerName,
        'status': log.status,
        'synced_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  Future<void> _syncWithSupabase() async {
    try {
      if (!SupabaseService.instance.isInitialized) return;
      final client = SupabaseService.instance.client;
      final userId = authState.user?.id;
      if (userId == null) return;

      // 1. Pull recent logs from remote
      final response = await client
          .from('prayer_logs')
          .select()
          .eq('user_id', userId)
          .order('prayer_date', ascending: false)
          .limit(100);

      if (response != null && response is List) {
        final box = await Hive.openBox(AppConfig.prayerTrackerBoxName);
        final Map<String, List<PrayerLogModel>> syncedLogs = Map.from(state.dailyLogs);

        for (var row in response) {
          final log = PrayerLogModel.fromJson(row);
          syncedLogs.putIfAbsent(log.prayerDate, () => []);
          
          final existingIndex = syncedLogs[log.prayerDate]!.indexWhere((e) => e.prayerName == log.prayerName);
          if (existingIndex != -1) {
            syncedLogs[log.prayerDate]![existingIndex] = log;
          } else {
            syncedLogs[log.prayerDate]!.add(log);
          }

          await box.put('log_${log.prayerDate}_${log.prayerName}', json.encode(log.toJson()));
        }

        state = state.copyWith(dailyLogs: syncedLogs);
      }
    } catch (_) {}
  }
}
