import 'package:flutter/foundation.dart';

class DebugConfig {
  static const bool _enableDebugMode = kDebugMode;
  
  // Debug mode settings
  static bool get isDebugMode => _enableDebugMode;
  
  // Test user credentials for development
  static const String testEmail = 'test@mindhearth.com';
  static const String testPassword = 'password123';
  
  // Debug API settings
  static const String debugApiUrl = 'http://localhost:8000/api';
  static const String productionApiUrl = 'https://api.mindhearth.com/api';
  
  // Get the appropriate API URL based on debug mode
  static String get apiUrl => isDebugMode ? debugApiUrl : productionApiUrl;
  
  // Debug features
  static bool get enableDebugLogging => isDebugMode;
  static bool get enableTestData => isDebugMode;
  static bool get enableMockResponses => isDebugMode;
  
  // Debug navigation shortcuts
  static bool get enableDebugNavigation => isDebugMode;
  
  // Debug user state shortcuts
  static bool get enableAutoLogin => isDebugMode;
  static bool get enableSkipOnboarding => isDebugMode;
  static bool get enableSkipSafetyCode => isDebugMode;
  
  // Debug UI features
  static bool get showDebugBanner => isDebugMode;
  static bool get enablePerformanceOverlay => isDebugMode;
  
  // Debug data
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
}
