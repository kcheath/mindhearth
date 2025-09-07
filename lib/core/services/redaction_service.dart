import 'package:mindhearth/core/services/api_service.dart';
import 'package:mindhearth/core/utils/logger.dart';
import 'package:mindhearth/core/config/logging_config.dart';

/// Service for handling content redaction and privacy protection
class RedactionService {
  final ApiService _apiService;

  RedactionService(this._apiService);

  /// Preprocess content to identify sensitive information
  Future<Map<String, dynamic>> preprocessContent(
    String content,
    Map<String, dynamic> redactionProfile,
  ) async {
    try {
      if (LoggingConfig.enableApiLogs) {
        appLogger.apiRequest('POST', '/redaction/preprocess', {
          'contentLength': content.length,
          'profileKeys': redactionProfile.keys.toList(),
        });
      }

      final response = await _apiService.dio.post('/redaction/preprocess', data: {
        'text': content,
        'profile': redactionProfile,
      });

      if (LoggingConfig.enableApiLogs) {
        appLogger.apiResponse('POST', '/redaction/preprocess', response.statusCode ?? 200, {
          'redactedLength': response.data['redacted_text']?.length ?? 0,
          'confidenceScore': response.data['confidence_score'] ?? 0,
        });
      }

      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (LoggingConfig.enableApiLogs) {
        appLogger.apiError('POST', '/redaction/preprocess', 500, e.toString());
      }
      
      // Fallback: return original content with basic redaction
      return _fallbackRedaction(content, redactionProfile);
    }
  }

  /// Fallback redaction when API is not available
  Map<String, dynamic> _fallbackRedaction(
    String content,
    Map<String, dynamic> redactionProfile,
  ) {
    String redactedContent = content;
    Map<String, int> redactionSummary = {};
    
    // Basic redaction patterns
    final patterns = {
      'names': RegExp(r'\b[A-Z][a-z]+ [A-Z][a-z]+\b'),
      'emails': RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'),
      'phones': RegExp(r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b'),
      'addresses': RegExp(r'\b\d+\s+[A-Za-z\s]+(?:Street|St|Avenue|Ave|Road|Rd|Drive|Dr|Lane|Ln|Boulevard|Blvd)\b'),
    };

    for (final entry in patterns.entries) {
      final matches = entry.value.allMatches(content);
      if (matches.isNotEmpty) {
        redactedContent = redactedContent.replaceAll(entry.value, '[REDACTED]');
        redactionSummary[entry.key] = matches.length;
      }
    }

    return {
      'redacted_text': redactedContent,
      'redaction_summary': redactionSummary,
      'confidence_score': 0.7, // Fallback confidence
    };
  }

  /// Get redaction profile for user
  Future<Map<String, dynamic>?> getRedactionProfile() async {
    try {
      if (LoggingConfig.enableApiLogs) {
        appLogger.apiRequest('GET', '/redaction/profile', {});
      }

      final response = await _apiService.dio.get('/redaction/profile');

      if (LoggingConfig.enableApiLogs) {
        appLogger.apiResponse('GET', '/redaction/profile', response.statusCode ?? 200, {
          'profileKeys': response.data.keys.toList(),
        });
      }

      return response.data as Map<String, dynamic>?;
    } catch (e) {
      if (LoggingConfig.enableApiLogs) {
        appLogger.apiError('GET', '/redaction/profile', 500, e.toString());
      }
      return null;
    }
  }

  /// Save redaction profile for user
  Future<bool> saveRedactionProfile(Map<String, dynamic> profile) async {
    try {
      if (LoggingConfig.enableApiLogs) {
        appLogger.apiRequest('POST', '/redaction/profile', {
          'profileKeys': profile.keys.toList(),
        });
      }

      final response = await _apiService.dio.post('/redaction/profile', data: profile);

      if (LoggingConfig.enableApiLogs) {
        appLogger.apiResponse('POST', '/redaction/profile', response.statusCode ?? 200, {
          'success': true,
        });
      }

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      if (LoggingConfig.enableApiLogs) {
        appLogger.apiError('POST', '/redaction/profile', 500, e.toString());
      }
      return false;
    }
  }
}
