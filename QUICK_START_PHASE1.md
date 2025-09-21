# Quick Start Guide - Phase 1 Implementation

## 🚀 Getting Started

This guide provides step-by-step instructions for implementing Phase 1 of the architecture improvements.

## Prerequisites

- Flutter development environment set up
- Understanding of Clean Architecture principles
- Familiarity with Riverpod and GetIt
- Access to the MindHearth codebase

## Step 1: Remove Layer Coupling (Day 1-3)

### 1.1 Audit Current Coupling
```bash
# Run these commands to find coupling issues
cd /Users/kendrickheath/Projects/mindhearth

# Find UI imports in services
grep -r "import.*widgets" lib/core/services/
grep -r "import.*presentation" lib/core/services/
grep -r "import.*features" lib/core/services/

# Find UI-specific logic in services
grep -r "ScaffoldMessenger" lib/core/services/
grep -r "showDialog" lib/core/services/
grep -r "Navigator" lib/core/services/
```

### 1.2 Fix ChatService Coupling
**File**: `lib/core/services/chat_service.dart`

**Issues to Fix**:
- Remove UI imports
- Move UI-specific error handling to presentation layer
- Keep only business logic

**Example Fix**:
```dart
// BEFORE (problematic)
import 'package:flutter/material.dart';

class ChatService {
  Future<void> sendMessage(String content) async {
    try {
      // ... business logic
    } catch (e) {
      // UI-specific error handling - WRONG!
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

// AFTER (correct)
class ChatService {
  Future<Result<ChatMessage>> sendMessage(String content) async {
    try {
      // ... business logic
      return Result.success(chatMessage);
    } catch (e) {
      return Result.failure(AppErrorFactory.network(
        message: 'Failed to send message: $e',
      ));
    }
  }
}
```

### 1.3 Fix ApiService Coupling
**File**: `lib/core/services/api_service.dart`

**Issues to Fix**:
- Remove UI-specific error handling
- Use Result type consistently
- Keep only HTTP logic

## Step 2: Standardize Dependency Injection (Day 4-7)

### 2.1 Create Core Service Providers
**File**: `lib/core/providers/core_service_providers.dart`

```dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/di/service_locator.dart';
import 'package:mindhearth/core/services/api_service.dart';
import 'package:mindhearth/core/services/encryption_service.dart';
import 'package:mindhearth/core/services/chat_service.dart';

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

### 2.2 Create Repository Providers
**File**: `lib/core/providers/repository_providers.dart`

```dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/domain/repositories/auth_repository.dart';
import 'package:mindhearth/core/domain/repositories/chat_repository.dart';
import 'package:mindhearth/core/domain/repositories/journal_repository.dart';
import 'package:mindhearth/core/domain/repositories/billing_repository.dart';
import 'package:mindhearth/core/data/repositories/auth_repository_impl.dart';
import 'package:mindhearth/core/data/repositories/chat_repository_impl.dart';
import 'package:mindhearth/core/data/repositories/journal_repository_impl.dart';
import 'package:mindhearth/core/data/repositories/billing_repository_impl.dart';
import 'package:mindhearth/core/providers/core_service_providers.dart';

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
```

### 2.3 Update StateNotifiers to Use Providers
**File**: `lib/features/chat/providers/chat_provider.dart`

```dart
// BEFORE (using GetIt directly)
class ChatNotifier extends StateNotifier<ChatState> {
  final ChatService _chatService;
  final Ref _ref;
  
  ChatNotifier(this._chatService, this._ref) : super(const ChatState());
  
  Future<void> sendMessage(String content) async {
    // Direct service call
    final result = await _chatService.sendMessage(content);
  }
}

