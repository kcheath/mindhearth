# Phase 1 Implementation Details

## Overview
Phase 1 focuses on foundation cleanup - removing layer coupling, standardizing dependency injection, and creating missing use cases. This is the most critical phase as it sets the foundation for all subsequent improvements.

## 1.1 Remove Layer Coupling

### Current Issues
- `ChatService` imports UI widgets
- Services have UI-specific logic
- Violation of Clean Architecture principles

### Implementation Steps

#### Step 1.1.1: Audit Current Coupling
```bash
# Find all UI imports in services
grep -r "import.*widgets" lib/core/services/
grep -r "import.*presentation" lib/core/services/
grep -r "import.*features" lib/core/services/
```

#### Step 1.1.2: Refactor ChatService
**Current Issues:**
- Direct UI widget imports
- UI-specific error handling
- Mixed concerns

**Refactoring Plan:**
1. Remove UI imports from `ChatService`
2. Move UI-specific logic to presentation layer
3. Keep only business logic in service
4. Use Result type for error handling

**Files to Modify:**
- `lib/core/services/chat_service.dart`
- `lib/features/chat/providers/chat_provider.dart`
- `lib/features/chat/presentation/pages/chat_page.dart`

#### Step 1.1.3: Refactor ApiService
**Current Issues:**
- Mixed concerns (API + UI logic)
- Direct error handling in service

**Refactoring Plan:**
1. Keep only HTTP logic in ApiService
2. Move error handling to use cases
3. Use Result type consistently

## 1.2 Standardize Dependency Injection

### Current State
- GetIt for core services (API, Encryption)
- Riverpod for state management
- Mixed usage causing confusion

### Implementation Steps

#### Step 1.2.1: Create Riverpod Providers for Core Services
```dart
// lib/core/providers/core_service_providers.dart
final apiServiceProvider = Provider<ApiService>((ref) {
  return serviceLocator<ApiService>();
});

final encryptionServiceProvider = Provider<EncryptionServiceWrapper>((ref) {
  return serviceLocator<EncryptionServiceWrapper>();
});

final chatServiceProvider = Provider<ChatService>((ref) {
  return serviceLocator<ChatService>();
});
```

#### Step 1.2.2: Update Repository Providers
```dart
// lib/core/providers/repository_providers.dart
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(apiServiceProvider));
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(ref.watch(apiServiceProvider));
});
```

#### Step 1.2.3: Remove Direct GetIt Usage
- Replace `serviceLocator<Service>()` with `ref.watch(serviceProvider)`
- Update all StateNotifiers to use Riverpod providers
- Remove GetIt imports from UI layer

## 1.3 Create Missing Use Cases

### Chat Use Cases

#### Step 1.3.1: Create Chat Use Cases
```dart
// lib/core/domain/usecases/chat_usecases.dart
class SendMessageUseCase {
  final ChatRepository _repository;
  final BillingRepository _billingRepository;
  
  SendMessageUseCase({
    required ChatRepository repository,
    required BillingRepository billingRepository,
  }) : _repository = repository,
       _billingRepository = billingRepository;
  
  Future<Result<ChatMessage>> call(String content, String sessionId) async {
    // Validate input
    if (content.trim().isEmpty) {
      return Result.failure(AppErrorFactory.validation(
        message: 'Message content cannot be empty',
      ));
    }
    
    // Check billing status
    final billingResult = await _billingRepository.checkBillingStatus();
    if (billingResult.isFailure) {
      return Result.failure(billingResult.error!);
    }
    
    // Send message
    return await _repository.sendMessage(content, sessionId);
  }
}

class GetSessionsUseCase {
  final ChatRepository _repository;
  
  GetSessionsUseCase(this._repository);
  
  Future<Result<List<Session>>> call() async {
    return await _repository.getSessions();
  }
}

class CreateSessionUseCase {
  final ChatRepository _repository;
  
  CreateSessionUseCase(this._repository);
  
  Future<Result<Session>> call(String? name) async {
    return await _repository.createSession(name);
  }
}

class DeleteSessionUseCase {
  final ChatRepository _repository;
  
  DeleteSessionUseCase(this._repository);
  
  Future<Result<void>> call(String sessionId) async {
    return await _repository.deleteSession(sessionId);
  }
}

class StartStreamingChatUseCase {
  final ChatRepository _repository;
  
  StartStreamingChatUseCase(this._repository);
  
  Future<Result<Stream<String>>> call(String content, String sessionId) async {
    return await _repository.startStreamingChat(content, sessionId);
  }
}
```

