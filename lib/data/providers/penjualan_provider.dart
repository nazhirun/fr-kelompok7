import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myatk/data/models/barang_model.dart';
import 'package:myatk/data/models/penjualan_model.dart';
import 'package:myatk/data/repositories/penjualan_repository.dart';

class PenjualanProvider with ChangeNotifier {
  final PenjualanRepository _penjualanRepository = PenjualanRepository();
  
  List<PenjualanModel> _listPenjualan = [];
  PenjualanModel? _detailPenjualan;
  String _errorMessage = '';
  bool _loading = false;
  bool _checkoutLoading = false;
  List<PenjualanModel> _lastCheckout = [];
  
  // Getters
  List<PenjualanModel> get listPenjualan => _listPenjualan;
  PenjualanModel? get detailPenjualan => _detailPenjualan;
  String get errorMessage => _errorMessage;
  bool get loading => _loading;
  bool get checkoutLoading => _checkoutLoading;
  List<PenjualanModel> get lastCheckout => _lastCheckout;
  
  // Mendapatkan semua penjualan
  Future<void> getPenjualan() async {
    _loading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      log("Getting all penjualan...");
      final response = await _penjualanRepository.getPenjualan();
      
      if (response.success && response.data != null) {
        _listPenjualan = response.data!;
        log("Get penjualan success: ${_listPenjualan.length} items");
      } else {
        _errorMessage = response.message;
        log("Get penjualan failed: ${response.message}");
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      log("Error getPenjualan: $e");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
  
  // Mendapatkan detail penjualan
  Future<void> getDetailPenjualan(int id) async {
    _loading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      log("Getting penjualan detail: $id");
      final response = await _penjualanRepository.getDetailPenjualan(id);
      
      if (response.success && response.data != null) {
        _detailPenjualan = response.data;
        log("Get detail penjualan success: ${_detailPenjualan?.id}");
      } else {
        _errorMessage = response.message;
        log("Get detail penjualan failed: ${response.message}");
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      log("Error getDetailPenjualan: $e");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
  
  // Menambah penjualan baru
  Future<bool> tambahPenjualan(PenjualanRequestModel requestModel) async {
    _loading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      log("Adding new penjualan: barang_id=${requestModel.barangId}, qty=${requestModel.qty}");
      final response = await _penjualanRepository.tambahPenjualan(requestModel);
      
      if (response.success && response.data != null) {
        _listPenjualan = [..._listPenjualan, response.data!];
        log("Tambah penjualan success: ${response.data!.id}");
        return true;
      } else {
        _errorMessage = response.message;
        log("Tambah penjualan failed: ${response.message}");
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      log("Error tambahPenjualan: $e");
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
  
  // Checkout keranjang dengan fallback mode
  Future<bool> checkout(List<BarangModel> keranjangItems) async {
    if (keranjangItems.isEmpty) {
      _errorMessage = 'Keranjang kosong';
      log("Checkout failed: Keranjang kosong");
      notifyListeners();
      return false;
    }
    
    _checkoutLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      // Generate faktur
      final faktur = 'INV-${DateTime.now().millisecondsSinceEpoch}';
      final tanggal = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      log("Starting checkout with faktur: $faktur, tanggal: $tanggal");
      log("Items in cart: ${keranjangItems.length}");
      
      // Buat items untuk checkout
      final items = keranjangItems.map((item) => CheckoutItemModel(
        barangId: item.id,
        qty: item.jumlahKeranjang,
      )).toList();
      
      // Log each item
      for (var i = 0; i < items.length; i++) {
        log("Checkout item $i: barang_id=${items[i].barangId}, qty=${items[i].qty}");
      }
      
      // Buat request model
      final requestModel = CheckoutRequestModel(
        tanggal: tanggal,
        faktur: faktur,
        items: items,
      );
      
      final response = await _penjualanRepository.checkout(requestModel);
      
      if (response.success && response.data != null) {
        // Simpan data checkout terakhir
        _lastCheckout = response.data!;
        log("Checkout success: ${_lastCheckout.length} items processed");
        
        // Refresh data penjualan
        await getPenjualan();
        
        return true;
      } else {
        log("Checkout failed with bulk method: ${response.message}. Trying fallback method...");
        
        // Fallback: Coba checkout satu per satu
        final fallbackResult = await _checkoutFallback(keranjangItems, faktur, tanggal);
        
        if (fallbackResult) {
          log("Checkout success using fallback method");
          return true;
        } else {
          _errorMessage = 'Checkout gagal: $_errorMessage';
          log("Checkout failed using both methods");
          return false;
        }
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan saat checkout. Silakan coba lagi.';
      log("Error checkout: $e");
      return false;
    } finally {
      _checkoutLoading = false;
      notifyListeners();
    }
  }
  
  // Metode fallback untuk checkout item satu per satu
  Future<bool> _checkoutFallback(List<BarangModel> items, String faktur, String tanggal) async {
    log("Using fallback checkout method for ${items.length} items");
    _lastCheckout = [];
    
    try {
      for (var item in items) {
        if (item.jumlahKeranjang <= 0) {
          log("Skipping item ${item.id} (${item.nama}) because qty <= 0");
          continue;
        }
        
        log("Processing item ${item.id} (${item.nama}) with qty ${item.jumlahKeranjang}");
        
        final requestModel = PenjualanRequestModel(
          tanggal: tanggal,
          faktur: faktur,
          barangId: item.id,
          qty: item.jumlahKeranjang,
        );
        
        final response = await _penjualanRepository.tambahPenjualan(requestModel);
        
        if (response.success && response.data != null) {
          _lastCheckout.add(response.data!);
          log("Item ${item.id} (${item.nama}) processed successfully");
        } else {
          log("Failed to process item ${item.id} (${item.nama}): ${response.message}");
          _errorMessage = 'Gagal memproses ${item.nama}: ${response.message}';
          // Continue processing other items
        }
      }
      
      // Refresh data penjualan
      await getPenjualan();
      
      // Jika tidak ada item yang berhasil di-checkout
      if (_lastCheckout.isEmpty) {
        _errorMessage = 'Tidak ada barang yang berhasil diproses';
        log("Fallback checkout failed: no items processed successfully");
        return false;
      }
      
      log("Fallback checkout completed: ${_lastCheckout.length}/${items.length} items processed");
      return true;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan saat checkout. Silakan coba lagi.';
      log("Error in fallback checkout: $e");
      return false;
    }
  }
  
  // Checkout single item (alternatif)
  Future<bool> checkoutSingleItem(BarangModel barang) async {
    _checkoutLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      // Generate faktur
      final faktur = 'INV-${DateTime.now().millisecondsSinceEpoch}';
      final tanggal = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      log("Starting single item checkout: id=${barang.id}, name=${barang.nama}, qty=${barang.jumlahKeranjang}");
      
      // Buat request model
      final requestModel = PenjualanRequestModel(
        tanggal: tanggal,
        faktur: faktur,
        barangId: barang.id,
        qty: barang.jumlahKeranjang,
      );
      
      final response = await _penjualanRepository.tambahPenjualan(requestModel);
      
      if (response.success && response.data != null) {
        // Simpan data checkout terakhir
        _lastCheckout = [response.data!];
        log("Single checkout success: item id=${response.data!.id}");
        
        // Refresh data penjualan
        await getPenjualan();
        
        return true;
      } else {
        _errorMessage = response.message;
        log("Single checkout failed: ${response.message}");
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      log("Error checkoutSingleItem: $e");
      return false;
    } finally {
      _checkoutLoading = false;
      notifyListeners();
    }
  }
  
  // Mengupdate penjualan
  Future<bool> updatePenjualan(int id, int qty) async {
    _loading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      log("Updating penjualan: id=$id, qty=$qty");
      final response = await _penjualanRepository.updatePenjualan(id, {'qty': qty});
      
      if (response.success && response.data != null) {
        // Update data di list
        final index = _listPenjualan.indexWhere((item) => item.id == id);
        if (index >= 0) {
          _listPenjualan[index] = response.data!;
        }
        
        // Update data detail jika sedang melihat detail yang diupdate
        if (_detailPenjualan?.id == id) {
          _detailPenjualan = response.data;
        }
        
        log("Update penjualan success: id=$id");
        return true;
      } else {
        _errorMessage = response.message;
        log("Update penjualan failed: ${response.message}");
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      log("Error updatePenjualan: $e");
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
  
  // Menghapus penjualan
  Future<bool> hapusPenjualan(int id) async {
    _loading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      log("Deleting penjualan: id=$id");
      final response = await _penjualanRepository.hapusPenjualan(id);
      
      if (response.success) {
        // Hapus data dari list
        _listPenjualan.removeWhere((item) => item.id == id);
        
        // Reset detail jika sedang melihat detail yang dihapus
        if (_detailPenjualan?.id == id) {
          _detailPenjualan = null;
        }
        
        log("Delete penjualan success: id=$id");
        return true;
      } else {
        _errorMessage = response.message;
        log("Delete penjualan failed: ${response.message}");
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      log("Error hapusPenjualan: $e");
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
  
  // Reset error message
  void resetErrorMessage() {
    _errorMessage = '';
    notifyListeners();
  }
  
  // Reset last checkout data
  void resetLastCheckout() {
    _lastCheckout = [];
    notifyListeners();
  }
} 