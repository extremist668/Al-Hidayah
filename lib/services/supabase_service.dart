import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:islamic_app/config/app_config.dart';

class SupabaseService {
  static final SupabaseService instance = SupabaseService._internal();
  SupabaseService._internal();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    try {
      // Avoid failing if the user hasn't configured correct Supabase URL or Key yet
      if (AppConfig.supabaseUrl.contains('your-supabase-url') || 
          AppConfig.supabaseAnonKey.contains('your-supabase-anon-key')) {
        _initialized = false;
        return;
      }

      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
      );
      _initialized = true;
    } catch (e) {
      _initialized = false;
    }
  }

  SupabaseClient get client {
    if (!_initialized) {
      throw Exception('Supabase is not initialized. Check your credentials in AppConfig.');
    }
    return Supabase.instance.client;
  }
}
