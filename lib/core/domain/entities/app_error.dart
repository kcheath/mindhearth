/// Sealed class for application errors
sealed class AppError {
  final String message;
  
  const AppError(this.message);
  
  String get type => runtimeType.toString();
}

/// Network-related errors
class NetworkError extends AppError {
  const NetworkError(super.message);
}

/// Validation errors
class ValidationError extends AppError {
  const ValidationError(super.message);
}

/// Authentication errors
class AuthenticationError extends AppError {
  const AuthenticationError(super.message);
}

/// Authorization errors
class AuthorizationError extends AppError {
  const AuthorizationError(super.message);
}

/// Storage errors
class StorageError extends AppError {
  const StorageError(super.message);
}

/// Encryption errors
class EncryptionError extends AppError {
  const EncryptionError(super.message);
}

/// Unknown errors
class UnknownError extends AppError {
  const UnknownError(super.message);
}

/// Factory constructors for creating specific error types
extension AppErrorFactory on AppError {
  static AppError network({required String message}) => NetworkError(message);
  static AppError validation({required String message}) => ValidationError(message);
  static AppError authentication({required String message}) => AuthenticationError(message);
  static AppError authorization({required String message}) => AuthorizationError(message);
  static AppError storage({required String message}) => StorageError(message);
  static AppError encryption({required String message}) => EncryptionError(message);
  static AppError unknown({required String message}) => UnknownError(message);
}

/// Pattern matching extension for AppError
extension AppErrorPatternMatching on AppError {
  T when<T>({
    required T Function(NetworkError) network,
    required T Function(ValidationError) validation,
    required T Function(AuthenticationError) authentication,
    required T Function(AuthorizationError) authorization,
    required T Function(StorageError) storage,
    required T Function(EncryptionError) encryption,
    required T Function(UnknownError) unknown,
  }) {
    return switch (this) {
      NetworkError e => network(e),
      ValidationError e => validation(e),
      AuthenticationError e => authentication(e),
      AuthorizationError e => authorization(e),
      StorageError e => storage(e),
      EncryptionError e => encryption(e),
      UnknownError e => unknown(e),
    };
  }
}
