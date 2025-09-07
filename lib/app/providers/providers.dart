import 'package:mindhearth/core/services/chat_service.dart';
import 'package:mindhearth/core/providers/onboarding_provider.dart';
import 'package:mindhearth/core/providers/safety_code_provider.dart';
import 'package:mindhearth/core/providers/auth_provider.dart';
import 'package:mindhearth/core/providers/api_providers.dart';

// Re-export providers from the new centralized location
export 'package:mindhearth/core/providers/auth_provider.dart';
export 'package:mindhearth/core/providers/onboarding_provider.dart';
export 'package:mindhearth/core/providers/safety_code_provider.dart';
export 'package:mindhearth/core/providers/api_providers.dart';
export 'package:mindhearth/core/services/chat_service.dart';

// Export all providers for easy access
final appProviders = [
  apiServiceProvider,
  authNotifierProvider,
  authStateProvider,
  chatServiceProvider,
  onboardingNotifierProvider,
  onboardingStateProvider,
  safetyCodeNotifierProvider,
  safetyCodeStateProvider,
];
