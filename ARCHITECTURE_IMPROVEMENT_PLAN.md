# MindHearth Architecture Improvement Plan

## Overview
This document outlines a phased approach to address the architect's recommendations for improving the MindHearth codebase architecture, following Clean Architecture principles and Flutter design patterns.

## Current State Analysis

### ✅ **Strengths**
- Clean Architecture foundation with proper layer separation
- Riverpod state management with proper providers
- Result type pattern for error handling
- Comprehensive validation system
- Good logging and debugging infrastructure

### ⚠️ **Issues to Address**
1. **Mixed Dependency Injection**: Both GetIt and Riverpod for same services
2. **Inconsistent Use Cases**: Auth/Onboarding have use cases, Chat/Journal don't
3. **Layer Coupling**: Some services import UI widgets
4. **Redundant Services**: ChatService and ChatRepository overlap
5. **Incomplete Features**: Documents and Reports need implementation
6. **Missing Tests**: No unit tests for business logic

---

## Phase 1: Foundation Cleanup (Weeks 1-2)
**Priority: HIGH** | **Effort: Medium** | **Risk: Low**

### 1.1 Remove Layer Coupling
- **Target**: Remove UI imports from services
- **Files**: `ChatService`, `ApiService`, etc.
- **Action**: Move UI-specific logic to presentation layer
- **Validation**: Ensure services only depend on lower layers

### 1.2 Standardize Dependency Injection
- **Target**: Choose Riverpod as primary DI solution
- **Action**: 
  - Keep GetIt for core services (API, Encryption)
  - Use Riverpod providers to access GetIt services
  - Remove direct GetIt usage from UI layer
- **Files**: All provider files, service locator

### 1.3 Create Missing Use Cases
- **Target**: Chat and Journal features
- **Create**:
  - `SendMessageUseCase`
  - `GetSessionsUseCase`
  - `CreateJournalEntryUseCase`
  - `GetJournalEntriesUseCase`
  - `UpdateJournalEntryUseCase`
  - `DeleteJournalEntryUseCase`

### 1.4 Refactor Chat Architecture
- **Decision**: Keep ChatRepository as primary interface
- **Action**: 
  - Move streaming logic to `StartStreamingChatUseCase`
  - Move session management to use cases
  - Deprecate ChatService or repurpose for orchestration only

---

## Phase 2: Architecture Consistency (Weeks 3-4)
**Priority: HIGH** | **Effort: High** | **Risk: Medium**

### 2.1 Implement Constructor Injection
- **Target**: All StateNotifiers
- **Action**: 
  - Refactor `AuthNotifier` to accept `LoginUseCase` in constructor
  - Refactor `ChatNotifier` to accept use cases
  - Refactor `JournalNotifier` to accept use cases
- **Benefit**: Better testability and loose coupling

### 2.2 Create Domain Use Cases for All Features
- **Chat Use Cases**:
  - `SendMessageUseCase`
  - `GetSessionsUseCase`
  - `CreateSessionUseCase`
  - `DeleteSessionUseCase`
  - `StartStreamingChatUseCase`
  - `StopStreamingChatUseCase`

- **Journal Use Cases**:
  - `CreateJournalEntryUseCase`
  - `GetJournalEntriesUseCase`
  - `UpdateJournalEntryUseCase`
  - `DeleteJournalEntryUseCase`
  - `GetJournalEntryUseCase`

- **Billing Use Cases**:
  - `GetBillingStatusUseCase`
  - `PurchaseCreditsUseCase`
  - `GetUsageAnalyticsUseCase`

### 2.3 Remove Direct Service Calls from UI
- **Target**: All presentation layers
- **Action**: Replace direct service calls with use case calls
- **Files**: All page and widget files

### 2.4 Implement Repository Pattern Consistently
- **Action**: Ensure all features use repository pattern
- **Validation**: No direct API calls from UI layer

---

## Phase 3: Testing Infrastructure (Weeks 5-6)
**Priority: MEDIUM** | **Effort: High** | **Risk: Low**

### 3.1 Create Test Infrastructure
- **Setup**: ProviderContainer for testing
- **Create**: Mock repositories and services
- **Action**: Set up test utilities and helpers

### 3.2 Write Unit Tests
- **Target**: All use cases
- **Target**: All StateNotifiers
- **Target**: Critical business logic
- **Coverage**: Aim for 80%+ coverage

### 3.3 Integration Tests
- **Target**: End-to-end user flows
- **Focus**: Authentication, Chat, Journal workflows

---

