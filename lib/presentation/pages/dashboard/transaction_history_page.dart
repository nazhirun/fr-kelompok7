import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myatk/core/theme/app_theme.dart';
import 'package:myatk/data/models/penjualan_model.dart';
import 'package:myatk/data/providers/penjualan_provider.dart';
import 'package:myatk/data/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({Key? key}) : super(key: key);

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ambil data penjualan saat halaman dibuka
      Provider.of<PenjualanProvider>(context, listen: false).getPenjualan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    // Format tanggal
    final dateFormatter = DateFormat('yyyy-MM-dd');
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Riwayat Transaksi', style: TextStyle(fontWeight: FontWeight.w600)),
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
      body: Consumer<PenjualanProvider>(
        builder: (context, penjualanProvider, _) {
          if (penjualanProvider.loading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGradientColors[0]),
              ),
            );
          }
          
          if (penjualanProvider.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Terjadi kesalahan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    penjualanProvider.errorMessage,
                    style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                  ),
                  SizedBox(height: 16),
                  AppTheme.gradientButton(
                    onPressed: () => penjualanProvider.getPenjualan(),
                    child: Text(
                      'Coba Lagi',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }
          
          if (penjualanProvider.listPenjualan.isEmpty) {
            return _buildEmptyHistory(isDark);
          }
          
          // Group transactions by faktur number
          Map<String, List<PenjualanModel>> groupedTransactions = {};
          for (var item in penjualanProvider.listPenjualan) {
            if (!groupedTransactions.containsKey(item.faktur)) {
              groupedTransactions[item.faktur] = [];
            }
            groupedTransactions[item.faktur]!.add(item);
          }
          
          return RefreshIndicator(
            onRefresh: () => penjualanProvider.getPenjualan(),
            color: AppTheme.primaryGradientColors[0],
            backgroundColor: isDark ? Color(0xFF1E1E2C) : Colors.white,
            child: ListView.builder(
              padding: EdgeInsets.only(top: kToolbarHeight + 16, left: 16, right: 16, bottom: 16),
              itemCount: groupedTransactions.length,
              itemBuilder: (context, index) {
                String faktur = groupedTransactions.keys.elementAt(index);
                List<PenjualanModel> items = groupedTransactions[faktur]!;
                
                // Calculate transaction total
                int total = items.fold(0, (sum, item) => sum + item.total);
                
                // Format tanggal
                String rawDate = items.isNotEmpty ? items.first.tanggal : '';
                String formattedDate = '';
                
                try {
                  if (rawDate.contains('T')) {
                    // ISO 8601 format
                    formattedDate = dateFormatter.format(DateTime.parse(rawDate));
                  } else {
                    formattedDate = rawDate;
                  }
                } catch (e) {
                  formattedDate = rawDate;
                }
                
                return AppTheme.gradientCard(
                  isDark: isDark,
                  borderRadius: AppTheme.borderRadiusMedium,
                  padding: EdgeInsets.zero,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 16),
                    child: InkWell(
                      onTap: () {
                        _showTransactionDetailDialog(context, faktur, items, currencyFormatter, isDark);
                      },
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header: Faktur & Tanggal
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Faktur: $faktur',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    color: isDark ? Colors.white60 : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            
                            Divider(color: isDark ? Colors.white24 : Colors.grey[300]),
                            
                            // Item preview (show only the first item and a counter if there are more)
                            _buildPreviewItem(items.first, items.length > 1 ? items.length - 1 : 0, currencyFormatter, isDark),
                            
                            Divider(color: isDark ? Colors.white24 : Colors.grey[300]),
                            
                            // Footer: Total & Items Count
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${items.length} item',
                                  style: TextStyle(
                                    color: isDark ? Colors.white60 : Colors.grey[600],
                                  ),
                                ),
                                AppTheme.gradientText(
                                  'Total: ${currencyFormatter.format(total)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyHistory(bool isDark) {
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
              Icons.receipt_long,
              size: 80,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Belum ada transaksi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Riwayat transaksi Anda akan ditampilkan di sini',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewItem(PenjualanModel item, int moreItems, NumberFormat formatter, bool isDark) {
    return Row(
      children: [
        // Product thumbnail or icon
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppTheme.primaryGradientColors.sublist(0, 2),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(
              Icons.shopping_bag,
              color: Colors.white,
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
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
        
        // More items indicator
        if (moreItems > 0)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE0E0E0), Color(0xFFBDBDBD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '+$moreItems lagi',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
      ],
    );
  }

  void _showTransactionDetailDialog(
    BuildContext context, 
    String faktur, 
    List<PenjualanModel> items,
    NumberFormat formatter,
    bool isDark,
  ) {
    // Calculate total
    int total = items.fold(0, (sum, item) => sum + item.total);
    
    // Format date
    final dateFormatter = DateFormat('yyyy-MM-dd');
    String rawDate = items.isNotEmpty ? items.first.tanggal : '';
    String formattedDate = '';
    
    try {
      if (rawDate.contains('T')) {
        // ISO 8601 format
        formattedDate = dateFormatter.format(DateTime.parse(rawDate));
      } else {
        formattedDate = rawDate;
      }
    } catch (e) {
      formattedDate = rawDate;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Color(0xFF1E1E2C) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        title: Text(
          'Detail Transaksi',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaction info
              _buildDetailRow('Faktur', faktur, isDark),
              _buildDetailRow('Tanggal', formattedDate, isDark),
              _buildDetailRow('Jumlah Item', '${items.length}', isDark),
              
              SizedBox(height: 16),
              
              // Items list
              Text(
                'Daftar Item',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              
              SizedBox(height: 8),
              
              // Show list of items if not too many, otherwise provide scrollable list
              if (items.length <= 5) 
                ...items.map((item) => _buildDetailItem(item, formatter, isDark)).toList()
              else
                Container(
                  constraints: BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) => _buildDetailItem(items[index], formatter, isDark),
                  ),
                ),
              
              SizedBox(height: 16),
              
              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  AppTheme.gradientText(
                    formatter.format(total),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          AppTheme.gradientButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Tutup',
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

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.grey[700],
            ),
          ),
          Text(
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

  Widget _buildDetailItem(PenjualanModel item, NumberFormat formatter, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.barang?.nama ?? 'Produk',
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
          ),
          SizedBox(width: 8),
          Text(
            '${item.qty}x',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
          ),
          SizedBox(width: 8),
          AppTheme.gradientText(
            formatter.format(item.total),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
} 