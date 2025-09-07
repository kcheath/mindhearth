import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/services/api_service.dart';
import 'package:mindhearth/core/services/redaction_service.dart';

// API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Redaction Service Provider
final redactionServiceProvider = Provider<RedactionService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return RedactionService(apiService);
});
