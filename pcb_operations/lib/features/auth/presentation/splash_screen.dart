import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(1.2.seconds, () {
      if (mounted && context.mounted) {
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Image.asset('assets/images/smk_logo.png', height: 44),
            )
                .animate()
                .fadeIn(duration: 800.ms)
                .scale(begin: const Offset(0.8, 0.8)),
            const Gap(20),
            Text(
              'Prakash Coach Builders',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 8),
            const Gap(8),
            Text(
              'Operations Management System',
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 2,
              ),
            ).animate().fadeIn(delay: 500.ms),
            const Spacer(flex: 3),
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.accent,
              ),
            ).animate().fadeIn(delay: 1000.ms),
            const Gap(8),
            Text(
              'Loading...',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 11,
              ),
            ).animate().fadeIn(delay: 1100.ms),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
