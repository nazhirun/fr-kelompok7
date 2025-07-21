import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:myatk/core/theme/app_theme.dart';
import 'package:myatk/data/providers/auth_provider.dart';
import 'package:myatk/data/providers/barang_provider.dart';
import 'package:myatk/data/providers/theme_provider.dart';
import 'package:myatk/presentation/pages/auth/login_page.dart';
import 'package:myatk/presentation/pages/dashboard/cart_page.dart';
import 'package:myatk/presentation/pages/dashboard/home_page.dart';
import 'package:myatk/presentation/pages/dashboard/transaction_history_page.dart';
import 'package:myatk/presentation/pages/profile/profile_page.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  
  final List<Widget> _pages = [
    HomePage(),
    CartPage(),
    TransactionHistoryPage(),
    ProfilePage()
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppTheme.animationDurationShort,
    );
    
    // Periksa status autentikasi setiap kali halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.status != AuthStatus.authenticated) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => LoginPage()),
          (route) => false,
        );
      }
      _animationController.forward();
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    // Tambahkan consumer untuk mendengarkan perubahan status autentikasi
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Redirect ke login jika tidak terautentikasi
        if (authProvider.status != AuthStatus.authenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => LoginPage()),
              (route) => false,
            );
          });
        }
        
        return Consumer<BarangProvider>(
          builder: (context, barangProvider, _) {
            final jumlahItemKeranjang = barangProvider.jumlahItemKeranjang;
            
            return AppTheme.gradientBackground(
              isDark: isDark,
              child: Scaffold(
                extendBody: true,
                body: _pages[_currentIndex],
                bottomNavigationBar: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark 
                        ? [Color(0xFF1E1E2C), Color(0xFF212332)]
                        : [Colors.white, Color(0xFFF5F7FA)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark 
                          ? Colors.black.withOpacity(0.3) 
                          : Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 0,
                        offset: Offset(0, -2),
                      )
                    ],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppTheme.borderRadiusLarge),
                      topRight: Radius.circular(AppTheme.borderRadiusLarge),
                    ),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppTheme.borderRadiusLarge),
                      topRight: Radius.circular(AppTheme.borderRadiusLarge),
                    ),
                    child: BottomNavigationBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      currentIndex: _currentIndex,
                      onTap: (index) {
                        if (_currentIndex != index) {
                          setState(() {
                            _currentIndex = index;
                          });
                        }
                      },
                      type: BottomNavigationBarType.fixed,
                      selectedItemColor: AppTheme.primaryGradientColors[0],
                      unselectedItemColor: isDark ? Colors.white60 : Colors.grey,
                      items: [
                        BottomNavigationBarItem(
                          icon: _buildNavIcon(Icons.home_outlined, 0),
                          activeIcon: _buildActiveNavIcon(Icons.home, 0),
                          label: 'Beranda',
                        ),
                        BottomNavigationBarItem(
                          icon: _buildNavIcon(
                            Icons.shopping_cart_outlined, 
                            1, 
                            showBadge: jumlahItemKeranjang > 0, 
                            badgeCount: jumlahItemKeranjang
                          ),
                          activeIcon: _buildActiveNavIcon(
                            Icons.shopping_cart, 
                            1, 
                            showBadge: jumlahItemKeranjang > 0, 
                            badgeCount: jumlahItemKeranjang
                          ),
                          label: 'Keranjang',
                        ),
                        BottomNavigationBarItem(
                          icon: _buildNavIcon(Icons.receipt_long_outlined, 2),
                          activeIcon: _buildActiveNavIcon(Icons.receipt_long, 2),
                          label: 'Transaksi',
                        ),
                        BottomNavigationBarItem(
                          icon: _buildNavIcon(Icons.person_outline, 3),
                          activeIcon: _buildActiveNavIcon(Icons.person, 3),
                          label: 'Profil',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        );
      }
    );
  }
  
  Widget _buildNavIcon(IconData icon, int index, {bool showBadge = false, int badgeCount = 0}) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon),
          if (showBadge)
            Positioned(
              right: -8,
              top: -8,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppTheme.errorGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  badgeCount > 9 ? '9+' : badgeCount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildActiveNavIcon(IconData icon, int index, {bool showBadge = false, int badgeCount = 0}) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: AppTheme.primaryGradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Icon(
              icon,
              color: Colors.white,
            ),
          ),
          if (showBadge)
            Positioned(
              right: -8,
              top: -8,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppTheme.errorGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  badgeCount > 9 ? '9+' : badgeCount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
