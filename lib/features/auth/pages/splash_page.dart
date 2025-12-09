import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/onboarding_state.dart';
import '../../../theme/app_colors.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Short delay to show splash then navigate
    _timer = Timer(const Duration(milliseconds: 500), _navigateNext);
  }

  Future<void> _navigateNext() async {
    if (!mounted) return;

    // If the onboarding hasn't been seen, go there first
    if (!OnboardingState.seenOnboarding) {
      debugPrint('[Splash] navigating to /onboarding (seenOnboarding=false)');
      if (mounted) GoRouter.of(context).go('/onboarding');
      return;
    }

    // Otherwise check if there is an active session
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      debugPrint('[Splash] session exists, navigating to /warga/dashboard');
      if (mounted) GoRouter.of(context).go('/warga/dashboard');
    } else {
      debugPrint('[Splash] no session, navigating to /login');
      if (mounted) GoRouter.of(context).go('/login');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo dengan container putih
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(5),
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) => const Icon(
                  Icons.home_work,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Nama aplikasi
            const Text(
              'Teras Warga',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            // Loading indicator
            const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
