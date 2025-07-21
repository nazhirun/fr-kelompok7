import 'package:flutter/material.dart';
import 'package:myatk/data/models/barang_model.dart';
import 'package:myatk/data/repositories/barang_repository.dart';

class BarangProvider with ChangeNotifier {
  final BarangRepository _barangRepository = BarangRepository();
  
  List<BarangModel> _listBarang = [];
  BarangModel? _detailBarang;
  String _errorMessage = '';
  bool _loading = false;
  Map<String, List<BarangModel>> _kategoriBarang = {};
  List<BarangModel> _keranjang = [];
  String _searchQuery = '';
  String _selectedKategori = '';
  
  // Tambah variabel untuk filter
  List<String> _selectedKategories = [];
  RangeValues? _priceRange;
  bool _onlyInStock = false;
  String _sortBy = 'default'; // 'default', 'price_asc', 'price_desc', 'name_asc', 'name_desc'
  
  // Getters
  List<BarangModel> get listBarang {
    List<BarangModel> filteredList = _listBarang;
    
    // Filter berdasarkan search query
    if (_searchQuery.isNotEmpty) {
      filteredList = _searchBarang(filteredList, _searchQuery);
    }
    
    // Filter berdasarkan kategori lama (untuk kompatibilitas)
    if (_selectedKategori.isNotEmpty) {
      filteredList = _filterByKategori(filteredList, _selectedKategori);
    }
    
    // Filter berdasarkan multi kategori baru
    if (_selectedKategories.isNotEmpty) {
      filteredList = _filterByMultiKategori(filteredList, _selectedKategories);
    }
    
    // Filter berdasarkan rentang harga
    if (_priceRange != null) {
      filteredList = _filterByPriceRange(filteredList, _priceRange!);
    }
    
    // Filter hanya barang dengan stok > 0
    if (_onlyInStock) {
      filteredList = filteredList.where((item) => item.stok > 0).toList();
    }
    
    // Urutkan hasil
    filteredList = _sortItems(filteredList, _sortBy);
    
    return filteredList;
  }
  
  BarangModel? get detailBarang => _detailBarang;
  String get errorMessage => _errorMessage;
  bool get loading => _loading;
  Map<String, List<BarangModel>> get kategoriBarang => _kategoriBarang;
  List<BarangModel> get keranjang => _keranjang;
  int get jumlahItemKeranjang => _keranjang.fold(0, (sum, item) => sum + item.jumlahKeranjang);
  int get totalHargaKeranjang => _keranjang.fold(0, (sum, item) => sum + (item.harga * item.jumlahKeranjang));
  String get searchQuery => _searchQuery;
  String get selectedKategori => _selectedKategori;
  
  // Getter untuk filter baru
  List<String> get selectedKategories => _selectedKategories;
  RangeValues? get priceRange => _priceRange;
  bool get onlyInStock => _onlyInStock;
  String get sortBy => _sortBy;
  
  // Getter untuk rentang harga min dan max
  int get minPrice => _listBarang.isEmpty 
      ? 0 
      : _listBarang.map((e) => e.harga).reduce((a, b) => a < b ? a : b);
  
  int get maxPrice => _listBarang.isEmpty 
      ? 1000000 
      : _listBarang.map((e) => e.harga).reduce((a, b) => a > b ? a : b);
  
