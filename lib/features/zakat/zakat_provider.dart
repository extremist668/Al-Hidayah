import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:islamic_app/config/app_config.dart';
import 'package:islamic_app/features/auth/auth_provider.dart';
import 'package:islamic_app/models/zakat_calculation_model.dart';
import 'package:islamic_app/services/supabase_service.dart';

class ZakatState {
  final bool isLoading;
  final List<ZakatCalculationModel> history;
  final double liveGoldPrice;
  final double liveSilverPrice;

  ZakatState({
    required this.isLoading,
    required this.history,
    required this.liveGoldPrice,
    required this.liveSilverPrice,
  });

  ZakatState copyWith({
    bool? isLoading,
    List<ZakatCalculationModel>? history,
    double? liveGoldPrice,
    double? liveSilverPrice,
  }) {
    return ZakatState(
      isLoading: isLoading ?? this.isLoading,
      history: history ?? this.history,
      liveGoldPrice: liveGoldPrice ?? this.liveGoldPrice,
      liveSilverPrice: liveSilverPrice ?? this.liveSilverPrice,
    );
  }
}

final zakatProvider = StateNotifierProvider<ZakatNotifier, ZakatState>((ref) {
  final authState = ref.watch(authProvider);
  return ZakatNotifier(authState);
});

class ZakatNotifier extends StateNotifier<ZakatState> {
  final AuthState authState;

  ZakatNotifier(this.authState)
      : super(ZakatState(
          isLoading: true,
          history: [],
          liveGoldPrice: AppConfig.fallbackGoldPricePerGram,
          liveSilverPrice: AppConfig.fallbackSilverPricePerGram,
        )) {
    loadZakatData();
  }

  Future<void> loadZakatData() async {
    state = state.copyWith(isLoading: true);
    try {
      final box = await Hive.openBox(AppConfig.zakatHistoryBoxName);
      final List<ZakatCalculationModel> records = [];

      for (var key in box.keys) {
        final item = box.get(key);
        if (item != null) {
          records.add(ZakatCalculationModel.fromJson(
              Map<String, dynamic>.from(json.decode(item))));
        }
      }

      records.sort((a, b) => b.calculationDate.compareTo(a.calculationDate));

      state = state.copyWith(
        isLoading: false,
        history: records,
      );

      if (authState.status == AuthStatus.authenticated) {
        _syncWithSupabase();
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> saveCalculation({
    required double cash,
    required double goldGrams,
    required double silverGrams,
    required double business,
    required double other,
    required double liabilities,
    required String nisabType,
  }) async {
    final double goldVal = goldGrams * state.liveGoldPrice;
    final double silverVal = silverGrams * state.liveSilverPrice;
    final double totalAssets = cash + goldVal + silverVal + business + other;
    final double netAssets = totalAssets - liabilities;

    final double nisabLimit = nisabType == 'gold'
        ? AppConfig.goldNisabThresholdGrams * state.liveGoldPrice
        : AppConfig.silverNisabThresholdGrams * state.liveSilverPrice;

    double calculatedZakat = 0.0;
    if (netAssets >= nisabLimit) {
      calculatedZakat = netAssets * 0.025; // 2.5% standard Zakat rate
    }

    final id = const Uuid().v4();
    final newRecord = ZakatCalculationModel(
      id: id,
      calculationDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      cashAmount: cash,
      goldValue: goldVal,
      silverValue: silverVal,
      businessAssets: business,
      otherAssets: other,
      liabilities: liabilities,
      nisabValue: nisabLimit,
      nisabType: nisabType,
      totalZakat: calculatedZakat,
    );

    try {
      final box = await Hive.openBox(AppConfig.zakatHistoryBoxName);
      await box.put(id, json.encode(newRecord.toJson()));

      final List<ZakatCalculationModel> updatedList = List.from(state.history)..insert(0, newRecord);
      state = state.copyWith(history: updatedList);

      if (authState.status == AuthStatus.authenticated) {
        _syncRecordToSupabase(newRecord);
      }
    } catch (_) {}
  }

  Future<void> _syncRecordToSupabase(ZakatCalculationModel rec) async {
    try {
      if (!SupabaseService.instance.isInitialized) return;
      final client = SupabaseService.instance.client;
      await client.from('zakat_history').insert({
        'id': rec.id,
        'user_id': authState.user?.id,
        'calculation_date': rec.calculationDate,
        'cash_amount': rec.cashAmount,
        'gold_value': rec.goldValue,
        'silver_value': rec.silverValue,
        'business_assets': rec.businessAssets,
        'other_assets': rec.otherAssets,
        'liabilities': rec.liabilities,
        'nisab_value': rec.nisabValue,
        'nisab_type': rec.nisabType,
        'total_zakat': rec.totalZakat,
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
          .from('zakat_history')
          .select()
          .eq('user_id', userId)
          .order('calculation_date', ascending: false);

      if (response != null && response is List && response.isNotEmpty) {
        final box = await Hive.openBox(AppConfig.zakatHistoryBoxName);
        final List<ZakatCalculationModel> syncedRecords = [];

        for (var row in response) {
          final record = ZakatCalculationModel(
            id: row['id'],
            calculationDate: row['calculation_date'],
            cashAmount: (row['cash_amount'] ?? 0.0).toDouble(),
            goldValue: (row['gold_value'] ?? 0.0).toDouble(),
            silverValue: (row['silver_value'] ?? 0.0).toDouble(),
            businessAssets: (row['business_assets'] ?? 0.0).toDouble(),
            otherAssets: (row['other_assets'] ?? 0.0).toDouble(),
            liabilities: (row['liabilities'] ?? 0.0).toDouble(),
            nisabValue: (row['nisab_value'] ?? 0.0).toDouble(),
            nisabType: row['nisab_type'],
            totalZakat: (row['total_zakat'] ?? 0.0).toDouble(),
          );
          
          syncedRecords.add(record);
          await box.put(record.id, json.encode(record.toJson()));
        }

        state = state.copyWith(history: syncedRecords);
      }
    } catch (_) {}
  }
}
