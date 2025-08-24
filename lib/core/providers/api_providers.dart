import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/services/api_service.dart';

// API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});
