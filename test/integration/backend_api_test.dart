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
          final response = await dio.post(
            '${TestConfig.apiBaseUrl}/auth/login',
            data: {
              'email': 'invalid@test.com',
              'password': 'wrongpassword',
              'tenant_id': TestConfig.tenantId,
              'application_id': TestConfig.applicationId,
            },
          );
          
          // If we get here, check the response status
          if (response.statusCode == 401) {
            // This is correct behavior - backend rejected invalid credentials
            expect(response.statusCode, 401, 
              reason: 'Backend correctly rejected invalid credentials with 401');
          } else {
            fail('❌ SECURITY ISSUE: Backend accepted invalid credentials! Status: ${response.statusCode}');
          }
        } catch (e) {
          // DioException is also acceptable - means request failed
          expect(e, isA<DioException>());
          final dioError = e as DioException;
          expect(dioError.response?.statusCode, 401, 
            reason: 'Backend should reject invalid credentials with 401 Unauthorized');
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
        
        expect(response.statusCode, 200, 
          reason: 'Sessions endpoint should return 200 OK. If 401, check JWT token. If 404, check API route.');
        expect(response.data, isA<List>(), 
          reason: 'Sessions endpoint should return a list, not: ${response.data.runtimeType}. '
              'If this fails, backend is returning wrong data format.');
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
        
        expect(response.statusCode, 200, 
          reason: 'Session creation should return 200 OK. If 400, check request data format. If 401, check JWT token.');
        expect(response.data, isA<Map<String, dynamic>>(), 
          reason: 'Session creation should return a session object, not: ${response.data.runtimeType}');
        expect(response.data['id'], isNotNull, 
          reason: 'Created session should have an ID');
        expect(response.data['name'], isNotNull, 
          reason: 'Created session should have a name');
      });

      test('should fail without authentication', () async {
        try {
          await dio.get('${TestConfig.apiBaseUrl}/sessions/');
          fail('❌ SECURITY ISSUE: Backend allowed unauthenticated access to sessions! '
              'This is a backend security problem - endpoints should require authentication.');
        } catch (e) {
          expect(e, isA<DioException>());
          final dioError = e as DioException;
          expect(dioError.response?.statusCode, 401, 
            reason: 'Backend should reject unauthenticated requests with 401 Unauthorized');
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
        
        expect(response.statusCode, 200, 
          reason: 'Journal endpoint should return 200 OK, not error status');
        
        // Check if response contains error (backend returns 200 with error object)
        if (response.data is Map && response.data.containsKey('error')) {
          fail('❌ BACKEND ISSUE: Journal endpoint returns error object instead of data. '
              'Backend team needs to implement journal endpoints properly. '
              'Error: ${response.data['error']}');
        }
        
        expect(response.data, isA<List>(), 
          reason: 'Journal endpoint should return a list of journal entries, not: ${response.data.runtimeType}');
        expect(response.data.length, greaterThanOrEqualTo(0));
      });

      test('should create a journal entry', () async {
        final response = await dio.post(
          '${TestConfig.apiBaseUrl}/journals/',
          data: {
            'original_content': 'Test journal entry ${DateTime.now().millisecondsSinceEpoch}',
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
        
        // Debug: Print the actual response
        print('🔍 DEBUG: Journal creation response:');
        print('Status Code: ${response.statusCode}');
        print('Response Data: ${response.data}');
        print('Response Type: ${response.data.runtimeType}');
        
        expect(response.statusCode, 200, 
          reason: 'Journal creation endpoint should return 200 OK, not error status');
        
        // Check if response contains error (backend returns 200 with error object)
        if (response.data is Map && response.data.containsKey('error')) {
          fail('❌ BACKEND ISSUE: Journal creation endpoint returns error object instead of data. '
              'Backend team needs to implement journal endpoints properly. '
              'Error: ${response.data['error']}');
        }
        
        expect(response.data, isA<Map<String, dynamic>>(), 
          reason: 'Journal creation should return a journal object, not: ${response.data.runtimeType}');
        expect(response.data['id'], isNotNull, 
          reason: 'Created journal entry should have an ID');
        expect(response.data['original_content'], isNotNull, 
          reason: 'Created journal entry should have original_content');
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

    group('Error Analysis & Troubleshooting', () {
      test('should provide troubleshooting guidance', () {
        print('\n🔍 BACKEND INTEGRATION TEST TROUBLESHOOTING GUIDE:');
        print('================================================');
        print('');
        print('If tests fail, here\'s how to determine if it\'s a frontend or backend issue:');
        print('');
        print('❌ AUTHENTICATION FAILURES:');
        print('  - 401 Unauthorized: Backend issue - check JWT token validation');
        print('  - 404 Not Found: Backend issue - check API routes and endpoints');
        print('  - Invalid credentials accepted: Backend security issue');
        print('');
        print('❌ DATA FORMAT ISSUES:');
        print('  - Wrong response type (List vs Map): Backend issue - check API implementation');
        print('  - Missing required fields: Backend issue - check data models');
        print('  - Error objects in 200 responses: Backend issue - check error handling');
        print('');
        print('❌ FRONTEND ISSUES:');
        print('  - Wrong request format: Check Flutter API service implementation');
        print('  - Missing headers: Check Flutter HTTP client configuration');
        print('  - Wrong endpoint URLs: Check Flutter API configuration');
        print('');
        print('📋 BACKEND TEAM ACTION ITEMS:');
        print('  - Implement missing journal endpoints');
        print('  - Fix error responses (return proper HTTP status codes)');
        print('  - Ensure all endpoints require proper authentication');
        print('  - Validate request data formats');
        print('');
        print('📋 FRONTEND TEAM ACTION ITEMS:');
        print('  - Check API service configuration');
        print('  - Verify request headers and authentication');
        print('  - Update API calls if backend changes');
        print('');
      });
    });
  });
}
