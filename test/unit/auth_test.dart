import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/app/providers/providers.dart';

void main() {
  group('AuthNotifier Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state should be unauthenticated', () {
      final authState = container.read(authStateProvider);
      expect(authState.isAuthenticated, false);
      expect(authState.isLoading, false);
      expect(authState.user, null);
      expect(authState.accessToken, null);
      expect(authState.error, null);
    });

    test('logout should reset state to initial', () async {
      final notifier = container.read(authNotifierProvider.notifier);
      await notifier.logout();
      
      final authState = container.read(authStateProvider);
      expect(authState.isAuthenticated, false);
      expect(authState.isLoading, false);
      expect(authState.user, null);
      expect(authState.accessToken, null);
      expect(authState.error, null);
    });
  });
}
