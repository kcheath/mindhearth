import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_error.freezed.dart';

@freezed
class AppError with _$AppError {
  const factory AppError.network({
    required String message,
    int? statusCode,
    Map<String, dynamic>? details,
  }) = NetworkError;

  const factory AppError.validation({
    required String message,
    Map<String, String>? fieldErrors,
  }) = ValidationError;

  const factory AppError.authentication({
    required String message,
  }) = AuthenticationError;

  const factory AppError.authorization({
    required String message,
  }) = AuthorizationError;

  const factory AppError.storage({
    required String message,
  }) = StorageError;

  const factory AppError.encryption({
    required String message,
  }) = EncryptionError;

  const factory AppError.unknown({
    required String message,
    Object? originalError,
  }) = UnknownError;

  const AppError._();

  String get userMessage {
    return when(
      network: (message, statusCode, details) => 
        'Network error: $message',
      validation: (message, fieldErrors) => 
        'Validation error: $message',
      authentication: (message) => 
        'Authentication error: $message',
      authorization: (message) => 
        'Authorization error: $message',
      storage: (message) => 
        'Storage error: $message',
      encryption: (message) => 
        'Encryption error: $message',
      unknown: (message, originalError) => 
        'An unexpected error occurred: $message',
    );
  }

  bool get isRetryable {
    return when(
      network: (_, __, ___) => true,
      validation: (_, __) => false,
      authentication: (_) => false,
      authorization: (_) => false,
      storage: (_) => true,
      encryption: (_) => false,
      unknown: (_, __) => false,
    );
  }

  bool get shouldShowToUser {
    return when(
      network: (_, __, ___) => true,
      validation: (_, __) => true,
      authentication: (_) => true,
      authorization: (_) => true,
      storage: (_) => true,
      encryption: (_) => false, // Don't expose encryption errors to users
      unknown: (_, __) => false, // Don't expose unknown errors to users
    );
  }
}
