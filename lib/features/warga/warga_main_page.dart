import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/custom_bottom_navbar.dart';
import '../../core/widgets/custom_top_bar.dart';

class WargaMainPage extends ConsumerWidget {
  final Widget child;

  const WargaMainPage({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current route to determine active tab
    final location = GoRouterState.of(context).matchedLocation;

    // Map routes to indexes
    int currentIndex = 0;
    String title = 'Dashboard';

    if (location.contains('/dashboard')) {
      currentIndex = 0;
      title = 'Dashboard';
    } else if (location.contains('/marketplace')) {
      currentIndex = 1;
      title = 'Marketplace';
    } else if (location.contains('/iuran')) {
      currentIndex = 2;
      title = 'Iuran';
    } else if (location.contains('/profil')) {
      currentIndex = 3;
      title = 'Profil';
    }

    return Scaffold(
      appBar: CustomTopBar(title: title),
      body: child, // Display the child route
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          // Navigate using GoRouter
          switch (index) {
            case 0:
              context.go('/warga/dashboard');
              break;
            case 1:
              context.go('/warga/marketplace');
              break;
            case 2:
              context.go('/warga/iuran');
              break;
            case 3:
              context.go('/warga/profil');
              break;
          }
        },
      ),
    );
  }
}
