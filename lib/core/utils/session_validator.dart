import 'package:mindhearth/core/utils/logger.dart';

/// Utility class for validating session IDs and ensuring proper UUID format
class SessionValidator {
  // UUID v4 regex pattern
  static final RegExp _uuidRegex = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  /// Validates if a session ID is a proper UUID v4 format
  static bool isValidSessionId(String sessionId) {
    if (sessionId.isEmpty) {
      appLogger.warning('Session ID is empty');
      return false;
    }

    final isValid = _uuidRegex.hasMatch(sessionId);
    
    if (!isValid) {
      appLogger.warning('Invalid session ID format', {
        'sessionId': sessionId,
        'expectedFormat': 'UUID v4',
      });
    }

    return isValid;
  }

  /// Validates session ID and logs the result
  static bool validateSessionId(String sessionId, {String? context}) {
    final isValid = isValidSessionId(sessionId);
    
    if (isValid) {
      appLogger.debug('✅ Valid session ID', {
        'sessionId': sessionId,
        'context': context ?? 'validation',
      });
    } else {
      appLogger.error('❌ Invalid session ID', {
        'sessionId': sessionId,
        'context': context ?? 'validation',
        'expectedFormat': 'UUID v4 (e.g., 550e8400-e29b-41d4-a716-446655440000)',
      });
    }

    return isValid;
  }

  /// Generates a sample UUID for testing purposes
  static String generateSampleSessionId() {
    return '550e8400-e29b-41d4-a716-446655440000';
  }

  /// Checks if session ID is from backend (UUID) or legacy (string)
  static bool isBackendSessionId(String sessionId) {
    return isValidSessionId(sessionId);
  }

  /// Checks if session ID is legacy format (for backward compatibility)
  static bool isLegacySessionId(String sessionId) {
    return !isValidSessionId(sessionId) && sessionId.isNotEmpty;
  }
}
