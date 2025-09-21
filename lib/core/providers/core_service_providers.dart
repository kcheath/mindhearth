import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/di/service_locator.dart';
import 'package:mindhearth/core/services/api_service.dart';
import 'package:mindhearth/core/services/encryption_service.dart';
import 'package:mindhearth/core/services/chat_service.dart';
import 'package:mindhearth/core/services/billing_service.dart';
import 'package:mindhearth/core/services/journal_service.dart';

/// Core service providers for dependency injection
/// These providers access services from GetIt service locator

final apiServiceProvider = Provider<ApiService>((ref) {
  return serviceLocator<ApiService>();
});

final encryptionServiceProvider = Provider<EncryptionServiceWrapper>((ref) {
  return serviceLocator<EncryptionServiceWrapper>();
});

final chatServiceProvider = Provider<ChatService>((ref) {
  return serviceLocator<ChatService>();
});

final billingServiceProvider = Provider<BillingService>((ref) {
  return serviceLocator<BillingService>();
});

final journalServiceProvider = Provider<JournalService>((ref) {
  return serviceLocator<JournalService>();
});
