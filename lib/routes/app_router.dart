import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers/auth_state_provider.dart';
import '../features/auth/pages/onboarding_page.dart';
import '../features/auth/pages/login_page.dart';
import '../features/auth/pages/splash_page.dart';
import '../core/onboarding_state.dart';
import '../features/warga/warga_main_page.dart';
import '../features/warga/pages/dashboard/dashboard_page.dart';
import '../features/warga/pages/marketplace/marketplace_page.dart';
import '../features/warga/pages/iuran/iuran_page.dart';
import '../features/warga/pages/profil/profil_page.dart';
import '../features/rt/pages/data_warga_keluarga_wrapper.dart';
import '../features/sekretaris/kegiatan/pages/kegiatan_list_page.dart';
import '../features/sekretaris/pengumuman/pengumuman_page.dart';
import '../features/bendahara/pages/keuangan/kelola_iuran.dart';
import '../features/bendahara/pages/keuangan_warga/keuangan_page.dart';
import '../features/admin/pages/kelola_pengguna_page.dart';
import '../features/admin/pages/system_settings_page.dart';
import '../features/admin/pages/log_activity_page.dart';
import '../features/rw/pages/laporan_keuangan_rw_page.dart';
import '../features/rw/pages/data_warga_rw_page.dart';
import '../core/widgets/app_error_page.dart';
import '../core/widgets/maintenance_page.dart';
import '../core/utils/page_transitions.dart';

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
    // Start at a short Splash page which will decide where to navigate next
    // (onboarding / login / dashboard). Using a splash avoids racing with
    // redirect logic and gives a consistent startup UX.
    initialLocation: '/splash',
    debugLogDiagnostics: true,

    // Redirect logic based on auth state and role
    redirect: (context, state) {
      // Debug log: show current onboarding flag and requested route
      debugPrint(
        '[Router] redirect check - seenOnboarding=${OnboardingState.seenOnboarding}, uri.path=${state.uri.path}',
      );
      final location = state.uri.path; // use uri.path to check requested path
      debugPrint('[Router] uri.path=$location');

      // Allow the splash page to load and perform its own navigation.
      if (location == '/splash') return null;
      // If onboarding hasn't been seen yet, short-circuit: allow staying on
      // `/onboarding` but force other routes to `/onboarding`. This prevents
      // the auth redirect from kicking in while onboarding is shown.
      if (!OnboardingState.seenOnboarding) {
        // While onboarding hasn't been seen, allow both splash and onboarding
        // to render so the splash can route to onboarding without being
        // redirected away prematurely.
        if (location == '/onboarding' || location == '/splash') return null;
        return '/onboarding';
      }

      final isAuthenticated = authState.asData?.value.session != null;
      final isLoggingIn = state.matchedLocation == '/login';

      // If not authenticated and not on login page, redirect to login
      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }

      // If authenticated and on login page, redirect to dashboard
      if (isAuthenticated && isLoggingIn) {
        return '/warga/dashboard';
      }

      return null; // No redirect needed
    },

    routes: [
      // ============= AUTH ROUTES =============
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
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

      // ============= RT ROUTES =============
      GoRoute(
        path: '/rt',
        name: 'rt',
        builder: (context, state) => const _PlaceholderPage(role: 'RT'),
      ),
      GoRoute(
        path: '/rt/data-warga',
        name: 'rt-data-warga',
        builder: (context, state) => const DataWargaKeluargaWrapper(),
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
      GoRoute(
        path: '/sekretaris/kegiatan',
        name: 'sekretaris-kegiatan',
        pageBuilder: (context, state) => CustomPageTransition.sharedAxis(
          child: const KegiatanListPage(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/sekretaris/pengumuman',
        name: 'sekretaris-pengumuman',
        pageBuilder: (context, state) => CustomPageTransition.sharedAxis(
          child: const PengumumanPage(),
          state: state,
        ),
      ),

      // ============= BENDAHARA ROUTES =============
      GoRoute(
        path: '/bendahara',
        name: 'bendahara',
        builder: (context, state) => const _PlaceholderPage(role: 'Bendahara'),
      ),
      GoRoute(
        path: '/bendahara/kelola-iuran',
        name: 'bendahara-kelola-iuran',
        pageBuilder: (context, state) => CustomPageTransition.sharedAxis(
          child: const KelolaIuranPage(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/bendahara/keuangan',
        name: 'bendahara-keuangan',
        pageBuilder: (context, state) => CustomPageTransition.sharedAxis(
          child: const KeuanganPage(),
          state: state,
        ),
      ),

      // ============= ADMIN ROUTES =============
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const _PlaceholderPage(role: 'Admin'),
      ),
      GoRoute(
        path: '/admin/kelola-pengguna',
        name: 'admin-kelola-pengguna',
        pageBuilder: (context, state) => CustomPageTransition.sharedAxis(
          child: const KelolaPenggunaPage(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/admin/pengaturan-sistem',
        name: 'admin-pengaturan-sistem',
        pageBuilder: (context, state) => CustomPageTransition.sharedAxis(
          child: const SystemSettingsPage(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/admin/log-aktivitas',
        name: 'admin-log-aktivitas',
        pageBuilder: (context, state) => CustomPageTransition.sharedAxis(
          child: const LogActivityPage(),
          state: state,
        ),
      ),
      // RW Routes
      GoRoute(
        path: '/rw/laporan-keuangan',
        name: 'rw-laporan-keuangan',
        pageBuilder: (context, state) => CustomPageTransition.sharedAxis(
          child: const LaporanKeuanganRwPage(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/rw/data-warga',
        name: 'rw-data-warga',
        pageBuilder: (context, state) => CustomPageTransition.sharedAxis(
          child: const DataWargaRwPage(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/admin/monitoring-sistem',
        name: 'admin-monitoring-sistem',
        pageBuilder: (context, state) => CustomPageTransition.sharedAxis(
          child: const AppErrorPage(
            errorMessage: 'Simulasi Error: Koneksi ke server monitoring gagal',
            errorDetails:
                'Error Code: 503\nService Unavailable\n\nDetail:\n- Database monitoring service sedang offline\n- Uptime monitor tidak dapat diakses\n- Real-time analytics unavailable',
          ),
          state: state,
        ),
      ),

      // ============= MAINTENANCE PAGE =============
      GoRoute(
        path: '/maintenance',
        name: 'maintenance',
        builder: (context, state) {
          final featureName = state.uri.queryParameters['feature'];
          final message = state.uri.queryParameters['message'];
          final estimatedTime = state.uri.queryParameters['time'];

          return MaintenancePage(
            featureName: featureName,
            message: message,
            estimatedTime: estimatedTime,
          );
        },
      ),
    ],

    // Error page dengan UI yang lebih baik
    errorBuilder: (context, state) =>
        AppErrorPage(errorMessage: state.error?.toString()),
  );
});
