import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class TimerUtil {
  Timer? _timer;
  String _expiresAt;
  Function(String) _onTick;
  VoidCallback _onFinish;

  TimerUtil({
    required String expiresAt,
    required Function(String) onTick,
    required VoidCallback onFinish,
  })  : _expiresAt = expiresAt,
        _onTick = onTick,
        _onFinish = onFinish;

  // Memulai timer
  void start() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      final remainingTime = getRemainingTime(_expiresAt);
      if (remainingTime == Duration.zero) {
        _onFinish();
        _timer?.cancel();
      } else {
        _onTick(formatDuration(remainingTime));
      }
    });
  }

  // Menghentikan timer
  void dispose() {
    _timer?.cancel();
  }

  // Menghitung waktu yang tersisa dari tanggal kadaluarsa
  static Duration getRemainingTime(String expiresAt) {
    final expirationDateTime = DateTime.parse(expiresAt);
    final now = DateTime.now();
    
    if (expirationDateTime.isBefore(now)) {
      return Duration.zero;
    }
    
    return expirationDateTime.difference(now);
  }
  
  // Format durasi ke bentuk mm:ss
  static String formatDuration(Duration duration) {
    if (duration.isNegative) {
      return '00:00';
    }
    
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    
    return '$minutes:$seconds';
  }
  
  // Format timestamp ke format yang diinginkan
  static String formatTimestamp(String timestamp, {String format = 'dd MMM yyyy, HH:mm'}) {
    final dateTime = DateTime.parse(timestamp);
    final formatter = DateFormat(format);
    return formatter.format(dateTime);
  }
} 