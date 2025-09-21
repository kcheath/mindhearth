import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mindhearth/core/models/api_response.dart';
import 'package:mindhearth/core/config/debug_config.dart';
import 'package:mindhearth/core/config/logging_config.dart';
import 'package:mindhearth/core/utils/logger.dart';

class ApiService {
  static const String _tokenKey = 'access_token';
  
  // Backend API keys from debug config
  static const String _tenantId = '1aca2ef7-b1fa-46bb-af08-a8fdb449b1f9';
  static const String _applicationId = '2852276f-16ca-462f-aa46-5e191880eb33';
  
  late final Dio _dio;
  late final FlutterSecureStorage _storage;
  
  Dio get dio => _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: DebugConfig.apiUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _storage = const FlutterSecureStorage();
    
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: _tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          // Add required headers for Tsukiyo API
          options.headers['X-Tenant-ID'] = _tenantId;
          options.headers['X-App-ID'] = _applicationId;
          
          // Debug logging to verify headers are being added
          appLogger.debug('API Request Headers: ${options.headers}', 'ApiService');
          
          if (LoggingConfig.enableApiLogs && LoggingConfig.shouldLogEndpoint(options.path)) {
            appLogger.apiRequest(options.method, options.path, options.headers);
          }
          
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (LoggingConfig.enableApiLogs && LoggingConfig.shouldLogEndpoint(response.requestOptions.path)) {
            appLogger.apiResponse(
              response.requestOptions.method,
              response.requestOptions.path,
              response.statusCode ?? 0,
              response.data,
            );
          }
          handler.next(response);
        },
        onError: (error, handler) {
          if (LoggingConfig.enableApiLogs && LoggingConfig.shouldLogEndpoint(error.requestOptions.path)) {
            appLogger.apiError(
              error.requestOptions.method,
              error.requestOptions.path,
              error.response?.statusCode ?? 0,
              error.message ?? 'Unknown error',
              error.response?.data,
            );
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<void> setToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Auth endpoints
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      if (LoggingConfig.enableAuthLogs) {
        appLogger.auth('Login attempt', {'email': email});
      }
      
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      if (LoggingConfig.enableAuthLogs) {
        appLogger.auth('Login successful', {'email': email});
      }
      
      return ApiSuccess(data: response.data);
    } on DioException catch (e) {
      if (LoggingConfig.enableAuthLogs) {
        appLogger.auth('Login failed', {
          'email': email,
          'error': e.message,
          'statusCode': e.response?.statusCode,
        });
      }
      
      return ApiError(
        message: e.response?.data?['detail'] ?? 'Login failed',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // Health check
  Future<ApiResponse<Map<String, dynamic>>> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return ApiSuccess(data: response.data);
    } on DioException catch (e) {
      return ApiError(
        message: 'Health check failed',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // Chat endpoint - Full AI chat with trauma-informed responses (Tsukiyo API)
  Future<ApiResponse<Map<String, dynamic>>> sendChatMessage({
    required List<Map<String, dynamic>> messages,
    String? sessionId,
    String? purpose,
    String sessionType = 'conversation',
  }) async {
    try {
      final requestData = {
        'messages': messages,
        if (sessionId != null) 'session_id': sessionId,
        'session_type': sessionType,
        'purpose': purpose ?? 'chat',
      };
      
      appLogger.debug('sendChatMessage - sending request to /chat/', 'ApiService');
      appLogger.debug('sendChatMessage - request data: $requestData', 'ApiService');
      
      final response = await _dio.post('/chat/', data: requestData);
      
      appLogger.debug('sendChatMessage - response status: ${response.statusCode}', 'ApiService');
      appLogger.debug('sendChatMessage - response data: ${response.data}', 'ApiService');
      
      return ApiSuccess(data: response.data);
    } on DioException catch (e) {
      appLogger.debug('sendChatMessage - error: ${e.toString()}', 'ApiService');
      appLogger.debug('sendChatMessage - error response: ${e.response?.data}', 'ApiService');
      appLogger.debug('sendChatMessage - error status code: ${e.response?.statusCode}', 'ApiService');
      
      return ApiError(
        message: e.response?.data?['detail'] ?? 'Chat request failed',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // Simple chat endpoint without session management
  Future<ApiResponse<Map<String, dynamic>>> sendSimpleChatMessage({
    required String message,
  }) async {
    try {
      final response = await _dio.post('/chat/simple', data: {
        'message': message,
      });
      
      return ApiSuccess(data: response.data);
    } on DioException catch (e) {
      return ApiError(
        message: e.response?.data?['detail'] ?? 'Simple chat request failed',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // Session Management
  Future<ApiResponse<Map<String, dynamic>>> createSession({
    String? name,
    String sessionType = 'conversation',
    String? purpose,
  }) async {
    try {
      final response = await _dio.post('/sessions/', data: {
        if (name != null) 'name': name,
        'session_type': sessionType,
        if (purpose != null) 'purpose': purpose,
      });
      
      return ApiSuccess(data: response.data);
    } on DioException catch (e) {
      return ApiError(
        message: e.response?.data?['detail'] ?? 'Failed to create session',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getSessions({
    int limit = 100,
    int offset = 0,
    String? sessionType,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      if (sessionType != null) {
        queryParams['session_type'] = sessionType;
      }
      
      final response = await _dio.get('/sessions/', queryParameters: queryParams);
      return ApiSuccess(data: response.data);
    } on DioException catch (e) {
      return ApiError(
        message: e.response?.data?['detail'] ?? 'Failed to get sessions',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // Update session name
  Future<ApiResponse<Map<String, dynamic>>> updateSessionName({
    required String sessionId,
    required String name,
  }) async {
    try {
      appLogger.debug('updateSessionName - sending request to /sessions/$sessionId', 'ApiService');
      appLogger.debug('updateSessionName - query parameter: name=$name', 'ApiService');
      
      final response = await _dio.put('/sessions/$sessionId', queryParameters: {
        'name': name,
      });
      
      appLogger.debug('updateSessionName - response status: ${response.statusCode}', 'ApiService');
      appLogger.debug('updateSessionName - response data: ${response.data}', 'ApiService');
      
      return ApiSuccess(data: response.data);
    } on DioException catch (e) {
      appLogger.debug('updateSessionName - error: ${e.toString()}', 'ApiService');
      appLogger.debug('updateSessionName - error response: ${e.response?.data}', 'ApiService');
      appLogger.debug('updateSessionName - error status code: ${e.response?.statusCode}', 'ApiService');
      
      return ApiError(
        message: e.response?.data?['detail'] ?? 'Failed to update session name',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // Delete session
  Future<ApiResponse<Map<String, dynamic>>> deleteSession({
    required String sessionId,
  }) async {
    try {
      appLogger.debug('deleteSession - sending request to /sessions/$sessionId', 'ApiService');
      
      final response = await _dio.delete('/sessions/$sessionId');
      
      appLogger.debug('deleteSession - response status: ${response.statusCode}', 'ApiService');
      appLogger.debug('deleteSession - response data: ${response.data}', 'ApiService');
      
      // Handle 204 No Content (successful deletion)
      if (response.statusCode == 204) {
        return ApiSuccess(data: {'deleted': true});
      }
      
      // Handle other success status codes
      return ApiSuccess(data: response.data ?? {'deleted': true});
    } on DioException catch (e) {
      appLogger.debug('deleteSession - error: ${e.toString()}', 'ApiService');
      appLogger.debug('deleteSession - error response: ${e.response?.data}', 'ApiService');
      appLogger.debug('deleteSession - error status code: ${e.response?.statusCode}', 'ApiService');
      
      // Handle specific error cases
      if (e.response?.statusCode == 404) {
        return ApiError(
          message: 'Session not found',
          statusCode: 404,
        );
      }
      
      return ApiError(
        message: e.response?.data?['detail'] ?? 'Failed to delete session',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // Communication Management
  Future<ApiResponse<Map<String, dynamic>>> createCommunication({
    required String sessionId,
    required String itemType,
    required String role,
    required String originalContent,
    String? redactedContent,
    bool consent = false,
  }) async {
    try {
      final response = await _dio.post('/communications/', data: {
        'session_id': sessionId,
        'item_type': itemType,
        'role': role,
        'original_content': originalContent,
        if (redactedContent != null) 'redacted_content': redactedContent,
        'consent': consent,
      });
      
      return ApiSuccess(data: response.data);
    } on DioException catch (e) {
      return ApiError(
        message: e.response?.data?['detail'] ?? 'Failed to create communication',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getCommunications({
    String? sessionId,
    String? itemType,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get('/communications/', queryParameters: {
        if (sessionId != null) 'session_id': sessionId,
        if (itemType != null) 'item_type': itemType,
        'limit': limit,
        'offset': offset,
      });
      
      return ApiSuccess(data: response.data);
    } on DioException catch (e) {
      return ApiError(
        message: e.response?.data?['detail'] ?? 'Failed to get communications',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // User Management
  Future<ApiResponse<Map<String, dynamic>>> getCurrentUser() async {
    try {
      final response = await _dio.get('/users/me');
      return ApiSuccess(data: response.data);
    } on DioException catch (e) {
      return ApiError(
        message: e.response?.data?['detail'] ?? 'Failed to get user information',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> updateOnboardedStatus(bool onboarded) async {
    try {
      // Use a shorter timeout for this specific endpoint
      final response = await _dio.put(
        '/users/onboarded', 
        data: {
          'onboarded': onboarded,
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );
      return ApiSuccess(data: response.data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        // For onboarding status, we'll consider this a success to avoid blocking the user
        // The backend will eventually update the status
        return ApiSuccess(data: {'onboarded': onboarded, 'status': 'pending'});
      }
      return ApiError(
        message: e.response?.data?['detail'] ?? 'Failed to update onboarded status',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> validateSafetyCode(String code, String passphrase) async {
    try {
      final response = await _dio.post('/users/safety-codes/validate', data: {
        'code': code,
        'passphrase': passphrase,
      });
      return ApiSuccess(data: response.data);
    } on DioException catch (e) {
      return ApiError(
        message: e.response?.data?['detail'] ?? 'Failed to validate safety code',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> saveSafetyCodes(Map<String, String> codes, String passphrase) async {
    try {
      final response = await _dio.post('/users/safety-codes', data: {
        'codes': codes,
        'passphrase': passphrase,
      });
      return ApiSuccess(data: response.data);
    } on DioException catch (e) {
      return ApiError(
        message: e.response?.data?['detail'] ?? 'Failed to save safety codes',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> clearSafetyCodes() async {
    try {
      final response = await _dio.delete('/users/safety-codes');
      return ApiSuccess(data: response.data);
    } on DioException catch (e) {
      return ApiError(
        message: e.response?.data?['detail'] ?? 'Failed to clear safety codes',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // Onboarding Data Management - Using user data approach like kch_dev
  Future<ApiResponse<Map<String, dynamic>>> getOnboardingData() async {
    try {
      // Use /users/me to get user data including onboarding information
      final response = await _dio.get('/users/me');
      return ApiSuccess(data: response.data);
    } on DioException catch (e) {
      return ApiError(
        message: e.response?.data?['detail'] ?? 'Failed to get user onboarding data',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> saveSituationData(Map<String, dynamic> situationData) async {
    try {
      // Update user's relationship context
      final response = await _dio.put('/users/relationship-context', data: {
        'relationship_context': situationData,
      });
      return ApiSuccess(data: response.data);
    } on DioException catch (e) {
      return ApiError(
        message: e.response?.data?['detail'] ?? 'Failed to save situation data',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> saveRedactionProfile(Map<String, dynamic> profileData) async {
    try {
      // Convert profile data to JSON string as expected by backend
      final profileDataString = jsonEncode(profileData);
      
      // Try to create new profile first
      try {
        final response = await _dio.post('/redaction-profiles/', data: {
          'encrypted_profile_data': profileDataString, // Backend expects a string
        });
        return ApiSuccess(data: response.data);
      } on DioException catch (e) {
        // If profile already exists (409), try to update it
        if (e.response?.statusCode == 409) {
          final updateResponse = await _dio.put('/redaction-profiles/', data: {
            'encrypted_profile_data': profileDataString,
          });
          return ApiSuccess(data: updateResponse.data);
        }
        // Re-throw other errors
        rethrow;
      }
    } on DioException catch (e) {
      return ApiError(
        message: e.response?.data?['detail'] ?? 'Failed to save redaction profile',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> saveConsentForm(bool accepted) async {
    try {
      // Update consent for LLM training
      final response = await _dio.post('/redaction-profiles/consent', data: {
        'consent': accepted,
      });
      return ApiSuccess(data: response.data);
    } on DioException catch (e) {
      return ApiError(
        message: e.response?.data?['detail'] ?? 'Failed to save consent form',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> clearOnboardingData() async {
    try {
      // Clear onboarding data by updating user data
      final response = await _dio.put('/users/me', data: {
        'relationship_context': null,
        'redaction_profile': null,
        'llm_training_consent': null,
      });
      return ApiSuccess(data: response.data);
    } on DioException catch (e) {
      return ApiError(
        message: e.response?.data?['detail'] ?? 'Failed to clear onboarding data',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // Update onboarding status
  Future<ApiResponse<Map<String, dynamic>>> updateOnboardingStatus(bool isOnboarded) async {
    try {
      // Use a shorter timeout for this specific endpoint
      final response = await _dio.put(
        '/users/onboarded', 
        data: {
          'onboarded': isOnboarded,
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );
      return ApiSuccess(data: response.data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        // For onboarding status, we'll consider this a success to avoid blocking the user
        // The backend will eventually update the status
        return ApiSuccess(data: {'onboarded': isOnboarded, 'status': 'pending'});
      }
      return ApiError(
        message: e.response?.data?['detail'] ?? 'Failed to update onboarding status',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // Update redaction profile (separate method for clarity)
  Future<ApiResponse<Map<String, dynamic>>> updateRedactionProfile(Map<String, dynamic> profileData) async {
    try {
      final profileDataString = jsonEncode(profileData);
      final response = await _dio.put('/redaction-profiles/', data: {
        'encrypted_profile_data': profileDataString,
      });
      return ApiSuccess(data: response.data);
    } on DioException catch (e) {
      return ApiError(
        message: e.response?.data?['detail'] ?? 'Failed to update redaction profile',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // Journal Management
  Future<ApiResponse<Map<String, dynamic>>> getJournalEntries({
    String? entryType,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      if (entryType != null) {
        queryParams['entry_type'] = entryType;
      }
      
      final response = await _dio.get('/journals/', queryParameters: queryParams);
      return ApiSuccess(data: response.data);
    } on DioException catch (e) {
      return ApiError(
        message: e.response?.data?['detail'] ?? 'Failed to get journal entries',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getJournalEntry(String entryId) async {
    try {
      final response = await _dio.get('/journals/$entryId');
      return ApiSuccess(data: response.data);
    } on DioException catch (e) {
      return ApiError(
        message: e.response?.data?['detail'] ?? 'Failed to get journal entry',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> createJournalEntry({
    required String header,
    required String entryType,
    String? sessionId,
    Map<String, dynamic>? metaData,
    String? originalContent,
    bool consent = false,
  }) async {
    try {
      final response = await _dio.post('/journals/', data: {
        'header': header,
        'entry_type': entryType,
        if (sessionId != null) 'session_id': sessionId,
        if (metaData != null) 'meta_data': metaData,
        if (originalContent != null) 'original_content': originalContent,
        'consent': consent,
      });
      
      return ApiSuccess(data: response.data);
    } on DioException catch (e) {
      return ApiError(
        message: e.response?.data?['detail'] ?? 'Failed to create journal entry',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> createAIJournalEntry({
    required String sessionId,
    String? customContent,
  }) async {
    try {
      final requestData = {
        'session_id': sessionId,
        if (customContent != null) 'custom_content': customContent,
      };
      
      // Validate session ID format
      if (sessionId.isEmpty) {
        throw Exception('Session ID cannot be empty');
      }
      
      appLogger.debug('createAIJournalEntry - sending request with sessionId: $sessionId', 'ApiService');
      appLogger.debug('createAIJournalEntry - request data: $requestData', 'ApiService');
      
      // Add more detailed logging for debugging
      appLogger.apiRequest('POST', '/journals/ai-summary', requestData);
      
      final response = await _dio.post(
        '/journals/ai-summary',
        data: requestData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          validateStatus: (status) {
            // Don't throw for 500 errors, let us handle them
            return status != null && status < 600;
          },
        ),
      );
      
      appLogger.debug('createAIJournalEntry - response status: ${response.statusCode}', 'ApiService');
      appLogger.debug('createAIJournalEntry - response data: ${response.data}', 'ApiService');
      
      if (response.statusCode == 200) {
        return ApiSuccess(data: response.data);
      } else {
        appLogger.apiError('POST', '/journals/ai-summary', response.statusCode ?? 500, response.data);
        return ApiError(
          message: response.data?['detail'] ?? 'Failed to create AI journal entry',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      appLogger.debug('createAIJournalEntry - error: ${e.toString()}', 'ApiService');
      appLogger.debug('createAIJournalEntry - error response: ${e.response?.data}', 'ApiService');
      
      return ApiError(
        message: e.response?.data?['detail'] ?? 'Failed to create AI journal entry',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> updateJournalEntry({
    required String entryId,
    String? header,
    String? entryType,
    String? originalContent,
    Map<String, dynamic>? metaData,
    bool? consent,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (header != null) data['header'] = header;
      if (entryType != null) data['entry_type'] = entryType;
      if (originalContent != null) data['original_content'] = originalContent;
      if (metaData != null) data['meta_data'] = metaData;
      if (consent != null) data['consent'] = consent;
      
      final response = await _dio.put('/journals/$entryId', data: data);
      return ApiSuccess(data: response.data);
    } on DioException catch (e) {
      return ApiError(
        message: e.response?.data?['detail'] ?? 'Failed to update journal entry',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> deleteJournalEntry(String entryId) async {
    try {
      final response = await _dio.delete('/journals/$entryId');
      return ApiSuccess(data: response.data);
    } on DioException catch (e) {
      return ApiError(
        message: e.response?.data?['detail'] ?? 'Failed to delete journal entry',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // Get user balance
  Future<ApiResponse<int>> getBalance() async {
    try {
      final response = await _dio.get('/billing/balance');
      return ApiSuccess(data: response.data['balance'] as int);
    } on DioException catch (e) {
      return ApiError(
        message: e.response?.data['detail'] ?? 'Failed to get balance',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiError(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  // Get billing status
  Future<ApiResponse<Map<String, dynamic>>> getBillingStatus() async {
    try {
      final response = await _dio.get('/billing/status');
      return ApiSuccess(data: response.data);
    } on DioException catch (e) {
      return ApiError(
        message: e.response?.data['detail'] ?? 'Failed to get billing status',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiError(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  // Generic HTTP methods for repositories
  Future<ApiResponse<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return ApiSuccess(data: response.data);
    } on DioException catch (e) {
      return ApiError(
        message: e.response?.data?['detail'] ?? 'GET request failed',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiError(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<ApiResponse<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(path, data: data, queryParameters: queryParameters);
      return ApiSuccess(data: response.data);
    } on DioException catch (e) {
      return ApiError(
        message: e.response?.data?['detail'] ?? 'POST request failed',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiError(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<ApiResponse<dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(path, data: data, queryParameters: queryParameters);
      return ApiSuccess(data: response.data);
    } on DioException catch (e) {
      return ApiError(
        message: e.response?.data?['detail'] ?? 'PUT request failed',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiError(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<ApiResponse<dynamic>> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(path, queryParameters: queryParameters);
      return ApiSuccess(data: response.data);
    } on DioException catch (e) {
      return ApiError(
        message: e.response?.data?['detail'] ?? 'DELETE request failed',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiError(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<ApiResponse<Stream<dynamic>>> postStream(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(responseType: ResponseType.stream),
      );
      
      // Convert the stream to the expected format
      final stream = response.data as Stream<dynamic>;
      return ApiSuccess(data: stream);
    } on DioException catch (e) {
      return ApiError(
        message: e.response?.data?['detail'] ?? 'Stream request failed',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiError(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }
}