  // Mendapatkan semua barang
  Future<void> getBarang() async {
    _loading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final response = await _barangRepository.getBarang();
      
      if (response.success && response.data != null) {
        _listBarang = response.data!;
        _updateKategoriBarang();
        
        // Inisialisasi rentang harga jika belum diatur
        if (_priceRange == null) {
          _priceRange = RangeValues(minPrice.toDouble(), maxPrice.toDouble());
        }
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
  
  // Mendapatkan detail barang
  Future<void> getDetailBarang(int id) async {
    _loading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final response = await _barangRepository.getDetailBarang(id);
      
      if (response.success && response.data != null) {
        _detailBarang = response.data;
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
  
  // Memperbarui kategori barang
  void _updateKategoriBarang() {
    _kategoriBarang.clear();
    
    for (final barang in _listBarang) {
      if (!_kategoriBarang.containsKey(barang.kategori)) {
        _kategoriBarang[barang.kategori] = [];
      }
      _kategoriBarang[barang.kategori]!.add(barang);
    }
    
    notifyListeners();
  }
  
  // Mencari barang berdasarkan query
  List<BarangModel> _searchBarang(List<BarangModel> barang, String query) {
    final lowercaseQuery = query.toLowerCase();
    return barang.where((item) => 
        item.nama.toLowerCase().contains(lowercaseQuery) ||
        item.kategori.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }
  
  // Filter barang berdasarkan kategori
  List<BarangModel> _filterByKategori(List<BarangModel> barang, String kategori) {
    return barang.where((item) => item.kategori == kategori).toList();
  }
  
  // Filter barang berdasarkan multi-kategori
  List<BarangModel> _filterByMultiKategori(List<BarangModel> barang, List<String> kategories) {
    return barang.where((item) => kategories.contains(item.kategori)).toList();
  }
  
  // Filter barang berdasarkan rentang harga
  List<BarangModel> _filterByPriceRange(List<BarangModel> barang, RangeValues range) {
    return barang.where((item) => 
        item.harga >= range.start && item.harga <= range.end
    ).toList();
  }
  
  // Urutkan barang
  List<BarangModel> _sortItems(List<BarangModel> barang, String sortBy) {
    switch (sortBy) {
      case 'price_asc':
        return List.from(barang)..sort((a, b) => a.harga.compareTo(b.harga));
      case 'price_desc':
        return List.from(barang)..sort((a, b) => b.harga.compareTo(a.harga));
      case 'name_asc':
        return List.from(barang)..sort((a, b) => a.nama.compareTo(b.nama));
      case 'name_desc':
        return List.from(barang)..sort((a, b) => b.nama.compareTo(a.nama));
      default:
        return barang;
    }
  }
  
  // Set query pencarian
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
  
  // Set kategori yang dipilih (versi lama, untuk kompatibilitas)
  void setSelectedKategori(String kategori) {
    _selectedKategori = kategori;
    notifyListeners();
  }
  
  // Set kategori-kategori yang dipilih (baru, multi-kategori)
  void toggleKategori(String kategori) {
    if (_selectedKategories.contains(kategori)) {
      _selectedKategories.remove(kategori);
    } else {
      _selectedKategories.add(kategori);
    }
    notifyListeners();
  }
  
  // Set rentang harga
  void setPriceRange(RangeValues range) {
    _priceRange = range;
    notifyListeners();
  }
  
  // Set filter hanya barang dengan stok
  void setOnlyInStock(bool value) {
    _onlyInStock = value;
    notifyListeners();
  }
  
  // Set pengurutan
  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }
  
  // Reset semua filter
  void resetFilters() {
    _searchQuery = '';
    _selectedKategori = '';
    _selectedKategories = [];
    _priceRange = RangeValues(minPrice.toDouble(), maxPrice.toDouble());
    _onlyInStock = false;
    _sortBy = 'default';
    notifyListeners();
  }
  
  // Tambah barang ke keranjang
  void tambahKeKeranjang(BarangModel barang) {
    final index = _keranjang.indexWhere((item) => item.id == barang.id);
    
    if (index >= 0) {
      // Jika barang sudah ada di keranjang, tambahkan jumlah
      final updatedBarang = _keranjang[index];
      
      // Cek apakah jumlah yang ditambahkan tidak melebihi stok
      if (updatedBarang.jumlahKeranjang < updatedBarang.stok) {
        updatedBarang.jumlahKeranjang++;
        _keranjang[index] = updatedBarang;
      }
    } else {
      // Jika barang belum ada di keranjang, tambahkan barang baru
      if (barang.stok > 0) {
        final newBarang = BarangModel(
          id: barang.id,
          nama: barang.nama,
          harga: barang.harga,
          stok: barang.stok,
          gambar: barang.gambar,
          keterangan: barang.keterangan,
          kategori: barang.kategori,
          createdAt: barang.createdAt,
          updatedAt: barang.updatedAt,
          jumlahKeranjang: 1,
        );
        _keranjang.add(newBarang);
      }
    }
    
    notifyListeners();
  }
  
  // Kurangi jumlah barang di keranjang
  void kurangiDariKeranjang(BarangModel barang) {
    final index = _keranjang.indexWhere((item) => item.id == barang.id);
    
    if (index >= 0) {
      final updatedBarang = _keranjang[index];
      
      if (updatedBarang.jumlahKeranjang > 1) {
        // Kurangi jumlah jika lebih dari 1
        updatedBarang.jumlahKeranjang--;
        _keranjang[index] = updatedBarang;
      } else {
        // Hapus dari keranjang jika jumlahnya 1
        _keranjang.removeAt(index);
      }
      
      notifyListeners();
    }
  }
  
  // Hapus barang dari keranjang
  void hapusDariKeranjang(BarangModel barang) {
    _keranjang.removeWhere((item) => item.id == barang.id);
    notifyListeners();
  }
  
  // Kosongkan keranjang
  void kosongkanKeranjang() {
    _keranjang.clear();
    notifyListeners();
  }
} 