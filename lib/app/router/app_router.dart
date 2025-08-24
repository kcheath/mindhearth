import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/app/providers/providers.dart';
import 'package:mindhearth/features/auth/presentation/pages/login_page.dart';
import 'package:mindhearth/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:mindhearth/features/safetycode/presentation/pages/safety_code_page.dart';
import 'package:mindhearth/features/chat/presentation/pages/chat_page.dart';
import 'package:mindhearth/features/sessions/presentation/pages/sessions_page.dart';
import 'package:mindhearth/features/journal/presentation/pages/journal_page.dart';
import 'package:mindhearth/features/documents/presentation/pages/documents_page.dart';
import 'package:mindhearth/features/reports/presentation/pages/reports_page.dart';
import 'package:mindhearth/features/settings/presentation/pages/settings_page.dart';
import 'package:mindhearth/features/safetycode/domain/providers/safety_code_providers.dart';
import 'package:mindhearth/features/onboarding/domain/providers/onboarding_providers.dart';
import 'package:mindhearth/core/models/auth_state.dart';
import 'package:flutter/foundation.dart';

// GoRouter Refresh Stream for Riverpod integration
class GoRouterRefreshStream extends ChangeNotifier {
  late final ProviderSubscription<AuthState> _authSubscription;
  late final ProviderSubscription<SafetyCodeState> _safetySubscription;
  late final ProviderSubscription<OnboardingState> _onboardingSubscription;

  GoRouterRefreshStream(Ref ref) {
    _authSubscription = ref.listen(authStateProvider, (previous, next) {
      notifyListeners();
    });
    
    _safetySubscription = ref.listen(safetyCodeVerifiedProvider, (previous, next) {
      notifyListeners();
    });
    
    _onboardingSubscription = ref.listen(onboardingStateProvider, (previous, next) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authSubscription.close();
    _safetySubscription.close();
    _onboardingSubscription.close();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final safetyCodeState = ref.watch(safetyCodeVerifiedProvider);
  
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(ref),
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isOnboarded = authState.user?.isOnboarded ?? false;
      final isSafetyVerified = safetyCodeState.isVerified;
      
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
      
      // If authenticated and onboarded but safety code not verified, redirect to safety
      if (isAuthenticated && isOnboarded && !isSafetyVerified && !isSafetyRoute) {
        return '/safety';
      }
      
      // If authenticated, onboarded, and safety verified, redirect to chat (main app)
      if (isAuthenticated && isOnboarded && isSafetyVerified && state.matchedLocation == '/') {
        return '/chat';
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
    ],
  );
});
