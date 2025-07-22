import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for SystemUiOverlayStyle

class AppTheme {
  static final Color _primaryColor = Color(0xFF6E4A6C);
  static final Color _accentColor = Color(0xFF524168);
  
  static const String fontFamily = 'Poppins';

  // Gradient colors untuk UI
  static const List<Color> primaryGradientColors = [
    Color(0xFF9C27B0),
    Color(0xFF673AB7),
    Color(0xFF3F51B5),
    Color(0xFF2196F3),
  ];
  
  static const List<Color> secondaryGradientColors = [
    Color(0xFF6E4A6C),
    Color(0xFF9C27B0),
  ];

  static const List<Color> backgroundGradientLight = [
    Color(0xFFF5F7FA),
    Color(0xFFEEF2F7),
  ];

  static const List<Color> backgroundGradientDark = [
    Color(0xFF121212),
    Color(0xFF1E1E2C),
  ];

  static const List<Color> cardGradientLight = [
    Color(0xFFFFFFFF),
    Color(0xFFF0F0F5),
  ];

  static const List<Color> cardGradientDark = [
    Color(0xFF2A2D3E),
    Color(0xFF212332),
  ];

  static const List<Color> buttonGradient = [
    Color(0xFF9C27B0),
    Color(0xFF673AB7),
  ];

  static const List<Color> successGradient = [
    Color(0xFF4CAF50),
    Color(0xFF8BC34A),
  ];

  static const List<Color> errorGradient = [
    Color(0xFFF44336),
    Color(0xFFFF5722),
  ];

