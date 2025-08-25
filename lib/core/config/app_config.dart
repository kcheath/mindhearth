import 'package:flutter/foundation.dart';

/// Centralized application configuration
class AppConfig {
  static const String _defaultApiBaseUrl = 'https://api.mindhearth.com';
  static const String _defaultApiVersion = 'v1';
  static const int _defaultRequestTimeout = 30000; // 30 seconds
  static const int _defaultRetryAttempts = 3;
  static const bool _defaultEnableLogging = true;
  static const bool _defaultEnableAnalytics = false;
  static const bool _defaultEnableCrashReporting = true;

  // API Configuration
  static String get apiBaseUrl {
    return const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: _defaultApiBaseUrl,
    );
  }

  static String get apiVersion {
    return const String.fromEnvironment(
      'API_VERSION',
      defaultValue: _defaultApiVersion,
    );
  }

  static String get apiUrl => '$apiBaseUrl/$apiVersion';

  static int get requestTimeout {
    return const int.fromEnvironment(
      'REQUEST_TIMEOUT',
      defaultValue: _defaultRequestTimeout,
    );
  }

  static int get retryAttempts {
    return const int.fromEnvironment(
      'RETRY_ATTEMPTS',
      defaultValue: _defaultRetryAttempts,
    );
  }

  // Feature Flags
  static bool get enableLogging {
    return const bool.fromEnvironment(
      'ENABLE_LOGGING',
      defaultValue: _defaultEnableLogging,
    );
  }

  static bool get enableAnalytics {
    return const bool.fromEnvironment(
      'ENABLE_ANALYTICS',
      defaultValue: _defaultEnableAnalytics,
    );
  }

  static bool get enableCrashReporting {
    return const bool.fromEnvironment(
      'ENABLE_CRASH_REPORTING',
      defaultValue: _defaultEnableCrashReporting,
    );
  }

  // Environment
  static bool get isDebug => kDebugMode;
  static bool get isRelease => kReleaseMode;
  static bool get isProfile => kProfileMode;

  // App Information
  static const String appName = 'Mindhearth';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Security Configuration
  static const int minPassphraseLength = 8;
  static const int maxPassphraseLength = 128;
  static const int safetyCodeLength = 6;
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);

  // UI Configuration
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 4);
  static const Duration loadingTimeout = Duration(seconds: 30);

  // Storage Configuration
  static const String secureStoragePrefix = 'mindhearth_';
  static const String sharedPreferencesPrefix = 'mindhearth_';

  // Validation Rules
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
  );

  static final RegExp passphraseRegex = RegExp(
    r'^[a-zA-Z0-9!@#$%^&*()_+\-=\[\]{};\':"\\|,.<>\/?]{8,}$',
  );

  // Error Messages
  static const Map<String, String> errorMessages = {
    'network_error': 'Please check your internet connection and try again.',
    'server_error': 'Something went wrong on our end. Please try again later.',
    'validation_error': 'Please check your input and try again.',
    'authentication_error': 'Invalid credentials. Please try again.',
    'authorization_error': 'You don\'t have permission to perform this action.',
    'storage_error': 'Failed to save data. Please try again.',
    'encryption_error': 'Security error. Please restart the app.',
    'unknown_error': 'An unexpected error occurred. Please try again.',
  };

  // Success Messages
  static const Map<String, String> successMessages = {
    'login_success': 'Welcome back!',
    'logout_success': 'You have been logged out successfully.',
    'onboarding_complete': 'Welcome to Mindhearth!',
    'data_saved': 'Your data has been saved successfully.',
    'settings_updated': 'Settings updated successfully.',
  };

  /// Get error message by key
  static String getErrorMessage(String key) {
    return errorMessages[key] ?? errorMessages['unknown_error']!;
  }

  /// Get success message by key
  static String getSuccessMessage(String key) {
    return successMessages[key] ?? 'Operation completed successfully.';
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    return emailRegex.hasMatch(email);
  }

  /// Validate passphrase strength
  static bool isValidPassphrase(String passphrase) {
    return passphrase.length >= minPassphraseLength &&
           passphrase.length <= maxPassphraseLength &&
           passphraseRegex.hasMatch(passphrase);
  }

  /// Get passphrase strength level
  static int getPassphraseStrength(String passphrase) {
    int strength = 0;
    
    if (passphrase.length >= minPassphraseLength) strength++;
    if (passphrase.contains(RegExp(r'[a-z]'))) strength++;
    if (passphrase.contains(RegExp(r'[A-Z]'))) strength++;
    if (passphrase.contains(RegExp(r'[0-9]'))) strength++;
    if (passphrase.contains(RegExp(r'[!@#$%^&*()_+\-=\[\]{};\':"\\|,.<>\/?]'))) strength++;
    
    return strength;
  }

  /// Get passphrase strength description
  static String getPassphraseStrengthDescription(String passphrase) {
    final strength = getPassphraseStrength(passphrase);
    
    switch (strength) {
      case 0:
      case 1:
        return 'Very Weak';
      case 2:
        return 'Weak';
      case 3:
        return 'Fair';
      case 4:
        return 'Good';
      case 5:
        return 'Strong';
      default:
        return 'Very Strong';
    }
  }
}