// AFTER (using providers)
class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository _chatRepository;
  final BillingRepository _billingRepository;
  
  ChatNotifier({
    required ChatRepository chatRepository,
    required BillingRepository billingRepository,
  }) : _chatRepository = chatRepository,
       _billingRepository = billingRepository,
       super(const ChatState());
  
  Future<void> sendMessage(String content) async {
    // Use repository through use case
    final result = await _chatRepository.sendMessage(content);
  }
}
```

## Step 3: Create Missing Use Cases (Day 8-12)

### 3.1 Create Chat Use Cases
**File**: `lib/core/domain/usecases/chat_usecases.dart`

```dart
import 'package:mindhearth/core/domain/entities/result.dart';
import 'package:mindhearth/core/domain/entities/app_error.dart';
import 'package:mindhearth/core/domain/repositories/chat_repository.dart';
import 'package:mindhearth/core/domain/repositories/billing_repository.dart';
import 'package:mindhearth/core/models/chat_message.dart';
import 'package:mindhearth/core/models/session.dart';

class SendMessageUseCase {
  final ChatRepository _chatRepository;
  final BillingRepository _billingRepository;
  
  SendMessageUseCase({
    required ChatRepository chatRepository,
    required BillingRepository billingRepository,
  }) : _chatRepository = chatRepository,
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
    return await _chatRepository.sendMessage(content, sessionId);
  }
}

class GetSessionsUseCase {
  final ChatRepository _chatRepository;
  
  GetSessionsUseCase(this._chatRepository);
  
  Future<Result<List<Session>>> call() async {
    return await _chatRepository.getSessions();
  }
}

class CreateSessionUseCase {
  final ChatRepository _chatRepository;
  
  CreateSessionUseCase(this._chatRepository);
  
  Future<Result<Session>> call(String? name) async {
    return await _chatRepository.createSession(name);
  }
}

class DeleteSessionUseCase {
  final ChatRepository _chatRepository;
  
  DeleteSessionUseCase(this._chatRepository);
  
  Future<Result<void>> call(String sessionId) async {
    return await _chatRepository.deleteSession(sessionId);
  }
}
```

### 3.2 Create Journal Use Cases
**File**: `lib/core/domain/usecases/journal_usecases.dart`

```dart
import 'package:mindhearth/core/domain/entities/result.dart';
import 'package:mindhearth/core/domain/entities/app_error.dart';
import 'package:mindhearth/core/domain/repositories/journal_repository.dart';
import 'package:mindhearth/core/models/journal_entry.dart';

class CreateJournalEntryUseCase {
  final JournalRepository _journalRepository;
  
  CreateJournalEntryUseCase(this._journalRepository);
  
  Future<Result<JournalEntry>> call(JournalEntry entry) async {
    // Validate entry
    if (entry.title.trim().isEmpty) {
      return Result.failure(AppErrorFactory.validation(
        message: 'Journal entry title is required',
      ));
    }
    
    if (entry.content.trim().isEmpty) {
      return Result.failure(AppErrorFactory.validation(
        message: 'Journal entry content is required',
      ));
    }
    
    return await _journalRepository.createEntry(entry);
  }
}

class GetJournalEntriesUseCase {
  final JournalRepository _journalRepository;
  
  GetJournalEntriesUseCase(this._journalRepository);
  
