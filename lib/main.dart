import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:myatk/core/theme/app_theme.dart';
import 'package:myatk/data/providers/auth_provider.dart';
import 'package:myatk/data/providers/barang_provider.dart';
import 'package:myatk/data/providers/penjualan_provider.dart';
import 'package:myatk/data/providers/theme_provider.dart';
import 'package:myatk/presentation/pages/splash/splash_page.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() async {
  // Pastikan Flutter binding diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();
  
  // Konfigurasi orientasi tampilan
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Pastikan storage diinisialisasi dengan benar
  const FlutterSecureStorage storage = FlutterSecureStorage();
  
  // Cek status tema
  final isDarkMode = await storage.read(key: 'is_dark_mode') == 'true';
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(isDarkMode: isDarkMode)),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BarangProvider()),
        ChangeNotifierProvider(create: (_) => PenjualanProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isDark = themeProvider.isDarkMode;
        
        return AppTheme.gradientBackground(
          isDark: isDark,
          child: MaterialApp(
            title: 'MyATK App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            builder: (context, child) {
              // Buat wrapper untuk menyediakan gradien background
              if (child == null) return SizedBox.shrink();
              
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
                child: child,
              );
            },
            home: const SplashPage()
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 400))
                .scale(delay: const Duration(milliseconds: 200), duration: const Duration(milliseconds: 400)),
          ),
        );
      }
    );
  }
}