#### Step 1.3.2: Create Journal Use Cases
```dart
// lib/core/domain/usecases/journal_usecases.dart
class CreateJournalEntryUseCase {
  final JournalRepository _repository;
  
  CreateJournalEntryUseCase(this._repository);
  
  Future<Result<JournalEntry>> call(JournalEntry entry) async {
    // Validate entry
    if (entry.title.trim().isEmpty) {
      return Result.failure(AppErrorFactory.validation(
        message: 'Journal entry title is required',
      ));
    }
    
    return await _repository.createEntry(entry);
  }
}

class GetJournalEntriesUseCase {
  final JournalRepository _repository;
  
  GetJournalEntriesUseCase(this._repository);
  
  Future<Result<List<JournalEntry>>> call({
    int? limit,
    int? offset,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    return await _repository.getEntries(
      limit: limit,
      offset: offset,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}

class UpdateJournalEntryUseCase {
  final JournalRepository _repository;
  
  UpdateJournalEntryUseCase(this._repository);
  
  Future<Result<JournalEntry>> call(String id, JournalEntry entry) async {
    return await _repository.updateEntry(id, entry);
  }
}

class DeleteJournalEntryUseCase {
  final JournalRepository _repository;
  
  DeleteJournalEntryUseCase(this._repository);
  
  Future<Result<void>> call(String id) async {
    return await _repository.deleteEntry(id);
  }
}
```

#### Step 1.3.3: Create Billing Use Cases
```dart
// lib/core/domain/usecases/billing_usecases.dart
class GetBillingStatusUseCase {
  final BillingRepository _repository;
  
  GetBillingStatusUseCase(this._repository);
  
  Future<Result<BillingStatus>> call() async {
    return await _repository.getBillingStatus();
  }
}

class PurchaseCreditsUseCase {
  final BillingRepository _repository;
  
  PurchaseCreditsUseCase(this._repository);
  
  Future<Result<PurchaseResult>> call(int amount, String paymentMethod) async {
    // Validate input
    if (amount <= 0) {
      return Result.failure(AppErrorFactory.validation(
        message: 'Credit amount must be positive',
      ));
    }
    
    return await _repository.purchaseCredits(amount, paymentMethod);
  }
}

class GetUsageAnalyticsUseCase {
  final BillingRepository _repository;
  
  GetUsageAnalyticsUseCase(this._repository);
  
  Future<Result<UsageAnalytics>> call({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    return await _repository.getUsageAnalytics(
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}
```

## 1.4 Refactor Chat Architecture

### Current Issues
- `ChatService` and `ChatRepository` overlap
- Confusing responsibilities
- Duplicate code

### Implementation Plan

#### Step 1.4.1: Define Clear Responsibilities
- **ChatRepository**: Basic CRUD operations, data persistence
- **ChatUseCases**: Business logic, validation, orchestration
- **ChatService**: Deprecate or repurpose for streaming orchestration only

#### Step 1.4.2: Refactor ChatNotifier
```dart
// lib/features/chat/providers/chat_provider.dart
class ChatNotifier extends StateNotifier<ChatState> {
  final SendMessageUseCase _sendMessageUseCase;
  final GetSessionsUseCase _getSessionsUseCase;
  final CreateSessionUseCase _createSessionUseCase;
  final DeleteSessionUseCase _deleteSessionUseCase;
  final StartStreamingChatUseCase _startStreamingChatUseCase;
  
  ChatNotifier({
    required SendMessageUseCase sendMessageUseCase,
    required GetSessionsUseCase getSessionsUseCase,
    required CreateSessionUseCase createSessionUseCase,
    required DeleteSessionUseCase deleteSessionUseCase,
    required StartStreamingChatUseCase startStreamingChatUseCase,
  }) : _sendMessageUseCase = sendMessageUseCase,
       _getSessionsUseCase = getSessionsUseCase,
       _createSessionUseCase = createSessionUseCase,
       _deleteSessionUseCase = deleteSessionUseCase,
       _startStreamingChatUseCase = startStreamingChatUseCase,
       super(const ChatState());
  
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    
    // Add user message immediately
    final userMessage = ChatMessage(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      message: content,
      isUser: true,
      timestamp: DateTime.now(),
      sessionId: state.currentSessionId,
    );
    
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isStreaming: true,
      error: null,
    );
    
    // Use use case to send message
    final result = await _sendMessageUseCase(content, state.currentSessionId);
    
    if (result.isSuccess) {
      // Handle success
      final aiMessage = result.data!;
      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isStreaming: false,
      );
    } else {
      // Handle error
      state = state.copyWith(
        isStreaming: false,
        error: result.error!.message,
      );
    }
  }
  
  Future<void> loadSessions() async {
    final result = await _getSessionsUseCase();
    
    if (result.isSuccess) {
      state = state.copyWith(sessions: result.data!);
    } else {
      state = state.copyWith(error: result.error!.message);
    }
  }
  
  Future<void> createNewSession({String? name}) async {
    final result = await _createSessionUseCase(name);
    
    if (result.isSuccess) {
      final session = result.data!;
      state = state.copyWith(
        currentSessionId: session.id,
        sessions: [...state.sessions, session.toJson()],
      );
    } else {
      state = state.copyWith(error: result.error!.message);
    }
  }
  
  Future<void> deleteSession(String sessionId) async {
    final result = await _deleteSessionUseCase(sessionId);
    
    if (result.isSuccess) {
      final updatedSessions = state.sessions
          .where((session) => session['id'] != sessionId)
          .toList();
      
      state = state.copyWith(
        sessions: updatedSessions,
        currentSessionId: state.currentSessionId == sessionId 
            ? null 
            : state.currentSessionId,
      );
    } else {
      state = state.copyWith(error: result.error!.message);
    }
  }
}
```

