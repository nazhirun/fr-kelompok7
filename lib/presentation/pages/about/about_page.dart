import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:myatk/data/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _backgroundController;
  final List<AnimationController> _developerCardControllers = [];
  
  @override
  void initState() {
    super.initState();
    
    // Header animation controller
    _headerAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    
    // Background animation controller
    _backgroundController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 30),
    )..repeat();
    
    // Create animation controllers for developer cards
    for (int i = 0; i < 4; i++) {
      _developerCardControllers.add(
        AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 300),
        )
      );
    }
    
    // Start header animation when widget is loaded
    _headerAnimationController.forward();
  }
  
  @override
  void dispose() {
    _headerAnimationController.dispose();
    _backgroundController.dispose();
    for (var controller in _developerCardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Tim Pengembang', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(0, 238, 229, 229),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark 
                ? [Color(0xFF3F2B63), Color(0xFF2B2440)]
                : [Color(0xFF9C27B0), Color(0xFF6E4A6C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  isDark ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.7),
                  BlendMode.dstATop,
                ),
              ),
              gradient: LinearGradient(
                colors: isDark 
                  ? [Color(0xFF121212), Color(0xFF1E1E2C)]
                  : [Color(0xFFF5F7FA), Color(0xFFEEF2F7)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: AnimationLimiter(
              child: ListView(
                padding: EdgeInsets.only(top: 100, bottom: 20, left: 20, right: 20),
                children: [
                  _buildAnimatedTeamHeader(isDark),
                  SizedBox(height: 40),
                  
                  // Backend Developers
                  AnimationConfiguration.synchronized(
                    duration: const Duration(milliseconds: 800),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: _buildSectionTitle('Backend Developers', isDark),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildAnimatedDeveloperCard(
                    index: 0,
                    name: 'Nazhirun Mardhiy',
                    nim: '2210059',
                    role: 'Backend Lead Developer',
                    description: 'Bertanggung jawab untuk arsitektur backend, Membuat Website ,integrasi ke hosting, pengembangan API, dan database design menggunakan Laravel.',
                    imageUrl: 'assets/images/nazir.jpg',
                    isLocalImage: true,
                    skills: ['Laravel', 'MySQL', 'Server'],
                    isDark: isDark,
                  ),
                  SizedBox(height: 16),
                  _buildAnimatedDeveloperCard(
                    index: 1,
                    name: 'Bima Pratama Putra',
                    nim: '2210200',
                    role: 'Backend Developer',
                    description: 'Fokus pada pengembangan fitur API, autentikasi, dan keamanan data.',
                    imageUrl: 'assets/images/bima.jpg',
                    isLocalImage: true,
                    skills: ['PHP', 'Laravel', 'MySQL'],
                    isDark: isDark,
                  ),
                  
                  SizedBox(height: 30),
                  
                  // Frontend Developer
                  AnimationConfiguration.synchronized(
                    duration: const Duration(milliseconds: 800),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: _buildSectionTitle('Frontend Developer', isDark),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildAnimatedDeveloperCard(
                    index: 2,
                    name: 'Idham Khalid',
                    nim: '2410017',
                    role: 'UI/UX Frontend Developer',
                    description: 'Bertanggung jawab untuk desain antarmuka, user experience, dan wireframing.',
                    imageUrl: 'assets/images/khalid.jpg',
                    isLocalImage: true,
                    skills: ['Flutter', 'Dart', 'Canva'],
                    isDark: isDark,
                  ),
                  
                  SizedBox(height: 20),
                  _buildAnimatedDeveloperCard(
                    index: 3,
                    name: 'Hutrila Afdhal',
                    nim: '2420006',
                    role: 'Frontend Developer',
                    description: 'Bertanggung jawab untuk pengembangan aplikasi mobile, integrasi API, dan state management.',
                    imageUrl: 'assets/images/afdal.jpg',
                    isLocalImage: true,
                    skills: ['Flutter', 'Dart', 'Provider'],
                    isDark: isDark,
                  ),
                  
                  SizedBox(height: 40),
                  
                  // App Info
                  AnimationConfiguration.synchronized(
                    duration: const Duration(milliseconds: 800),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: _buildAppInfo(isDark),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedTeamHeader(bool isDark) {
    return FadeTransition(
      opacity: _headerAnimationController.drive(
        CurveTween(curve: Curves.easeOut)
      ),
      child: SlideTransition(
        position: _headerAnimationController.drive(
          Tween<Offset>(
            begin: Offset(0, -0.5),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOut)),
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Text shadernya tetap agar terlihat menarik
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    Color(0xFF9C27B0),
                    Color(0xFF673AB7),
                    Color(0xFF3F51B5),
                    Color(0xFF2196F3),
                  ],
                  stops: [0.1, 0.3, 0.7, 0.9],
                ).createShader(bounds),
                child: Text(
                  'MyATK Development Team',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 15),
              Text(
                'Kami adalah kelompok MyATK Kelas Kerja untuk matakuliah Mobile 1 dengan Dosen Pengampun Isnardi, S.Kom, M.Kom \n yang berdedikasi untuk mengembangkan aplikasi MyATK guna memudahkan manajemen inventaris alat tulis kantor',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF6E4A6C),
            Color(0xFF9C27B0),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5), // Tingkatkan bayangan
            blurRadius: 15, // Tingkatkan blur
            offset: Offset(0, 6), // Tingkatkan offset
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getIconForSection(title),
            color: Colors.white,
            size: 20,
          ),
          SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  IconData _getIconForSection(String title) {
    switch (title) {
      case 'Backend Developers':
        return Icons.storage;
      case 'Frontend Developer':
        return Icons.phone_iphone;
      case 'UI/UX Designer':
        return Icons.design_services;
      default:
        return Icons.people;
    }
  }

  Widget _buildAnimatedDeveloperCard({
    required int index,
    required String name,
    required String role,
    required String description,
    required String imageUrl,
    required String nim,
    bool isLocalImage = false,
    required List<String> skills,
    required bool isDark,
  }) {
    // Use staggered animation to animate cards with delay based on index
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 600),
      delay: Duration(milliseconds: 200 * index),
      child: SlideAnimation(
        horizontalOffset: 100.0,
        child: FadeInAnimation(
          child: MouseRegion(
            onEnter: (_) => _developerCardControllers[index].forward(),
            onExit: (_) => _developerCardControllers[index].reverse(),
            child: AnimatedBuilder(
              animation: _developerCardControllers[index],
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_developerCardControllers[index].value * 0.05),
                  child: Card(
                    elevation: 8 + (_developerCardControllers[index].value * 5), // Tingkatkan elevasi
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: Colors.white, // Hapus transparansi
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header with image and basic info
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF6E4A6C),
                                Color(0xFF9C27B0),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: 20),
                              Hero(
                                tag: 'dev_image_$index',
                                child: TweenAnimationBuilder(
                                  duration: Duration(seconds: 2),
                                  tween: Tween<double>(begin: 0, end: 2 * math.pi),
                                  builder: (_, double value, Widget? child) {
                                    return Transform.rotate(
                                      angle: math.sin(value) * 0.05,
                                      child: child,
                                    );
                                  },
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 3),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: isLocalImage 
                                        ? Image.asset(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Center(
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  value: loadingProgress.expectedTotalBytes != null
                                                      ? loadingProgress.cumulativeBytesLoaded / 
                                                        loadingProgress.expectedTotalBytes!
                                                      : null,
                                                ),
                                              );
                                            },
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ShaderMask(
                                      shaderCallback: (bounds) => LinearGradient(
                                        colors: [Colors.white, Colors.white70],
                                        stops: [0.7, 1.0],
                                      ).createShader(bounds),
                                      child: Text(
                                        name,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      role,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.9),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      "Nomor BP: $nim",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.verified,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            'Verified Developer',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Description
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.description, 
                                    color: Color(0xFF6E4A6C), 
                                    size: 18
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Deskripsi',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF6E4A6C),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Color(0xFF6E4A6C).withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              
                              SizedBox(height: 16),
                              
                              // Skills
                              Row(
                                children: [
                                  Icon(Icons.lightbulb_outline, 
                                    color: Color(0xFF6E4A6C), 
                                    size: 18
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Keahlian',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF6E4A6C),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: skills.asMap().entries.map((entry) {
                                  int idx = entry.key;
                                  String skill = entry.value;
                                  return TweenAnimationBuilder<double>(
                                    tween: Tween<double>(begin: 0, end: 1),
                                    duration: Duration(milliseconds: 600 + (idx * 100)),
                                    builder: (context, value, child) {
                                      return Transform.scale(
                                        scale: value,
                                        child: Opacity(
                                          opacity: value,
                                          child: Chip(
                                            avatar: Icon(
                                              _getIconForSkill(skill),
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                            label: Text(
                                              skill,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            backgroundColor: Color(0xFF6E4A6C),
                                            elevation: 3,
                                            shadowColor: Colors.black45,
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            ),
          ),
        ),
      ),
    );
  }
  
  IconData _getIconForSkill(String skill) {
    if (skill.toLowerCase().contains('php')) return Icons.code;
    if (skill.toLowerCase().contains('flutter')) return Icons.flutter_dash;
    if (skill.toLowerCase().contains('dart')) return Icons.circle;
    if (skill.toLowerCase().contains('figma')) return Icons.palette;
    if (skill.toLowerCase().contains('xd')) return Icons.design_services;
    if (skill.toLowerCase().contains('ui')) return Icons.dashboard_customize;
    if (skill.toLowerCase().contains('laravel')) return Icons.check_circle;
    if (skill.toLowerCase().contains('sql')) return Icons.storage;
    if (skill.toLowerCase().contains('api')) return Icons.api;
    if (skill.toLowerCase().contains('python')) return Icons.code;
    if (skill.toLowerCase().contains('prototyping')) return Icons.widgets;
    if (skill.toLowerCase().contains('provider')) return Icons.extension;
    if (skill.toLowerCase().contains('redis')) return Icons.data_object;
    return Icons.code;
  }

  Widget _buildAppInfo(bool isDark) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(seconds: 1),
      curve: Curves.elasticOut,
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Card(
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: Color(0xFF6E4A6C).withOpacity(0.9),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.white70,
                        Colors.white,
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ).createShader(bounds),
                    child: Text(
                      'MyATK v1.0.0',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: Duration(seconds: 2),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.copyright,
                                size: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              SizedBox(width: 5),
                              Text(
                                '2023 MyATK Development Team',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 10),
                  Text(
                    'All Rights Reserved',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
} 