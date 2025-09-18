import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/services/journal_service.dart';
import 'package:mindhearth/core/services/api_service.dart';
import 'package:mindhearth/core/providers/api_providers.dart';
import 'package:mindhearth/features/journal/domain/entities/journal_entry.dart';
import 'package:mindhearth/core/utils/logger.dart';

// Journal state class
class JournalState {
  final List<JournalEntry> journalEntries;
  final bool isLoading;
  final String? error;
  final int totalEntries;

  const JournalState({
    this.journalEntries = const [],
    this.isLoading = false,
    this.error,
    this.totalEntries = 0,
  });

  JournalState copyWith({
    List<JournalEntry>? journalEntries,
    bool? isLoading,
    String? error,
    int? totalEntries,
  }) {
    return JournalState(
      journalEntries: journalEntries ?? this.journalEntries,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      totalEntries: totalEntries ?? this.totalEntries,
    );
  }
}

// Journal notifier
class JournalNotifier extends StateNotifier<JournalState> {
  final JournalService _journalService;

  JournalNotifier(this._journalService) : super(const JournalState());

  // Load journal entries
  Future<void> loadJournalEntries({
    int limit = 100,
    int offset = 0,
    String? sessionId,
    String? entryType,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final response = await _journalService.getJournalEntries(
        limit: limit,
        offset: offset,
        sessionId: sessionId,
        entryType: entryType,
      );
      
      response.when(
        success: (data, statusCode) {
          state = state.copyWith(
            journalEntries: data.journalEntries,
            totalEntries: data.total,
            isLoading: false,
          );
          appLogger.info('Loaded journal entries', {
            'count': data.journalEntries.length,
            'total': data.total,
          });
        },
        error: (message, statusCode, errors) {
          state = state.copyWith(
            isLoading: false,
            error: message,
          );
          appLogger.error('Failed to load journal entries', {
            'error': message,
            'statusCode': statusCode,
          });
        },
      );
    } catch (e) {
      appLogger.error('Error loading journal entries', {'error': e.toString()});
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load journal entries',
      );
    }
  }

  // Create manual journal entry
  Future<JournalEntry?> createJournalEntry({
    required String content,
    String? sessionId,
    String? entryType,
    String? header,
    List<String>? tags,
    bool consent = false,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final request = JournalEntryCreate(
        originalContent: content,
        sessionId: sessionId,
        entryType: entryType,
        header: header,
        tags: tags,
        consent: consent,
      );

      final response = await _journalService.createJournalEntry(request);
      
      return response.when(
        success: (entry, statusCode) {
          // Add to local list
          final updatedEntries = <JournalEntry>[entry, ...state.journalEntries];
          state = state.copyWith(
            journalEntries: updatedEntries,
            totalEntries: state.totalEntries + 1,
            isLoading: false,
          );
          
          appLogger.info('Created journal entry', {
            'entryId': entry.id,
            'entryType': entry.entryType,
          });
          
          return entry;
        },
        error: (message, statusCode, errors) {
          state = state.copyWith(
            isLoading: false,
            error: message,
          );
          appLogger.error('Failed to create journal entry', {
            'error': message,
            'statusCode': statusCode,
          });
          return null;
        },
      );
    } catch (e) {
      appLogger.error('Error creating journal entry', {'error': e.toString()});
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create journal entry',
      );
      return null;
    }
  }

  // Create AI journal summary
  Future<JournalEntry?> createAIJournalSummary({
    required String sessionId,
    String? entryType,
    List<String>? tags,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final request = AIJournalSummaryRequest(
        sessionId: sessionId,
        entryType: entryType,
        tags: tags,
      );

      final response = await _journalService.createAIJournalSummary(request);
      
      return response.when(
        success: (entry, statusCode) {
          // Add to local list
          final updatedEntries = <JournalEntry>[entry, ...state.journalEntries];
          state = state.copyWith(
            journalEntries: updatedEntries,
            totalEntries: state.totalEntries + 1,
            isLoading: false,
          );
          
          appLogger.info('Created AI journal summary', {
            'entryId': entry.id,
            'sessionId': sessionId,
          });
          
          return entry;
        },
        error: (message, statusCode, errors) {
          state = state.copyWith(
            isLoading: false,
            error: message,
          );
          appLogger.error('Failed to create AI journal summary', {
            'error': message,
            'statusCode': statusCode,
          });
          return null;
        },
      );
    } catch (e) {
      appLogger.error('Error creating AI journal summary', {'error': e.toString()});
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create AI journal summary',
      );
      return null;
    }
  }

  // Update journal entry
  Future<JournalEntry?> updateJournalEntry({
    required String entryId,
    required String content,
    String? header,
    String? entryType,
    List<String>? tags,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final request = JournalEntryCreate(
        originalContent: content,
        header: header,
        entryType: entryType,
        tags: tags,
      );

      final response = await _journalService.updateJournalEntry(entryId, request);
      
      return response.when(
        success: (entry, statusCode) {
          // Update local list
          final updatedEntries = List<JournalEntry>.from(state.journalEntries);
          final index = updatedEntries.indexWhere((e) => e.id == entryId);
          if (index != -1) {
            updatedEntries[index] = entry;
          }
          
          state = state.copyWith(
            journalEntries: updatedEntries,
            isLoading: false,
          );
          
          appLogger.info('Updated journal entry', {
            'entryId': entryId,
          });
          
          return entry;
        },
        error: (message, statusCode, errors) {
          state = state.copyWith(
            isLoading: false,
            error: message,
          );
          appLogger.error('Failed to update journal entry', {
            'error': message,
            'statusCode': statusCode,
          });
          return null;
        },
      );
    } catch (e) {
      appLogger.error('Error updating journal entry', {'error': e.toString()});
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update journal entry',
      );
      return null;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final journalServiceProvider = Provider<JournalService>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return JournalService(apiService);
});

final journalProvider = StateNotifierProvider<JournalNotifier, JournalState>((ref) {
  final journalService = ref.read(journalServiceProvider);
  return JournalNotifier(journalService);
});
