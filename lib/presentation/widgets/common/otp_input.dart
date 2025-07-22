import 'package:flutter/material.dart';
import 'package:myatk/core/constants/app_constants.dart';
import 'package:myatk/core/theme/app_theme.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String)? onChanged;
  final bool hasError;
  final String? errorText;
  final bool isDark;

  const OtpInput({
    Key? key,
    required this.controller,
    this.onChanged,
    this.hasError = false,
    this.errorText,
    this.isDark = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PinCodeTextField(
          appContext: context,
          length: AppConstants.otpLength,
          controller: controller,
          onChanged: onChanged ?? (value) {},
          keyboardType: TextInputType.number,
          autoFocus: true,
          animationDuration: AppTheme.animationDurationShort,
          textStyle: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: AppTheme.fontFamily,
          ),
          cursorColor: AppTheme.primaryGradientColors[0],
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            fieldHeight: 55,
            fieldWidth: 45,
            activeFillColor: isDark ? Color(0xFF272042) : Colors.white,
            inactiveFillColor: isDark ? Color(0xFF272042) : Colors.white,
            // ignore: deprecated_member_use
            selectedFillColor: isDark ? Color(0xFF272042).withOpacity(0.7) : Colors.white.withOpacity(0.9),
            activeColor: hasError
                ? Colors.red
                : AppTheme.primaryGradientColors[0],
            inactiveColor: isDark ? Colors.grey.withOpacity(0.3) : Colors.grey.withOpacity(0.4),
            selectedColor: AppTheme.primaryGradientColors[0],
          ),
          enableActiveFill: true,
          animationType: AnimationType.fade,
          backgroundColor: Colors.transparent,
        ),
        if (hasError && errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              errorText!,
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
          ),
      ],
    );
  }
} 