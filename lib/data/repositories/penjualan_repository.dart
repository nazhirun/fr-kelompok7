import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:myatk/core/config/api_config.dart';
import 'package:myatk/data/api/api_client.dart';
import 'package:myatk/data/models/api_response_model.dart';
import 'package:myatk/data/models/penjualan_model.dart';

class PenjualanRepository {
  final ApiClient _apiClient = ApiClient();

  // Mendapatkan semua data penjualan
  Future<ApiResponse<List<PenjualanModel>>> getPenjualan() async {
    try {
      final response = await _apiClient.get(ApiConfig.penjualan);
      
      final List<dynamic> data = response.data['data'];
      final List<PenjualanModel> penjualan = data.map((json) => PenjualanModel.fromJson(json)).toList();
      
      return ApiResponse(
        success: response.data['success'] ?? false,
        message: response.data['message'] ?? 'Berhasil mendapatkan data penjualan',
        data: penjualan,
      );
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          log("Error getPenjualan: ${e.response?.statusCode} - ${e.response?.data}");
          return ApiResponse(
            success: false,
            message: e.response?.data['message'] ?? 'Gagal mendapatkan data penjualan',
          );
        }
      }
      log("Error getPenjualan: $e");
      return ApiResponse(success: false, message: 'Terjadi kesalahan jaringan');
    }
  }

  // Mendapatkan detail penjualan
  Future<ApiResponse<PenjualanModel>> getDetailPenjualan(int id) async {
    try {
      final response = await _apiClient.get('${ApiConfig.penjualan}/$id');
      
      final PenjualanModel penjualan = PenjualanModel.fromJson(response.data['data']);
      
      return ApiResponse(
        success: response.data['success'] ?? false,
        message: response.data['message'] ?? 'Berhasil mendapatkan detail penjualan',
        data: penjualan,
      );
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          log("Error getDetailPenjualan: ${e.response?.statusCode} - ${e.response?.data}");
          return ApiResponse(
            success: false,
            message: e.response?.data['message'] ?? 'Gagal mendapatkan detail penjualan',
          );
        }
      }
      log("Error getDetailPenjualan: $e");
      return ApiResponse(success: false, message: 'Terjadi kesalahan jaringan');
    }
  }

  // Menambah penjualan baru
  Future<ApiResponse<PenjualanModel>> tambahPenjualan(PenjualanRequestModel requestModel) async {
    try {
      // Log request untuk debugging
      final requestData = requestModel.toJson();
      log("Request tambahPenjualan: $requestData");

      final response = await _apiClient.post(
        ApiConfig.penjualan,
        data: requestData,
      );
      
      final PenjualanModel penjualan = PenjualanModel.fromJson(response.data['data']);
      
      return ApiResponse(
        success: response.data['success'] ?? false,
        message: response.data['message'] ?? 'Penjualan berhasil disimpan',
        data: penjualan,
      );
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          log("Error tambahPenjualan: ${e.response?.statusCode} - ${e.response?.data}");
          return ApiResponse(
            success: false,
            message: e.response?.data['message'] ?? 'Gagal menyimpan penjualan',
          );
        }
      }
      log("Error tambahPenjualan: $e");
      return ApiResponse(success: false, message: 'Terjadi kesalahan jaringan');
    }
  }
  
  // Checkout multiple barang (menggunakan multiple request ke endpoint penjualan)
  Future<ApiResponse<List<PenjualanModel>>> checkout(CheckoutRequestModel requestModel) async {
    try {
      List<PenjualanModel> results = [];
      
      // Lakukan request untuk setiap item
      for (var item in requestModel.items) {
        // Pastikan qty lebih dari 0
        if (item.qty <= 0) continue;
        
        final penjualanRequest = PenjualanRequestModel(
          tanggal: requestModel.tanggal,
          faktur: requestModel.faktur,
          barangId: item.barangId,
          qty: item.qty,
        );
        
        log("Processing checkout item: barangId=${item.barangId}, qty=${item.qty}");
        final response = await tambahPenjualan(penjualanRequest);
        
        if (response.success && response.data != null) {
          results.add(response.data!);
        } else {
          // Jika salah satu request gagal, kembalikan error
          log("Checkout item failed: ${response.message}");
          return ApiResponse(
            success: false,
            message: "Gagal checkout item: ${response.message}",
          );
        }
      }
      
      if (results.isEmpty) {
        return ApiResponse(
          success: false,
          message: "Tidak ada item yang berhasil diproses",
        );
      }
      
      return ApiResponse(
        success: true,
        message: 'Checkout berhasil',
        data: results,
      );
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          log("Error checkout: ${e.response?.statusCode} - ${e.response?.data}");
          return ApiResponse(
            success: false,
            message: e.response?.data['message'] ?? 'Gagal melakukan checkout',
          );
        }
      }
      log("Error checkout: $e");
      return ApiResponse(success: false, message: 'Terjadi kesalahan jaringan');
    }
  }

  // Mengupdate penjualan
  Future<ApiResponse<PenjualanModel>> updatePenjualan(int id, Map<String, dynamic> data) async {
    try {
      log("Request updatePenjualan: id=$id, data=$data");
      final response = await _apiClient.put(
        '${ApiConfig.penjualan}/$id',
        data: data,
      );
      
      final PenjualanModel penjualan = PenjualanModel.fromJson(response.data['data']);
      
      return ApiResponse(
        success: response.data['success'] ?? false,
        message: response.data['message'] ?? 'Penjualan berhasil diupdate',
        data: penjualan,
      );
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          log("Error updatePenjualan: ${e.response?.statusCode} - ${e.response?.data}");
          return ApiResponse(
            success: false,
            message: e.response?.data['message'] ?? 'Gagal mengupdate penjualan',
          );
        }
      }
      log("Error updatePenjualan: $e");
      return ApiResponse(success: false, message: 'Terjadi kesalahan jaringan');
    }
  }

  // Menghapus penjualan
  Future<ApiResponse<void>> hapusPenjualan(int id) async {
    try {
      log("Request hapusPenjualan: id=$id");
      final response = await _apiClient.delete('${ApiConfig.penjualan}/$id');
      
      return ApiResponse(
        success: response.data['success'] ?? false,
        message: response.data['message'] ?? 'Penjualan berhasil dihapus',
      );
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          log("Error hapusPenjualan: ${e.response?.statusCode} - ${e.response?.data}");
          return ApiResponse(
            success: false,
            message: e.response?.data['message'] ?? 'Gagal menghapus penjualan',
          );
        }
      }
      log("Error hapusPenjualan: $e");
      return ApiResponse(success: false, message: 'Terjadi kesalahan jaringan');
    }
  }
} 