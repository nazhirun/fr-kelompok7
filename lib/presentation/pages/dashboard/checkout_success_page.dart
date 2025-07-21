import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myatk/core/theme/app_theme.dart';
import 'package:myatk/data/models/penjualan_model.dart';
import 'package:myatk/data/providers/penjualan_provider.dart';
import 'package:myatk/data/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class CheckoutSuccessPage extends StatelessWidget {
  const CheckoutSuccessPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final penjualanProvider = Provider.of<PenjualanProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final lastCheckout = penjualanProvider.lastCheckout;
    
    // Format currency
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    
    // Format tanggal
    final dateFormatter = DateFormat('yyyy-MM-dd');
    
    // Hitung total
    int totalItems = 0;
    int totalHarga = 0;
    for (var item in lastCheckout) {
      totalItems += item.qty;
      totalHarga += item.total;
    }
    
    // Ambil nomor faktur dari item pertama (semua item memiliki faktur yang sama)
    String faktur = lastCheckout.isNotEmpty ? lastCheckout.first.faktur : '-';
    
    // Format tanggal dari ISO 8601 menjadi tanggal yang mudah dibaca
    String tanggal = '-';
    if (lastCheckout.isNotEmpty) {
      try {
        // Ambil tanggal dari response
        final rawTanggal = lastCheckout.first.tanggal;
        
        // Cek apakah format tanggal sudah mengandung timestamp
        if (rawTanggal.contains('T')) {
          // Format dari ISO 8601
          final date = DateTime.parse(rawTanggal);
          tanggal = dateFormatter.format(date);
        } else {
          // Tanggal sudah dalam format yang benar
          tanggal = rawTanggal;
        }
      } catch (e) {
        // Jika parsing gagal, gunakan tanggal as-is
        tanggal = lastCheckout.first.tanggal;
      }
    }
    
    return WillPopScope(
      onWillPop: () async {
        // Reset data checkout terakhir saat kembali
        penjualanProvider.resetLastCheckout();
        return true;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text('Checkout Berhasil', style: TextStyle(fontWeight: FontWeight.w600)),
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
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: kToolbarHeight + 16), // Ruang untuk AppBar
              // Success Icon
              Container(
                padding: EdgeInsets.all(24),
                alignment: Alignment.center,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.withOpacity(0.1), Colors.green.withOpacity(0.3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 80,
                  ),
                ),
              ),
              
              // Success Message
              AppTheme.gradientText(
                'Checkout Berhasil!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                gradientColors: AppTheme.primaryGradientColors,
              ),
              
              SizedBox(height: 8),
              
              Text(
                'Pesanan Anda telah berhasil diproses.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey[700],
                  fontSize: 16,
                ),
              ),
              
              SizedBox(height: 32),
              
              // Detail Transaksi
              AppTheme.gradientCard(
                isDark: isDark,
                borderRadius: AppTheme.borderRadiusMedium,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Transaksi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    _buildDetailItem('No. Faktur', faktur, isDark),
                    _buildDetailItem('Tanggal', tanggal, isDark),
                    _buildDetailItem('Jumlah Item', '$totalItems', isDark),
                    _buildDetailItem('Total', currencyFormatter.format(totalHarga), isDark, isTotal: true),
                    
                    Divider(height: 32, color: isDark ? Colors.white24 : Colors.grey[300]),
                    
                    // Daftar Item
                    Text(
                      'Daftar Item',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    
                    SizedBox(height: 8),
                    
                    ...lastCheckout.map((item) => _buildPenjualanItem(item, currencyFormatter, isDark)).toList(),
                  ],
                ),
              ),
              
              SizedBox(height: 32),
              
              // Back to Home Button
              AppTheme.gradientButton(
                onPressed: () {
                  // Reset data checkout terakhir
                  penjualanProvider.resetLastCheckout();
                  
                  // Kembali ke halaman utama
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text(
                  'Kembali ke Beranda',
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
      ),
    );
  }
  
  Widget _buildDetailItem(String label, String value, bool isDark, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.grey[600],
            ),
          ),
          isTotal 
            ? AppTheme.gradientText(
                value,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              )
            : Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
        ],
      ),
    );
  }
  
  Widget _buildPenjualanItem(PenjualanModel item, NumberFormat formatter, bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.black12 : Colors.grey[100],
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item number indicator
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppTheme.primaryGradientColors.sublist(0, 2),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${item.id}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          
          // Item details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.barang?.nama ?? 'Produk',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${item.qty} x ${formatter.format(item.total ~/ item.qty)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          
          // Item total price
          AppTheme.gradientText(
            formatter.format(item.total),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
} 