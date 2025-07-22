import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:myatk/data/models/barang_model.dart';
import 'package:myatk/data/models/penjualan_model.dart';
import 'package:myatk/data/providers/auth_provider.dart';
import 'package:myatk/data/providers/barang_provider.dart';
import 'package:myatk/data/providers/penjualan_provider.dart';
import 'package:myatk/data/providers/theme_provider.dart';
import 'package:myatk/presentation/pages/dashboard/cart_page.dart';
import 'package:myatk/presentation/pages/dashboard/transaction_history_page.dart';
import 'package:myatk/presentation/pages/about/about_page.dart';
import 'package:myatk/presentation/pages/calculator/calculator_page.dart';
import 'package:myatk/presentation/pages/barang/all_barang_page.dart';
import 'package:myatk/core/theme/app_theme.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  // ignore: unused_field
  int _currentCarouselIndex = 0;
  late AnimationController _animationController;
  
  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BarangProvider>(context, listen: false).getBarang();
      Provider.of<PenjualanProvider>(context, listen: false).getPenjualan();
      _animationController.forward(from: 0.0);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  int _calculateTotalOmset(List<PenjualanModel> penjualan, {bool todayOnly = false}) {
    if (penjualan.isEmpty) return 0;
    
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    
    return penjualan.fold(0, (sum, item) {
      if (todayOnly) {
        String itemDate;
        try {
          if (item.tanggal.contains('T')) {
            final date = DateTime.parse(item.tanggal);
            itemDate = DateFormat('yyyy-MM-dd').format(date);
          } else {
            itemDate = item.tanggal;
          }
        } catch (e) {
          return sum;
        }
        
        if (itemDate == today) {
          return sum + item.total;
        }
        return sum;
      } else {
        return sum + item.total;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final barangProvider = Provider.of<BarangProvider>(context);
    final penjualanProvider = Provider.of<PenjualanProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    // ignore: unused_local_variable
    final user = authProvider.user;
    final barang = barangProvider.listBarang;
    final isLoading = barangProvider.loading;
    final kategoriList = barangProvider.kategoriBarang.keys.toList();
    
    final int totalOmset = _calculateTotalOmset(penjualanProvider.listPenjualan);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            barangProvider.getBarang(),
            penjualanProvider.getPenjualan(),
          ]);
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                      ? [Color(0xFF3F2B63), Color(0xFF2B2440)]
                      : [Color(0xFF9C27B0), Color(0xFF6E4A6C)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                  child: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.1,
                          child: Image.asset(
                            'assets/images/background.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      
                      Positioned(
                        top: 100,
                        left: 20,
                        right: 20,
                        child: AppTheme.gradientCard(
                          isDark: isDark,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 0,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                          child: Column(
                            children: [
                              AppTheme.gradientText(
                                'OMSET TOTAL HARI INI',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                gradientColors: AppTheme.secondaryGradientColors,
                              ),
                              SizedBox(height: 8),
                              // Tampilkan omset dari data transaksi
                              penjualanProvider.loading
                                  ? SizedBox(
                                      height: 28,
                                      width: 28,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGradientColors[0]),
                                      ),
                                    )
                                  : AppTheme.gradientText(
                                      currencyFormatter.format(totalOmset),
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      gradientColors: AppTheme.primaryGradientColors,
                                    ),
                              SizedBox(height: 10),
                              // Informasi total transaksi
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.receipt, 
                                    size: 16, 
                                    color: isDark ? Colors.white70 : Colors.grey[600],
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Total ${penjualanProvider.listPenjualan.length} Transaksi',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? Colors.white70 : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Kategori Menu
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                      ? [Color(0xFF3F2B63), Color(0xFF2B2440)]
                      : [Color(0xFF9C27B0), Color(0xFF6E4A6C)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCategoryItem(Icons.inventory_2_outlined, 'Barang', 0),
                    _buildCategoryItem(Icons.shopping_cart_outlined, 'Keranjang', 1),
                    _buildCategoryItem(Icons.backpack_outlined, 'Transaksi', 2),
                    _buildCategoryItem(Icons.calculate_outlined, 'Kalkulator', 3),
                    _buildCategoryItem(Icons.supervised_user_circle_sharp, 'About', 4),
                  ],
                ),
              ),
            ),
            
            // Search Bar
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                      ? [Color(0xFF3F2B63), Color(0xFF2B2440)]
                      : [Color(0xFF9C27B0), Color(0xFF6E4A6C)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xFF272042) : Colors.white,
                    borderRadius: BorderRadius.circular(23),
                    boxShadow: [
                      BoxShadow(
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
              ),
            ),
            
            // Filter Kategori
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // Tombol "Semua"
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildFilterChip(
                          'Semua', 
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
                            kategori,
                            isSelected: isSelected,
                            onSelected: (_) {
                              // Mode kompatibilitas: jika menggunakan filter kategori lama, reset ke mode multi-kategori
                              if (barangProvider.selectedKategori.isNotEmpty) {
                                barangProvider.setSelectedKategori('');
                              }
                              
                              // Toggle kategori di multi-kategori
                              barangProvider.toggleKategori(kategori);
                            },
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
            
            // Produk Grid
            isLoading
                ? SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGradientColors[0]),
                      ),
                    ),
                  )
                : barang.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined, 
                                size: 80, 
                                color: isDark ? Colors.white30 : Colors.grey[300],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Tidak ada barang yang tersedia',
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: EdgeInsets.all(16),
                        sliver: SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = barang[index];
                              return _buildProductItem(context, item, isDark);
                            },
                            childCount: barang.length,
                          ),
                        ),
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false, required Function(bool) onSelected}) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      checkmarkColor: Colors.white,
      selectedColor: AppTheme.primaryGradientColors[0].withOpacity(0.8),
      backgroundColor: isDark ? Color(0xFF272042) : Colors.white,
      shadowColor: Colors.black.withOpacity(0.1),
      elevation: 2,
      pressElevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontFamily: AppTheme.fontFamily,
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String label, int index) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final delay = 100 * index;
    
    return GestureDetector(
      onTap: () {
        switch (label) {
          case 'Barang':
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AllBarangPage(),
              ),
            );
            break;
          case 'Keranjang':
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CartPage(),
              ),
            );
            break;
          case 'Transaksi':
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TransactionHistoryPage(),
              ),
            );
            break;
          case 'Kalkulator':
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CalculatorPage(),
              ),
            );
            break;
          case 'About':
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AboutPage(),
              ),
            );
            break;
        }
      },
      child: Container(
        width: 60,
        height: 70,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark 
              ? [Color(0xFF272042), Color(0xFF1E1E2C)]
              : [Colors.white, Color(0xFFF8F8F8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: AppTheme.primaryGradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Icon(
                icon,
                size: 28,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(BuildContext context, BarangModel barang, bool isDark) {
    final barangProvider = Provider.of<BarangProvider>(context, listen: false);
    
    return GestureDetector(
      onTap: () => _showDetailModal(context, barang),
      child: AppTheme.gradientCard(
        isDark: isDark,
        borderRadius: AppTheme.borderRadiusMedium,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Produk
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.borderRadiusMedium)),
                child: Stack(
                  children: [
                    // Background fallback
                    Container(
                      color: isDark ? Color(0xFF1A1A2E) : Colors.grey[200],
                    ),
                    // Image
                    Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl: barang.gambar,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGradientColors[0]),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: isDark ? Color(0xFF1A1A2E) : Colors.grey[200],
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported, 
                              size: 50, 
                              color: isDark ? Colors.white24 : Colors.grey[400],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Gradient overlay
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                    // Product category badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: AppTheme.primaryGradientColors,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                        ),
                        child: Text(
                          barang.kategori,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Informasi Produk
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    barang.nama,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      AppTheme.gradientText(
                        currencyFormatter.format(barang.harga),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        gradientColors: AppTheme.primaryGradientColors,
                      ),
                      Spacer(),
                      // Tambahkan informasi stok dengan indikator warna
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: barang.stok > 0 ? AppTheme.successGradient : AppTheme.errorGradient,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                        ),
                        child: Text(
                          'Stok: ${barang.stok}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Action Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppTheme.primaryGradientColors,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGradientColors[0].withOpacity(0.3),
                          spreadRadius: 0,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.add_shopping_cart, color: Colors.white, size: 20),
                      onPressed: () => barangProvider.tambahKeKeranjang(barang),
                      tooltip: 'Tambah ke keranjang',
                      constraints: BoxConstraints(minHeight: 36, minWidth: 36),
                      padding: EdgeInsets.all(8),
                      splashRadius: 24,
                    ),
                  ),
                ],
              ),
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
                              child: AppTheme.gradientText(
                                barang.nama,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.left,
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
                        AppTheme.gradientText(
                          currencyFormatter.format(barang.harga),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                          gradientColors: AppTheme.secondaryGradientColors,
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
                            AppTheme.gradientText(
                              'Filter Produk',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.left,
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
                          AppTheme.gradientText(
                            'Kategori',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                            gradientColors: AppTheme.secondaryGradientColors,
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
                              AppTheme.gradientText(
                                'Rentang Harga',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.left,
                                gradientColors: AppTheme.secondaryGradientColors,
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
                          AppTheme.gradientText(
                            'Urutkan Berdasarkan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                            gradientColors: AppTheme.secondaryGradientColors,
                          ),
                          SizedBox(height: 8),
                          
                          // Radio untuk pengurutan
                          _buildSortRadio(
                            context: context, 
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
                            context: context, 
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
                            context: context, 
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
                            context: context, 
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
                            context: context, 
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

  Widget _buildSortRadio({
    required BuildContext context,
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