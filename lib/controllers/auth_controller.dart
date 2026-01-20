import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final Rx<User?> _user = Rx<User?>(null);
  User? get user => _user.value;
  bool get isAuthenticated => _user.value != null;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    _authService.authStateChanges.listen((AuthState state) {
      _user.value = state.session?.user;
    });
    // Set initial user
    _user.value = _authService.currentUser;
  }

  // Register
  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _authService.registerWithEmailPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      Get.snackbar(
        'Berhasil',
        'Akun berhasil dibuat',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _authService.signInWithEmailPassword(
        email: email,
        password: password,
      );

      Get.snackbar(
        'Berhasil',
        'Login berhasil',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _authService.resetPassword(email);

      Get.snackbar(
        'Berhasil',
        'Email reset password telah dikirim',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _authService.signOut();
      Get.snackbar(
        'Berhasil',
        'Logout berhasil',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
