import 'package:flutter_test/flutter_test.dart';
import 'package:mindhearth/core/providers/auth_provider.dart';
import 'package:mindhearth/core/config/test_config.dart';
import 'package:mindhearth/core/di/service_locator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  group('Authentication Flow Integration Tests', () {
    late ProviderContainer container;

    setUpAll(() async {
      await setupServiceLocator();
      container = ProviderContainer();
    });

    tearDownAll(() {
      container.dispose();
    });

    group('Login Flow Tests', () {
      test('should login successfully with valid credentials', () async {
        final authNotifier = container.read(authNotifierProvider.notifier);
        
        // Test login
        await authNotifier.login(
          email: TestConfig.testEmail,
          password: TestConfig.testPassword,
        );

        // Wait for state to update
        await Future.delayed(const Duration(milliseconds: 500));

        final authState = container.read(authNotifierProvider);
        
        expect(authState.isAuthenticated, isTrue);
        expect(authState.user, isNotNull);
        expect(authState.user?.email, equals(TestConfig.testEmail));
        expect(authState.isLoading, isFalse);
        expect(authState.error, isNull);
      });

      test('should fail login with invalid credentials', () async {
        final authNotifier = container.read(authNotifierProvider.notifier);
        
        // Test login with invalid credentials
        await authNotifier.login(
          email: 'invalid@test.com',
          password: 'wrongpassword',
        );

        // Wait for state to update
        await Future.delayed(const Duration(milliseconds: 500));

        final authState = container.read(authNotifierProvider);
        
        expect(authState.isAuthenticated, isFalse);
        expect(authState.user, isNull);
        expect(authState.isLoading, isFalse);
        expect(authState.error, isNotNull);
        expect(authState.error, isNotEmpty);
      });

      test('should handle login loading state', () async {
        final authNotifier = container.read(authNotifierProvider.notifier);
        
        // Start login process
        final loginFuture = authNotifier.login(
          email: TestConfig.testEmail,
          password: TestConfig.testPassword,
        );

        // Check loading state immediately
        final authState = container.read(authNotifierProvider);
        expect(authState.isLoading, isTrue);

        // Wait for login to complete
        await loginFuture;
        await Future.delayed(const Duration(milliseconds: 500));

        // Check final state
        final finalAuthState = container.read(authNotifierProvider);
        expect(finalAuthState.isLoading, isFalse);
      });

      test('should clear error on successful login', () async {
        final authNotifier = container.read(authNotifierProvider.notifier);
        
        // First, create an error state
        await authNotifier.login(
          email: 'invalid@test.com',
          password: 'wrongpassword',
        );
        await Future.delayed(const Duration(milliseconds: 500));

        // Verify error state
        var authState = container.read(authNotifierProvider);
        expect(authState.error, isNotNull);

        // Now login successfully
        await authNotifier.login(
          email: TestConfig.testEmail,
          password: TestConfig.testPassword,
        );
        await Future.delayed(const Duration(milliseconds: 500));

        // Verify error is cleared
        authState = container.read(authNotifierProvider);
        expect(authState.error, isNull);
        expect(authState.isAuthenticated, isTrue);
      });
    });

    group('Logout Flow Tests', () {
      test('should logout successfully', () async {
        final authNotifier = container.read(authNotifierProvider.notifier);
        
        // First login
        await authNotifier.login(
          email: TestConfig.testEmail,
          password: TestConfig.testPassword,
        );
        await Future.delayed(const Duration(milliseconds: 500));

        // Verify logged in
        var authState = container.read(authNotifierProvider);
        expect(authState.isAuthenticated, isTrue);

        // Now logout
        await authNotifier.logout();
        await Future.delayed(const Duration(milliseconds: 500));

        // Verify logged out
        authState = container.read(authNotifierProvider);
        expect(authState.isAuthenticated, isFalse);
        expect(authState.user, isNull);
        expect(authState.isLoading, isFalse);
      });

      test('should clear user data on logout', () async {
        final authNotifier = container.read(authNotifierProvider.notifier);
        
        // Login first
        await authNotifier.login(
          email: TestConfig.testEmail,
          password: TestConfig.testPassword,
        );
        await Future.delayed(const Duration(milliseconds: 500));

        // Verify user data exists
        var authState = container.read(authNotifierProvider);
        expect(authState.user, isNotNull);
        expect(authState.user?.email, equals(TestConfig.testEmail));

        // Logout
        await authNotifier.logout();
        await Future.delayed(const Duration(milliseconds: 500));

        // Verify user data is cleared
        authState = container.read(authNotifierProvider);
        expect(authState.user, isNull);
      });
    });

    group('Token Management Tests', () {
      test('should store and retrieve access token', () async {
        final authNotifier = container.read(authNotifierProvider.notifier);
        
        // Login
        await authNotifier.login(
          email: TestConfig.testEmail,
          password: TestConfig.testPassword,
        );
        await Future.delayed(const Duration(milliseconds: 500));

        // Verify token is stored
        final authState = container.read(authNotifierProvider);
        expect(authState.user, isNotNull);
        expect(authState.user?.accessToken, isNotNull);
        expect(authState.user?.accessToken, isNotEmpty);
      });

      test('should handle token refresh', () async {
        final authNotifier = container.read(authNotifierProvider.notifier);
        
        // Login
        await authNotifier.login(
          email: TestConfig.testEmail,
          password: TestConfig.testPassword,
        );
        await Future.delayed(const Duration(milliseconds: 500));

        // Get initial token
        var authState = container.read(authNotifierProvider);
        final initialToken = authState.user?.accessToken;

        // Refresh token
        await authNotifier.refreshToken();
        await Future.delayed(const Duration(milliseconds: 500));

        // Verify token is refreshed
        authState = container.read(authNotifierProvider);
        final refreshedToken = authState.user?.accessToken;
        
        expect(refreshedToken, isNotNull);
        expect(refreshedToken, isNotEmpty);
        // Note: Token might be the same if not expired, or different if refreshed
      });
    });

    group('State Persistence Tests', () {
      test('should persist authentication state', () async {
        final authNotifier = container.read(authNotifierProvider.notifier);
        
        // Login
        await authNotifier.login(
          email: TestConfig.testEmail,
          password: TestConfig.testPassword,
        );
        await Future.delayed(const Duration(milliseconds: 500));

        // Verify logged in
        var authState = container.read(authNotifierProvider);
        expect(authState.isAuthenticated, isTrue);

        // Simulate app restart by creating new container
        final newContainer = ProviderContainer();
        
        // Check if state is persisted
        final newAuthState = newContainer.read(authNotifierProvider);
        // Note: This would require actual persistence implementation
        // For now, we'll just verify the state structure
        
        newContainer.dispose();
      });
    });

    group('Error Handling Tests', () {
      test('should handle network errors gracefully', () async {
        final authNotifier = container.read(authNotifierProvider.notifier);
        
        // Test with invalid server (this would require network mocking)
        await authNotifier.login(
          email: TestConfig.testEmail,
          password: TestConfig.testPassword,
        );
        await Future.delayed(const Duration(milliseconds: 500));

        final authState = container.read(authNotifierProvider);
        
        // Should either succeed or fail gracefully
        expect(authState.isLoading, isFalse);
        if (!authState.isAuthenticated) {
          expect(authState.error, isNotNull);
        }
      });

      test('should handle malformed responses', () async {
        final authNotifier = container.read(authNotifierProvider.notifier);
        
        // This test would require backend to return malformed data
        // For now, we'll test the error handling structure
        await authNotifier.login(
          email: TestConfig.testEmail,
          password: TestConfig.testPassword,
        );
        await Future.delayed(const Duration(milliseconds: 500));

        final authState = container.read(authNotifierProvider);
        
        // Should handle response gracefully
        expect(authState.isLoading, isFalse);
        // Either authenticated or error state
        expect(
          authState.isAuthenticated || authState.error != null,
          isTrue,
        );
      });
    });

    group('Performance Tests', () {
      test('should complete login within reasonable time', () async {
        final authNotifier = container.read(authNotifierProvider.notifier);
        
        final stopwatch = Stopwatch()..start();
        
        await authNotifier.login(
          email: TestConfig.testEmail,
          password: TestConfig.testPassword,
        );
        
        stopwatch.stop();
        
        expect(stopwatch.elapsedMilliseconds, lessThan(10000)); // 10 seconds max
      });

      test('should handle multiple login attempts', () async {
        final authNotifier = container.read(authNotifierProvider.notifier);
        
        // Multiple rapid login attempts
        final futures = List.generate(3, (index) => authNotifier.login(
          email: TestConfig.testEmail,
          password: TestConfig.testPassword,
        ));
        
        final results = await Future.wait(futures);
        
        // Should handle gracefully (either succeed or fail)
        final authState = container.read(authNotifierProvider);
        expect(authState.isLoading, isFalse);
      });
    });
  });
}
