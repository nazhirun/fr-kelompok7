import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myatk/core/constants/app_constants.dart';
import 'package:myatk/core/theme/app_theme.dart';
import 'package:myatk/data/providers/auth_provider.dart';
import 'package:myatk/presentation/pages/auth/login_page.dart';
import 'package:myatk/presentation/pages/dashboard/dashboard_page.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
    
    // Set status bar untuk tampilan splash yang lebih baik
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    
    // Memastikan provider sudah siap sebelum melakukan pengecekan
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthState();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthState() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Berikan waktu agar animasi splash dapat berjalan
    await Future.delayed(AppConstants.splashDuration);
    
    setState(() {
      _isChecking = false;
    });
    
    // Navigasi berdasarkan status autentikasi
    if (authProvider.status == AuthStatus.authenticated) {
      debugPrint('🔓 Sesi tersimpan ditemukan, navigasi ke Dashboard');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => DashboardPage()),
      );
    } else if (authProvider.status == AuthStatus.unauthenticated) {
      debugPrint('🔒 Tidak ada sesi tersimpan, navigasi ke Login');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    } else {
      // Jika status masih initial, tunggu perubahan status
      debugPrint('⏳ Menunggu status autentikasi...');
      authProvider.addListener(_onAuthStateChanged);
    }
  }
  
  void _onAuthStateChanged() {
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.status == AuthStatus.authenticated) {
      authProvider.removeListener(_onAuthStateChanged);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => DashboardPage()),
      );
    } else if (authProvider.status == AuthStatus.unauthenticated) {
      authProvider.removeListener(_onAuthStateChanged);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppTheme.backgroundGradientLight,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          image: DecorationImage(
            image: AssetImage('assets/images/splash.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Loading indicator at the bottom
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  children: [
                    // Animasi loading
                    ScaleTransition(
                      scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: Curves.elasticOut,
                        ),
                      ),
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryGradientColors[0],
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Pesan status
                    AnimatedOpacity(
                      opacity: _isChecking ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 300),
                      child: Text(
                        'Memuat sesi...',
                        style: TextStyle(
                          color: AppTheme.primaryGradientColors[0],
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 