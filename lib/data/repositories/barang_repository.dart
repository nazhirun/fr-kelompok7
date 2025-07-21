import 'package:dio/dio.dart';
import 'package:myatk/core/config/api_config.dart';
import 'package:myatk/data/api/api_client.dart';
import 'package:myatk/data/models/api_response_model.dart';
import 'package:myatk/data/models/barang_model.dart';

class BarangRepository {
  final ApiClient _apiClient = ApiClient();

  // Mendapatkan semua barang
  Future<ApiResponse<List<BarangModel>>> getBarang() async {
    try {
      final response = await _apiClient.get(ApiConfig.barang);
      
      final List<dynamic> data = response.data['data'];
      final List<BarangModel> barang = data.map((json) => BarangModel.fromJson(json)).toList();
      
      return ApiResponse(
        success: response.data['success'] ?? false,
        message: response.data['message'] ?? 'Berhasil mendapatkan data barang',
        data: barang,
      );
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          return ApiResponse(
            success: false,
            message: e.response?.data['message'] ?? 'Gagal mendapatkan data barang',
          );
        }
      }
      return ApiResponse(success: false, message: 'Terjadi kesalahan jaringan');
    }
  }

  // Mendapatkan detail barang berdasarkan ID
  Future<ApiResponse<BarangModel>> getDetailBarang(int id) async {
    try {
      final response = await _apiClient.get('${ApiConfig.barang}/$id');
      
      final BarangModel barang = BarangModel.fromJson(response.data['data']);
      
      return ApiResponse(
        success: response.data['success'] ?? false,
        message: response.data['message'] ?? 'Berhasil mendapatkan detail barang',
        data: barang,
      );
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          return ApiResponse(
            success: false,
            message: e.response?.data['message'] ?? 'Gagal mendapatkan detail barang',
          );
        }
      }
      return ApiResponse(success: false, message: 'Terjadi kesalahan jaringan');
    }
  }
} 