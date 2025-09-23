import 'package:mindhearth/core/domain/entities/app_error.dart';
import 'package:mindhearth/core/domain/entities/result.dart';
import 'package:mindhearth/core/services/logger.dart';

/// Advanced error recovery patterns for the MindHearth app
/// 
/// This class implements various error recovery strategies including:
/// - Retry mechanisms with exponential backoff
/// - Circuit breaker pattern
/// - Fallback strategies
/// - Error classification and handling
class ErrorRecovery {
  static final _logger = AppLogger('ErrorRecovery');

  /// Retry configuration
  static const int maxRetries = 3;
  static const Duration baseDelay = Duration(milliseconds: 500);
  static const Duration maxDelay = Duration(seconds: 10);

  /// Circuit breaker configuration
  static const int failureThreshold = 5;
  static const Duration timeoutDuration = Duration(minutes: 1);

  /// Retry mechanism with exponential backoff
  static Future<Result<T>> retryWithBackoff<T>(
    Future<Result<T>> Function() operation, {
    int maxAttempts = maxRetries,
    Duration initialDelay = baseDelay,
    Duration maxDelayDuration = maxDelay,
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (attempt < maxAttempts) {
      try {
        final result = await operation();
        
        if (result.isSuccess) {
          _logger.info('Operation succeeded on attempt ${attempt + 1}');
          return result;
        }

        // If it's a non-retryable error, don't retry
        if (!_isRetryableError(result.error)) {
          _logger.warning('Non-retryable error encountered: ${result.error?.message}');
          return result;
        }

        attempt++;
        if (attempt < maxAttempts) {
          _logger.warning('Operation failed on attempt $attempt, retrying in ${delay.inMilliseconds}ms');
          await Future.delayed(delay);
          delay = Duration(
            milliseconds: (delay.inMilliseconds * 2).clamp(
              initialDelay.inMilliseconds,
              maxDelayDuration.inMilliseconds,
            ),
          );
        }
      } catch (e, stackTrace) {
        _logger.error('Unexpected error during retry attempt $attempt', null, stackTrace);
        attempt++;
        
        if (attempt < maxAttempts) {
          await Future.delayed(delay);
          delay = Duration(
            milliseconds: (delay.inMilliseconds * 2).clamp(
              initialDelay.inMilliseconds,
              maxDelayDuration.inMilliseconds,
            ),
          );
        }
      }
    }

    _logger.error('Operation failed after $maxAttempts attempts');
    return Result.failure(
      AppErrorFactory.network(message: 'Operation failed after $maxAttempts attempts'),
    );
  }

  /// Circuit breaker pattern implementation
  static Future<Result<T>> circuitBreaker<T>(
    Future<Result<T>> Function() operation,
    String operationName,
  ) async {
    // In a real implementation, you would maintain circuit breaker state
    // For now, we'll implement a simple version
    try {
      final result = await operation();
      
      if (result.isSuccess) {
        _logger.info('Circuit breaker: $operationName succeeded');
        return result;
      } else {
        _logger.warning('Circuit breaker: $operationName failed - ${result.error?.message}');
        return result;
      }
    } catch (e, stackTrace) {
      _logger.error('Circuit breaker: $operationName threw exception', null, stackTrace);
      return Result.failure(
        AppErrorFactory.network(message: 'Circuit breaker: $operationName failed with exception'),
      );
    }
  }

  /// Fallback strategy for critical operations
  static Future<Result<T>> withFallback<T>(
    Future<Result<T>> Function() primaryOperation,
    Future<Result<T>> Function() fallbackOperation,
    String operationName,
  ) async {
    try {
      _logger.info('Attempting primary operation: $operationName');
      final result = await primaryOperation();
      
      if (result.isSuccess) {
        _logger.info('Primary operation succeeded: $operationName');
        return result;
      }
    } catch (e, stackTrace) {
      _logger.warning('Primary operation failed: $operationName', null, stackTrace);
    }

    try {
      _logger.info('Attempting fallback operation: $operationName');
      final result = await fallbackOperation();
      
      if (result.isSuccess) {
        _logger.info('Fallback operation succeeded: $operationName');
        return result;
      } else {
        _logger.error('Fallback operation failed: $operationName - ${result.error?.message}');
        return result;
      }
    } catch (e, stackTrace) {
      _logger.error('Fallback operation threw exception: $operationName', null, stackTrace);
      return Result.failure(
        AppErrorFactory.network(message: 'Both primary and fallback operations failed for $operationName'),
      );
    }
  }

  /// Error classification and appropriate handling
  static ErrorHandlingStrategy classifyError(AppError error) {
    switch (error.type) {
      case AppErrorType.network:
        return ErrorHandlingStrategy.retry;
      case AppErrorType.authentication:
        return ErrorHandlingStrategy.redirectToLogin;
      case AppErrorType.authorization:
        return ErrorHandlingStrategy.showError;
      case AppErrorType.validation:
        return ErrorHandlingStrategy.showError;
      case AppErrorType.server:
        return ErrorHandlingStrategy.retry;
      case AppErrorType.encryption:
        return ErrorHandlingStrategy.showError;
      case AppErrorType.unknown:
        return ErrorHandlingStrategy.showError;
    }
  }

  /// Check if an error is retryable
  static bool _isRetryableError(AppError? error) {
    if (error == null) return false;
    
    switch (error.type) {
      case AppErrorType.network:
      case AppErrorType.server:
        return true;
      case AppErrorType.authentication:
      case AppErrorType.authorization:
      case AppErrorType.validation:
      case AppErrorType.encryption:
      case AppErrorType.unknown:
        return false;
    }
  }

  /// Get user-friendly error message
  static String getUserFriendlyMessage(AppError error) {
    switch (error.type) {
      case AppErrorType.network:
        return 'Please check your internet connection and try again.';
      case AppErrorType.authentication:
        return 'Please log in again to continue.';
      case AppErrorType.authorization:
        return 'You don\'t have permission to perform this action.';
      case AppErrorType.validation:
        return 'Please check your input and try again.';
      case AppErrorType.server:
        return 'Our servers are experiencing issues. Please try again later.';
      case AppErrorType.encryption:
        return 'There was a security issue. Please try again.';
      case AppErrorType.unknown:
        return 'Something went wrong. Please try again.';
    }
  }

  /// Log error with context
  static void logError(AppError error, String context, {StackTrace? stackTrace}) {
    _logger.error('Error in $context: ${error.message}', null, stackTrace);
  }
}

/// Error handling strategies
enum ErrorHandlingStrategy {
  retry,
  redirectToLogin,
  showError,
  fallback,
}

/// Error recovery configuration
class ErrorRecoveryConfig {
  final int maxRetries;
  final Duration baseDelay;
  final Duration maxDelay;
  final int failureThreshold;
  final Duration timeoutDuration;

  const ErrorRecoveryConfig({
    this.maxRetries = 3,
    this.baseDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 10),
    this.failureThreshold = 5,
    this.timeoutDuration = const Duration(minutes: 1),
  });
}
