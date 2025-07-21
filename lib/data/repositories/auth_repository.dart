import 'package:dio/dio.dart';
import 'package:myatk/core/config/api_config.dart';
import 'package:myatk/data/api/api_client.dart';
import 'package:myatk/data/api/interceptors/auth_interceptor.dart';
import 'package:myatk/data/models/api_response_model.dart';
import 'package:myatk/data/models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();
  final AuthInterceptor _authInterceptor = AuthInterceptor();

  // Register user
  Future<ApiResponse<UserModel>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      return ApiResponse.fromJson(response.data, UserModel.fromJson);
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          return ApiResponse(
            success: false,
            message: e.response?.data['message'] ?? 'Terjadi kesalahan',
          );
        }
      }
      return ApiResponse(success: false, message: 'Terjadi kesalahan jaringan');
    }
  }

  // Verify OTP
  Future<ApiResponse<UserModel>> verifyOtp({
    required int userId,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.verifyOtp,
        data: {
          'user_id': userId,
          'otp': otp,
        },
      );

      final apiResponse = ApiResponse.fromJson(response.data, UserModel.fromJson);
      
      if (apiResponse.success && apiResponse.token != null) {
        await _authInterceptor.setToken(apiResponse.token!);
      }

      return apiResponse;
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          return ApiResponse(
            success: false,
            message: e.response?.data['message'] ?? 'Kode OTP tidak valid',
          );
        }
      }
      return ApiResponse(success: false, message: 'Terjadi kesalahan jaringan');
    }
  }

  // Resend OTP
  Future<ApiResponse<void>> resendOtp({
    required int userId,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.resendOtp,
        data: {
          'user_id': userId,
        },
      );

      return ApiResponse(
        success: response.data['success'] ?? false,
        message: response.data['message'] ?? 'Kode OTP telah dikirim ulang',
        expiresAt: response.data['expires_at'],
      );
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          return ApiResponse(
            success: false,
            message: e.response?.data['message'] ?? 'Gagal mengirim ulang OTP',
          );
        }
      }
      return ApiResponse(success: false, message: 'Terjadi kesalahan jaringan');
    }
  }

  // Login
  Future<ApiResponse<UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final apiResponse = ApiResponse.fromJson(response.data, UserModel.fromJson);
      
      if (apiResponse.success && apiResponse.token != null) {
        await _authInterceptor.setToken(apiResponse.token!);
      }

      return apiResponse;
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          return ApiResponse(
            success: false,
            message: e.response?.data['message'] ?? 'Email atau password salah',
            userId: e.response?.data['user_id'],
            verificationRequired: e.response?.data['verification_required'],
            expiresAt: e.response?.data['expires_at'],
          );
        }
      }
      return ApiResponse(success: false, message: 'Terjadi kesalahan jaringan');
    }
  }

  // Forgot Password
  Future<ApiResponse<void>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.forgotPassword,
        data: {
          'email': email,
        },
      );

      return ApiResponse(
        success: response.data['success'] ?? false,
        message: response.data['message'] ?? 'Kode OTP telah dikirim ke email Anda',
        expiresAt: response.data['expires_at'],
      );
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          return ApiResponse(
            success: false,
            message: e.response?.data['message'] ?? 'Email tidak ditemukan',
          );
        }
      }
      return ApiResponse(success: false, message: 'Terjadi kesalahan jaringan');
    }
  }

  // Verify Reset OTP
  Future<ApiResponse<void>> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.verifyResetOtp,
        data: {
          'email': email,
          'otp': otp,
        },
      );

      return ApiResponse(
        success: response.data['success'] ?? false,
        message: response.data['message'] ?? 'OTP berhasil diverifikasi',
        token: response.data['reset_token'],
      );
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          return ApiResponse(
            success: false,
            message: e.response?.data['message'] ?? 'Kode OTP tidak valid',
          );
        }
      }
      return ApiResponse(success: false, message: 'Terjadi kesalahan jaringan');
    }
  }

  // Reset Password
  Future<ApiResponse<void>> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.resetPassword,
        data: {
          'email': email,
          'token': token,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      return ApiResponse(
        success: response.data['success'] ?? false,
        message: response.data['message'] ?? 'Password berhasil diubah',
      );
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          return ApiResponse(
            success: false,
            message: e.response?.data['message'] ?? 'Gagal mengubah password',
          );
        }
      }
      return ApiResponse(success: false, message: 'Terjadi kesalahan jaringan');
    }
  }

  // Get profile
  Future<ApiResponse<UserModel>> getProfile() async {
    try {
      final response = await _apiClient.get(ApiConfig.profile);
      return ApiResponse.fromJson(response.data, UserModel.fromJson);
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          return ApiResponse(
            success: false,
            message: e.response?.data['message'] ?? 'Gagal mengambil data profil',
          );
        }
      }
      return ApiResponse(success: false, message: 'Terjadi kesalahan jaringan');
    }
  }

  // Logout
  Future<ApiResponse<void>> logout() async {
    try {
      final response = await _apiClient.post(ApiConfig.logout);
      await _authInterceptor.clearToken();
      return ApiResponse(
        success: response.data['success'] ?? true,
        message: response.data['message'] ?? 'Berhasil logout',
      );
    } catch (e) {
      await _authInterceptor.clearToken();
      return ApiResponse(success: true, message: 'Berhasil logout');
    }
  }
} 