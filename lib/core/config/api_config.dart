class ApiConfig {
  static const String baseUrl = 'http://192.168.218.249:8000';
  static const int timeout = 30000;
  static const String apiVersion = '/api';

  // Auth endpoints
  static const String register = '$apiVersion/auth/register';
  static const String verifyOtp = '$apiVersion/auth/verify-otp';
  static const String resendOtp = '$apiVersion/auth/resend-otp';
  static const String login = '$apiVersion/auth/login';
  static const String profile = '$apiVersion/auth/profile';
  static const String logout = '$apiVersion/auth/logout';
  static const String forgotPassword = '$apiVersion/auth/forgot-password';
  static const String verifyResetOtp = '$apiVersion/auth/verify-reset-otp';
  static const String resetPassword = '$apiVersion/auth/reset-password';

  // Barang endpoints
  static const String barang = '$apiVersion/barang';

  // Penjualan endpoints
  static const String penjualan = '$apiVersion/penjualan';
}
