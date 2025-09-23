import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mindhearth/core/domain/repositories/auth_repository.dart';
import 'package:mindhearth/core/domain/repositories/chat_repository.dart';
import 'package:mindhearth/core/domain/repositories/journal_repository.dart';
import 'package:mindhearth/core/domain/repositories/billing_repository.dart';
import 'package:mindhearth/core/domain/repositories/onboarding_repository.dart';
import 'package:mindhearth/core/services/api_service.dart';
import 'package:mindhearth/core/services/encryption_service.dart';

// Generate mocks for all repositories and services
@GenerateMocks([
  AuthRepository,
  ChatRepository,
  JournalRepository,
  BillingRepository,
  OnboardingRepository,
  ApiService,
  EncryptionService,
])
void main() {}

/// Test utilities for setting up test environments
class TestHelpers {
  /// Creates a ProviderContainer with overridden providers for testing
  static ProviderContainer createTestContainer({
    AuthRepository? authRepository,
    ChatRepository? chatRepository,
    JournalRepository? journalRepository,
    BillingRepository? billingRepository,
    OnboardingRepository? onboardingRepository,
    ApiService? apiService,
  }) {
    final overrides = <Override>[];
    
    if (authRepository != null) {
      overrides.add(authRepositoryProvider.overrideWithValue(authRepository));
    }
    
    if (chatRepository != null) {
      overrides.add(chatRepositoryProvider.overrideWithValue(chatRepository));
    }
    
    if (journalRepository != null) {
      overrides.add(journalRepositoryProvider.overrideWithValue(journalRepository));
    }
    
    if (billingRepository != null) {
      overrides.add(billingRepositoryProvider.overrideWithValue(billingRepository));
    }
    
    if (onboardingRepository != null) {
      overrides.add(onboardingRepositoryProvider.overrideWithValue(onboardingRepository));
    }
    
    if (apiService != null) {
      overrides.add(apiServiceProvider.overrideWithValue(apiService));
    }
    
    return ProviderContainer(overrides: overrides);
  }
  
  /// Creates a mock user for testing
  static Map<String, dynamic> createMockUser() {
    return {
      'id': 'test-user-id',
      'email': 'test@example.com',
      'name': 'Test User',
      'tenant_id': 'test-tenant-id',
      'onboarded': true,
    };
  }
  
  /// Creates a mock session for testing
  static Map<String, dynamic> createMockSession() {
    return {
      'id': 'test-session-id',
      'name': 'Test Session',
      'session_type': 'chat',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
  
  /// Creates a mock chat message for testing
  static Map<String, dynamic> createMockChatMessage() {
    return {
      'id': 'test-message-id',
      'content': 'Test message content',
      'role': 'user',
      'created_at': DateTime.now().toIso8601String(),
    };
  }
  
  /// Creates a mock journal entry for testing
  static Map<String, dynamic> createMockJournalEntry() {
    return {
      'id': 'test-journal-id',
      'header': 'Test Journal Entry',
      'content': 'Test journal content',
      'entry_type': 'general',
      'created_at': DateTime.now().toIso8601String(),
    };
  }
  
  /// Creates a mock billing status for testing
  static Map<String, dynamic> createMockBillingStatus() {
    return {
      'is_healthy': true,
      'current_balance': 100,
      'subscription_status': 'active',
    };
  }
}

/// Test data constants
class TestData {
  static const String testEmail = 'test@example.com';
  static const String testPassword = 'testpassword123';
  static const String testTenantId = 'test-tenant-id';
  static const String testApplicationId = 'test-app-id';
  static const String testAccessToken = 'test-access-token';
  static const String testUserId = 'test-user-id';
  static const String testSessionId = 'test-session-id';
  static const String testMessageId = 'test-message-id';
  static const String testJournalId = 'test-journal-id';
}
