import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:mindhearth/core/models/api_response.dart';
import 'package:mindhearth/core/config/debug_config.dart';

class ApiService {
  static const String _tokenKey = 'access_token';
  
  late final Dio _dio;
  late final FlutterSecureStorage _storage;
  late final Logger _logger;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: DebugConfig.apiUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _storage = const FlutterSecureStorage();
    _logger = Logger();
    
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
          _logger.d('Request: ${options.method} ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d('Response: ${response.statusCode} ${response.requestOptions.path}');
          handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('API Error: ${error.message}');
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
      _logger.d('Attempting login with real backend: $email');
      
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      _logger.d('Login successful');
      return ApiSuccess(data: response.data);
    } on DioException catch (e) {
      _logger.e('Login failed: ${e.message}');
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

  // Chat endpoint
  Future<ApiResponse<Map<String, dynamic>>> sendChatMessage({
    required List<Map<String, dynamic>> messages,
  }) async {
    try {
      final response = await _dio.post('/chat', data: {
        'messages': messages,
      });
      
      return ApiSuccess(data: response.data);
    } on DioException catch (e) {
      return ApiError(
        message: e.response?.data?['detail'] ?? 'Chat request failed',
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
      final response = await _dio.put('/users/onboarded', data: {
        'onboarded': onboarded,
      });
      return ApiSuccess(data: response.data);
    } on DioException catch (e) {
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
}
