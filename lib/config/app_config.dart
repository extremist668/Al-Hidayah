// Secure config class for credentials and constants. No .env files as per rules.
class AppConfig {
  static const String appName = 'Al-Hidayah';
  
  // Supabase Configuration
  // Note: Replace these placeholders with your actual production credentials
  static const String supabaseUrl = 'https://your-supabase-url.supabase.co';
  static const String supabaseAnonKey = 'your-supabase-anon-key-here-get-from-dashboard';

  // API Endpoints
  static const String prayerTimesBaseUrl = 'https://api.aladhan.com/v1';
  static const String quranApiBaseUrl = 'https://api.quran.com/api/v4';

  // Cache/Hive Box Names
  static const String settingsBoxName = 'settings_box';
  static const String prayerTimesBoxName = 'prayer_times_box';
  static const String prayerTrackerBoxName = 'prayer_tracker_box';
  static const String quranProgressBoxName = 'quran_progress_box';
  static const String ramadanTrackerBoxName = 'ramadan_tracker_box';
  static const String zakatHistoryBoxName = 'zakat_history_box';

  // Gold and Silver Nisab rates (Free API/static backup fallback)
  // Standard thresholds: 87.48g gold, 612.36g silver
  static const double goldNisabThresholdGrams = 87.48;
  static const double silverNisabThresholdGrams = 612.36;
  
  // Default fallback gold price per gram in USD
  static const double fallbackGoldPricePerGram = 75.0; 
  static const double fallbackSilverPricePerGram = 0.90;
}
