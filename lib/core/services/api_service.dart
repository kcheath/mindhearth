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
}
