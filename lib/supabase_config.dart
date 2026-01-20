import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // TODO: Ganti dengan credentials Supabase Anda
  // Dapatkan dari: Supabase Dashboard > Settings > API
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}

// Helper untuk akses Supabase client
final supabase = Supabase.instance.client;
