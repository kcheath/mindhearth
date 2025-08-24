import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/providers.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/safetycode/presentation/pages/safety_code_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/sessions/presentation/pages/sessions_page.dart';
import '../../features/journal/presentation/pages/journal_page.dart';
import '../../features/documents/presentation/pages/documents_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isOnboarded = authState.user?.isOnboarded ?? false;
      final isOnboardingRoute = state.matchedLocation == '/onboarding';
      final isLoginRoute = state.matchedLocation == '/login';
      
      // If not authenticated, redirect to login
      if (!isAuthenticated && !isLoginRoute) {
        return '/login';
      }
      
      // If authenticated but not onboarded, redirect to onboarding
      if (isAuthenticated && !isOnboarded && !isOnboardingRoute) {
        return '/onboarding';
      }
      
      // If authenticated and onboarded, allow access to all routes
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
      
      // Main app routes
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const ChatPage(),
      ),
      
      GoRoute(
        path: '/safety-code',
        name: 'safety-code',
        builder: (context, state) => const SafetyCodePage(),
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
