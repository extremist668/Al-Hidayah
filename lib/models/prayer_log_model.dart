import 'package:intl/intl.dart';

class PrayerLogModel {
  final String id;
  final String userId;
  final String prayerDate; // Format: yyyy-MM-dd
  final String prayerName; // 'fajr', 'dhuhr', 'asr', 'maghrib', 'isha'
  final String status;     // 'completed', 'missed', 'qaza', 'none'
  final DateTime syncedAt;

  PrayerLogModel({
    required this.id,
    required this.userId,
    required this.prayerDate,
    required this.prayerName,
    required this.status,
    required this.syncedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'prayer_date': prayerDate,
      'prayer_name': prayerName,
      'status': status,
      'synced_at': syncedAt.toIso8601String(),
    };
  }

  factory PrayerLogModel.fromJson(Map<String, dynamic> json) {
    return PrayerLogModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      prayerDate: json['prayer_date'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
      prayerName: json['prayer_name'] ?? '',
      status: json['status'] ?? 'none',
      syncedAt: json['synced_at'] != null 
          ? DateTime.parse(json['synced_at']) 
          : DateTime.now(),
    );
  }

  PrayerLogModel copyWith({
    String? id,
    String? userId,
    String? prayerDate,
    String? prayerName,
    String? status,
    DateTime? syncedAt,
  }) {
    return PrayerLogModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      prayerDate: prayerDate ?? this.prayerDate,
      prayerName: prayerName ?? this.prayerName,
      status: status ?? this.status,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}
