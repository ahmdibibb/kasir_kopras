import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // TODO: Ganti dengan credentials Supabase Anda
  // Dapatkan dari: Supabase Dashboard > Settings > API
  static const String supabaseUrl = 'https://fuwzneypymegcmhjjnzl.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ1d3puZXlweW1lZ2NtaGpqbnpsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg5MDgxOTMsImV4cCI6MjA4NDQ4NDE5M30.fon132-rpHjNxnubM-iK2agC1OCpk43Lcdsw6jJYmvg';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}

// Helper untuk akses Supabase client
final supabase = Supabase.instance.client;
