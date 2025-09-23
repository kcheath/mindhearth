import 'package:mockito/mockito.dart';
import 'package:mindhearth/core/domain/entities/result.dart';
import 'package:mindhearth/core/domain/entities/app_error.dart';
import 'package:mindhearth/core/domain/repositories/auth_repository.dart';
import 'package:mindhearth/core/domain/repositories/chat_repository.dart';
import 'package:mindhearth/core/domain/repositories/journal_repository.dart';
import 'package:mindhearth/core/domain/repositories/billing_repository.dart';
import 'package:mindhearth/core/domain/repositories/onboarding_repository.dart';
import 'package:mindhearth/features/chat/domain/entities/chat_message.dart';
import 'package:mindhearth/features/chat/domain/entities/session.dart';
import 'package:mindhearth/features/journal/domain/entities/journal_entry.dart';
import 'package:mindhearth/features/billing/domain/entities/billing_status.dart';
import 'package:mindhearth/features/billing/domain/entities/credit_package.dart';
import 'package:mindhearth/features/billing/domain/entities/purchase.dart';
import 'package:mindhearth/features/billing/domain/entities/ledger_entry.dart';

/// Mock AuthRepository for testing
class MockAuthRepository extends Mock implements AuthRepository {
  @override
  Future<Result<Map<String, dynamic>>> login({
    required String email,
    required String password,
    required String tenantId,
    required String applicationId,
  }) async {
    return Result.success({
      'access_token': 'mock-access-token',
      'user': {
        'id': 'mock-user-id',
        'email': email,
        'name': 'Mock User',
        'tenant_id': tenantId,
      },
    });
  }

  @override
  Future<Result<Map<String, dynamic>>> getCurrentUser() async {
    return Result.success({
      'id': 'mock-user-id',
      'email': 'test@example.com',
      'name': 'Mock User',
      'tenant_id': 'mock-tenant-id',
      'onboarded': true,
    });
  }

  @override
  Future<Result<void>> logout() async {
    return Result.success(null);
  }

  @override
  Future<Result<bool>> isAuthenticated() async {
    return Result.success(true);
  }
}

