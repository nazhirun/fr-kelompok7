import 'package:myatk/core/constants/app_constants.dart';

class AuthValidator {
  // Email validator
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    
    if (!AppConstants.emailRegex.hasMatch(value)) {
      return 'Email tidak valid';
    }
    
    return null;
  }

  // Password validator
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }
    
    if (!AppConstants.passwordRegex.hasMatch(value)) {
      return 'Password harus mengandung huruf besar, huruf kecil, angka, dan simbol';
    }
    
    return null;
  }

  // Confirm password validator
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    
    if (value != password) {
      return 'Password tidak cocok';
    }
    
    return null;
  }

  // Name validator
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    
    if (value.length < 3) {
      return 'Nama minimal 3 karakter';
    }
    
    return null;
  }

  // OTP validator
  static String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kode OTP tidak boleh kosong';
    }
    
    if (value.length != AppConstants.otpLength) {
      return 'Kode OTP harus ${AppConstants.otpLength} digit';
    }
    
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Kode OTP hanya boleh berisi angka';
    }
    
    return null;
  }
} 