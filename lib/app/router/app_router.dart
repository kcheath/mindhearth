import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/providers/auth_provider.dart';
import 'package:mindhearth/core/models/auth_state.dart';
import 'package:mindhearth/core/providers/onboarding_provider.dart';
import 'package:mindhearth/core/models/onboarding_state.dart';
import 'package:mindhearth/core/providers/safety_code_provider.dart';
import 'package:mindhearth/core/models/safety_code_state.dart';
import 'package:mindhearth/core/config/logging_config.dart';
import 'package:mindhearth/core/utils/logger.dart';
import 'package:mindhearth/features/auth/presentation/pages/login_page.dart';
import 'package:mindhearth/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:mindhearth/features/safetycode/presentation/pages/safety_code_page.dart';
import 'package:mindhearth/features/chat/presentation/pages/chat_page.dart';
import 'package:mindhearth/features/sessions/presentation/pages/sessions_page.dart';
import 'package:mindhearth/features/journal/presentation/pages/journal_page.dart';
import 'package:mindhearth/features/documents/presentation/pages/documents_page.dart';
import 'package:mindhearth/features/reports/presentation/pages/reports_page.dart';
import 'package:mindhearth/features/settings/presentation/pages/settings_page.dart';
import 'package:mindhearth/features/settings/presentation/pages/privacy_security_settings_page.dart';
import 'package:flutter/foundation.dart';

// GoRouter Refresh Stream for Riverpod integration
class GoRouterRefreshStream extends ChangeNotifier {
  late final ProviderSubscription<AuthState> _authStateSubscription;
  late final ProviderSubscription<OnboardingState> _onboardingStateSubscription;
  late final ProviderSubscription<SafetyCodeState> _safetyCodeStateSubscription;

  GoRouterRefreshStream(Ref ref) {
    _authStateSubscription = ref.listen(authStateProvider, (previous, next) {
      notifyListeners();
    });
    _onboardingStateSubscription = ref.listen(onboardingStateProvider, (previous, next) {
      notifyListeners();
    });
    _safetyCodeStateSubscription = ref.listen(safetyCodeStateProvider, (previous, next) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authStateSubscription.close();
    _onboardingStateSubscription.close();
    _safetyCodeStateSubscription.close();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final onboardingState = ref.watch(onboardingStateProvider);
  final safetyCodeState = ref.watch(safetyCodeStateProvider);
  
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(ref),
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isOnboarded = onboardingState.isCompleted;
      final isSafetyVerified = safetyCodeState.isSafetyCodeVerified;
      final hasSafetyCodes = safetyCodeState.hasSafetyCodes;
      
      if (LoggingConfig.enableNavigationLogs) {
        appLogger.navigation(state.matchedLocation, 'redirect', {
          'isAuthenticated': isAuthenticated,
          'isOnboarded': isOnboarded,
          'isSafetyVerified': isSafetyVerified,
          'hasSafetyCodes': hasSafetyCodes,
        });
      }
      
      final isLoginRoute = state.matchedLocation == '/login';
      final isOnboardingRoute = state.matchedLocation == '/onboarding';
      final isSafetyRoute = state.matchedLocation == '/safety';
      
      // If not authenticated, redirect to login
      if (!isAuthenticated && !isLoginRoute) {
        return '/login';
      }
      
      // If authenticated but not onboarded, redirect to onboarding
      if (isAuthenticated && !isOnboarded && !isOnboardingRoute) {
        return '/onboarding';
      }
      
      // If authenticated and onboarded, check safety code requirements
      if (isAuthenticated && isOnboarded) {
        // Only require safety code verification if safety codes are configured
        if (hasSafetyCodes && !isSafetyVerified && !isSafetyRoute) {
          return '/safety';
        }
        
        // If no safety codes configured or safety code is verified, redirect to chat
        if ((!hasSafetyCodes || isSafetyVerified) && state.matchedLocation == '/') {
          return '/chat';
        }
      }
      
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      
      // Onboarding routes
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      
      // Safety code route
      GoRoute(
        path: '/safety',
        name: 'safety',
        builder: (context, state) => const SafetyCodePage(),
      ),
      
      // Main app routes
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => const ChatPage(),
      ),
      
      GoRoute(
        path: '/sessions',
        name: 'sessions',
        builder: (context, state) => const SessionsPage(),
      ),
      
      GoRoute(
        path: '/journal',
        name: 'journal',
        builder: (context, state) => const JournalPage(),
      ),
      
      GoRoute(
        path: '/documents',
        name: 'documents',
        builder: (context, state) => const DocumentsPage(),
      ),
      
      GoRoute(
        path: '/reports',
        name: 'reports',
        builder: (context, state) => const ReportsPage(),
      ),
      
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      
      GoRoute(
        path: '/settings/privacy-security',
        name: 'privacy-security',
        builder: (context, state) => const PrivacySecuritySettingsPage(),
      ),
    ],
  );
});
