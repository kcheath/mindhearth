import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/domain/usecases/chat_usecases.dart';
import 'package:mindhearth/core/domain/usecases/journal_usecases.dart';
import 'package:mindhearth/core/domain/usecases/billing_usecases.dart';
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
    chatRepository: ref.watch(chatRepositoryProvider),
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
