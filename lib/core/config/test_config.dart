/// Test configuration for backend integration
/// Contains test credentials and IDs for development
class TestConfig {
  // API Configuration
  static const String apiBaseUrl = 'http://3.150.176.19:3012/api/v1';
  static const String apiVersion = 'v1';
  static String get fullApiUrl => apiBaseUrl;
  
  // Test User Credentials
  static const String testEmail = 'test@mindhearth.dev';
  static const String testPassword = 'password123';
  
  // Tenant & Application IDs
  static const String tenantId = '50cd82c6-22a2-4532-9743-e9ebef4f21e0';
  static const String applicationId = '60dd93d7-33b3-5643-0854-f0fcf5f32f1f';
  static const String userId = 'c9380306-ea04-47de-bd14-3e26afa0063f';
  static const String apiKey = 'test-api-key-12345-new';
  
  // API Endpoints
  static const Map<String, String> endpoints = {
    'auth_login': '/auth/login',
    'auth_me': '/auth/me',
    'auth_register': '/auth/register',
    'sessions_list': '/sessions/',
    'sessions_create': '/sessions/',
    'sessions_detail': '/sessions/{id}',
    'journals_list': '/journals/',
    'journals_create': '/journals/',
    'journals_detail': '/journals/{id}',
    'chat_send': '/communications/chat',
    'chat_simple': '/communications/chat',
    'chat_stream': '/communications/chat/stream',
    'documents_list': '/documents/',
    'documents_upload': '/documents/',
    'documents_detail': '/documents/{id}',
  };
  
  // API Documentation URLs
  static const String swaggerUrl = 'http://3.150.176.19:3012/docs';
  static const String redocUrl = 'http://3.150.176.19:3012/redoc';
  static const String openApiUrl = 'http://3.150.176.19:3012/openapi.json';
  
  // Request Headers Template
  static Map<String, String> getAuthHeaders({
    required String accessToken,
    required String userId,
  }) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
      // Note: X-User-ID, X-App-ID no longer needed - backend extracts from JWT token
      // X-API-Key may still be needed for some endpoints - verify with backend
    };
  }
  
  // Login Request Data
  static Map<String, dynamic> getLoginData() {
    return {
      'email': testEmail,
      'password': testPassword,
      'tenant_id': tenantId,
      'application_id': applicationId,
    };
  }
  
  // Get full endpoint URL
  static String getEndpointUrl(String endpointKey) {
    final endpoint = endpoints[endpointKey];
    if (endpoint == null) {
      throw ArgumentError('Unknown endpoint: $endpointKey');
    }
    return '$fullApiUrl$endpoint';
  }
  
  // Get endpoint URL with ID parameter
  static String getEndpointUrlWithId(String endpointKey, String id) {
    final endpoint = endpoints[endpointKey];
    if (endpoint == null) {
      throw ArgumentError('Unknown endpoint: $endpointKey');
    }
    return '$fullApiUrl${endpoint.replaceAll('{id}', id)}';
  }
  
  // Development Notes
  static const List<String> developmentNotes = [
    'These are test credentials for development only',
    'Never use in production environment',
    'CORS is configured for localhost development',
    'HTTPS is not required for localhost',
    'API returns standard HTTP status codes',
    'All endpoints return JSON responses',
  ];
  
  // Quick Start Guide
  static const List<String> quickStartSteps = [
    'Set up environment variables with test values',
    'Implement login flow using test credentials',
    'Store JWT token from login response',
    'Use token in subsequent API calls',
    'Test core features: sessions, journals, chat',
  ];
}
