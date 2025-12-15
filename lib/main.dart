import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'routes/app_router.dart';
import 'theme/theme_provider.dart';
import 'theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/config/env_config.dart';
import 'core/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/onboarding_state.dart';
import 'core/providers/auth_state_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Indonesian locale for date formatting
  await initializeDateFormatting('id_ID', null);

  // ✅ Gunakan EnvConfig (auto-detect dev/prod environment)
  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 🔍 Print environment info untuk debugging (optional, bisa di-comment)
  EnvConfig.printEnvironmentInfo();

  // 🔧 Initialize AppConfig (load development mode setting)
  await AppConfig.initialize();
  debugPrint('[AppConfig] Development Mode: ${AppConfig.isDevelopmentMode}');

  // 🚨 Override Flutter error screen untuk production
  if (AppConfig.isProductionMode) {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Terjadi Kesalahan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Mohon maaf, terjadi kesalahan. Silakan coba lagi atau hubungi admin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      );
    };
  }

  // Read onboarding flag and store in a global so router can check it synchronously
  final prefs = await SharedPreferences.getInstance();
  // Read and log the onboarding flag for debugging
  final seen = prefs.getBool('seenOnboarding');
  OnboardingState.seenOnboarding = seen ?? false;
  // Use debugPrint to ensure the message is visible in Flutter logs
  debugPrint('[Onboarding] seenOnboarding from SharedPreferences: $seen');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);
    // Ensure auth enforcer provider is watched so it stays active and can
    // sign out users whose `status` is not 'aktif'. We don't use the
    // returned value; watching is sufficient to create the listener.
    // ignore: unused_local_variable
    final _authEnforcer = ref.watch(authEnforcerProvider);

    return MaterialApp.router(
      title: 'TerasWarga',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
