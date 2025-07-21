import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:myatk/core/theme/app_theme.dart';
import 'package:myatk/data/models/barang_model.dart';
import 'package:myatk/data/providers/barang_provider.dart';
import 'package:myatk/data/providers/penjualan_provider.dart';
import 'package:myatk/data/providers/theme_provider.dart';
import 'package:myatk/presentation/pages/dashboard/checkout_success_page.dart';
import 'package:provider/provider.dart';

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final barangProvider = Provider.of<BarangProvider>(context);
    final penjualanProvider = Provider.of<PenjualanProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final mediaQuery = MediaQuery.of(context);
    
    final keranjang = barangProvider.keranjang;
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Keranjang', style: TextStyle(fontWeight: FontWeight.w600)),
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
      body: keranjang.isEmpty
          ? _buildEmptyCart(isDark)
          : SafeArea(
              bottom: false, // Tidak gunakan SafeArea di bawah karena akan ditangani manual
              child: Column(
                children: [
                  // Error message jika ada
                  if (penjualanProvider.errorMessage.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      color: Colors.red[50],
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              penjualanProvider.errorMessage,
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.red),
                            onPressed: () => penjualanProvider.resetErrorMessage(),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // List Item Keranjang
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: keranjang.length,
                      itemBuilder: (context, index) {
                        final item = keranjang[index];
                        return _buildCartItem(context, item, currencyFormatter, isDark);
                      },
                    ),
                  ),
                  
                  // Bottom Card untuk Total dan Checkout - tambahkan bottom padding untuk navigasi
                  Container(
                    padding: EdgeInsets.only(
                      left: 16, 
                      right: 16, 
                      top: 16, 
                      bottom: mediaQuery.padding.bottom + kBottomNavigationBarHeight + 8, // Tambah ruang untuk nav bar
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? Color(0xFF1E1E2C) : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            AppTheme.gradientText(
                              currencyFormatter.format(barangProvider.totalHargaKeranjang),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        AppTheme.gradientButton(
                          onPressed: penjualanProvider.checkoutLoading
                              ? () {} 
                              : () => _showCheckoutDialog(context),
                          child: penjualanProvider.checkoutLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Pembayaran',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
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

  Widget _buildEmptyCart(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: AppTheme.primaryGradientColors,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(bounds),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Keranjang Belanja Kosong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tambahkan produk ke keranjang',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    BarangModel item,
    NumberFormat currencyFormatter,
    bool isDark,
  ) {
    final barangProvider = Provider.of<BarangProvider>(context, listen: false);
    
    return AppTheme.gradientCard(
      isDark: isDark,
      borderRadius: AppTheme.borderRadiusMedium,
      padding: EdgeInsets.all(12),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            // Gambar Produk
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              child: CachedNetworkImage(
                imageUrl: item.gambar,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 80,
                  height: 80,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGradientColors[0]),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 80,
                  height: 80,
                  color: isDark ? Color(0xFF1A1A2E) : Colors.grey[200],
                  child: Icon(
                    Icons.image_not_supported, 
                    color: isDark ? Colors.white24 : Colors.grey[400],
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            
            // Informasi Produk
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nama,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  AppTheme.gradientText(
                    currencyFormatter.format(item.harga),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  // Tambahkan informasi stok
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        margin: EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: item.stok > 0 ? AppTheme.successGradient : AppTheme.errorGradient,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                        ),
                        child: Text(
                          'Stok: ${item.stok}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (item.jumlahKeranjang >= item.stok)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, left: 4),
                          child: Text(
                            '(Max)',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8),
                  
                  // Quantity Controls
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black12 : Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                      border: Border.all(color: isDark ? Colors.white12 : Colors.grey[200]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove, size: 16, color: isDark ? Colors.white70 : Colors.black54),
                          onPressed: () => barangProvider.kurangiDariKeranjang(item),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                        Container(
                          width: 40,
                          alignment: Alignment.center,
                          child: Text(
                            '${item.jumlahKeranjang}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, size: 16, color: isDark ? Colors.white70 : Colors.black54),
                          onPressed: () => barangProvider.tambahKeKeranjang(item),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Delete Button
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade300, Colors.red.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.white),
                onPressed: () => barangProvider.hapusDariKeranjang(item),
                constraints: BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context) {
    final barangProvider = Provider.of<BarangProvider>(context, listen: false);
    final penjualanProvider = Provider.of<PenjualanProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? Color(0xFF1E1E2C) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        title: Text(
          'Konfirmasi Pembayaran',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Belanja:',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[700],
              ),
            ),
            AppTheme.gradientText(
              currencyFormatter.format(barangProvider.totalHargaKeranjang),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              gradientColors: AppTheme.primaryGradientColors,
            ),
            SizedBox(height: 16),
            Text(
              'Apakah Anda yakin ingin melanjutkan Pembayaran?',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Batal'),
          ),
          AppTheme.gradientButton(
            onPressed: () async {
              // Simpan reference ke BuildContext untuk digunakan nanti
              final scaffoldContext = context;
              
              // Tutup dialog konfirmasi
              Navigator.of(dialogContext).pop();
              
              // Tampilkan dialog loading
              _showLoadingDialog(scaffoldContext);
              
              // Proses checkout ke API
              final result = await penjualanProvider.checkout(barangProvider.keranjang);
              
              // Pastikan navigasi dilakukan hanya jika context masih valid
              if (scaffoldContext.mounted) {
                // Tutup dialog loading
                Navigator.of(scaffoldContext).pop();
                
                if (result) {
                  // Kosongkan keranjang
                  barangProvider.kosongkanKeranjang();
                  
                  // Refresh data barang
                  await barangProvider.getBarang();
                  
                  // Navigasi ke halaman sukses
                  if (scaffoldContext.mounted) {
                    Navigator.of(scaffoldContext).push(
                      MaterialPageRoute(
                        builder: (context) => CheckoutSuccessPage(),
                      ),
                    );
                  }
                }
              }
            },
            child: Text(
              'Ya',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showLoadingDialog(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? Color(0xFF1E1E2C) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGradientColors[0]),
            ),
            SizedBox(height: 16),
            Text(
              'Memproses Pembayaran...',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 