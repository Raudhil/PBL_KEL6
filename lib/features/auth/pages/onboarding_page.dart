import 'package:flutter/material.dart';
import 'package:jawara/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/onboarding_state.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _page = 0;

  final List<_OnboardItem> _items = const [
    _OnboardItem(
      title: 'Konektivitas',
      description: 'Cek informasi dan bayar iuran RT dengan mudah.',
      icon: Icons.home_work_outlined,
    ),
    _OnboardItem(
      title: 'Marketplace',
      description: 'Jual beli kebutuhan warga di marketplace lokal RT dengan mudah.',
      icon: Icons.storefront_outlined,
    ),
  ];

  Future<void> _goToLogin() async {
    // Mark onboarding as seen and persist it, then navigate to login using GoRouter
    try {
      final prefs = await SharedPreferences.getInstance();
      debugPrint('[Onboarding] persisting seenOnboarding=true');
      await prefs.setBool('seenOnboarding', true);
      OnboardingState.seenOnboarding = true;
      debugPrint('[Onboarding] OnboardingState.seenOnboarding set to true, navigating to /login (extra.fromOnboard=true)');
      // Pass an `extra` payload so the router redirect can allow this
      // navigation even if the onboarding flag hasn't been fully observed
      // elsewhere yet.
      context.go('/login', extra: {'fromOnboard': true});
    } catch (e, st) {
      debugPrint('[Onboarding] ERROR persisting seenOnboarding: $e\n$st');
      // Even if persisting fails, still navigate to login to avoid blocking the user
      OnboardingState.seenOnboarding = true;
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _items.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(item.icon, size: 96, color: AppColors.white),
                          const SizedBox(height: 20),
                          Text(
                            item.title,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item.description,
                            style: const TextStyle(color: AppColors.white, fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Dots
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_items.length, (i) {
                  final isActive = i == _page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: isActive ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.white : AppColors.white.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }),
              ),
            ),

            // Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: Row(
                children: [
                  TextButton(
                    onPressed: _goToLogin,
                    child: const Text('Skip', style: TextStyle(color: AppColors.white)),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      if (_page < _items.length - 1) {
                        _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      } else {
                        _goToLogin();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(_page < _items.length - 1 ? 'Next' : 'Get Started'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardItem {
  final String title;
  final String description;
  final IconData icon;
  const _OnboardItem({required this.title, required this.description, required this.icon});
}
