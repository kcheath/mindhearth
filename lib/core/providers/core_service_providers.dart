import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/services/api_service.dart';
import 'package:mindhearth/core/services/chat_service.dart';
import 'package:mindhearth/core/services/billing_service.dart';
import 'package:mindhearth/core/services/journal_service.dart';
import 'package:mindhearth/core/di/service_locator.dart';

/// Core service providers for dependency injection
/// These providers create services directly with constructor injection

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final encryptionServiceProvider = Provider<EncryptionServiceWrapper>((ref) {
  return EncryptionServiceWrapper();
});

final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService(ref.watch(apiServiceProvider));
});

final billingServiceProvider = Provider<BillingService>((ref) {
  return BillingService(ref.watch(apiServiceProvider));
});

final journalServiceProvider = Provider<JournalService>((ref) {
  return JournalService(ref.watch(apiServiceProvider));
});
