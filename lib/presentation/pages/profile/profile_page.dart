import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:myatk/core/theme/app_theme.dart';
import 'package:myatk/data/providers/auth_provider.dart';
import 'package:myatk/data/providers/theme_provider.dart';
import 'package:myatk/presentation/pages/auth/login_page.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final user = authProvider.user;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: AppTheme.gradientText(
          'Profil',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          gradientColors: isDark 
            ? [Colors.white, Colors.white70]
            : AppTheme.secondaryGradientColors,
        ),
        centerTitle: true,
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
        ),
        elevation: 0,
        systemOverlayStyle: isDark 
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.light,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: AppTheme.gradientBackground(
        isDark: isDark,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                
                // Profile Card
                AppTheme.gradientCard(
                  isDark: isDark,
                  borderRadius: AppTheme.borderRadiusLarge,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      spreadRadius: 1,
                      offset: Offset(0, 8),
                    ),
                  ],
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      // Avatar dengan gradient border
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: AppTheme.primaryGradientColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryGradientColors[0].withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 2,
                            )
                          ]
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: isDark ? Color(0xFF272042) : Colors.white,
                            child: Text(
                              user?.name?.substring(0, 1) ?? 'U',
                              style: TextStyle(
                                fontSize: 40,
                                color: AppTheme.primaryGradientColors[0],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ).animate()
                       .fadeIn(duration: Duration(milliseconds: 500))
                       .slideY(begin: 0.2, end: 0, duration: Duration(milliseconds: 500)),
                      
                      SizedBox(height: 16),
                      
                      // Nama Pengguna
                      AppTheme.gradientText(
                        user?.name ?? 'Pengguna',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate()
                       .fadeIn(duration: Duration(milliseconds: 500), delay: Duration(milliseconds: 100)),
                      
                      SizedBox(height: 8),
                      
                      // Email
                      Text(
                        user?.email ?? 'email@example.com',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.grey[600],
                        ),
                      ).animate()
                       .fadeIn(duration: Duration(milliseconds: 500), delay: Duration(milliseconds: 200)),
                      
                      SizedBox(height: 12),
                      
                      // Role Badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: user?.role == 'admin'
                                ? AppTheme.errorGradient
                                : AppTheme.successGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user?.role == 'admin' ? 'Admin' : 'Kasir',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ).animate()
                       .fadeIn(duration: Duration(milliseconds: 500), delay: Duration(milliseconds: 300)),
                      
                      SizedBox(height: 20),
                    ],
                  ),
                ),
                
                SizedBox(height: 30),
                
                // Theme Toggle
                AppTheme.gradientCard(
                  isDark: isDark,
                  borderRadius: AppTheme.borderRadiusMedium,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTheme.gradientText(
                        'Tema Aplikasi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isDark ? Icons.dark_mode : Icons.light_mode,
                                color: isDark ? Colors.white70 : Colors.amber,
                              ),
                              SizedBox(width: 8),
                              Text(
                                isDark ? 'Mode Gelap' : 'Mode Terang',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white70 : Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: isDark,
                            onChanged: (value) {
                              themeProvider.toggleTheme();
                            },
                            activeColor: AppTheme.primaryGradientColors[0],
                            activeTrackColor: AppTheme.primaryGradientColors[0].withOpacity(0.5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate()
                 .fadeIn(duration: Duration(milliseconds: 500), delay: Duration(milliseconds: 400)),
                
                SizedBox(height: 24),
                
                // Menu Items
                _buildMenuItemGroup(
                  context, 
                  'Pengaturan Akun', 
                  [
                    _MenuItem(
                      icon: Icons.person_outline,
                      title: 'Edit Profil',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.lock_outline,
                      title: 'Ubah Password',
                      onTap: () {},
                    ),
                  ],
                  isDark: isDark,
                ).animate()
                 .fadeIn(duration: Duration(milliseconds: 500), delay: Duration(milliseconds: 500)),
                
                SizedBox(height: 16),
                
                _buildMenuItemGroup(
                  context, 
                  'Aktivitas', 
                  [
                    _MenuItem(
                      icon: Icons.history,
                      title: 'Riwayat Transaksi',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.receipt_long,
                      title: 'Laporan Penjualan',
                      onTap: () {},
                    ),
                  ],
                  isDark: isDark,
                ).animate()
                 .fadeIn(duration: Duration(milliseconds: 500), delay: Duration(milliseconds: 600)),
                
                SizedBox(height: 16),
                
                _buildMenuItemGroup(
                  context, 
                  'Lainnya', 
                  [
                    _MenuItem(
                      icon: Icons.help_outline,
                      title: 'Bantuan',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.info_outline,
                      title: 'Tentang Aplikasi',
                      onTap: () {},
                    ),
                  ],
                  isDark: isDark,
                ).animate()
                 .fadeIn(duration: Duration(milliseconds: 500), delay: Duration(milliseconds: 700)),
                
                SizedBox(height: 32),
                
                // Logout Button
                AppTheme.gradientButton(
                  onPressed: () => _showLogoutDialog(context),
                  gradientColors: AppTheme.errorGradient,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ).animate()
                 .fadeIn(duration: Duration(milliseconds: 500), delay: Duration(milliseconds: 800)),
                
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItemGroup(BuildContext context, String title, List<_MenuItem> items, {bool isDark = false}) {
    return AppTheme.gradientCard(
      isDark: isDark,
      borderRadius: AppTheme.borderRadiusMedium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTheme.gradientText(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.start,
          ),
          SizedBox(height: 12),
          ...items.map((item) => _buildMenuItem(context, item, isDark: isDark)).toList(),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, _MenuItem item, {bool isDark = false}) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: AppTheme.primaryGradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Icon(
                item.icon,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Color(0xFF272042) : Colors.white,
        title: AppTheme.gradientText(
          'Konfirmasi Logout',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari aplikasi?',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Batal',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[700],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // Tutup dialog
              Navigator.of(context).pop();
              
              // Logout dan tunggu sampai selesai
              await Provider.of<AuthProvider>(context, listen: false).logout();
              
              // Navigasi ke halaman login dan hapus semua halaman dari stack
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => LoginPage()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
            ),
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  
  _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}