  // Animation durations
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 400);
  static const Duration animationDurationLong = Duration(milliseconds: 800);

  // Border radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 20.0;
  static const double borderRadiusExtraLarge = 30.0;

  // Shadows
  static List<BoxShadow> lightShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      spreadRadius: 1,
      blurRadius: 15,
      offset: Offset(0, 5),
    ),
  ];

  static List<BoxShadow> darkShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      spreadRadius: 1,
      blurRadius: 10,
      offset: Offset(0, 5),
    ),
  ];

  // Light theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: fontFamily,
    colorScheme: ColorScheme.light(
      primary: _primaryColor,
      secondary: _accentColor,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black87,
    ),
    textTheme: _buildTextTheme(ThemeData.light().textTheme),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shadowColor: Colors.transparent,
      ).copyWith(
        backgroundColor: WidgetStateProperty.all(Colors.transparent),
        foregroundColor: WidgetStateProperty.all(Colors.white),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide(color: _primaryColor, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide(color: Colors.red, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: fontFamily,
        color: Colors.black87,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: Colors.black87),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      foregroundColor: Colors.black87,
    ),
    scaffoldBackgroundColor: Colors.transparent,
    cardTheme: CardThemeData(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: _primaryColor,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.normal,
        fontSize: 12,
      ),
    ),
  );

  // Dark theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: fontFamily,
    colorScheme: ColorScheme.dark(
      primary: _primaryColor,
      secondary: _accentColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white70,
      surface: Color(0xFF1E1E1E),
      onSurface: Colors.white,
    ),
    textTheme: _buildTextTheme(ThemeData.dark().textTheme),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shadowColor: Colors.transparent,
      ).copyWith(
        backgroundColor: WidgetStateProperty.all(Colors.transparent),
        foregroundColor: WidgetStateProperty.all(Colors.white),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF2C2C2C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide(color: _primaryColor, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide(color: Colors.red, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: fontFamily,
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: Colors.white),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      foregroundColor: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.transparent,
    cardTheme: CardThemeData(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E2C),
      selectedItemColor: _primaryColor,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.normal,
        fontSize: 12,
      ),
    ),
  );
  
  // Helper method to apply Poppins font to text theme
  static TextTheme _buildTextTheme(TextTheme baseTextTheme) {
    return baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge!.copyWith(fontFamily: fontFamily, fontWeight: FontWeight.bold),
      displayMedium: baseTextTheme.displayMedium!.copyWith(fontFamily: fontFamily, fontWeight: FontWeight.bold),
      displaySmall: baseTextTheme.displaySmall!.copyWith(fontFamily: fontFamily, fontWeight: FontWeight.bold),
      headlineLarge: baseTextTheme.headlineLarge!.copyWith(fontFamily: fontFamily, fontWeight: FontWeight.bold),
      headlineMedium: baseTextTheme.headlineMedium!.copyWith(fontFamily: fontFamily, fontWeight: FontWeight.w600),
      headlineSmall: baseTextTheme.headlineSmall!.copyWith(fontFamily: fontFamily, fontWeight: FontWeight.w600),
      titleLarge: baseTextTheme.titleLarge!.copyWith(fontFamily: fontFamily, fontWeight: FontWeight.w600),
      titleMedium: baseTextTheme.titleMedium!.copyWith(fontFamily: fontFamily, fontWeight: FontWeight.w600),
      titleSmall: baseTextTheme.titleSmall!.copyWith(fontFamily: fontFamily, fontWeight: FontWeight.w500),
      bodyLarge: baseTextTheme.bodyLarge!.copyWith(fontFamily: fontFamily),
      bodyMedium: baseTextTheme.bodyMedium!.copyWith(fontFamily: fontFamily),
      bodySmall: baseTextTheme.bodySmall!.copyWith(fontFamily: fontFamily),
      labelLarge: baseTextTheme.labelLarge!.copyWith(fontFamily: fontFamily, fontWeight: FontWeight.w500),
      labelMedium: baseTextTheme.labelMedium!.copyWith(fontFamily: fontFamily, fontWeight: FontWeight.w500),
      labelSmall: baseTextTheme.labelSmall!.copyWith(fontFamily: fontFamily, fontWeight: FontWeight.w500),
    );
  }
  
  // Helper untuk membuat gradient text
  static Widget gradientText(
    String text, {
    required TextStyle style,
    List<Color>? gradientColors,
    List<double>? stops,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
    TextAlign textAlign = TextAlign.center,
  }) {
    // Pastikan jumlah stops sesuai dengan jumlah warna
    final colors = gradientColors ?? primaryGradientColors;
    final actualStops = stops ?? List.generate(
      colors.length, 
      (index) => index / (colors.length - 1)
    );
    
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: colors,
        stops: actualStops,
        begin: begin,
        end: end,
      ).createShader(bounds),
      child: Text(
        text,
        style: style.copyWith(color: Colors.white),
        textAlign: textAlign,
      ),
    );
  }

  // Helper untuk membuat gradient container
  static BoxDecoration gradientBoxDecoration({
    List<Color>? gradientColors,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
    double borderRadius = borderRadiusMedium,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: gradientColors ?? primaryGradientColors,
        begin: begin,
        end: end,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: boxShadow,
    );
  }

  // Helper untuk membuat gradient button
  static Widget gradientButton({
    required Widget child,
    required VoidCallback onPressed,
    List<Color>? gradientColors,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    double borderRadius = borderRadiusMedium,
    List<BoxShadow>? boxShadow,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors ?? buttonGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow ?? lightShadow,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: padding,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: child,
      ),
    );
  }

  // Helper untuk membuat gradient card
  static Widget gradientCard({
    required Widget child,
    List<Color>? gradientColors,
    double borderRadius = borderRadiusMedium,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    List<BoxShadow>? boxShadow,
    bool isDark = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors ?? (isDark ? cardGradientDark : cardGradientLight),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow ?? (isDark ? darkShadow : lightShadow),
      ),
      padding: padding,
      child: child,
    );
  }

  // Helper untuk membuat gradient background
  static Widget gradientBackground({
    required Widget child,
    List<Color>? gradientColors,
    AlignmentGeometry begin = Alignment.topCenter,
    AlignmentGeometry end = Alignment.bottomCenter,
    bool isDark = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors ?? (isDark ? backgroundGradientDark : backgroundGradientLight),
          begin: begin,
          end: end,
        ),
      ),
      child: child,
    );
  }
} 