#### Step 1.4.3: Create Use Case Providers
```dart
// lib/core/providers/usecase_providers.dart
final sendMessageUseCaseProvider = Provider<SendMessageUseCase>((ref) {
  return SendMessageUseCase(
    repository: ref.watch(chatRepositoryProvider),
    billingRepository: ref.watch(billingRepositoryProvider),
  );
});

final getSessionsUseCaseProvider = Provider<GetSessionsUseCase>((ref) {
  return GetSessionsUseCase(ref.watch(chatRepositoryProvider));
});

final createSessionUseCaseProvider = Provider<CreateSessionUseCase>((ref) {
  return CreateSessionUseCase(ref.watch(chatRepositoryProvider));
});

final deleteSessionUseCaseProvider = Provider<DeleteSessionUseCase>((ref) {
  return DeleteSessionUseCase(ref.watch(chatRepositoryProvider));
});

final startStreamingChatUseCaseProvider = Provider<StartStreamingChatUseCase>((ref) {
  return StartStreamingChatUseCase(ref.watch(chatRepositoryProvider));
});
```

#### Step 1.4.4: Update Chat Provider
```dart
// lib/features/chat/providers/chat_provider.dart
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(
    sendMessageUseCase: ref.watch(sendMessageUseCaseProvider),
    getSessionsUseCase: ref.watch(getSessionsUseCaseProvider),
    createSessionUseCase: ref.watch(createSessionUseCaseProvider),
    deleteSessionUseCase: ref.watch(deleteSessionUseCaseProvider),
    startStreamingChatUseCase: ref.watch(startStreamingChatUseCaseProvider),
  );
});
```

## Implementation Checklist

### Phase 1.1: Remove Layer Coupling
- [ ] Audit all service files for UI imports
- [ ] Remove UI imports from ChatService
- [ ] Remove UI imports from ApiService
- [ ] Move UI-specific logic to presentation layer
- [ ] Update error handling to use Result type

### Phase 1.2: Standardize Dependency Injection
- [ ] Create core service providers
- [ ] Create repository providers
- [ ] Update all StateNotifiers to use providers
- [ ] Remove direct GetIt usage from UI layer
- [ ] Test all providers work correctly

### Phase 1.3: Create Missing Use Cases
- [ ] Create Chat use cases
- [ ] Create Journal use cases
- [ ] Create Billing use cases
- [ ] Create use case providers
- [ ] Test all use cases

### Phase 1.4: Refactor Chat Architecture
- [ ] Define clear responsibilities
- [ ] Refactor ChatNotifier to use use cases
- [ ] Update ChatProvider to use constructor injection
- [ ] Test chat functionality
- [ ] Document new architecture

## Success Criteria

### Phase 1.1 Success
- [ ] No UI imports in any service file
- [ ] All services only depend on lower layers
- [ ] Error handling uses Result type consistently

### Phase 1.2 Success
- [ ] All services accessible via Riverpod providers
- [ ] No direct GetIt usage in UI layer
- [ ] Consistent dependency injection pattern

### Phase 1.3 Success
- [ ] All features have corresponding use cases
- [ ] Use cases contain business logic
- [ ] Use cases are properly tested

### Phase 1.4 Success
- [ ] Chat architecture is clear and consistent
- [ ] ChatNotifier uses constructor injection
- [ ] No duplicate code between services
- [ ] All chat functionality works correctly

## Testing Strategy

### Unit Tests
- Test all use cases with mock repositories
- Test StateNotifiers with mock use cases
- Test error handling scenarios

### Integration Tests
- Test complete user flows
- Test error scenarios
- Test state management

### Manual Testing
- Test all chat functionality
- Test all journal functionality
- Test all billing functionality
- Test error handling and recovery

## Risk Mitigation

### High Risk: Constructor Injection Refactoring
- **Risk**: Breaking existing functionality
- **Mitigation**: Implement gradually, test thoroughly
- **Rollback**: Keep old implementation until new one is verified

### Medium Risk: Use Case Implementation
- **Risk**: Duplicating existing logic
- **Mitigation**: Careful analysis of existing code
- **Rollback**: Keep existing implementation as fallback

### Low Risk: Provider Updates
- **Risk**: Provider dependency issues
- **Mitigation**: Test all providers individually
- **Rollback**: Revert to GetIt if needed

## Timeline

| Task | Duration | Dependencies |
|------|----------|--------------|
| 1.1 Remove Layer Coupling | 3 days | None |
| 1.2 Standardize DI | 4 days | 1.1 |
| 1.3 Create Use Cases | 5 days | 1.2 |
| 1.4 Refactor Chat | 3 days | 1.3 |
| Testing & Validation | 2 days | All |
| **Total** | **17 days** | |

## Next Steps

After Phase 1 completion:
1. Review and validate all changes
2. Update documentation
3. Begin Phase 2: Architecture Consistency
4. Plan Phase 3: Testing Infrastructure
