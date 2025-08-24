import 'package:flutter/foundation.dart';

class DebugConfig {
  static const bool _enableDebugMode = kDebugMode;
  
  // Debug mode settings
  static bool get isDebugMode => _enableDebugMode;
  
  // Test user credentials for development
  // ✅ Found in kch_dev backend database
  // Email: test@tsukiyo.dev
  // Password: password123
  // Tenant ID: 1aca2ef7-b1fa-46bb-af08-a8fdb449b1f9
  // Application ID: c8f67708-8f15-4205-be08-ebc676205d1d
  static const String testEmail = 'test@tsukiyo.dev';
  static const String testPassword = 'password123';
  
  // Debug API settings
  static const String debugApiUrl = 'http://localhost:8000/api';
  static const String productionApiUrl = 'https://api.mindhearth.com/api';
  
  // Get the appropriate API URL based on debug mode
  static String get apiUrl => isDebugMode ? debugApiUrl : productionApiUrl;
  
  // Debug features
  static bool get enableDebugLogging => isDebugMode;
  static bool get enableTestData => isDebugMode;
  static bool get enableMockResponses => false; // Always use real backend
  
  // Debug navigation shortcuts
  static bool get enableDebugNavigation => isDebugMode;
  
  // Debug user state shortcuts
  static bool get enableAutoLogin => isDebugMode;
  static bool get enableSkipOnboarding => false; // Always go through real onboarding
  static bool get enableSkipSafetyCode => false; // Always go through real safety code
  
  // Debug UI features
  static bool get showDebugBanner => isDebugMode;
  static bool get enablePerformanceOverlay => isDebugMode;
  
  // Debug data - only used if backend is unavailable
  static Map<String, dynamic> get testUserData => {
    'id': 'test_user_123',
    'email': testEmail,
    'tenant_id': 'test_tenant_456',
    'first_name': 'Test',
    'last_name': 'User',
    'is_onboarded': false,
  };
  
  static Map<String, dynamic> get testAuthResponse => {
    'access_token': 'debug_jwt_token_for_testing',
    'user_id': testUserData['id'],
    'tenant_id': testUserData['tenant_id'],
    'message': 'Debug login successful',
  };
  
  // Backend connectivity check
  static bool get useRealBackend => true; // Always use real backend in debug mode
}
