import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/providers/auth_provider.dart';
import 'package:mindhearth/core/providers/safety_code_provider.dart';
import 'package:mindhearth/core/providers/onboarding_provider.dart';
import 'package:mindhearth/core/config/logging_config.dart';
import 'package:mindhearth/core/utils/logger.dart';
import 'package:mindhearth/features/auth/presentation/pages/login_page.dart';
import 'package:mindhearth/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:mindhearth/features/safetycode/presentation/pages/safety_code_page.dart';
import 'package:mindhearth/features/chat/presentation/pages/chat_page.dart';
import 'package:mindhearth/features/sessions/presentation/pages/sessions_page.dart';
import 'package:mindhearth/features/journal/presentation/pages/journal_page.dart';
import 'package:mindhearth/features/journal/presentation/pages/journal_entry_page.dart';
import 'package:mindhearth/features/documents/presentation/pages/documents_page.dart';
import 'package:mindhearth/features/reports/presentation/pages/reports_page.dart';
import 'package:mindhearth/features/settings/presentation/pages/settings_page.dart';
import 'package:mindhearth/features/settings/presentation/pages/privacy_security_settings_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final safetyCodeState = ref.watch(safetyCodeStateProvider);
  final onboardingState = ref.watch(onboardingStateProvider);
  
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isOnboarded = authState.user?.isOnboarded ?? false;
      final isSafetyVerified = safetyCodeState.isSafetyCodeVerified;
      final hasSafetyCodes = safetyCodeState.hasSafetyCodes;
      final isOnboardingInProgress = onboardingState.isOnboarding;
      
      if (LoggingConfig.enableNavigationLogs) {
        appLogger.navigation(state.matchedLocation, 'redirect', {
          'isAuthenticated': isAuthenticated,
          'isOnboarded': isOnboarded,
          'isSafetyVerified': isSafetyVerified,
          'hasSafetyCodes': hasSafetyCodes,
          'isOnboardingInProgress': isOnboardingInProgress,
        });
      }
      
      final isLoginRoute = state.matchedLocation == '/login';
      final isOnboardingRoute = state.matchedLocation == '/onboarding';
      final isSafetyRoute = state.matchedLocation == '/safety';
      
      // If not authenticated, redirect to login
      if (!isAuthenticated && !isLoginRoute) {
        return '/login';
      }
      
      // If authenticated but not onboarded OR onboarding is in progress, redirect to onboarding
      if (isAuthenticated && (!isOnboarded || isOnboardingInProgress) && !isOnboardingRoute) {
        return '/onboarding';
      }
      
      // If authenticated and onboarded and not in onboarding flow, check safety code requirements
      if (isAuthenticated && isOnboarded && !isOnboardingInProgress) {
        // Only require safety code verification if safety codes are configured
        if (hasSafetyCodes && !isSafetyVerified && !isSafetyRoute) {
          return '/safety';
        }
        
        // If no safety codes configured or safety code is verified, redirect to chat only from root
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
        path: '/journal/:entryId',
        name: 'journal-entry',
        builder: (context, state) {
          final entryId = state.pathParameters['entryId']!;
          return JournalEntryPage(entryId: entryId);
        },
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
