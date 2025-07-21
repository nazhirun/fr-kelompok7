import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:myatk/core/constants/app_constants.dart';
import 'package:flutter/foundation.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Ambil token dari storage
    final token = await _storage.read(key: AppConstants.tokenKey);

    // Jika token ada, tambahkan ke header
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      debugPrint('🔐 Request dengan token: ${options.path}');
    } else {
      debugPrint('⚠️ Request tanpa token: ${options.path}');
    }

    // Lanjutkan request
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle token expired (status code 401)
    if (err.response?.statusCode == 401) {
      debugPrint('🚫 Error 401: Token tidak valid atau kedaluwarsa');
      
      // Jika endpoint bukan untuk login/register, hapus token yang tidak valid
      if (!err.requestOptions.path.contains('login') && 
          !err.requestOptions.path.contains('register')) {
        _handleTokenExpired();
      }
    }

    // Teruskan error
    handler.next(err);
  }

  // Handler untuk token yang kedaluwarsa
  Future<void> _handleTokenExpired() async {
    debugPrint('🔄 Menghapus token yang tidak valid dari storage');
    await clearToken();
    
    // Note: Di sini kita hanya menghapus token
    // Logic untuk logout/redirect diimplementasikan di level UI
  }

  // Metode untuk mengatur token baru
  Future<void> setToken(String token) async {
    await _storage.write(key: AppConstants.tokenKey, value: token);
    debugPrint('✅ Token baru disimpan ke secure storage');
  }

  // Metode untuk menghapus token (logout)
  Future<void> clearToken() async {
    await _storage.delete(key: AppConstants.tokenKey);
    debugPrint('🗑️ Token dihapus dari secure storage');
  }
} 