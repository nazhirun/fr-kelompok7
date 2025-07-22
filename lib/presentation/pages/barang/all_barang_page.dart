import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:myatk/core/theme/app_theme.dart';
import 'package:myatk/data/models/barang_model.dart';
import 'package:myatk/data/providers/barang_provider.dart';
import 'package:myatk/data/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class AllBarangPage extends StatefulWidget {
  const AllBarangPage({Key? key}) : super(key: key);

  @override
  State<AllBarangPage> createState() => _AllBarangPageState();
}

class _AllBarangPageState extends State<AllBarangPage> {
  final TextEditingController _searchController = TextEditingController();
  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BarangProvider>(context, listen: false).getBarang();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final barangProvider = Provider.of<BarangProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    final barang = barangProvider.listBarang;
    final isLoading = barangProvider.loading;
    final kategoriList = barangProvider.kategoriBarang.keys.toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Semua Barang', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark 
                ? [Color(0xFF3F2B63), Color(0xFF2B2440)]
                : [Color(0xFF9C27B0), Color(0xFF6E4A6C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              // ignore: deprecated_member_use
              isDark ? Colors.black.withOpacity(0.6) : Colors.white.withOpacity(0.9),
              BlendMode.dstATop,
            ),
          ),
          gradient: LinearGradient(
            colors: isDark 
              ? [Color(0xFF121212), Color(0xFF1E1E2C)]
              : [Color(0xFFF5F7FA), Color(0xFFEEF2F7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + 16), // Ruang untuk AppBar
            
            // Search Bar
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              height: 46,
              decoration: BoxDecoration(
                color: isDark ? Color(0xFF272042) : Colors.white,
                borderRadius: BorderRadius.circular(23),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Icon(
                      Icons.search, 
                      color: isDark ? Colors.white60 : Colors.grey,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Cari Barang...',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white38 : Colors.grey,
                          fontFamily: AppTheme.fontFamily,
                        ),
                      ),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontFamily: AppTheme.fontFamily,
                      ),
                      onChanged: barangProvider.setSearchQuery,
                    ),
                  ),
                  Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppTheme.primaryGradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(23),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.tune, color: Colors.white),
                      padding: EdgeInsets.zero,
                      onPressed: () => _showFilterModal(context),
                    ),
                  ),
                ],
              ),
            ),

            // Filter Kategori
            Container(
              height: 50,
              margin: EdgeInsets.only(top: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Tombol "Semua"
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(
                      label: 'Semua', 
                      isSelected: barangProvider.selectedKategori.isEmpty && barangProvider.selectedKategories.isEmpty,
                      onSelected: (_) {
                        barangProvider.setSelectedKategori('');
                        
                        // Reset multi kategori jika ada
                        if (barangProvider.selectedKategories.isNotEmpty) {
                          for (String kategori in List.from(barangProvider.selectedKategories)) {
                            barangProvider.toggleKategori(kategori);
                          }
                        }
                      },
                      isDark: isDark,
                    ),
                  ),
                  // Daftar kategori dari provider
                  ...kategoriList.map((kategori) {
                    final isSelectedLegacy = barangProvider.selectedKategori == kategori;
                    final isSelectedMulti = barangProvider.selectedKategories.contains(kategori);
                    final isSelected = isSelectedLegacy || isSelectedMulti;
                    
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildFilterChip(
                        label: kategori,
                        isSelected: isSelected,
                        onSelected: (_) {
                          // Mode kompatibilitas: jika menggunakan filter kategori lama, reset ke mode multi-kategori
                          if (barangProvider.selectedKategori.isNotEmpty) {
                            barangProvider.setSelectedKategori('');
                          }
                          
                          // Toggle kategori di multi-kategori
                          barangProvider.toggleKategori(kategori);
                        },
                        isDark: isDark,
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

            // Produk Grid
            Expanded(
              child: isLoading
                ? Center(child: CircularProgressIndicator())
                : barang.isEmpty
                  ? Center(
                      child: Text('Tidak ada barang yang tersedia'),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: barang.length,
                      itemBuilder: (context, index) {
                        final item = barang[index];
                        return _buildProductItem(context, item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(BuildContext context, BarangModel barang) {
    final barangProvider = Provider.of<BarangProvider>(context, listen: false);
    
    return GestureDetector(
      onTap: () => _showDetailModal(context, barang),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Produk
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: barang.gambar,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey[500]),
                    ),
                  ),
                ),
              ),
            ),
            
            // Informasi Produk
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    barang.nama,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    currencyFormatter.format(barang.harga),
                    style: TextStyle(
                      color: Color(0xFF6E4A6C),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // Tambahkan informasi stok
                  Text(
                    'Stok: ${barang.stok}',
                    style: TextStyle(
                      fontSize: 12,
                      color: barang.stok > 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.add_circle, color: Color(0xFF6E4A6C)),
                  onPressed: () => barangProvider.tambahKeKeranjang(barang),
                  iconSize: 28,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailModal(BuildContext context, BarangModel barang) {
    final barangProvider = Provider.of<BarangProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              
              // Gambar produk
              Container(
                height: 250,
                child: CachedNetworkImage(
                  imageUrl: barang.gambar,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              
              // Informasi produk
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                barang.nama,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Color(0xFF6E4A6C).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                barang.kategori,
                                style: TextStyle(
                                  color: Color(0xFF6E4A6C),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          currencyFormatter.format(barang.harga),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6E4A6C),
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 18,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Stok: ${barang.stok}',
                              style: TextStyle(
                                fontSize: 16,
                                color: barang.stok > 0 ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Deskripsi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          barang.keterangan,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Tombol Tambah ke Keranjang
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, -1),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: barang.stok > 0
                              ? () {
                                  barangProvider.tambahKeKeranjang(barang);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${barang.nama} ditambahkan ke keranjang'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  Navigator.pop(context);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF6E4A6C),
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Tambahkan ke Keranjang',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterModal(BuildContext context) {
    final barangProvider = Provider.of<BarangProvider>(context, listen: false);
    final kategoriList = barangProvider.kategoriBarang.keys.toList();
    
    // Buat variabel lokal untuk menyimpan perubahan sementara
    RangeValues priceRange = barangProvider.priceRange ?? RangeValues(
      barangProvider.minPrice.toDouble(),
      barangProvider.maxPrice.toDouble()
    );
    List<String> selectedKategories = List.from(barangProvider.selectedKategories);
    bool onlyInStock = barangProvider.onlyInStock;
    String sortBy = barangProvider.sortBy;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle bar dan header
                  Container(
                    padding: EdgeInsets.only(top: 12, left: 16, right: 16),
                    child: Column(
                      children: [
                        // Handle bar
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Filter Produk',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  priceRange = RangeValues(
                                    barangProvider.minPrice.toDouble(),
                                    barangProvider.maxPrice.toDouble()
                                  );
                                  selectedKategories = [];
                                  onlyInStock = false;
                                  sortBy = 'default';
                                });
                              },
                              child: Text(
                                'Reset',
                                style: TextStyle(
                                  color: Color(0xFF6E4A6C),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Filter content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Filter Kategori
                          Text(
                            'Kategori',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ...kategoriList.map((kategori) {
                                final isSelected = selectedKategories.contains(kategori);
                                return FilterChip(
                                  label: Text(kategori),
                                  selected: isSelected,
                                  onSelected: (_) {
                                    setState(() {
                                      if (isSelected) {
                                        selectedKategories.remove(kategori);
                                      } else {
                                        selectedKategories.add(kategori);
                                      }
                                    });
                                  },
                                  backgroundColor: Colors.white,
                                  selectedColor: Color(0xFF6E4A6C).withOpacity(0.2),
                                  checkmarkColor: Color(0xFF6E4A6C),
                                  labelStyle: TextStyle(
                                    color: isSelected ? Color(0xFF6E4A6C) : Colors.black87,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                          
                          SizedBox(height: 24),
                          
                          // Filter Harga
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Rentang Harga',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${currencyFormatter.format(priceRange.start.toInt())} - ${currencyFormatter.format(priceRange.end.toInt())}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6E4A6C),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          RangeSlider(
                            min: barangProvider.minPrice.toDouble(),
                            max: barangProvider.maxPrice.toDouble(),
                            values: priceRange,
                            divisions: 20,
                            activeColor: Color(0xFF6E4A6C),
                            inactiveColor: Color(0xFF6E4A6C).withOpacity(0.2),
                            onChanged: (newRange) {
                              setState(() {
                                priceRange = newRange;
                              });
                            },
                          ),
                          
                          SizedBox(height: 24),
                          
                          // Filter Stok
                          Row(
                            children: [
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                  value: onlyInStock,
                                  activeColor: Color(0xFF6E4A6C),
                                  onChanged: (value) {
                                    setState(() {
                                      onlyInStock = value ?? false;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Hanya tampilkan barang dengan stok',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 24),
                          
                          // Pengurutan
                          Text(
                            'Urutkan Berdasarkan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          
                          // Radio untuk pengurutan
                          _buildSortRadio(
                            title: 'Default', 
                            value: 'default', 
                            groupValue: sortBy,
                            onChanged: (value) {
                              setState(() {
                                sortBy = value ?? 'default';
                              });
                            },
                          ),
                          _buildSortRadio(
                            title: 'Harga Terendah', 
                            value: 'price_asc', 
                            groupValue: sortBy,
                            onChanged: (value) {
                              setState(() {
                                sortBy = value ?? 'price_asc';
                              });
                            },
                          ),
                          _buildSortRadio(
                            title: 'Harga Tertinggi', 
                            value: 'price_desc', 
                            groupValue: sortBy,
                            onChanged: (value) {
                              setState(() {
                                sortBy = value ?? 'price_desc';
                              });
                            },
                          ),
                          _buildSortRadio(
                            title: 'Nama A-Z', 
                            value: 'name_asc', 
                            groupValue: sortBy,
                            onChanged: (value) {
                              setState(() {
                                sortBy = value ?? 'name_asc';
                              });
                            },
                          ),
                          _buildSortRadio(
                            title: 'Nama Z-A', 
                            value: 'name_desc', 
                            groupValue: sortBy,
                            onChanged: (value) {
                              setState(() {
                                sortBy = value ?? 'name_desc';
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Tombol Terapkan Filter
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, -1),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // Terapkan filter
                                barangProvider.setPriceRange(priceRange);
                                
                                // Jika multi kategori dipilih, update selectedKategories
                                if (selectedKategories.isNotEmpty) {
                                  // Hapus kategori lama
                                  barangProvider.setSelectedKategori('');
                                  
                                  // Set kategori baru dari selectedKategories
                                  for (String kategori in selectedKategories) {
                                    barangProvider.toggleKategori(kategori);
                                  }
                                } else {
                                  // Kosongkan kategori
                                  barangProvider.setSelectedKategori('');
                                  // Reset multi kategori
                                  if (barangProvider.selectedKategories.isNotEmpty) {
                                    for (String kategori in barangProvider.selectedKategories) {
                                      barangProvider.toggleKategori(kategori);
                                    }
                                  }
                                }
                                
                                // Set filter stok dan pengurutan
                                barangProvider.setOnlyInStock(onlyInStock);
                                barangProvider.setSortBy(sortBy);
                                
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF6E4A6C),
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Terapkan Filter',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required void Function(bool?) onSelected,
    required bool isDark,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: isDark ? Color(0xFF272042) : Colors.white,
      selectedColor: Color(0xFF6E4A6C).withOpacity(0.2),
      checkmarkColor: Color(0xFF6E4A6C),
      labelStyle: TextStyle(
        color: isSelected ? Color(0xFF6E4A6C) : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildSortRadio({
    required String title,
    required String value,
    required String groupValue,
    required void Function(String?) onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: groupValue,
              activeColor: Color(0xFF6E4A6C),
              onChanged: onChanged,
            ),
            Text(
              title,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
} 