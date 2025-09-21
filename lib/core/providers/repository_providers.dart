import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/domain/repositories/auth_repository.dart';
import 'package:mindhearth/core/domain/repositories/chat_repository.dart';
import 'package:mindhearth/core/domain/repositories/journal_repository.dart';
import 'package:mindhearth/core/domain/repositories/billing_repository.dart';
import 'package:mindhearth/core/domain/repositories/onboarding_repository.dart';
import 'package:mindhearth/core/data/repositories/auth_repository_impl.dart';
import 'package:mindhearth/core/data/repositories/chat_repository_impl.dart';
import 'package:mindhearth/core/data/repositories/journal_repository_impl.dart';
import 'package:mindhearth/core/data/repositories/billing_repository_impl.dart';
import 'package:mindhearth/core/data/repositories/onboarding_repository_impl.dart';
import 'package:mindhearth/core/providers/core_service_providers.dart';

/// Repository providers for dependency injection
/// These providers create repository implementations with injected dependencies

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(apiServiceProvider));
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(ref.watch(apiServiceProvider));
});

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepositoryImpl(ref.watch(apiServiceProvider));
});

final billingRepositoryProvider = Provider<BillingRepository>((ref) {
  return BillingRepositoryImpl(ref.watch(apiServiceProvider));
});

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepositoryImpl(ref.watch(apiServiceProvider));
});