/// Mock ChatRepository for testing
class MockChatRepository extends Mock implements ChatRepository {
  @override
  Future<Result<List<Session>>> getSessions() async {
    return Result.success([
      Session(
        id: 'mock-session-1',
        name: 'Mock Session 1',
        sessionType: 'chat',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ]);
  }

  @override
  Future<Result<Session>> createSession({String? name}) async {
    return Result.success(Session(
      id: 'mock-session-2',
      name: name ?? 'New Session',
      sessionType: 'chat',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  }

  @override
  Future<Result<Session>> updateSession({
    required String sessionId,
    String? name,
  }) async {
    return Result.success(Session(
      id: sessionId,
      name: name ?? 'Updated Session',
      sessionType: 'chat',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  }

  @override
  Future<Result<void>> deleteSession(String sessionId) async {
    return Result.success(null);
  }

  @override
  Future<Result<List<ChatMessage>>> getSessionMessages(String sessionId) async {
    return Result.success([
      ChatMessage(
        id: 'mock-message-1',
        content: 'Mock message content',
        role: 'user',
        createdAt: DateTime.now(),
      ),
    ]);
  }

  @override
  Future<Result<ChatMessage>> sendMessage({
    required String sessionId,
    required String content,
  }) async {
    return Result.success(ChatMessage(
      id: 'mock-message-2',
      content: content,
      role: 'assistant',
      createdAt: DateTime.now(),
    ));
  }

  @override
  Stream<ChatMessage> startStreamingChat({
    required String sessionId,
    required String content,
  }) {
    return Stream.value(ChatMessage(
      id: 'mock-stream-message',
      content: 'Mock streaming response',
      role: 'assistant',
      createdAt: DateTime.now(),
    ));
  }
}

/// Mock JournalRepository for testing
class MockJournalRepository extends Mock implements JournalRepository {
  @override
  Future<Result<JournalEntry>> createJournalEntry({
    required String content,
    required String header,
    required String entryType,
    Map<String, dynamic>? metaData,
    bool? consent,
  }) async {
    return Result.success(JournalEntry(
      id: 'mock-journal-1',
      header: header,
      originalContent: content,
      entryType: entryType,
      metaData: metaData,
      consent: consent ?? false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  }

  @override
  Future<Result<List<JournalEntry>>> getJournalEntries({
    int? limit,
    int? offset,
  }) async {
    return Result.success([
      JournalEntry(
        id: 'mock-journal-1',
        header: 'Mock Journal Entry',
        originalContent: 'Mock journal content',
        entryType: 'general',
        metaData: {},
        consent: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ]);
  }

  @override
  Future<Result<JournalEntry>> getJournalEntry(String entryId) async {
    return Result.success(JournalEntry(
      id: entryId,
      header: 'Mock Journal Entry',
      originalContent: 'Mock journal content',
      entryType: 'general',
      metaData: {},
      consent: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  }

  @override
  Future<Result<JournalEntry>> updateJournalEntry({
    required String entryId,
    String? header,
    String? content,
    String? entryType,
    Map<String, dynamic>? metaData,
    bool? consent,
  }) async {
    return Result.success(JournalEntry(
      id: entryId,
      header: header ?? 'Updated Journal Entry',
      originalContent: content ?? 'Updated journal content',
      entryType: entryType ?? 'general',
      metaData: metaData ?? {},
      consent: consent ?? true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  }

  @override
  Future<Result<void>> deleteJournalEntry(String entryId) async {
    return Result.success(null);
  }

  @override
  Future<Result<String>> createAIJournalSummary(String entryId) async {
    return Result.success('Mock AI summary for journal entry');
  }
}

/// Mock BillingRepository for testing
class MockBillingRepository extends Mock implements BillingRepository {
  @override
  Future<Result<BillingStatus>> getBillingStatus() async {
    return Result.success(BillingStatus(
      isHealthy: true,
      currentBalance: 100,
      subscriptionStatus: 'active',
    ));
  }

  @override
  Future<Result<Purchase>> purchaseCredits({
    required String packageId,
    required String paymentMethod,
    Map<String, dynamic>? paymentData,
  }) async {
    return Result.success(Purchase(
      id: 'mock-purchase-1',
      packageId: packageId,
      amount: 10.0,
      currency: 'USD',
      status: 'completed',
      createdAt: DateTime.now(),
    ));
  }

  @override
  Future<Result<List<CreditPackage>>> getCreditPackages() async {
    return Result.success([
      CreditPackage(
        id: 'mock-package-1',
        name: 'Basic Package',
        credits: 100,
        price: 9.99,
        currency: 'USD',
      ),
    ]);
  }

  @override
  Future<Result<List<Purchase>>> getPurchaseHistory({
    int? limit,
    int? offset,
  }) async {
    return Result.success([
      Purchase(
        id: 'mock-purchase-1',
        packageId: 'mock-package-1',
        amount: 9.99,
        currency: 'USD',
        status: 'completed',
        createdAt: DateTime.now(),
      ),
    ]);
  }

  @override
  Future<Result<List<LedgerEntry>>> getLedgerHistory({
    int? limit,
    int? offset,
  }) async {
    return Result.success([
      LedgerEntry(
        id: 'mock-ledger-1',
        type: 'credit',
        amount: 100,
        description: 'Mock credit entry',
        createdAt: DateTime.now(),
      ),
    ]);
  }

  // Debug billing methods
  @override
  Future<Result<Map<String, dynamic>>> seedCredits(int credits) async {
    return Result.success({
      'credits_added': credits,
      'new_balance': 100 + credits,
    });
  }

  @override
  Future<Result<Map<String, dynamic>>> topUpCredits(int credits) async {
    return Result.success({
      'credits_added': credits,
      'new_balance': 100 + credits,
    });
  }

  @override
  Future<Result<Map<String, dynamic>>> simulatePurchase(int credits) async {
    return Result.success({
      'purchase_simulated': true,
      'credits': credits,
    });
  }

  @override
  Future<Result<Map<String, dynamic>>> resetBillingData() async {
    return Result.success({
      'reset': true,
      'message': 'Billing data reset successfully',
    });
  }

  @override
  Future<Result<Map<String, dynamic>>> getBillingHealth() async {
    return Result.success({
      'status': 'healthy',
      'services': ['payment', 'billing', 'credits'],
    });
  }

  @override
  Future<Result<Map<String, dynamic>>> getBillingMode() async {
    return Result.success({
      'mode': 'debug',
      'features': ['simulation', 'testing'],
    });
  }

  @override
  Future<Result<Map<String, dynamic>>> checkOperation(String operationType) async {
    return Result.success({
      'operation': operationType,
      'allowed': true,
      'message': 'Operation allowed',
    });
  }

  @override
  Future<Result<int>> getCurrentBalance() async {
    return Result.success(100);
  }

  @override
  Future<Result<void>> sendHeartbeat() async {
    return Result.success(null);
  }

  @override
  Future<Result<void>> addSessionQuestions({
    required String sessionId,
    required int questions,
  }) async {
    return Result.success(null);
  }

  @override
  Future<Result<int>> getSessionQuestionCount(String sessionId) async {
    return Result.success(5);
  }

  @override
  Future<Result<Map<String, dynamic>>> getSessionQuestionStatus() async {
    return Result.success({
      'total_questions': 10,
      'answered': 5,
      'remaining': 5,
    });
  }

  @override
  Future<Result<Map<String, dynamic>>> getUsageAnalytics(int periodDays) async {
    return Result.success({
      'period_days': periodDays,
      'total_credits_used': 50,
      'average_daily_usage': 5.0,
    });
  }
}

/// Mock OnboardingRepository for testing
class MockOnboardingRepository extends Mock implements OnboardingRepository {
  @override
  Future<Result<void>> savePassphrase(String passphrase) async {
    return Result.success(null);
  }

  @override
  Future<Result<String?>> getPassphrase() async {
    return Result.success('mock-passphrase');
  }

  @override
  Future<Result<void>> saveSafetyCodes(Map<String, String> codes) async {
    return Result.success(null);
  }

  @override
  Future<Result<Map<String, String>?>> getSafetyCodes() async {
    return Result.success({
      'code1': 'safety123',
      'code2': 'safety456',
    });
  }

  @override
  Future<Result<bool>> verifySafetyCode(String code) async {
    return Result.success(code == 'safety123' || code == 'safety456');
  }
}
