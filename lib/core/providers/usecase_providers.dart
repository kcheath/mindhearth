import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/domain/usecases/chat_usecases.dart';
import 'package:mindhearth/core/domain/usecases/journal_usecases.dart';
import 'package:mindhearth/core/domain/usecases/billing_usecases.dart';
import 'package:mindhearth/core/domain/usecases/safety_usecases.dart';
import 'package:mindhearth/core/domain/usecases/debug_billing_usecases.dart';
import 'package:mindhearth/core/domain/usecases/balance_stream_usecases.dart';
import 'package:mindhearth/core/domain/usecases/session_question_usecases.dart';
import 'package:mindhearth/core/domain/usecases/usage_analytics_usecases.dart';
import 'package:mindhearth/core/providers/repository_providers.dart';

/// Use case providers for dependency injection
/// These providers create use cases with injected repository dependencies

// Chat Use Cases
final sendMessageUseCaseProvider = Provider<SendMessageUseCase>((ref) {
  return SendMessageUseCase(
    chatRepository: ref.watch(chatRepositoryProvider),
    billingRepository: ref.watch(billingRepositoryProvider),
  );
});

final getSessionsUseCaseProvider = Provider<GetSessionsUseCase>((ref) {
  return GetSessionsUseCase(ref.watch(chatRepositoryProvider));
});

final createSessionUseCaseProvider = Provider<CreateSessionUseCase>((ref) {
  return CreateSessionUseCase(ref.watch(chatRepositoryProvider));
});

final updateSessionUseCaseProvider = Provider<UpdateSessionUseCase>((ref) {
  return UpdateSessionUseCase(ref.watch(chatRepositoryProvider));
});

final deleteSessionUseCaseProvider = Provider<DeleteSessionUseCase>((ref) {
  return DeleteSessionUseCase(ref.watch(chatRepositoryProvider));
});

final getSessionMessagesUseCaseProvider = Provider<GetSessionMessagesUseCase>((ref) {
  return GetSessionMessagesUseCase(ref.watch(chatRepositoryProvider));
});

final startStreamingChatUseCaseProvider = Provider<StartStreamingChatUseCase>((ref) {
  return StartStreamingChatUseCase(
    chatRepository: ref.watch(chatRepositoryProvider),
    billingRepository: ref.watch(billingRepositoryProvider),
  );
});

// Journal Use Cases
final createJournalEntryUseCaseProvider = Provider<CreateJournalEntryUseCase>((ref) {
  return CreateJournalEntryUseCase(ref.watch(journalRepositoryProvider));
});

final getJournalEntriesUseCaseProvider = Provider<GetJournalEntriesUseCase>((ref) {
  return GetJournalEntriesUseCase(ref.watch(journalRepositoryProvider));
});

final getJournalEntryUseCaseProvider = Provider<GetJournalEntryUseCase>((ref) {
  return GetJournalEntryUseCase(ref.watch(journalRepositoryProvider));
});

final updateJournalEntryUseCaseProvider = Provider<UpdateJournalEntryUseCase>((ref) {
  return UpdateJournalEntryUseCase(ref.watch(journalRepositoryProvider));
});

final deleteJournalEntryUseCaseProvider = Provider<DeleteJournalEntryUseCase>((ref) {
  return DeleteJournalEntryUseCase(ref.watch(journalRepositoryProvider));
});

final createAIJournalSummaryUseCaseProvider = Provider<CreateAIJournalSummaryUseCase>((ref) {
  return CreateAIJournalSummaryUseCase(
    journalRepository: ref.watch(journalRepositoryProvider),
  );
});

// Billing Use Cases
final getBillingStatusUseCaseProvider = Provider<GetBillingStatusUseCase>((ref) {
  return GetBillingStatusUseCase(ref.watch(billingRepositoryProvider));
});

final purchaseCreditsUseCaseProvider = Provider<PurchaseCreditsUseCase>((ref) {
  return PurchaseCreditsUseCase(ref.watch(billingRepositoryProvider));
});

