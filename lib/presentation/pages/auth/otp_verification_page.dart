import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myatk/core/theme/app_theme.dart';
import 'package:myatk/core/utils/timer_util.dart';
import 'package:myatk/core/validators/auth_validator.dart';
import 'package:myatk/data/providers/auth_provider.dart';
import 'package:myatk/data/providers/theme_provider.dart';
import 'package:myatk/presentation/pages/auth/reset_password_page.dart';
import 'package:myatk/presentation/widgets/common/otp_input.dart';
import 'package:provider/provider.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({Key? key}) : super(key: key);

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> with SingleTickerProviderStateMixin {
  final TextEditingController _otpController = TextEditingController();
  bool _isSubmitting = false;

  // Timer untuk countdown OTP
  late TimerUtil _timerUtil;
  String _timeLeft = '';
  bool _canResend = false;
  
  // Animation controller
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
      _startOtpTimer();
      
      // Atur status bar untuk tampilan yang lebih baik
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      );
    });
  }

  void _startOtpTimer() {
    final expiresAt = Provider.of<AuthProvider>(context, listen: false).expiresAt;
    if (expiresAt != null) {
      _timerUtil = TimerUtil(
        expiresAt: expiresAt,
        onTick: (timeLeft) {
          setState(() {
            _timeLeft = timeLeft;
          });
        },
        onFinish: () {
          setState(() {
            _canResend = true;
          });
        },
      );
      _timerUtil.start();
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timerUtil.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    // Validasi OTP
    final otpError = AuthValidator.validateOtp(_otpController.text);
    if (otpError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(otpError)),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final result = await Provider.of<AuthProvider>(context, listen: false)
        .verifyResetOtp(otp: _otpController.text);

    setState(() {
      _isSubmitting = false;
    });

    if (result) {
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ResetPasswordPage()),
        );
      }
    }
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;

    setState(() {
      _canResend = false;
    });

    final result = await Provider.of<AuthProvider>(context, listen: false).resendResetOtp();

    if (result) {
      _startOtpTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kode OTP baru telah dikirim ke email Anda'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final email = authProvider.resetEmail ?? 'email Anda';
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: AppTheme.gradientText(
          'Verifikasi OTP',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          gradientColors: isDark 
            ? [Colors.white, Colors.white70]
            : AppTheme.secondaryGradientColors,
        ),
      ),
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  
                  // Progress indicator
                  FadeTransition(
                    opacity: _animationController,
                    child: Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                        gradient: LinearGradient(
                          colors: AppTheme.primaryGradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: isDark ? Color(0xFF272042) : Colors.white,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: AppTheme.primaryGradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Progress text
                  Center(
                    child: FadeTransition(
                      opacity: _animationController,
                      child: Text(
                        'Langkah 2 dari 3',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Header with animation
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(0, -0.3),
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
                            'Verifikasi OTP',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                            gradientColors: AppTheme.primaryGradientColors,
                          ),
                          
                          const SizedBox(height: 10),
                          
                          Text(
                            'Masukkan kode OTP yang telah dikirimkan ke $email',
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
                  
                  // Card container with animation
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(0, 0.3),
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
                            // OTP input field
                            Center(
                              child: OtpInput(
                                controller: _otpController,
                                isDark: isDark,
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Timer dan resend
                            Center(
                              child: _canResend
                                  ? TextButton.icon(
                                      onPressed: _resendOtp,
                                      icon: Icon(Icons.refresh),
                                      label: Text('Kirim Ulang Kode OTP'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppTheme.primaryGradientColors[0],
                                        textStyle: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Kode akan berakhir dalam ',
                                          style: TextStyle(
                                            color: isDark ? Colors.white70 : Colors.grey[700],
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          _timeLeft,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryGradientColors[0],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                            
                            // Error message
                            if (authProvider.errorMessage.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(top: 16, bottom: 16),
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
                            
                            // Verify button
                            AppTheme.gradientButton(
                              onPressed: _verifyOtp,
                              gradientColors: AppTheme.primaryGradientColors,
                              child: _isSubmitting
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Verifikasi',
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 