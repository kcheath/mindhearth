import 'package:mindhearth/core/domain/entities/app_error.dart';

/// A functional Result type that can be either Success or Failure
sealed class Result<T> {
  const Result();
  
  /// Create a success result
  const factory Result.success(T data) = Success<T>;
  
  /// Create a failure result
  const factory Result.failure(AppError error) = Failure<T>;
  
  /// Check if this is a success result
  bool get isSuccess => this is Success<T>;
  
  /// Check if this is a failure result
  bool get isFailure => this is Failure<T>;
  
  /// Get the data if this is a success result, null otherwise
  T? get data => when(
    success: (data) => data,
    failure: (_) => null,
  );
  
  /// Get the error if this is a failure result, null otherwise
  AppError? get error => when(
    success: (_) => null,
    failure: (error) => error,
  );
  
  /// Pattern matching for Result
  R when<R>({
    required R Function(T data) success,
    required R Function(AppError error) failure,
  }) {
    return switch (this) {
      Success<T> s => success(s.data),
      Failure<T> f => failure(f.error),
    };
  }
  
  /// Transform the success value
  Result<R> map<R>(R Function(T data) transform) {
    return when(
      success: (data) => Result.success(transform(data)),
      failure: (error) => Result.failure(error),
    );
  }
  
  /// Transform the success value and flatten the result
  Result<R> flatMap<R>(Result<R> Function(T data) transform) {
    return when(
      success: (data) => transform(data),
      failure: (error) => Result.failure(error),
    );
  }
  
  /// Get the success value or a default value
  T getOrElse(T defaultValue) {
    return when(
      success: (data) => data,
      failure: (_) => defaultValue,
    );
  }
  
  /// Get the success value or throw the error
  T getOrThrow() {
    return when(
      success: (data) => data,
      failure: (error) => throw Exception(error.message),
    );
  }
}

/// Success case of Result
class Success<T> extends Result<T> {
  final T data;
  
  const Success(this.data);
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Success<T> && other.data == data;
  }
  
  @override
  int get hashCode => data.hashCode;
  
  @override
  String toString() => 'Success($data)';
}

/// Failure case of Result
class Failure<T> extends Result<T> {
  final AppError error;
  
  const Failure(this.error);
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure<T> && other.error == error;
  }
  
  @override
  int get hashCode => error.hashCode;
  
  @override
  String toString() => 'Failure($error)';
}