## Phase 4: Complete Incomplete Features (Weeks 7-8)
**Priority: MEDIUM** | **Effort: Medium** | **Risk: Low**

### 4.1 Implement Documents Feature
- **Create**: `DocumentNotifier`
- **Create**: Document use cases
- **Integrate**: `DocumentCostService`
- **UI**: Document upload and management interface

### 4.2 Implement Reports Feature
- **Create**: `ReportsNotifier`
- **Create**: Reports use cases
- **Integrate**: Analytics endpoints
- **UI**: Reports and analytics dashboard

### 4.3 Implement Safety Code Features
- **Action**: Complete safety code behaviors
- **Features**: Safe mode, data wipe functionality
- **Integration**: Coordinate with EncryptionService

---

## Phase 5: Performance & Polish (Weeks 9-10)
**Priority: LOW** | **Effort: Medium** | **Risk: Low**

### 5.1 Performance Optimization
- **Action**: Optimize state management
- **Action**: Implement proper caching
- **Action**: Optimize API calls

### 5.2 Code Quality Improvements
- **Action**: Remove unused code
- **Action**: Improve documentation
- **Action**: Add more comprehensive logging

### 5.3 Final Architecture Review
- **Action**: Ensure all patterns are consistent
- **Action**: Validate Clean Architecture compliance
- **Action**: Performance testing

---

## Implementation Guidelines

### Use Case Pattern
```dart
class SendMessageUseCase {
  final ChatRepository _repository;
  final BillingRepository _billingRepository;
  
  SendMessageUseCase({
    required ChatRepository repository,
    required BillingRepository billingRepository,
  }) : _repository = repository,
       _billingRepository = billingRepository;
  
  Future<Result<ChatMessage>> call(String content, String sessionId) async {
    // Business logic here
    return await _repository.sendMessage(content, sessionId);
  }
}
```

### Provider Pattern
```dart
final sendMessageUseCaseProvider = Provider<SendMessageUseCase>((ref) {
  return SendMessageUseCase(
    repository: ref.watch(chatRepositoryProvider),
    billingRepository: ref.watch(billingRepositoryProvider),
  );
});
```

### StateNotifier Pattern
```dart
class ChatNotifier extends StateNotifier<ChatState> {
  final SendMessageUseCase _sendMessageUseCase;
  final GetSessionsUseCase _getSessionsUseCase;
  
  ChatNotifier({
    required SendMessageUseCase sendMessageUseCase,
    required GetSessionsUseCase getSessionsUseCase,
  }) : _sendMessageUseCase = sendMessageUseCase,
       _getSessionsUseCase = getSessionsUseCase,
       super(const ChatState());
  
  Future<void> sendMessage(String content) async {
    final result = await _sendMessageUseCase(content, state.currentSessionId);
    // Handle result
  }
}
```

---

## Success Metrics

### Phase 1 Success
- [ ] No UI imports in services
- [ ] Consistent dependency injection
- [ ] All features have use cases
- [ ] Chat architecture simplified

### Phase 2 Success
- [ ] All StateNotifiers use constructor injection
- [ ] No direct service calls from UI
- [ ] Consistent repository pattern usage
- [ ] All business logic in use cases

### Phase 3 Success
- [ ] 80%+ test coverage
- [ ] All use cases tested
- [ ] All StateNotifiers tested
- [ ] Integration tests passing

### Phase 4 Success
- [ ] Documents feature complete
- [ ] Reports feature complete
- [ ] Safety code features working
- [ ] All features follow established patterns

### Phase 5 Success
- [ ] Performance optimized
- [ ] Code quality improved
- [ ] Architecture fully compliant
- [ ] Documentation complete

---

## Risk Mitigation

### High Risk Items
- **Constructor Injection Refactoring**: May break existing functionality
- **Mitigation**: Implement gradually, test thoroughly

### Medium Risk Items
- **Use Case Implementation**: May duplicate existing logic
- **Mitigation**: Careful analysis of existing code before implementation

### Low Risk Items
- **Testing**: Well-established patterns
- **Documentation**: Non-breaking changes

---

## Timeline Summary

| Phase | Duration | Priority | Key Deliverables |
|-------|----------|----------|------------------|
| 1 | 2 weeks | HIGH | Foundation cleanup, use cases |
| 2 | 2 weeks | HIGH | Architecture consistency |
| 3 | 2 weeks | MEDIUM | Testing infrastructure |
| 4 | 2 weeks | MEDIUM | Complete features |
| 5 | 2 weeks | LOW | Performance & polish |

**Total Duration**: 10 weeks
**Team Size**: 2-3 developers
**Effort**: High (significant refactoring required)
