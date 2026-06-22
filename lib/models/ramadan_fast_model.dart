class RamadanFastModel {
  final int fastDay; // Day of Ramadan (1-30)
  final String date;  // Format: yyyy-MM-dd
  final bool isFasting;
  final int quranPagesRead;
  final double charityAmount;
  final bool sehriReminder;
  final bool iftarReminder;

  RamadanFastModel({
    required this.fastDay,
    required this.date,
    required this.isFasting,
    required this.quranPagesRead,
    required this.charityAmount,
    required this.sehriReminder,
    required this.iftarReminder,
  });

  Map<String, dynamic> toJson() {
    return {
      'fast_day': fastDay,
      'date': date,
      'is_fasting': isFasting,
      'quran_pages_read': quranPagesRead,
      'charity_amount': charityAmount,
      'sehri_reminder': sehriReminder,
      'iftar_reminder': iftarReminder,
    };
  }

  factory RamadanFastModel.fromJson(Map<String, dynamic> json) {
    return RamadanFastModel(
      fastDay: json['fast_day'] ?? 1,
      date: json['date'] ?? '',
      isFasting: json['is_fasting'] ?? true,
      quran_pages_read: json['quran_pages_read'] ?? 0,
      charityAmount: (json['charity_amount'] ?? 0.0).toDouble(),
      sehriReminder: json['sehri_reminder'] ?? true,
      iftarReminder: json['iftar_reminder'] ?? true,
    );
  }

  RamadanFastModel copyWith({
    int? fastDay,
    String? date,
    bool? isFasting,
    int? quranPagesRead,
    double? charityAmount,
    bool? sehriReminder,
    bool? iftarReminder,
  }) {
    return RamadanFastModel(
      fastDay: fastDay ?? this.fastDay,
      date: date ?? this.date,
      isFasting: isFasting ?? this.isFasting,
      quran_pages_read: quranPagesRead ?? this.quranPagesRead,
      charityAmount: charityAmount ?? this.charityAmount,
      sehriReminder: sehriReminder ?? this.sehriReminder,
      iftarReminder: iftarReminder ?? this.iftarReminder,
    );
  }
}
