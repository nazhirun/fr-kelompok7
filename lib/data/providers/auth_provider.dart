import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:myatk/core/constants/app_constants.dart';
import 'package:myatk/data/models/user_model.dart';
import 'package:myatk/data/repositories/auth_repository.dart';
import 'dart:convert';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  registering,
  verifying,
  resetPassword,
  otpVerification,
  passwordReset,
}

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _token;
  String _errorMessage = '';
  bool _loading = false;
  int? _userId;
  String? _expiresAt;
  String? _resetToken;
  String? _resetEmail;

  // Getters
  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get token => _token;
  String get errorMessage => _errorMessage;
  bool get loading => _loading;
  int? get userId => _userId;
  String? get expiresAt => _expiresAt;
  String? get resetToken => _resetToken;
  String? get resetEmail => _resetEmail;

  AuthProvider() {
    _checkIfLoggedIn();
  }

  // Memeriksa apakah pengguna sudah login
  Future<void> _checkIfLoggedIn() async {
    _loading = true;
    notifyListeners();

    try {
      final userJson = await _storage.read(key: AppConstants.userKey);
      final token = await _storage.read(key: AppConstants.tokenKey);

      if (userJson != null && token != null) {
        _user = UserModel.fromJson(json.decode(userJson));
        _token = token;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    _loading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _authRepository.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      if (response.success) {
        _userId = response.userId;
        _expiresAt = response.expiresAt;
        _status = AuthStatus.verifying;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      notifyListeners();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Verify OTP
  Future<bool> verifyOtp({required String otp}) async {
    if (_userId == null) return false;

    _loading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _authRepository.verifyOtp(
        userId: _userId!,
        otp: otp,
      );

      if (response.success) {
        // Hanya mengatur status sebagai unauthenticated agar perlu login ulang
        _status = AuthStatus.unauthenticated;

        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      notifyListeners();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Resend OTP
  Future<bool> resendOtp() async {
    if (_userId == null) return false;

    _loading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _authRepository.resendOtp(userId: _userId!);

      if (response.success) {
        _expiresAt = response.expiresAt;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      notifyListeners();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login({required String email, required String password}) async {
    _loading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _authRepository.login(
        email: email,
        password: password,
      );

      if (response.success && response.data != null && response.token != null) {
        _user = response.data;
        _token = response.token;
        _status = AuthStatus.authenticated;

        // Save user data to storage
        await _storage.write(
          key: AppConstants.userKey,
          value: json.encode(_user!.toJson()),
        );

        // Save token to secure storage
        await _storage.write(
          key: AppConstants.tokenKey,
          value: _token,
        );

        notifyListeners();
        return true;
      } else if (response.verificationRequired == true) {
        _userId = response.userId;
        _expiresAt = response.expiresAt;
        _status = AuthStatus.verifying;
        notifyListeners();
        return false;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      notifyListeners();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Get Profile
  Future<void> getProfile() async {
    _loading = true;
    notifyListeners();

    try {
      final response = await _authRepository.getProfile();

      if (response.success && response.data != null) {
        _user = response.data;

        // Update user data in storage
        await _storage.write(
          key: AppConstants.userKey,
          value: json.encode(_user!.toJson()),
        );
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    _loading = true;
    notifyListeners();

    try {
      await _authRepository.logout();
    } finally {
      // Clear storage
      await _storage.delete(key: AppConstants.userKey);
      await _storage.delete(key: AppConstants.tokenKey);

      // Reset state
      _user = null;
      _token = null;
      _userId = null;
      _expiresAt = null;
      _status = AuthStatus.unauthenticated;

      _loading = false;
      notifyListeners();
    }
  }

  // Forgot Password - Step 1
  Future<bool> forgotPassword({required String email}) async {
    _loading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _authRepository.forgotPassword(email: email);

      if (response.success) {
        _resetEmail = email;
        _expiresAt = response.expiresAt;
        _status = AuthStatus.otpVerification;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      notifyListeners();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Verify Reset OTP - Step 2
  Future<bool> verifyResetOtp({required String otp}) async {
    if (_resetEmail == null) {
      _errorMessage = 'Email tidak ditemukan. Silakan coba lagi dari awal.';
      notifyListeners();
      return false;
    }

    _loading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _authRepository.verifyResetOtp(
        email: _resetEmail!,
        otp: otp,
      );

      if (response.success) {
        _resetToken = response.token;
        print("Reset token received: ${response.token}"); // Debug log
        _status = AuthStatus.passwordReset;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      notifyListeners();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Reset Password - Step 3
  Future<bool> resetPassword({
    required String password,
    required String passwordConfirmation,
  }) async {
    if (_resetEmail == null || _resetToken == null) {
      _errorMessage = 'Sesi reset password tidak valid. Silakan coba lagi dari awal.';
      print("Reset password failed: Email: $_resetEmail, Token: $_resetToken"); // Debug log
      notifyListeners();
      return false;
    }

    _loading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      print("Attempting to reset password with token: $_resetToken"); // Debug log
      final response = await _authRepository.resetPassword(
        email: _resetEmail!,
        token: _resetToken!,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      if (response.success) {
        // Reset data dan status
        _resetToken = null;
        _resetEmail = null;
        _expiresAt = null;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        print("Reset password API error: ${response.message}"); // Debug log
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      print("Reset password exception: $e"); // Debug log
      notifyListeners();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Resend Reset OTP
  Future<bool> resendResetOtp() async {
    if (_resetEmail == null) return false;

    _loading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _authRepository.forgotPassword(email: _resetEmail!);

      if (response.success) {
        _expiresAt = response.expiresAt;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      notifyListeners();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
