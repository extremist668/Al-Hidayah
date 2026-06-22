class QuranProgressModel {
  final int surahNumber;
  final int lastReadAyah;
  final String surahNameEn;
  final String surahNameAr;
  final double progressPercentage;
  final bool isCompleted;

  QuranProgressModel({
    required this.surahNumber,
    required this.lastReadAyah,
    required this.surahNameEn,
    required this.surahNameAr,
    required this.progressPercentage,
    required this.isCompleted,
  });

  Map<String, dynamic> toJson() {
    return {
      'last_read_surah': surahNumber,
      'last_read_ayah': lastReadAyah,
      'surah_name_en': surahNameEn,
      'surah_name_ar': surahNameAr,
      'progress_percentage': progressPercentage,
      'is_completed': isCompleted,
    };
  }

  factory QuranProgressModel.fromJson(Map<String, dynamic> json) {
    return QuranProgressModel(
      surahNumber: json['last_read_surah'] ?? 1,
      lastReadAyah: json['last_read_ayah'] ?? 1,
      surahNameEn: json['surah_name_en'] ?? 'Al-Fatihah',
      surahNameAr: json['surah_name_ar'] ?? 'الفاتحة',
      progressPercentage: (json['progress_percentage'] ?? 0.0).toDouble(),
      isCompleted: json['is_completed'] ?? false,
    );
  }

  QuranProgressModel copyWith({
    int? surahNumber,
    int? lastReadAyah,
    String? surahNameEn,
    String? surahNameAr,
    double? progressPercentage,
    bool? isCompleted,
  }) {
    return QuranProgressModel(
      surahNumber: surahNumber ?? this.surahNumber,
      lastReadAyah: lastReadAyah ?? this.lastReadAyah,
      surahNameEn: surahNameEn ?? this.surahNameEn,
      surahNameAr: surahNameAr ?? this.surahNameAr,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