  Future<Result<List<JournalEntry>>> call({
    int? limit,
    int? offset,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    return await _journalRepository.getEntries(
      limit: limit,
      offset: offset,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}

class UpdateJournalEntryUseCase {
  final JournalRepository _journalRepository;
  
  UpdateJournalEntryUseCase(this._journalRepository);
  
  Future<Result<JournalEntry>> call(String id, JournalEntry entry) async {
    return await _journalRepository.updateEntry(id, entry);
  }
}

class DeleteJournalEntryUseCase {
  final JournalRepository _journalRepository;
  
  DeleteJournalEntryUseCase(this._journalRepository);
  
  Future<Result<void>> call(String id) async {
    return await _journalRepository.deleteEntry(id);
  }
}
```

### 3.3 Create Use Case Providers
**File**: `lib/core/providers/usecase_providers.dart`

```dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/domain/usecases/chat_usecases.dart';
import 'package:mindhearth/core/domain/usecases/journal_usecases.dart';
import 'package:mindhearth/core/providers/repository_providers.dart';

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

final deleteSessionUseCaseProvider = Provider<DeleteSessionUseCase>((ref) {
  return DeleteSessionUseCase(ref.watch(chatRepositoryProvider));
});

// Journal Use Cases
final createJournalEntryUseCaseProvider = Provider<CreateJournalEntryUseCase>((ref) {
  return CreateJournalEntryUseCase(ref.watch(journalRepositoryProvider));
});

final getJournalEntriesUseCaseProvider = Provider<GetJournalEntriesUseCase>((ref) {
  return GetJournalEntriesUseCase(ref.watch(journalRepositoryProvider));
});

final updateJournalEntryUseCaseProvider = Provider<UpdateJournalEntryUseCase>((ref) {
  return UpdateJournalEntryUseCase(ref.watch(journalRepositoryProvider));
});

final deleteJournalEntryUseCaseProvider = Provider<DeleteJournalEntryUseCase>((ref) {
  return DeleteJournalEntryUseCase(ref.watch(journalRepositoryProvider));
});
```

## Step 4: Refactor Chat Architecture (Day 13-15)

### 4.1 Update ChatNotifier
**File**: `lib/features/chat/providers/chat_provider.dart`

```dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/domain/usecases/chat_usecases.dart';
import 'package:mindhearth/core/models/chat_message.dart';
import 'package:mindhearth/core/models/session.dart';

class ChatNotifier extends StateNotifier<ChatState> {
  final SendMessageUseCase _sendMessageUseCase;
  final GetSessionsUseCase _getSessionsUseCase;
  final CreateSessionUseCase _createSessionUseCase;
  final DeleteSessionUseCase _deleteSessionUseCase;
  
  ChatNotifier({
    required SendMessageUseCase sendMessageUseCase,
    required GetSessionsUseCase getSessionsUseCase,
    required CreateSessionUseCase createSessionUseCase,
    required DeleteSessionUseCase deleteSessionUseCase,
  }) : _sendMessageUseCase = sendMessageUseCase,
       _getSessionsUseCase = getSessionsUseCase,
       _createSessionUseCase = createSessionUseCase,
       _deleteSessionUseCase = deleteSessionUseCase,
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
      state = state.copyWith(sessions: result.data!.map((s) => s.toJson()).toList());
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

// Provider with constructor injection
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(
    sendMessageUseCase: ref.watch(sendMessageUseCaseProvider),
    getSessionsUseCase: ref.watch(getSessionsUseCaseProvider),
    createSessionUseCase: ref.watch(createSessionUseCaseProvider),
    deleteSessionUseCase: ref.watch(deleteSessionUseCaseProvider),
  );
});
```

## Step 5: Testing & Validation (Day 16-17)

### 5.1 Test All Changes
```bash
# Run Flutter analyze
flutter analyze

# Run tests
flutter test

# Check for any remaining issues
grep -r "serviceLocator<" lib/features/
grep -r "import.*widgets" lib/core/services/
```

### 5.2 Manual Testing
1. Test chat functionality
2. Test journal functionality
3. Test error handling
4. Test state management

### 5.3 Validation Checklist
- [ ] No UI imports in services
- [ ] All services use Result type
- [ ] All StateNotifiers use constructor injection
- [ ] All features have use cases
- [ ] No direct GetIt usage in UI layer
- [ ] All functionality works correctly

## Common Issues & Solutions

### Issue 1: Provider Dependencies
**Problem**: Circular dependencies between providers
**Solution**: Use `ref.read()` instead of `ref.watch()` for dependencies

### Issue 2: Result Type Handling
**Problem**: Forgetting to handle Result type
**Solution**: Always check `result.isSuccess` before accessing data

### Issue 3: Constructor Injection
**Problem**: Too many parameters in constructor
**Solution**: Group related dependencies into service classes

## Next Steps

After completing Phase 1:
1. Review all changes
2. Update documentation
3. Begin Phase 2: Architecture Consistency
4. Plan testing strategy for Phase 3

## Support

If you encounter issues:
1. Check the error messages carefully
2. Review the Clean Architecture principles
3. Ensure all dependencies are properly injected
4. Test each change incrementally
