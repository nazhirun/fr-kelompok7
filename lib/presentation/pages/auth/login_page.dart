import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:myatk/core/theme/app_theme.dart';
import 'package:myatk/core/validators/auth_validator.dart';
import 'package:myatk/data/providers/auth_provider.dart';
import 'package:myatk/data/providers/theme_provider.dart';
import 'package:myatk/presentation/pages/auth/forgot_password_page.dart';
import 'package:myatk/presentation/pages/auth/verify_otp_page.dart';
import 'package:myatk/presentation/pages/dashboard/dashboard_page.dart';
import 'package:myatk/presentation/widgets/common/custom_text_field.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _showSuccessAnimation = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppTheme.animationDurationMedium,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
      
      // Atur status bar untuk tampilan yang lebih baik
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      );
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final result = await Provider.of<AuthProvider>(context, listen: false).login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (result) {
        // Tampilkan animasi sukses sebelum navigasi
        setState(() {
          _showSuccessAnimation = true;
        });
        
        // Tunggu animasi selesai sebelum navigasi
        await Future.delayed(const Duration(milliseconds: 1500));
        
        if (!mounted) return;
        
        // Login berhasil, navigasi ke dashboard
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => DashboardPage()),
        );
      } else {
        // Cek apakah perlu verifikasi
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        if (authProvider.status == AuthStatus.verifying) {
          // Navigasi ke halaman verifikasi OTP
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => VerifyOtpPage(),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              // ignore: deprecated_member_use
              isDark ? Colors.black.withOpacity(0.7) : Colors.black.withOpacity(0.5),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Form content
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 60),
                        
                        // Header with animation
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(0, -0.5),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _animationController,
                            curve: Curves.easeOut,
                          )),
                          child: FadeTransition(
                            opacity: _animationController,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppTheme.gradientText(
                                  'Selamat Datang',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  gradientColors: AppTheme.primaryGradientColors,
                                ),
                                
                                const SizedBox(height: 8),
                                
                                Text(
                                  'Masuk ke akun Anda',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Form card with animation
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(0, 0.5),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _animationController,
                            curve: Curves.easeOut,
                          )),
                          child: FadeTransition(
                            opacity: _animationController,
                            child: AppTheme.gradientCard(
                              isDark: isDark,
                              borderRadius: AppTheme.borderRadiusLarge,
                              boxShadow: [
                                BoxShadow(
                                  // ignore: deprecated_member_use
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 15,
                                  spreadRadius: 0,
                                  offset: Offset(0, 10),
                                ),
                              ],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Email field
                                  CustomTextField(
                                    controller: _emailController,
                                    label: 'Email',
                                    hint: 'Masukkan email Anda',
                                    keyboardType: TextInputType.emailAddress,
                                    validator: AuthValidator.validateEmail,
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      color: isDark ? Colors.white70 : AppTheme.primaryGradientColors[0],
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Password field
                                  CustomTextField(
                                    controller: _passwordController,
                                    label: 'Password',
                                    hint: 'Masukkan password Anda',
                                    obscureText: _obscurePassword,
                                    validator: AuthValidator.validatePassword,
                                    prefixIcon: Icon(
                                      Icons.lock_outlined,
                                      color: isDark ? Colors.white70 : AppTheme.primaryGradientColors[0],
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword 
                                          ? Icons.visibility_outlined 
                                          : Icons.visibility_off_outlined,
                                        color: isDark ? Colors.white70 : Colors.grey,
                                      ),
                                      onPressed: _togglePasswordVisibility,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 12),
                                  
                                  // Forgot Password link
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => ForgotPasswordPage(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Lupa Password?',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: TextButton.styleFrom(
                                        foregroundColor: isDark 
                                          ? Colors.white 
                                          : AppTheme.primaryGradientColors[0],
                                      ),
                                    ),
                                  ),
                                  
                                  // Error message
                                  if (authProvider.errorMessage.isNotEmpty)
                                    Container(
                                      margin: const EdgeInsets.only(top: 12, bottom: 12),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        // ignore: deprecated_member_use
                                        color: Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                                        // ignore: deprecated_member_use
                                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.error_outline, color: Colors.red, size: 20),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              authProvider.errorMessage,
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Login button
                                  AppTheme.gradientButton(
                                    onPressed: _login,
                                    gradientColors: AppTheme.primaryGradientColors,
                                    child: authProvider.loading
                                        ? SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            'Masuk',
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
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Theme toggle with animation
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(0, 1),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _animationController,
                            curve: Curves.easeOut,
                          )),
                          child: FadeTransition(
                            opacity: _animationController,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isDark ? Icons.dark_mode : Icons.light_mode,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Mode ${isDark ? "Gelap" : "Terang"}',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  SizedBox(width: 8),
                                  Switch(
                                    value: isDark,
                                    onChanged: (value) {
                                      themeProvider.toggleTheme();
                                    },
                                    activeColor: Colors.white,
                                    // ignore: deprecated_member_use
                                    activeTrackColor: AppTheme.primaryGradientColors[0].withOpacity(0.5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Success animation overlay
              if (_showSuccessAnimation)
                Container(
                  color: isDark 
                    // ignore: deprecated_member_use
                    ? Colors.black.withOpacity(0.9)
                    // ignore: deprecated_member_use
                    : Colors.white.withOpacity(0.9),
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          'assets/animations/lottie.json',
                          width: 200,
                          height: 200,
                          fit: BoxFit.contain,
                          repeat: false,
                        ),
                        const SizedBox(height: 20),
                        AppTheme.gradientText(
                          'Login Berhasil!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          gradientColors: AppTheme.primaryGradientColors,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 