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
            Image.asset(
              'assets/images/logo.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
              errorBuilder: (c, e, s) => const FlutterLogo(size: 96),
            ),
          ],
        ),
      ),
    );
  }
}
