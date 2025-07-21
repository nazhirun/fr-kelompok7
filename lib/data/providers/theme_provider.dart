import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:myatk/core/constants/app_constants.dart';

class ThemeProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isDarkMode;

  ThemeProvider({bool isDarkMode = false}) : _isDarkMode = isDarkMode;

  bool get isDarkMode => _isDarkMode;

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    
    // Simpan preferensi tema di secure storage
    await _storage.write(
      key: AppConstants.isDarkModeKey,
      value: _isDarkMode.toString(),
    );
    
    notifyListeners();
  }
  
  // Fungsi untuk memuat tema dari storage saat aplikasi dibuka
  Future<void> loadThemePreference() async {
    try {
      final themeValue = await _storage.read(key: AppConstants.isDarkModeKey);
      if (themeValue != null) {
        _isDarkMode = themeValue == 'true';
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading theme preference: $e');
    }
  }
} 