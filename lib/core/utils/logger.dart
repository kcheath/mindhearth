import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

/// A centralized logging system for the Mindhearth application.
/// 
/// This logger provides:
/// - Structured logging with different levels (debug, info, warning, error)
/// - Security-conscious logging (no sensitive data in production)
/// - Performance-optimized logging (conditional compilation)
/// - Consistent formatting across the application
/// - Easy filtering and debugging capabilities
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  late final Logger _logger;
  bool _isInitialized = false;

  /// Initialize the logger with appropriate configuration
  void initialize({bool enableDebugLogs = false}) {
    if (_isInitialized) return;

    final filter = enableDebugLogs || kDebugMode 
        ? DevelopmentFilter() 
        : ProductionFilter();

    _logger = Logger(
      filter: filter,
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
    );

    _isInitialized = true;
    
    // Log initialization
    _logger.i('🚀 AppLogger initialized - debugMode: $kDebugMode, enableDebugLogs: $enableDebugLogs, filter: ${filter.runtimeType}');
  }

  /// Get the underlying logger instance
  Logger get logger {
    if (!_isInitialized) {
      throw StateError('AppLogger must be initialized before use. Call AppLogger().initialize() first.');
    }
    return _logger;
  }

  /// Log a debug message
  /// Use for detailed debugging information
  void debug(String message, [dynamic data, StackTrace? stackTrace]) {
    _log(Level.debug, message, data, stackTrace);
  }

  /// Log an info message
  /// Use for general application flow information
  void info(String message, [dynamic data, StackTrace? stackTrace]) {
    _log(Level.info, message, data, stackTrace);
  }

  /// Log a warning message
  /// Use for potentially harmful situations
  void warning(String message, [dynamic data, StackTrace? stackTrace]) {
    _log(Level.warning, message, data, stackTrace);
  }

  /// Log an error message
  /// Use for error conditions that don't prevent the app from running
  void error(String message, [dynamic data, StackTrace? stackTrace]) {
    _log(Level.error, message, data, stackTrace);
  }

  /// Log a fatal error message
  /// Use for severe errors that prevent the app from running
  void fatal(String message, [dynamic data, StackTrace? stackTrace]) {
    _log(Level.fatal, message, data, stackTrace);
  }

  /// Log API requests
  /// Use for logging HTTP requests (without sensitive data)
  void apiRequest(String method, String endpoint, [Map<String, dynamic>? headers]) {
    final sanitizedHeaders = _sanitizeHeaders(headers);
    _log(Level.info, '🌐 API Request', {
      'method': method,
      'endpoint': endpoint,
      'headers': sanitizedHeaders,
    });
  }

  /// Log API responses
  /// Use for logging HTTP responses (without sensitive data)
  void apiResponse(String method, String endpoint, int statusCode, [dynamic data]) {
    final sanitizedData = _sanitizeResponseData(data);
    _log(Level.info, '📡 API Response', {
      'method': method,
      'endpoint': endpoint,
      'statusCode': statusCode,
      'data': sanitizedData,
    });
  }

  /// Log API errors
  /// Use for logging HTTP errors
  void apiError(String method, String endpoint, int statusCode, String error, [dynamic data]) {
    final sanitizedData = _sanitizeResponseData(data);
    _log(Level.error, '❌ API Error', {
      'method': method,
      'endpoint': endpoint,
      'statusCode': statusCode,
      'error': error,
      'data': sanitizedData,
    });
  }

  /// Log authentication events
  /// Use for logging login/logout events (without sensitive data)
  void auth(String event, [Map<String, dynamic>? data]) {
    final sanitizedData = _sanitizeAuthData(data);
    _log(Level.info, '🔐 Auth Event: $event', sanitizedData);
  }

  /// Log onboarding events
  /// Use for logging onboarding flow events
  void onboarding(String event, [Map<String, dynamic>? data]) {
    _log(Level.info, '📋 Onboarding: $event', data);
  }

  /// Log safety code events
  /// Use for logging safety code operations (without actual codes)
  void safetyCode(String event, [Map<String, dynamic>? data]) {
    final sanitizedData = _sanitizeSafetyCodeData(data);
    _log(Level.info, '🔑 Safety Code: $event', sanitizedData);
  }

  /// Log encryption events
  /// Use for logging encryption operations (without actual data)
  void encryption(String event, [Map<String, dynamic>? data]) {
    final sanitizedData = _sanitizeEncryptionData(data);
    _log(Level.info, '🔒 Encryption: $event', sanitizedData);
  }

  /// Log navigation events
  /// Use for logging route changes
  void navigation(String from, String to, [Map<String, dynamic>? data]) {
    _log(Level.debug, '🧭 Navigation', {
      'from': from,
      'to': to,
      ...?data,
    });
  }

  /// Log state changes
  /// Use for logging significant state changes
  void stateChange(String component, String event, [Map<String, dynamic>? data]) {
    _log(Level.debug, '🔄 State Change: $component - $event', data);
  }

  /// Log performance metrics
  /// Use for logging performance-related information
  void performance(String operation, int durationMs, [Map<String, dynamic>? data]) {
    _log(Level.debug, '⚡ Performance: $operation (${durationMs}ms)', data);
  }

  /// Log user interactions
  /// Use for logging user actions (without sensitive data)
  void userInteraction(String action, [Map<String, dynamic>? data]) {
    final sanitizedData = _sanitizeUserData(data);
    _log(Level.debug, '👤 User Interaction: $action', sanitizedData);
  }

  /// Internal logging method
  void _log(Level level, String message, [dynamic data, StackTrace? stackTrace]) {
    if (!_isInitialized) {
      // Fallback to print if logger not initialized
      print('[$level] $message ${data != null ? '- $data' : ''}');
      return;
    }

    final logMessage = data != null ? '$message - $data' : message;

    switch (level) {
      case Level.debug:
        logger.d(logMessage);
        break;
      case Level.info:
        logger.i(logMessage);
        break;
      case Level.warning:
        logger.w(logMessage);
        break;
      case Level.error:
        logger.e(logMessage);
        break;
      case Level.fatal:
        logger.f(logMessage);
        break;
      case Level.verbose:
        logger.v(logMessage);
        break;
      case Level.wtf:
        logger.wtf(logMessage);
        break;
      case Level.all:
        // Handle all level if needed
        break;
      case Level.trace:
        logger.t(logMessage);
        break;
      default:
        // Handle any other levels (like Level.nothing)
        logger.d(logMessage);
        break;
    }
  }

  /// Sanitize headers to remove sensitive information
  Map<String, dynamic>? _sanitizeHeaders(Map<String, dynamic>? headers) {
    if (headers == null) return null;
    
    final sanitized = Map<String, dynamic>.from(headers);
    const sensitiveKeys = ['authorization', 'cookie', 'x-api-key', 'token'];
    
    for (final key in sensitiveKeys) {
      if (sanitized.containsKey(key)) {
        sanitized[key] = '[REDACTED]';
      }
    }
    
    return sanitized;
  }

  /// Sanitize response data to remove sensitive information
  dynamic _sanitizeResponseData(dynamic data) {
    if (data == null) return null;
    
    if (data is Map<String, dynamic>) {
      final sanitized = Map<String, dynamic>.from(data);
      const sensitiveKeys = ['access_token', 'refresh_token', 'password', 'passphrase'];
      
      for (final key in sensitiveKeys) {
        if (sanitized.containsKey(key)) {
          sanitized[key] = '[REDACTED]';
        }
      }
      
      return sanitized;
    }
    
    return data;
  }

  /// Sanitize authentication data
  Map<String, dynamic>? _sanitizeAuthData(Map<String, dynamic>? data) {
    if (data == null) return null;
    
    final sanitized = Map<String, dynamic>.from(data);
    const sensitiveKeys = ['password', 'token', 'access_token', 'refresh_token'];
    
    for (final key in sensitiveKeys) {
      if (sanitized.containsKey(key)) {
        sanitized[key] = '[REDACTED]';
      }
    }
    
    return sanitized;
  }

  /// Sanitize safety code data
  Map<String, dynamic>? _sanitizeSafetyCodeData(Map<String, dynamic>? data) {
    if (data == null) return null;
    
    final sanitized = Map<String, dynamic>.from(data);
    const sensitiveKeys = ['journal', 'safe', 'wipe', 'code', 'codes'];
    
    for (final key in sensitiveKeys) {
      if (sanitized.containsKey(key)) {
        sanitized[key] = '[REDACTED]';
      }
    }
    
    return sanitized;
  }

  /// Sanitize encryption data
  Map<String, dynamic>? _sanitizeEncryptionData(Map<String, dynamic>? data) {
    if (data == null) return null;
    
    final sanitized = Map<String, dynamic>.from(data);
    const sensitiveKeys = ['passphrase', 'key', 'data', 'content'];
    
    for (final key in sensitiveKeys) {
      if (sanitized.containsKey(key)) {
        sanitized[key] = '[REDACTED]';
      }
    }
    
    return sanitized;
  }

  /// Sanitize user data
  Map<String, dynamic>? _sanitizeUserData(Map<String, dynamic>? data) {
    if (data == null) return null;
    
    final sanitized = Map<String, dynamic>.from(data);
    const sensitiveKeys = ['email', 'password', 'token', 'personal_info'];
    
    for (final key in sensitiveKeys) {
      if (sanitized.containsKey(key)) {
        sanitized[key] = '[REDACTED]';
      }
    }
    
    return sanitized;
  }
}

/// Global logger instance for easy access
final appLogger = AppLogger();

/// Extension methods for easier logging
extension LoggerExtensions on Object {
  /// Log debug message with class context
  void logDebug(String message, [dynamic data]) {
    appLogger.debug('${runtimeType}: $message', data);
  }

  /// Log info message with class context
  void logInfo(String message, [dynamic data]) {
    appLogger.info('${runtimeType}: $message', data);
  }

  /// Log warning message with class context
  void logWarning(String message, [dynamic data]) {
    appLogger.warning('${runtimeType}: $message', data);
  }

  /// Log error message with class context
  void logError(String message, [dynamic data, StackTrace? stackTrace]) {
    appLogger.error('${runtimeType}: $message', data, stackTrace);
  }
}