final getCreditPackagesUseCaseProvider = Provider<GetCreditPackagesUseCase>((ref) {
  return GetCreditPackagesUseCase(ref.watch(billingRepositoryProvider));
});

final getPurchaseHistoryUseCaseProvider = Provider<GetPurchaseHistoryUseCase>((ref) {
  return GetPurchaseHistoryUseCase(ref.watch(billingRepositoryProvider));
});

final getLedgerEntriesUseCaseProvider = Provider<GetLedgerEntriesUseCase>((ref) {
  return GetLedgerEntriesUseCase(ref.watch(billingRepositoryProvider));
});

final checkBillingStatusUseCaseProvider = Provider<CheckBillingStatusUseCase>((ref) {
  return CheckBillingStatusUseCase(ref.watch(billingRepositoryProvider));
});

final getUsageAnalyticsUseCaseProvider = Provider<GetUsageAnalyticsUseCase>((ref) {
  return GetUsageAnalyticsUseCase(ref.watch(billingRepositoryProvider));
});

// Safety Use Cases
final getSafetyCodesUseCaseProvider = Provider<GetSafetyCodesUseCase>((ref) {
  return GetSafetyCodesUseCase(ref.watch(onboardingRepositoryProvider));
});

final verifySafetyCodeUseCaseProvider = Provider<VerifySafetyCodeUseCase>((ref) {
  return VerifySafetyCodeUseCase(ref.watch(onboardingRepositoryProvider));
});

// Debug Billing Use Cases
final seedCreditsUseCaseProvider = Provider<SeedCreditsUseCase>((ref) {
  return SeedCreditsUseCase(ref.watch(billingRepositoryProvider));
});

final topUpCreditsUseCaseProvider = Provider<TopUpCreditsUseCase>((ref) {
  return TopUpCreditsUseCase(ref.watch(billingRepositoryProvider));
});

final simulatePurchaseUseCaseProvider = Provider<SimulatePurchaseUseCase>((ref) {
  return SimulatePurchaseUseCase(ref.watch(billingRepositoryProvider));
});

final resetBillingDataUseCaseProvider = Provider<ResetBillingDataUseCase>((ref) {
  return ResetBillingDataUseCase(ref.watch(billingRepositoryProvider));
});

final getBillingHealthUseCaseProvider = Provider<GetBillingHealthUseCase>((ref) {
  return GetBillingHealthUseCase(ref.watch(billingRepositoryProvider));
});

final getBillingModeUseCaseProvider = Provider<GetBillingModeUseCase>((ref) {
  return GetBillingModeUseCase(ref.watch(billingRepositoryProvider));
});

final checkOperationUseCaseProvider = Provider<CheckOperationUseCase>((ref) {
  return CheckOperationUseCase(ref.watch(billingRepositoryProvider));
});

// Balance Stream Use Cases
final getCurrentBalanceUseCaseProvider = Provider<GetCurrentBalanceUseCase>((ref) {
  return GetCurrentBalanceUseCase(ref.watch(billingRepositoryProvider));
});

final sendHeartbeatUseCaseProvider = Provider<SendHeartbeatUseCase>((ref) {
  return SendHeartbeatUseCase(ref.watch(billingRepositoryProvider));
});

// Session Question Use Cases
final addSessionQuestionsUseCaseProvider = Provider<AddSessionQuestionsUseCase>((ref) {
  return AddSessionQuestionsUseCase(ref.watch(billingRepositoryProvider));
});

final getSessionQuestionCountUseCaseProvider = Provider<GetSessionQuestionCountUseCase>((ref) {
  return GetSessionQuestionCountUseCase(ref.watch(billingRepositoryProvider));
});

final getSessionQuestionStatusUseCaseProvider = Provider<GetSessionQuestionStatusUseCase>((ref) {
  return GetSessionQuestionStatusUseCase(ref.watch(billingRepositoryProvider));
});
