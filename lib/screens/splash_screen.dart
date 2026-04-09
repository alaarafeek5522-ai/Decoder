import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primaryGreen, width: 2),
              ),
              child: const Icon(
                Icons.code,
                size: 60,
                color: AppTheme.primaryGreen,
              ),
            ).animate().scale(duration: 500.ms).then().fade(),
            const SizedBox(height: 30),
            Text(
              'PY_Code',
              style: GoogleFonts.shareTechMono(
                fontSize: 36,
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ).animate().fadeIn(duration: 800.ms).then().shimmer(),
            const SizedBox(height: 10),
            Text(
              'Decoder • by Alaa & PY_Code',
              style: GoogleFonts.shareTechMono(
                fontSize: 14,
                color: Colors.grey,
              ),
            ).animate().fadeIn(delay: 500.ms),
            const SizedBox(height: 50),
            Container(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                strokeWidth: 2,
              ),
            ).animate().fadeIn(delay: 1000.ms),
          ],
        ),
      ),
    );
  }
}
