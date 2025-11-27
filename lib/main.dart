import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'routes/app_router.dart';
import 'theme/theme_provider.dart';
import 'theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/config/env_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/onboarding_state.dart';
import 'core/providers/auth_state_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Gunakan EnvConfig (auto-detect dev/prod environment)
  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 🔍 Print environment info untuk debugging (optional, bisa di-comment)
  EnvConfig.printEnvironmentInfo();

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
      title: 'JAWARA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
