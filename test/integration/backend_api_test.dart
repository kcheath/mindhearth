import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mindhearth/core/config/test_config.dart';

void main() {
  group('Backend API Integration Tests', () {
    late Dio dio;
    String? accessToken;

    setUpAll(() {
      dio = Dio();
    });

    group('Authentication Tests', () {
      test('should login with valid credentials', () async {
        final response = await dio.post(
          '${TestConfig.apiBaseUrl}/auth/login',
          data: {
            'email': TestConfig.testEmail,
            'password': TestConfig.testPassword,
            'tenant_id': TestConfig.tenantId,
            'application_id': TestConfig.applicationId,
          },
        );
        
        expect(response.statusCode, 200);
        expect(response.data, isA<Map<String, dynamic>>());
        expect(response.data['access_token'], isNotNull);
        expect(response.data['access_token'], isNotEmpty);
        
        accessToken = response.data['access_token'] as String;
      });

      test('should fail login with invalid credentials', () async {
        try {
          await dio.post(
            '${TestConfig.apiBaseUrl}/auth/login',
            data: {
              'email': 'invalid@test.com',
              'password': 'wrongpassword',
              'tenant_id': TestConfig.tenantId,
              'application_id': TestConfig.applicationId,
            },
          );
          fail('Should have thrown an exception');
        } catch (e) {
          expect(e, isA<DioException>());
          final dioError = e as DioException;
          expect(dioError.response?.statusCode, 401);
        }
      });
    });

    group('Sessions API Tests', () {
      setUp(() async {
        if (accessToken == null) {
          // Get token first
          final loginResponse = await dio.post(
            '${TestConfig.apiBaseUrl}/auth/login',
            data: {
              'email': TestConfig.testEmail,
              'password': TestConfig.testPassword,
              'tenant_id': TestConfig.tenantId,
              'application_id': TestConfig.applicationId,
            },
          );
          accessToken = loginResponse.data['access_token'] as String;
        }
      });

      test('should get sessions list', () async {
        final response = await dio.get(
          '${TestConfig.apiBaseUrl}/sessions/',
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
          ),
        );
        
        expect(response.statusCode, 200);
        expect(response.data, isA<List>());
        expect(response.data.length, greaterThanOrEqualTo(0));
      });

      test('should create a new session', () async {
        final response = await dio.post(
          '${TestConfig.apiBaseUrl}/sessions/',
          data: {
            'name': 'Test Session ${DateTime.now().millisecondsSinceEpoch}',
            'session_type': 'chat',
            'purpose': 'testing',
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
          ),
        );
        
        expect(response.statusCode, 200);
        expect(response.data, isA<Map<String, dynamic>>());
        expect(response.data['id'], isNotNull);
        expect(response.data['name'], isNotNull);
      });

      test('should fail without authentication', () async {
        try {
          await dio.get('${TestConfig.apiBaseUrl}/sessions/');
          fail('Should have thrown an exception');
        } catch (e) {
          expect(e, isA<DioException>());
          final dioError = e as DioException;
          expect(dioError.response?.statusCode, 401);
        }
      });
    });

    group('Journal API Tests', () {
      setUp(() async {
        if (accessToken == null) {
          // Get token first
          final loginResponse = await dio.post(
            '${TestConfig.apiBaseUrl}/auth/login',
            data: {
              'email': TestConfig.testEmail,
              'password': TestConfig.testPassword,
              'tenant_id': TestConfig.tenantId,
              'application_id': TestConfig.applicationId,
            },
          );
          accessToken = loginResponse.data['access_token'] as String;
        }
      });

      test('should get journal entries', () async {
        final response = await dio.get(
          '${TestConfig.apiBaseUrl}/journals/',
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
          ),
        );
        
        expect(response.statusCode, 200);
        expect(response.data, isA<List>());
        expect(response.data.length, greaterThanOrEqualTo(0));
      });

      test('should create a journal entry', () async {
        final response = await dio.post(
          '${TestConfig.apiBaseUrl}/journals/',
          data: {
            'content': 'Test journal entry ${DateTime.now().millisecondsSinceEpoch}',
            'header': 'Test Header',
            'entry_type': 'general',
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
          ),
        );
        
        expect(response.statusCode, 200);
        expect(response.data, isA<Map<String, dynamic>>());
        expect(response.data['id'], isNotNull);
        expect(response.data['content'], isNotNull);
      });
    });

    group('Chat API Tests', () {
      setUp(() async {
        if (accessToken == null) {
          // Get token first
          final loginResponse = await dio.post(
            '${TestConfig.apiBaseUrl}/auth/login',
            data: {
              'email': TestConfig.testEmail,
              'password': TestConfig.testPassword,
              'tenant_id': TestConfig.tenantId,
              'application_id': TestConfig.applicationId,
            },
          );
          accessToken = loginResponse.data['access_token'] as String;
        }
      });

      test('should send a chat message', () async {
        final response = await dio.post(
          '${TestConfig.apiBaseUrl}/chat/',
          data: {
            'message': 'Test chat message ${DateTime.now().millisecondsSinceEpoch}',
            'session_id': 'test-session-id',
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
          ),
        );
        
        expect(response.statusCode, 200);
        expect(response.data, isA<Map<String, dynamic>>());
      });
    });

    group('User Management Tests', () {
      setUp(() async {
        if (accessToken == null) {
          // Get token first
          final loginResponse = await dio.post(
            '${TestConfig.apiBaseUrl}/auth/login',
            data: {
              'email': TestConfig.testEmail,
              'password': TestConfig.testPassword,
              'tenant_id': TestConfig.tenantId,
              'application_id': TestConfig.applicationId,
            },
          );
          accessToken = loginResponse.data['access_token'] as String;
        }
      });

      test('should get user profile', () async {
        final response = await dio.get(
          '${TestConfig.apiBaseUrl}/users/me',
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
          ),
        );
        
        expect(response.statusCode, 200);
        expect(response.data, isA<Map<String, dynamic>>());
        expect(response.data['id'], isNotNull);
        expect(response.data['email'], isNotNull);
      });

      test('should update onboarding status', () async {
        final response = await dio.put(
          '${TestConfig.apiBaseUrl}/users/onboarded',
          data: {
            'onboarded': true,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
          ),
        );
        
        expect(response.statusCode, 200);
        expect(response.data, isA<Map<String, dynamic>>());
      });
    });
  });
}
