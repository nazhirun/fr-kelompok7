import 'dart:async';
import 'package:flutter/material.dart';
import 'package:myatk/core/constants/app_constants.dart';
import 'package:myatk/core/utils/timer_util.dart';
import 'package:myatk/core/validators/auth_validator.dart';
import 'package:myatk/data/providers/auth_provider.dart';
import 'package:myatk/presentation/pages/dashboard/dashboard_page.dart';
import 'package:myatk/presentation/pages/auth/login_page.dart';
import 'package:myatk/presentation/widgets/common/loading_button.dart';
import 'package:myatk/presentation/widgets/common/otp_input.dart';
import 'package:provider/provider.dart';

class VerifyOtpPage extends StatefulWidget {
  const VerifyOtpPage({Key? key}) : super(key: key);

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final TextEditingController _otpController = TextEditingController();
  Timer? _timer;
  Duration _remainingTime = Duration.zero;
  bool _otpIsValid = true;
  String? _otpError;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.expiresAt == null) return;

    // Set initial remaining time
    setState(() {
      _remainingTime = TimerUtil.getRemainingTime(authProvider.expiresAt!);
    });

    // Update every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (_remainingTime.inSeconds > 0) {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  void _onOtpChanged(String value) {
    setState(() {
      _otpIsValid = true;
      _otpError = null;
    });
  }

  Future<void> _verifyOtp() async {
    // Validasi OTP
    final error = AuthValidator.validateOtp(_otpController.text);

    if (error != null) {
      setState(() {
        _otpIsValid = false;
        _otpError = error;
      });
      return;
    }

    final result = await Provider.of<AuthProvider>(
      context,
      listen: false,
    ).verifyOtp(otp: _otpController.text);

    if (result) {
      // Tampilkan alert sukses kemudian kembali ke halaman login
      _showSuccessDialog();
    } else {
      // OTP tidak valid
      setState(() {
        _otpIsValid = false;
        _otpError = 'Kode OTP tidak valid';
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Verifikasi Berhasil'),
          content: Text(
            'Akun Anda telah berhasil diverifikasi. Silakan login kembali.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog

                // Arahkan ke halaman login
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => LoginPage()),
                  (route) => false,
                );
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _resendOtp() async {
    if (_remainingTime.inSeconds > 0) return;

    final result = await Provider.of<AuthProvider>(
      context,
      listen: false,
    ).resendOtp();

    if (result) {
      // Reset timer
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Verifikasi OTP')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Header
              Text(
                'Masukkan Kode OTP',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Kode OTP telah dikirim ke email Anda. Masukkan kode tersebut untuk verifikasi akun.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),

              const SizedBox(height: 40),

              // OTP input
              OtpInput(
                controller: _otpController,
                onChanged: _onOtpChanged,
                hasError: !_otpIsValid,
                errorText: _otpError,
              ),

              const SizedBox(height: 24),

              // Timer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: _remainingTime.inSeconds > 0
                        ? Theme.of(context).colorScheme.primary
                        : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sisa waktu: ${TimerUtil.formatDuration(_remainingTime)}',
                    style: TextStyle(
                      color: _remainingTime.inSeconds > 0
                          ? Theme.of(context).colorScheme.primary
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Error message
              if (authProvider.errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    authProvider.errorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 24),

              // Verify button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: LoadingButton(
                  text: 'Verifikasi',
                  onPressed: _verifyOtp,
                  isLoading: authProvider.loading,
                ),
              ),

              const SizedBox(height: 24),

              // Resend link
              TextButton(
                onPressed: _remainingTime.inSeconds > 0 ? null : _resendOtp,
                child: Text(
                  'Kirim Ulang OTP',
                  style: TextStyle(
                    color: _remainingTime.inSeconds > 0
                        ? Colors.grey
                        : Theme.of(context).colorScheme.primary,
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
