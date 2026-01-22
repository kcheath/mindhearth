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
          // Extract journal entries from the response
          List<dynamic> entriesList = [];
          
          if (data is Map<String, dynamic>) {
            // The API service should have already normalized the response
            final journalEntries = data['journal_entries'];
            if (journalEntries is List) {
              entriesList = journalEntries;
            }
          }
          
          final entries = entriesList
              .map((entryData) => JournalEntry.fromJson(entryData as Map<String, dynamic>))
              .toList();
          
          state = state.loadEntries(entries);
          
          if (LoggingConfig.enableApiLogs) {
            appLogger.apiResponse('GET', '/journals/', 200, {
              'count': entries.length,
              'entryType': entryType,
            });
          }
        },
        error: (message, statusCode, errors) {
          state = state.setError(message);
          
          if (LoggingConfig.enableApiLogs) {
            appLogger.apiError('GET', '/journals/', statusCode ?? 500, message);
          }
        },
      );
    } catch (e) {
      state = state.setError('Failed to load journal entries: ${e.toString()}');
      
      if (LoggingConfig.enableApiLogs) {
        appLogger.apiError('GET', '/journals/', 500, e.toString());
      }
    }
  }

  /// Create new journal entry
  Future<JournalEntry?> createJournalEntry({
    required String header,
    required String entryType,
    String? sessionId,
    Map<String, dynamic>? metaData,
    String? originalContent,
    bool consent = false,
    List<String>? keywords,
    String? sentiment,
    bool isAIGenerated = false,
  }) async {
    state = state.setLoading(true);
    
    try {
      // Prepare metadata with new fields
      final enhancedMetaData = {
        ...?metaData,
        'tags': keywords ?? [],
        'sentiment': sentiment,
        'ai_generated': isAIGenerated,
      };

      final response = await _apiService.createJournalEntry(
        header: header,
        entryType: entryType,
        sessionId: sessionId,
        metaData: enhancedMetaData,
        originalContent: originalContent,
        consent: consent,
      );
      
      return response.when(
        success: (data, message) {
          final entry = JournalEntry.fromJson(data);
          state = state.addEntry(entry);
          
          if (LoggingConfig.enableApiLogs) {
            appLogger.apiResponse('POST', '/journals/', 201, {
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
            appLogger.apiError('POST', '/journals/', statusCode ?? 500, message);
          }
          
          return null;
        },
      );
    } catch (e) {
      state = state.setError('Failed to create journal entry: ${e.toString()}');
      
      if (LoggingConfig.enableApiLogs) {
        appLogger.apiError('POST', '/journals/', 500, e.toString());
      }
      
      return null;
    }
  }

  /// Update journal entry
  Future<JournalEntry?> updateJournalEntry({
    required String entryId,
    String? header,
    String? entryType,
    String? originalContent,
    Map<String, dynamic>? metaData,
    bool? consent,
    List<String>? keywords,
    String? sentiment,
    bool? isAIGenerated,
  }) async {
    state = state.setLoading(true);
    
    try {
      // Prepare metadata with new fields
      final enhancedMetaData = {
        ...?metaData,
        if (keywords != null) 'tags': keywords,
        if (sentiment != null) 'sentiment': sentiment,
        if (isAIGenerated != null) 'ai_generated': isAIGenerated,
      };

      final response = await _apiService.updateJournalEntry(
        entryId: entryId,
        header: header,
        entryType: entryType,
        originalContent: originalContent,
        metaData: enhancedMetaData,
        consent: consent,
      );
      
      return response.when(
        success: (data, message) {
          final entry = JournalEntry.fromJson(data);
          state = state.updateEntry(entry);
          
          if (LoggingConfig.enableApiLogs) {
            appLogger.apiResponse('PUT', '/journals/${entry.id}', 200, {
              'entryId': entry.id,
              'header': entry.header,
            });
          }
          
          return entry;
        },
        error: (message, statusCode, errors) {
          state = state.setError(message);
          
          if (LoggingConfig.enableApiLogs) {
            appLogger.apiError('PUT', '/journals/$entryId', statusCode ?? 500, message);
          }
          
          return null;
        },
      );
    } catch (e) {
      state = state.setError('Failed to update journal entry: ${e.toString()}');
      
      if (LoggingConfig.enableApiLogs) {
        appLogger.apiError('PUT', '/journals/$entryId', 500, e.toString());
      }
      
      return null;
    }
  }

  /// Delete journal entry
  Future<bool> deleteJournalEntry(String entryId) async {
    state = state.setLoading(true);
    
    try {
      final response = await _apiService.deleteJournalEntry(entryId);
      
      return response.when(
        success: (data, message) {
          state = state.deleteEntry(entryId);
          
          if (LoggingConfig.enableApiLogs) {
            appLogger.apiResponse('DELETE', '/journals/$entryId', 200, {
              'entryId': entryId,
            });
          }
          
          return true;
        },
        error: (message, statusCode, errors) {
          state = state.setError(message);
          
          if (LoggingConfig.enableApiLogs) {
            appLogger.apiError('DELETE', '/journals/$entryId', statusCode ?? 500, message);
          }
          
          return false;
        },
      );
    } catch (e) {
      state = state.setError('Failed to delete journal entry: ${e.toString()}');
      
      if (LoggingConfig.enableApiLogs) {
        appLogger.apiError('DELETE', '/journals/$entryId', 500, e.toString());
      }
      
      return false;
    }
  }

  /// Set current entry
  void setCurrentEntry(JournalEntry entry) {
    state = state.setCurrentEntry(entry);
    
    if (LoggingConfig.enableApiLogs) {
      appLogger.apiRequest('SELECT', '/journals/${entry.id}', {
        'entryId': entry.id,
        'header': entry.header,
      });
    }
  }

  /// Clear current entry
  void clearCurrentEntry() {
    state = state.clearCurrentEntry();
    
    if (LoggingConfig.enableApiLogs) {
      appLogger.apiRequest('CLEAR', '/journals/', {});
    }
  }

  /// Get entry by ID
  JournalEntry? getEntryById(String id) {
    return state.getEntryById(id);
  }

  /// Load single journal entry by ID
  Future<JournalEntry?> loadJournalEntry(String entryId) async {
    try {
      final response = await _apiService.getJournalEntry(entryId);
      
      return response.when(
        success: (data, message) {
          final entry = JournalEntry.fromJson(data);
          
          // Add to state if not already present
          if (state.getEntryById(entryId) == null) {
            state = state.addEntry(entry);
          }
          
          if (LoggingConfig.enableApiLogs) {
            appLogger.apiResponse('GET', '/journals/$entryId', 200, {
              'entryId': entry.id,
              'header': entry.header,
            });
          }
          
          return entry;
        },
        error: (message, statusCode, errors) {
          if (LoggingConfig.enableApiLogs) {
            appLogger.apiError('GET', '/journals/$entryId', statusCode ?? 500, message);
          }
          return null;
        },
      );
    } catch (e) {
      if (LoggingConfig.enableApiLogs) {
        appLogger.apiError('GET', '/journals/$entryId', 500, e.toString());
      }
      return null;
    }
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

  /// Get journal tag configurations
  Future<List<Map<String, dynamic>>> getJournalTagConfigurations() async {
    try {
      final response = await _apiService.dio.get('/journals/tags/config');
      
      if (LoggingConfig.enableApiLogs) {
        appLogger.apiResponse('GET', '/journals/tags/config', response.statusCode ?? 200, {
          'count': (response.data as List).length,
        });
      }
      
      return (response.data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      if (LoggingConfig.enableApiLogs) {
        appLogger.apiError('GET', '/journals/tags/config', 500, e.toString());
      }
      
      // Return default tags if API fails
      return [
        {'tag_name': 'emotional-support', 'tag_description': 'Emotional support and validation'},
        {'tag_name': 'parenting-challenges', 'tag_description': 'Parenting difficulties and strategies'},
        {'tag_name': 'trauma-processing', 'tag_description': 'Processing trauma and healing'},
        {'tag_name': 'post-separation-abuse', 'tag_description': 'Abuse after separation'},
        {'tag_name': 'safety-planning', 'tag_description': 'Safety planning and protection'},
        {'tag_name': 'legal-issues', 'tag_description': 'Legal matters and court proceedings'},
        {'tag_name': 'visitation-issues', 'tag_description': 'Visitation and custody challenges'},
        {'tag_name': 'depression', 'tag_description': 'Depression and mental health'},
        {'tag_name': 'daily-reflection', 'tag_description': 'Daily thoughts and reflections'},
        {'tag_name': 'gratitude', 'tag_description': 'Gratitude and positive moments'},
      ];
    }
  }

  /// Create AI-generated journal entry from session
  Future<JournalEntry?> createAIJournalEntry({
    required String sessionId,
    String? customContent,
  }) async {
    state = state.setLoading(true);
    
    try {
      final response = await _apiService.createAIJournalEntry(
        sessionId: sessionId,
        customContent: customContent,
      );
      
      return response.when(
        success: (data, message) {
          final entry = JournalEntry.fromJson(data);
          state = state.addEntry(entry);
          
          if (LoggingConfig.enableApiLogs) {
            appLogger.apiResponse('POST', '/journals/ai-summary', 200, {
              'entryId': entry.id,
              'header': entry.header,
              'sessionId': sessionId,
            });
          }
          
          return entry;
        },
        error: (message, statusCode, errors) {
          state = state.setError(message);
          
          if (LoggingConfig.enableApiLogs) {
            appLogger.apiError('POST', '/journals/ai-summary', statusCode ?? 500, message);
          }
          
          return null;
        },
      );
    } catch (e) {
      state = state.setError('Failed to create AI journal entry: ${e.toString()}');
      
      if (LoggingConfig.enableApiLogs) {
        appLogger.apiError('POST', '/journals/ai-summary', 500, e.toString());
      }
      
      return null;
    }
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
