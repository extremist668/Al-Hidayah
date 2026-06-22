import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:islamic_app/config/app_config.dart';
import 'package:islamic_app/features/auth/auth_provider.dart';
import 'package:islamic_app/models/quran_progress_model.dart';
import 'package:islamic_app/services/supabase_service.dart';

class QuranState {
  final bool isLoading;
  final List<QuranProgressModel> progressList;
  final QuranProgressModel? lastRead;
  final List<int> bookmarkedSurahs;

  QuranState({
    required this.isLoading,
    required this.progressList,
    this.lastRead,
    required this.bookmarkedSurahs,
  });

  QuranState copyWith({
    bool? isLoading,
    List<QuranProgressModel>? progressList,
    QuranProgressModel? lastRead,
    List<int>? bookmarkedSurahs,
  }) {
    return QuranState(
      isLoading: isLoading ?? this.isLoading,
      progressList: progressList ?? this.progressList,
      lastRead: lastRead ?? this.lastRead,
      bookmarkedSurahs: bookmarkedSurahs ?? this.bookmarkedSurahs,
    );
  }
}

final quranProvider = StateNotifierProvider<QuranNotifier, QuranState>((ref) {
  final authState = ref.watch(authProvider);
  return QuranNotifier(authState);
});

class QuranNotifier extends StateNotifier<QuranState> {
  final AuthState authState;

  QuranNotifier(this.authState)
      : super(QuranState(isLoading: true, progressList: [], bookmarkedSurahs: [])) {
    loadQuranProgress();
  }

  Future<void> loadQuranProgress() async {
    state = state.copyWith(isLoading: true);
    try {
      final box = await Hive.openBox(AppConfig.quranProgressBoxName);
      final List<QuranProgressModel> progress = [];
      final List<int> bookmarks = List<int>.from(box.get('bookmarks', defaultValue: <int>[]));

      for (var key in box.keys) {
        if (key.toString().startsWith('progress_')) {
          final jsonStr = box.get(key);
          if (jsonStr != null) {
            progress.add(QuranProgressModel.fromJson(
                Map<String, dynamic>.from(json.decode(jsonStr))));
          }
        }
      }

      final lastReadJson = box.get('last_read');
      final QuranProgressModel? lastRead = lastReadJson != null
          ? QuranProgressModel.fromJson(Map<String, dynamic>.from(json.decode(lastReadJson)))
          : null;

      state = state.copyWith(
        isLoading: false,
        progressList: progress,
        lastRead: lastRead,
        bookmarkedSurahs: bookmarks,
      );

      if (authState.status == AuthStatus.authenticated) {
        _syncWithSupabase();
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> updateProgress({
    required int surahNum,
    required int ayahNum,
    required String nameEn,
    required String nameAr,
    required double progressPercent,
  }) async {
    final updatedModel = QuranProgressModel(
      surahNumber: surahNum,
      lastReadAyah: ayahNum,
      surahNameEn: nameEn,
      surahNameAr: nameAr,
      progressPercentage: progressPercent,
      isCompleted: progressPercent >= 100.0,
    );

    try {
      final box = await Hive.openBox(AppConfig.quranProgressBoxName);
      await box.put('progress_$surahNum', json.encode(updatedModel.toJson()));
      await box.put('last_read', json.encode(updatedModel.toJson()));

      final List<QuranProgressModel> updatedList = List.from(state.progressList);
      final idx = updatedList.indexWhere((element) => element.surahNumber == surahNum);
      if (idx != -1) {
        updatedList[idx] = updatedModel;
      } else {
        updatedList.add(updatedModel);
      }

      state = state.copyWith(
        progressList: updatedList,
        lastRead: updatedModel,
      );

      if (authState.status == AuthStatus.authenticated) {
        _syncProgressToSupabase(updatedModel);
      }
    } catch (_) {}
  }

  Future<void> toggleBookmark(int surahNum) async {
    final updatedBookmarks = List<int>.from(state.bookmarkedSurahs);
    if (updatedBookmarks.contains(surahNum)) {
      updatedBookmarks.remove(surahNum);
    } else {
      updatedBookmarks.add(surahNum);
    }

    try {
      final box = await Hive.openBox(AppConfig.quranProgressBoxName);
      await box.put('bookmarks', updatedBookmarks);
      state = state.copyWith(bookmarkedSurahs: updatedBookmarks);
    } catch (_) {}
  }

  Future<void> _syncProgressToSupabase(QuranProgressModel model) async {
    try {
      if (!SupabaseService.instance.isInitialized) return;
      final client = SupabaseService.instance.client;
      await client.from('quran_progress').upsert({
        'user_id': authState.user?.id,
        'last_read_surah': model.surahNumber,
        'last_read_ayah': model.lastReadAyah,
        'surah_name_en': model.surahNameEn,
        'surah_name_ar': model.surahNameAr,
        'progress_percentage': model.progressPercentage,
        'is_completed': model.isCompleted,
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
          .from('quran_progress')
          .select()
          .eq('user_id', userId);

      if (response != null && response is List && response.isNotEmpty) {
        final box = await Hive.openBox(AppConfig.quranProgressBoxName);
        final List<QuranProgressModel> syncedProgress = [];

        for (var row in response) {
          final model = QuranProgressModel(
            surahNumber: row['last_read_surah'],
            lastReadAyah: row['last_read_ayah'],
            surahNameEn: row['surah_name_en'],
            surahNameAr: row['surah_name_ar'],
            progressPercentage: (row['progress_percentage'] ?? 0.0).toDouble(),
            isCompleted: row['is_completed'] ?? false,
          );

          syncedProgress.add(model);
          await box.put('progress_${model.surahNumber}', json.encode(model.toJson()));
        }

        // Set last read to the most recently updated item
        final last = syncedProgress.isNotEmpty ? syncedProgress.first : null;
        if (last != null) {
          await box.put('last_read', json.encode(last.toJson()));
        }

        state = state.copyWith(
          progressList: syncedProgress,
          lastRead: last,
        );
      }
    } catch (_) {}
  }
}
