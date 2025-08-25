import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mindhearth/core/domain/entities/app_error.dart';

part 'result.freezed.dart';

@freezed
class Result<T> with _$Result<T> {
  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(AppError error) = Failure<T>;

  const Result._();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get data => when(
    success: (data) => data,
    failure: (_) => null,
  );

  AppError? get error => when(
    success: (_) => null,
    failure: (error) => error,
  );

  Result<R> map<R>(R Function(T) transform) {
    return when(
      success: (data) => Result.success(transform(data)),
      failure: (error) => Result.failure(error),
    );
  }

  Result<R> flatMap<R>(Result<R> Function(T) transform) {
    return when(
      success: (data) => transform(data),
      failure: (error) => Result.failure(error),
    );
  }

  T getOrElse(T Function(AppError) fallback) {
    return when(
      success: (data) => data,
      failure: (error) => fallback(error),
    );
  }

  T getOrThrow() {
    return when(
      success: (data) => data,
      failure: (error) => throw Exception(error.userMessage),
    );
  }

  void whenSuccess(void Function(T) action) {
    when(
      success: action,
      failure: (_) {},
    );
  }

  void whenFailure(void Function(AppError) action) {
    when(
      success: (_) {},
      failure: action,
    );
  }

  void when({
    required void Function(T) success,
    required void Function(AppError) failure,
  }) {
    if (isSuccess) {
      success(data!);
    } else {
      failure(error!);
    }
  }
}
