import 'package:flutter/foundation.dart';

/// Configuration for the application logging system.
/// 
/// This class centralizes all logging configuration and provides
/// easy ways to enable/disable different types of logging.
class LoggingConfig {
  static const bool _defaultEnableDebugLogs = true;
  static const bool _defaultEnableApiLogs = true;
  static const bool _defaultEnableAuthLogs = true;
  static const bool _defaultEnableNavigationLogs = true;
  static const bool _defaultEnableStateLogs = true;
  static const bool _defaultEnablePerformanceLogs = true;
  static const bool _defaultEnableUserInteractionLogs = true;

  /// Whether to enable debug logging
  static bool get enableDebugLogs => kDebugMode && _defaultEnableDebugLogs;

  /// Whether to enable API request/response logging
  static bool get enableApiLogs => kDebugMode && _defaultEnableApiLogs;

  /// Whether to enable authentication event logging
  static bool get enableAuthLogs => kDebugMode && _defaultEnableAuthLogs;

  /// Whether to enable navigation event logging
  static bool get enableNavigationLogs => kDebugMode && _defaultEnableNavigationLogs;

  /// Whether to enable state change logging
  static bool get enableStateLogs => kDebugMode && _defaultEnableStateLogs;

  /// Whether to enable performance logging
  static bool get enablePerformanceLogs => kDebugMode && _defaultEnablePerformanceLogs;

  /// Whether to enable user interaction logging
  static bool get enableUserInteractionLogs => kDebugMode && _defaultEnableUserInteractionLogs;

  /// Whether to enable safety code logging (without actual codes)
  static bool get enableSafetyCodeLogs => kDebugMode;

  /// Whether to enable encryption logging (without actual data)
  static bool get enableEncryptionLogs => kDebugMode;

  /// Whether to enable onboarding logging
  static bool get enableOnboardingLogs => kDebugMode;

  /// Get all logging configuration as a map for debugging
  static Map<String, bool> get allConfig => {
    'debugMode': kDebugMode,
    'enableDebugLogs': enableDebugLogs,
    'enableApiLogs': enableApiLogs,
    'enableAuthLogs': enableAuthLogs,
    'enableNavigationLogs': enableNavigationLogs,
    'enableStateLogs': enableStateLogs,
    'enablePerformanceLogs': enablePerformanceLogs,
    'enableUserInteractionLogs': enableUserInteractionLogs,
    'enableSafetyCodeLogs': enableSafetyCodeLogs,
    'enableEncryptionLogs': enableEncryptionLogs,
    'enableOnboardingLogs': enableOnboardingLogs,
  };

  /// Log levels that should be enabled in debug mode
  static const List<String> debugLogLevels = [
    'debug',
    'info',
    'warning',
    'error',
    'fatal',
  ];

  /// Log levels that should be enabled in production mode
  static const List<String> productionLogLevels = [
    'warning',
    'error',
    'fatal',
  ];

  /// Sensitive keys that should be redacted from logs
  static const List<String> sensitiveKeys = [
    'password',
    'passphrase',
    'access_token',
    'refresh_token',
    'authorization',
    'cookie',
    'x-api-key',
    'token',
    'journal',
    'safe',
    'wipe',
    'code',
    'codes',
    'key',
    'data',
    'content',
    'email',
    'personal_info',
  ];

  /// API endpoints that should not be logged (for security)
  static const List<String> sensitiveEndpoints = [
    '/auth/login',
    '/auth/register',
    '/auth/refresh',
    '/users/password',
    '/users/safety-codes',
  ];

  /// Whether an endpoint should be logged
  static bool shouldLogEndpoint(String endpoint) {
    return !sensitiveEndpoints.contains(endpoint);
  }

  /// Whether a key should be redacted
  static bool shouldRedactKey(String key) {
    return sensitiveKeys.contains(key.toLowerCase());
  }
}
