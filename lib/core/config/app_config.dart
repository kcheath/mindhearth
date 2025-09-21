class AppConfig {
  // Environment
  static const String environment = String.fromEnvironment('ENV', defaultValue: 'development');
  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';

  // API Configuration
  static String get apiBaseUrl => const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  static String get apiVersion => const String.fromEnvironment(
    'API_VERSION',
    defaultValue: 'v1',
  );

  static String get fullApiUrl => '$apiBaseUrl/$apiVersion';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Feature Flags
  static const bool enableDebugLogs = true;
  static const bool enablePerformanceLogs = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;

  // App Information
  static const String appName = 'Mindhearth';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Security
  static const int minPassphraseLength = 8;
  static const int maxPassphraseLength = 128;
  static const int safetyCodeLength = 6;
  static const int maxLoginAttempts = 3;
  static const Duration lockoutDuration = Duration(minutes: 15);

  // UI Configuration
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 8.0;
  static const double defaultBorderRadius = 8.0;
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Storage
  static const String sharedPreferencesPrefix = 'mindhearth_';

  // Validation Rules
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+$',
  );

  static final RegExp passphraseRegex = RegExp(
    r'''^[a-zA-Z0-9!@#\$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]{8,}$''',
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

  // Validation Methods
  static bool isValidEmail(String email) {
    return emailRegex.hasMatch(email);
  }

  static bool isValidPassphrase(String passphrase) {
    return passphrase.length >= minPassphraseLength &&
           passphrase.length <= maxPassphraseLength &&
           passphraseRegex.hasMatch(passphrase);
  }

  static bool isValidSafetyCode(String code) {
    return code.length == safetyCodeLength && RegExp(r'^\d+$').hasMatch(code);
  }

  // Helper Methods
  static String getErrorMessage(String errorType) {
    return errorMessages[errorType] ?? errorMessages['unknown_error']!;
  }

  static int getMaxRetryAttempts() {
    return isDevelopment ? 1 : 3;
  }

  static Duration getRetryDelay(int attempt) {
    return Duration(seconds: attempt * 2);
  }
}