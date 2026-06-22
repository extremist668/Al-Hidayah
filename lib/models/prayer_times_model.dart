class PrayerTimesModel {
  final String date;
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String timezone;
  final String calculationMethod;

  PrayerTimesModel({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.timezone,
    required this.calculationMethod,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'fajr': fajr,
      'sunrise': sunrise,
      'dhuhr': dhuhr,
      'asr': asr,
      'maghrib': maghrib,
      'isha': isha,
      'timezone': timezone,
      'calculationMethod': calculationMethod,
    };
  }

  factory PrayerTimesModel.fromJson(Map<String, dynamic> json) {
    return PrayerTimesModel(
      date: json['date'] ?? '',
      fajr: json['fajr'] ?? '',
      sunrise: json['sunrise'] ?? '',
      dhuhr: json['dhuhr'] ?? '',
      asr: json['asr'] ?? '',
      maghrib: json['maghrib'] ?? '',
      isha: json['isha'] ?? '',
      timezone: json['timezone'] ?? 'UTC',
      calculationMethod: json['calculationMethod'] ?? 'Custom',
    );
  }

  // Parse Aladhan response format
  factory PrayerTimesModel.fromAladhan(Map<String, dynamic> json) {
    final timings = json['data']['timings'];
    final dateData = json['data']['date']['readable'];
    final meta = json['data']['meta'];
    return PrayerTimesModel(
      date: dateData,
      fajr: _cleanTime(timings['Fajr']),
      sunrise: _cleanTime(timings['Sunrise']),
      dhuhr: _cleanTime(timings['Dhuhr']),
      asr: _cleanTime(timings['Asr']),
      maghrib: _cleanTime(timings['Maghrib']),
      isha: _cleanTime(timings['Isha']),
      timezone: meta['timezone'],
      calculationMethod: meta['method']['name'],
    );
  }

  static String _cleanTime(String rawTime) {
    // Some Aladhan timings append the timezone suffix (e.g. "05:12 (PKT)")
    if (rawTime.contains(' ')) {
      return rawTime.split(' ').first;
    }
    return rawTime;
  }
}
