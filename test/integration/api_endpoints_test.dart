import 'package:flutter_test/flutter_test.dart';
import 'package:mindhearth/core/services/api_service.dart';
import 'package:mindhearth/core/config/test_config.dart';
import 'package:mindhearth/core/di/service_locator.dart';
import 'package:mindhearth/core/models/api_response.dart';

void main() {
  group('API Endpoints Integration Tests', () {
    late ApiService apiService;
    String? accessToken;

    setUpAll(() async {
      // Initialize service locator
      await setupServiceLocator();
      apiService = getIt<ApiService>();
    });

    group('Authentication Tests', () {
      test('should login with valid credentials', () async {
        final response = await apiService.login(
          email: TestConfig.testEmail,
          password: TestConfig.testPassword,
        );

        expect(response, isA<ApiSuccess>());
        
        response.when(
          success: (data, message) {
            expect(data, isA<Map<String, dynamic>>());
            expect(data['access_token'], isNotNull);
            expect(data['token_type'], equals('bearer'));
            accessToken = data['access_token'] as String;
          },
          error: (message, statusCode, errors) {
            fail('Login failed: $message');
          },
        );
      });

      test('should fail login with invalid credentials', () async {
        final response = await apiService.login(
          email: 'invalid@test.com',
          password: 'wrongpassword',
        );

        expect(response, isA<ApiError>());
        
        response.when(
          success: (data, message) {
            fail('Login should have failed');
          },
          error: (message, statusCode, errors) {
            expect(statusCode, isNotNull);
            expect(message, isNotEmpty);
          },
        );
      });

      test('should get current user info', () async {
        if (accessToken == null) {
          // Login first
          final loginResponse = await apiService.login(
            email: TestConfig.testEmail,
            password: TestConfig.testPassword,
          );
          
          loginResponse.when(
            success: (data, message) {
              accessToken = data['access_token'] as String;
            },
            error: (message, statusCode, errors) {
              fail('Login failed: $message');
            },
          );
        }

        final response = await apiService.getCurrentUser();

        expect(response, isA<ApiSuccess>());
        
        response.when(
          success: (data, message) {
            expect(data, isA<Map<String, dynamic>>());
            expect(data['id'], isNotNull);
            expect(data['email'], equals(TestConfig.testEmail));
          },
          error: (message, statusCode, errors) {
            fail('Get current user failed: $message');
          },
        );
      });
    });

    group('Session Management Tests', () {
      test('should get sessions list', () async {
        final response = await apiService.getSessions();

        expect(response, isA<ApiSuccess>());
        
        response.when(
          success: (data, message) {
            expect(data, isA<List>());
            expect(data, isNotEmpty);
          },
          error: (message, statusCode, errors) {
            fail('Get sessions failed: $message');
          },
        );
      });

      test('should create new session', () async {
        final response = await apiService.createSession(
          name: 'Test Session ${DateTime.now().millisecondsSinceEpoch}',
          sessionType: 'chat',
          purpose: 'testing',
        );

        expect(response, isA<ApiSuccess>());
        
        response.when(
          success: (data, message) {
            expect(data, isA<Map<String, dynamic>>());
            expect(data['id'], isNotNull);
            expect(data['name'], isNotNull);
          },
          error: (message, statusCode, errors) {
            fail('Create session failed: $message');
          },
        );
      });
    });

    group('Chat Functionality Tests', () {
      test('should send simple chat message', () async {
        final response = await apiService.sendSimpleChat(
          message: 'Hello, this is a test message',
        );

        expect(response, isA<ApiSuccess>());
        
        response.when(
          success: (data, message) {
            expect(data, isA<Map<String, dynamic>>());
            expect(data['response'], isNotNull);
          },
          error: (message, statusCode, errors) {
            fail('Send chat message failed: $message');
          },
        );
      });
    });

    group('Journal Management Tests', () {
      test('should get journal entries', () async {
        final response = await apiService.getJournalEntries();

        expect(response, isA<ApiSuccess>());
        
        response.when(
          success: (data, message) {
            expect(data, isA<List>());
          },
          error: (message, statusCode, errors) {
            fail('Get journal entries failed: $message');
          },
        );
      });

      test('should create journal entry', () async {
        final response = await apiService.createJournalEntry(
          content: 'Test journal entry ${DateTime.now().millisecondsSinceEpoch}',
          header: 'Test Header',
        );

        expect(response, isA<ApiSuccess>());
        
        response.when(
          success: (data, message) {
            expect(data, isA<Map<String, dynamic>>());
            expect(data['id'], isNotNull);
            expect(data['content'], isNotNull);
          },
          error: (message, statusCode, errors) {
            fail('Create journal entry failed: $message');
          },
        );
      });
    });

    group('Error Handling Tests', () {
      test('should handle network timeout gracefully', () async {
        // This test would require mocking network conditions
        // For now, we'll test with an invalid endpoint
        try {
          final response = await apiService.dio.get('/invalid-endpoint');
          fail('Should have thrown an exception');
        } catch (e) {
          expect(e, isA<Exception>());
        }
      });

      test('should handle malformed response gracefully', () async {
        // This test would require backend to return malformed data
        // For now, we'll test the response parsing logic
        final response = await apiService.getSessions();
        
        response.when(
          success: (data, message) {
            // Verify data is properly parsed
            expect(data, isA<List>());
          },
          error: (message, statusCode, errors) {
            // Should handle errors gracefully
            expect(message, isNotEmpty);
          },
        );
      });
    });

    group('Performance Tests', () {
      test('should complete API calls within timeout', () async {
        final stopwatch = Stopwatch()..start();
        
        final response = await apiService.getSessions();
        
        stopwatch.stop();
        
        expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // 5 seconds max
        expect(response, isA<ApiSuccess>());
      });

      test('should handle concurrent requests', () async {
        final futures = List.generate(5, (index) => apiService.getSessions());
        
        final results = await Future.wait(futures);
        
        for (final result in results) {
          expect(result, isA<ApiSuccess>());
        }
      });
    });
  });
}
