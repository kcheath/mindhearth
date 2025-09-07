import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/models/journal_state.dart';
import 'package:mindhearth/core/services/api_service.dart';
import 'package:mindhearth/core/config/logging_config.dart';
import 'package:mindhearth/core/utils/logger.dart';
import 'package:mindhearth/core/providers/api_providers.dart';

/// Journal state notifier
class JournalNotifier extends StateNotifier<JournalState> {
  final ApiService _apiService;

  JournalNotifier(this._apiService) : super(const JournalState());

  /// Load journal entries
  Future<void> loadJournalEntries({String? entryType}) async {
    state = state.setLoading(true);
    
    try {
      // Note: This endpoint needs to be implemented in the API service
      // For now, we'll use a placeholder response
      final response = await _apiService.getJournalEntries(
        entryType: entryType,
        limit: 100,
        offset: 0,
      );
      
      response.when(
        success: (data, message) {
          final entriesList = data['entries'] as List<dynamic>? ?? [];
          final entries = entriesList
              .map((entryData) => JournalEntry.fromJson(entryData as Map<String, dynamic>))
              .toList();
          
          state = state.loadEntries(entries);
          
          if (LoggingConfig.enableApiLogs) {
            appLogger.apiResponse('GET', '/journal-entries/', 200, {
              'count': entries.length,
              'entryType': entryType,
            });
          }
        },
        error: (message, statusCode, errors) {
          state = state.setError(message);
          
          if (LoggingConfig.enableApiLogs) {
            appLogger.apiError('GET', '/journal-entries/', statusCode ?? 500, message);
          }
        },
      );
    } catch (e) {
      state = state.setError('Failed to load journal entries: ${e.toString()}');
      
      if (LoggingConfig.enableApiLogs) {
        appLogger.apiError('GET', '/journal-entries/', 500, e.toString());
      }
    }
  }

  /// Create new journal entry
  Future<JournalEntry?> createJournalEntry({
    required String header,
    required String entryType,
    String? sessionId,
    Map<String, dynamic>? metaData,
    bool consent = false,
  }) async {
    state = state.setLoading(true);
    
    try {
      final response = await _apiService.createJournalEntry(
        header: header,
        entryType: entryType,
        sessionId: sessionId,
        metaData: metaData,
        consent: consent,
      );
      
      return response.when(
        success: (data, message) {
          final entry = JournalEntry.fromJson(data);
          state = state.addEntry(entry);
          
          if (LoggingConfig.enableApiLogs) {
            appLogger.apiResponse('POST', '/journal-entries/', 201, {
              'entryId': entry.id,
              'header': entry.header,
              'entryType': entry.entryType,
            });
          }
          
          return entry;
        },
        error: (message, statusCode, errors) {
          state = state.setError(message);
          
          if (LoggingConfig.enableApiLogs) {
            appLogger.apiError('POST', '/journal-entries/', statusCode ?? 500, message);
          }
          
          return null;
        },
      );
    } catch (e) {
      state = state.setError('Failed to create journal entry: ${e.toString()}');
      
      if (LoggingConfig.enableApiLogs) {
        appLogger.apiError('POST', '/journal-entries/', 500, e.toString());
      }
      
      return null;
    }
  }

  /// Update journal entry
  Future<JournalEntry?> updateJournalEntry({
    required String entryId,
    String? header,
    String? entryType,
    Map<String, dynamic>? metaData,
    bool? consent,
  }) async {
    state = state.setLoading(true);
    
    try {
      final response = await _apiService.updateJournalEntry(
        entryId: entryId,
        header: header,
        entryType: entryType,
        metaData: metaData,
        consent: consent,
      );
      
      return response.when(
        success: (data, message) {
          final entry = JournalEntry.fromJson(data);
          state = state.updateEntry(entry);
          
          if (LoggingConfig.enableApiLogs) {
            appLogger.apiResponse('PUT', '/journal-entries/${entry.id}', 200, {
              'entryId': entry.id,
              'header': entry.header,
            });
          }
          
          return entry;
        },
        error: (message, statusCode, errors) {
          state = state.setError(message);
          
          if (LoggingConfig.enableApiLogs) {
            appLogger.apiError('PUT', '/journal-entries/$entryId', statusCode ?? 500, message);
          }
          
          return null;
        },
      );
    } catch (e) {
      state = state.setError('Failed to update journal entry: ${e.toString()}');
      
      if (LoggingConfig.enableApiLogs) {
        appLogger.apiError('PUT', '/journal-entries/$entryId', 500, e.toString());
      }
      
      return null;
    }
  }

  /// Delete journal entry
  Future<void> deleteJournalEntry(String entryId) async {
    state = state.setLoading(true);
    
    try {
      final response = await _apiService.deleteJournalEntry(entryId);
      
      response.when(
        success: (data, message) {
          state = state.deleteEntry(entryId);
          
          if (LoggingConfig.enableApiLogs) {
            appLogger.apiResponse('DELETE', '/journal-entries/$entryId', 200, {
              'entryId': entryId,
            });
          }
        },
        error: (message, statusCode, errors) {
          state = state.setError(message);
          
          if (LoggingConfig.enableApiLogs) {
            appLogger.apiError('DELETE', '/journal-entries/$entryId', statusCode ?? 500, message);
          }
        },
      );
    } catch (e) {
      state = state.setError('Failed to delete journal entry: ${e.toString()}');
      
      if (LoggingConfig.enableApiLogs) {
        appLogger.apiError('DELETE', '/journal-entries/$entryId', 500, e.toString());
      }
    }
  }

  /// Set current entry
  void setCurrentEntry(JournalEntry entry) {
    state = state.setCurrentEntry(entry);
    
    if (LoggingConfig.enableApiLogs) {
      appLogger.apiRequest('SELECT', '/journal-entries/${entry.id}', {
        'entryId': entry.id,
        'header': entry.header,
      });
    }
  }

  /// Clear current entry
  void clearCurrentEntry() {
    state = state.clearCurrentEntry();
    
    if (LoggingConfig.enableApiLogs) {
      appLogger.apiRequest('CLEAR', '/journal-entries/', {});
    }
  }

  /// Get entry by ID
  JournalEntry? getEntryById(String id) {
    return state.getEntryById(id);
  }

  /// Get entries by type
  List<JournalEntry> getEntriesByType(String type) {
    return state.getEntriesByType(type);
  }

  /// Refresh journal entries
  Future<void> refreshJournalEntries({String? entryType}) async {
    await loadJournalEntries(entryType: entryType);
  }

  /// Clear error
  void clearError() {
    state = state.clearError();
  }

  /// Set loading state
  void setLoading(bool loading) {
    state = state.setLoading(loading);
  }
}

/// Journal state provider
final journalNotifierProvider = StateNotifierProvider<JournalNotifier, JournalState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return JournalNotifier(apiService);
});

/// Journal state provider (read-only)
final journalStateProvider = Provider<JournalState>((ref) {
  return ref.watch(journalNotifierProvider);
});

/// Current journal entry provider
final currentJournalEntryProvider = Provider<JournalEntry?>((ref) {
  return ref.watch(journalStateProvider).currentEntry;
});

/// Journal entries list provider
final journalEntriesProvider = Provider<List<JournalEntry>>((ref) {
  return ref.watch(journalStateProvider).entries;
});

/// Journal entry count provider
final journalEntryCountProvider = Provider<int>((ref) {
  return ref.watch(journalStateProvider).entryCount;
});

/// Recent journal entries provider
final recentJournalEntriesProvider = Provider<List<JournalEntry>>((ref) {
  return ref.watch(journalStateProvider).recentEntries;
});
