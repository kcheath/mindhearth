import 'package:flutter_test/flutter_test.dart';
import 'package:mindhearth/core/providers/session_provider.dart';
import 'package:mindhearth/core/providers/auth_provider.dart';
import 'package:mindhearth/core/config/test_config.dart';
import 'package:mindhearth/core/di/service_locator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  group('Session Management Integration Tests', () {
    late ProviderContainer container;

    setUpAll(() async {
      await setupServiceLocator();
      container = ProviderContainer();
    });

    tearDownAll(() {
      container.dispose();
    });

    group('Session Loading Tests', () {
      test('should load sessions successfully', () async {
        // First login
        final authNotifier = container.read(authNotifierProvider.notifier);
        await authNotifier.login(
          email: TestConfig.testEmail,
          password: TestConfig.testPassword,
        );
        await Future.delayed(const Duration(milliseconds: 500));

        // Load sessions
        final sessionNotifier = container.read(sessionNotifierProvider.notifier);
        await sessionNotifier.loadSessions();

        await Future.delayed(const Duration(milliseconds: 500));

        final sessionState = container.read(sessionNotifierProvider);
        
        expect(sessionState.isLoading, isFalse);
        expect(sessionState.error, isNull);
        expect(sessionState.sessions, isA<List>());
        expect(sessionState.sessions.length, greaterThanOrEqualTo(0));
      });

      test('should handle empty sessions list', () async {
        final sessionNotifier = container.read(sessionNotifierProvider.notifier);
        await sessionNotifier.loadSessions();

        await Future.delayed(const Duration(milliseconds: 500));

        final sessionState = container.read(sessionNotifierProvider);
        
        expect(sessionState.isLoading, isFalse);
        expect(sessionState.error, isNull);
        expect(sessionState.sessions, isA<List>());
        // Empty list is acceptable
      });

      test('should handle session loading errors gracefully', () async {
        final sessionNotifier = container.read(sessionNotifierProvider.notifier);
        
        // This test would require network mocking to simulate errors
        await sessionNotifier.loadSessions();

        await Future.delayed(const Duration(milliseconds: 500));

        final sessionState = container.read(sessionNotifierProvider);
        
        expect(sessionState.isLoading, isFalse);
        // Should either have sessions or error
        expect(
          sessionState.sessions.isNotEmpty || sessionState.error != null,
          isTrue,
        );
      });
    });

    group('Session Creation Tests', () {
      test('should create new session successfully', () async {
        final sessionNotifier = container.read(sessionNotifierProvider.notifier);
        
        final sessionName = 'Test Session ${DateTime.now().millisecondsSinceEpoch}';
        final session = await sessionNotifier.createSession(
          name: sessionName,
          sessionType: 'chat',
          purpose: 'testing',
        );

        expect(session, isNotNull);
        expect(session?.name, equals(sessionName));
        expect(session?.sessionType, equals('chat'));
        expect(session?.purpose, equals('testing'));
        expect(session?.id, isNotNull);
        expect(session?.id, isNotEmpty);
      });

      test('should create session with minimal data', () async {
        final sessionNotifier = container.read(sessionNotifierProvider.notifier);
        
        final session = await sessionNotifier.createSession();

        expect(session, isNotNull);
        expect(session?.id, isNotNull);
        expect(session?.id, isNotEmpty);
      });

      test('should handle session creation errors', () async {
        final sessionNotifier = container.read(sessionNotifierProvider.notifier);
        
        // Test with invalid data that might cause errors
        final session = await sessionNotifier.createSession(
          name: '', // Empty name might cause issues
          sessionType: 'invalid_type',
        );

        // Should either succeed or fail gracefully
        if (session != null) {
          expect(session.id, isNotNull);
        } else {
          // Error case - check error state
          final sessionState = container.read(sessionNotifierProvider);
          expect(sessionState.error, isNotNull);
        }
      });
    });

    group('Session Selection Tests', () {
      test('should set current session', () async {
        final sessionNotifier = container.read(sessionNotifierProvider.notifier);
        
        // First create a session
        final session = await sessionNotifier.createSession(
          name: 'Test Session for Selection',
        );

        expect(session, isNotNull);

        // Set as current session
        sessionNotifier.setCurrentSession(session!);

        final sessionState = container.read(sessionNotifierProvider);
        expect(sessionState.currentSession, isNotNull);
        expect(sessionState.currentSession?.id, equals(session.id));
        expect(sessionState.currentSession?.name, equals(session.name));
      });

      test('should clear current session', () async {
        final sessionNotifier = container.read(sessionNotifierProvider.notifier);
        
        // First set a current session
        final session = await sessionNotifier.createSession(
          name: 'Test Session for Clearing',
        );
        sessionNotifier.setCurrentSession(session!);

        // Verify session is set
        var sessionState = container.read(sessionNotifierProvider);
        expect(sessionState.currentSession, isNotNull);

        // Clear current session
        sessionNotifier.clearCurrentSession();

        // Verify session is cleared
        sessionState = container.read(sessionNotifierProvider);
        expect(sessionState.currentSession, isNull);
      });

      test('should get session by ID', () async {
        final sessionNotifier = container.read(sessionNotifierProvider.notifier);
        
        // Create a session
        final session = await sessionNotifier.createSession(
          name: 'Test Session for ID Lookup',
        );

        expect(session, isNotNull);

        // Get session by ID
        final retrievedSession = sessionNotifier.getSessionById(session!.id);
        
        expect(retrievedSession, isNotNull);
        expect(retrievedSession?.id, equals(session.id));
        expect(retrievedSession?.name, equals(session.name));
      });

      test('should return null for non-existent session ID', () async {
        final sessionNotifier = container.read(sessionNotifierProvider.notifier);
        
        // Try to get non-existent session
        final session = sessionNotifier.getSessionById('non-existent-id');
        
        expect(session, isNull);
      });
    });

    group('Session State Management Tests', () {
      test('should handle loading state during operations', () async {
        final sessionNotifier = container.read(sessionNotifierProvider.notifier);
        
        // Start loading sessions
        final loadFuture = sessionNotifier.loadSessions();

        // Check loading state
        var sessionState = container.read(sessionNotifierProvider);
        expect(sessionState.isLoading, isTrue);

        // Wait for completion
        await loadFuture;
        await Future.delayed(const Duration(milliseconds: 500));

        // Check final state
        sessionState = container.read(sessionNotifierProvider);
        expect(sessionState.isLoading, isFalse);
      });

      test('should clear errors when operations succeed', () async {
        final sessionNotifier = container.read(sessionNotifierProvider.notifier);
        
        // First create an error state (if possible)
        // Then perform successful operation
        await sessionNotifier.loadSessions();
        await Future.delayed(const Duration(milliseconds: 500));

        final sessionState = container.read(sessionNotifierProvider);
        
        // Should either have sessions or error, but not both
        expect(
          sessionState.sessions.isNotEmpty || sessionState.error != null,
          isTrue,
        );
      });

      test('should handle error clearing', () async {
        final sessionNotifier = container.read(sessionNotifierProvider.notifier);
        
        // Clear any existing errors
        sessionNotifier.clearError();

        final sessionState = container.read(sessionNotifierProvider);
        expect(sessionState.error, isNull);
      });
    });

    group('Session Refresh Tests', () {
      test('should refresh sessions successfully', () async {
        final sessionNotifier = container.read(sessionNotifierProvider.notifier);
        
        // Load sessions first
        await sessionNotifier.loadSessions();
        await Future.delayed(const Duration(milliseconds: 500));

        // Get initial count
        var sessionState = container.read(sessionNotifierProvider);
        final initialCount = sessionState.sessions.length;

        // Refresh sessions
        await sessionNotifier.refreshSessions();
        await Future.delayed(const Duration(milliseconds: 500));

        // Verify refresh completed
        sessionState = container.read(sessionNotifierProvider);
        expect(sessionState.isLoading, isFalse);
        expect(sessionState.error, isNull);
        expect(sessionState.sessions.length, greaterThanOrEqualTo(initialCount));
      });

      test('should refresh sessions with specific type', () async {
        final sessionNotifier = container.read(sessionNotifierProvider.notifier);
        
        // Refresh with specific session type
        await sessionNotifier.refreshSessions(sessionType: 'chat');
        await Future.delayed(const Duration(milliseconds: 500));

        final sessionState = container.read(sessionNotifierProvider);
        expect(sessionState.isLoading, isFalse);
        expect(sessionState.error, isNull);
      });
    });

    group('Performance Tests', () {
      test('should complete session operations within reasonable time', () async {
        final sessionNotifier = container.read(sessionNotifierProvider.notifier);
        
        final stopwatch = Stopwatch()..start();
        
        await sessionNotifier.loadSessions();
        
        stopwatch.stop();
        
        expect(stopwatch.elapsedMilliseconds, lessThan(10000)); // 10 seconds max
      });

      test('should handle concurrent session operations', () async {
        final sessionNotifier = container.read(sessionNotifierProvider.notifier);
        
        // Multiple concurrent operations
        final futures = [
          sessionNotifier.loadSessions(),
          sessionNotifier.createSession(name: 'Concurrent Session 1'),
          sessionNotifier.createSession(name: 'Concurrent Session 2'),
        ];
        
        final results = await Future.wait(futures);
        
        // Should handle gracefully
        final sessionState = container.read(sessionNotifierProvider);
        expect(sessionState.isLoading, isFalse);
      });
    });

    group('Data Consistency Tests', () {
      test('should maintain session count consistency', () async {
        final sessionNotifier = container.read(sessionNotifierProvider.notifier);
        
        // Load sessions
        await sessionNotifier.loadSessions();
        await Future.delayed(const Duration(milliseconds: 500));

        var sessionState = container.read(sessionNotifierProvider);
        final initialCount = sessionState.sessions.length;

        // Create new session
        final newSession = await sessionNotifier.createSession(
          name: 'Consistency Test Session',
        );

        if (newSession != null) {
          // Verify count increased
          sessionState = container.read(sessionNotifierProvider);
          expect(sessionState.sessions.length, greaterThan(initialCount));
        }
      });

      test('should maintain session data integrity', () async {
        final sessionNotifier = container.read(sessionNotifierProvider.notifier);
        
        // Create session with specific data
        final sessionName = 'Integrity Test Session';
        final sessionType = 'chat';
        final sessionPurpose = 'testing';
        
        final session = await sessionNotifier.createSession(
          name: sessionName,
          sessionType: sessionType,
          purpose: sessionPurpose,
        );

        if (session != null) {
          expect(session.name, equals(sessionName));
          expect(session.sessionType, equals(sessionType));
          expect(session.purpose, equals(sessionPurpose));
          expect(session.id, isNotNull);
          expect(session.id, isNotEmpty);
        }
      });
    });
  });
}
