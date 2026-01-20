import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../supabase_config.dart';

class AuthService extends GetxService {
  // Get current user
  User? get currentUser => supabase.auth.currentUser;

  // Get current user ID
  String? get currentUserId => supabase.auth.currentUser?.id;

  // Current user stream
  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;

  // Register with email and password
  Future<AuthResponse?> registerWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': displayName},
      );

      if (response.user == null) {
        throw Exception('Gagal membuat akun');
      }

      return response;
    } on AuthException catch (e) {
      String message = 'Terjadi kesalahan';
      
      switch (e.statusCode) {
        case '400':
          message = 'Email atau password tidak valid';
          break;
        case '422':
          message = 'Email sudah terdaftar';
          break;
        default:
          message = e.message;
      }
      
      throw Exception(message);
    } catch (e) {
      throw Exception('Gagal mendaftar: ${e.toString()}');
    }
  }

  // Sign in with email and password
  Future<AuthResponse?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Login gagal');
      }

      return response;
    } on AuthException catch (e) {
      String message = 'Terjadi kesalahan';
      
      if (e.message.contains('Invalid login credentials')) {
        message = 'Email atau password salah';
      } else if (e.message.contains('Email not confirmed')) {
        message = 'Email belum diverifikasi';
      } else {
        message = e.message;
      }
      
      throw Exception(message);
    } catch (e) {
      throw Exception('Gagal login: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Gagal mengirim email reset: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      throw Exception('Gagal logout: ${e.toString()}');
    }
  }

  // Get user data
  Future<UserModel?> getUserData(String userId) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      return UserModel(
        id: user.id,
        email: user.email ?? '',
        displayName: user.userMetadata?['display_name'] ?? '',
        createdAt: DateTime.parse(user.createdAt),
      );
    } catch (e) {
      throw Exception('Gagal mengambil data user: ${e.toString()}');
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String userId,
    required String displayName,
  }) async {
    try {
      await supabase.auth.updateUser(
        UserAttributes(
          data: {'display_name': displayName},
        ),
      );
    } catch (e) {
      throw Exception('Gagal update profil: ${e.toString()}');
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      // Note: Supabase doesn't have direct delete user from client
      // You need to implement this via Edge Function or Admin API
      // For now, we'll just sign out
      await signOut();
      throw Exception('Fitur hapus akun belum tersedia. Silakan hubungi admin.');
    } catch (e) {
      throw Exception('Gagal menghapus akun: ${e.toString()}');
    }
  }
}
