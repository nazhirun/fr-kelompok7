class AppConstants {
  // Shared Preferences / Secure Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String isDarkModeKey = 'is_dark_mode';
  
  // OTP Configuration
  static const int otpLength = 6;
  static const int otpTimeoutInMinutes = 10;
  
  // Validation Regexes
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&#])[A-Za-z\d@$!%*?&#]{8,}$',
  );
  
  // Animation Durations
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration pageFadeTransition = Duration(milliseconds: 300);
} 