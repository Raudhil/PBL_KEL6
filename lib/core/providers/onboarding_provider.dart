import 'package:flutter_riverpod/flutter_riverpod.dart';

// Tracks whether the onboarding has been seen by the user.
final seenOnboardingProvider = StateProvider<bool>((ref) => false);
