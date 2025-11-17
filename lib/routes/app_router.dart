import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers/auth_state_provider.dart';
import '../features/auth/login_page.dart';
import '../features/warga/warga_main_page.dart';
import '../features/warga/pages/dashboard/dashboard_page.dart';
import '../features/warga/pages/marketplace/marketplace_page.dart';
import '../features/warga/pages/iuran/iuran_page.dart';
import '../features/warga/pages/profil/profil_page.dart';

// Placeholder pages for unimplemented roles
class _PlaceholderPage extends StatelessWidget {
  final String role;
  const _PlaceholderPage({required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$role Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '$role Dashboard',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Halaman ini belum diimplementasikan'),
          ],
        ),
      ),
    );
  }
}

// Router provider that handles auth state changes
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,

    // Redirect logic based on auth state and role
    redirect: (context, state) {
      final isAuthenticated = authState.asData?.value.session != null;
      final isLoggingIn = state.matchedLocation == '/login';

      // If not authenticated and not on login page, redirect to login
      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }

      // If authenticated and on login page, redirect based on role
      if (isAuthenticated && isLoggingIn) {
        final user = authState.asData?.value.session?.user;
        if (user?.email != null) {
          // Get role synchronously from cache or default to warga
          return '/warga/dashboard';
        }
      }

      return null; // No redirect needed
    },

    routes: [
      // ============= AUTH ROUTES =============
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // ============= WARGA ROUTES =============
      // Warga mode (regular user view with navbar)
      ShellRoute(
        builder: (context, state, child) {
          return WargaMainPage(child: child);
        },
        routes: [
          GoRoute(
            path: '/warga/dashboard',
            name: 'warga-dashboard',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: WargaDashboardPage()),
          ),
          GoRoute(
            path: '/warga/marketplace',
            name: 'warga-marketplace',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: WargaMarketplacePage()),
          ),
          GoRoute(
            path: '/warga/iuran',
            name: 'warga-iuran',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: WargaIuranPage()),
          ),
          GoRoute(
            path: '/warga/profil',
            name: 'warga-profil',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: WargaProfilPage()),
          ),
        ],
      ),

      // Seller mode (marketplace seller view - different navbar/features)
      // TODO: Create SellerShellRoute with different navbar
      GoRoute(
        path: '/seller',
        name: 'seller-dashboard',
        builder: (context, state) => const _PlaceholderPage(role: 'Seller'),
      ),

      // ============= ADMIN ROUTES =============
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const _PlaceholderPage(role: 'Admin'),
      ),

      // ============= RT ROUTES =============
      GoRoute(
        path: '/rt',
        name: 'rt',
        builder: (context, state) => const _PlaceholderPage(role: 'RT'),
      ),

      // ============= RW ROUTES =============
      GoRoute(
        path: '/rw',
        name: 'rw',
        builder: (context, state) => const _PlaceholderPage(role: 'RW'),
      ),

      // ============= SEKRETARIS ROUTES =============
      GoRoute(
        path: '/sekretaris',
        name: 'sekretaris',
        builder: (context, state) => const _PlaceholderPage(role: 'Sekretaris'),
      ),

      // ============= BENDAHARA ROUTES =============
      GoRoute(
        path: '/bendahara',
        name: 'bendahara',
        builder: (context, state) => const _PlaceholderPage(role: 'Bendahara'),
      ),
    ],

    // Error page
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: ${state.error}',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
});
