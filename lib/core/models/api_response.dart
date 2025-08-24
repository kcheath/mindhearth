abstract class ApiResponse<T> {
  const ApiResponse();
  
  R when<R>({
    required R Function(T data, String? message) success,
    required R Function(String message, int? statusCode, Map<String, dynamic>? errors) error,
  });
}

class ApiSuccess<T> extends ApiResponse<T> {
  final T data;
  final String? message;

  const ApiSuccess({
    required this.data,
    this.message,
  });

  @override
  R when<R>({
    required R Function(T data, String? message) success,
    required R Function(String message, int? statusCode, Map<String, dynamic>? errors) error,
  }) {
    return success(data, message);
  }
}

class ApiError<T> extends ApiResponse<T> {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const ApiError({
    required this.message,
    this.statusCode,
    this.errors,
  });

  @override
  R when<R>({
    required R Function(T data, String? message) success,
    required R Function(String message, int? statusCode, Map<String, dynamic>? errors) error,
  }) {
    return error(message, statusCode, errors);
  }
}
