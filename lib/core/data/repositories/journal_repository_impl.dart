import 'package:mindhearth/core/domain/entities/result.dart';
import 'package:mindhearth/core/domain/entities/app_error.dart';
import 'package:mindhearth/core/domain/repositories/journal_repository.dart';
import 'package:mindhearth/core/services/api_service.dart';
import 'package:mindhearth/features/journal/domain/entities/journal_entry.dart';
import 'package:mindhearth/core/utils/logger.dart';

class JournalRepositoryImpl implements JournalRepository {
  final ApiService _apiService;

  JournalRepositoryImpl(this._apiService);

  @override
  Future<Result<List<JournalEntry>>> getJournalEntries({
    String? entryType,
    int? limit,
    int? offset,
  }) async {
    try {
      appLogger.info('📝 Getting journal entries');

      final response = await _apiService.get('/journals/');

      return response.when(
        success: (data, message) {
          final entries = (data['journal_entries'] as List)
              .map((json) => JournalEntry.fromJson(json as Map<String, dynamic>))
              .toList();
          appLogger.info('✅ Retrieved ${entries.length} journal entries');
          return Result.success(entries);
        },
        error: (message, statusCode, errors) {
          appLogger.error('❌ Failed to get journal entries: $message');
          return Result.failure(AppErrorFactory.network(message: message));
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception getting journal entries: $e');
      return Result.failure(AppErrorFactory.network(message: 'Failed to get journal entries: $e'));
    }
  }

  @override
  Future<Result<JournalEntry?>> getJournalEntry(String id) async {
    try {
      appLogger.info('📖 Getting journal entry: $id');

      final response = await _apiService.get('/journals/$id');

      return response.when(
        success: (data, message) {
          final entry = JournalEntry.fromJson(data as Map<String, dynamic>);
          appLogger.info('✅ Retrieved journal entry: ${entry.id}');
          return Result.success(entry);
        },
        error: (message, statusCode, errors) {
          appLogger.error('❌ Failed to get journal entry: $message');
          return Result.failure(AppErrorFactory.network(message: message));
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception getting journal entry: $e');
      return Result.failure(AppErrorFactory.network(message: 'Failed to get journal entry: $e'));
    }
  }

  @override
  Future<Result<JournalEntry>> createJournalEntry({
    required String content,
    String? header,
    String? entryType,
    Map<String, dynamic>? metaData,
    bool? consent,
  }) async {
    try {
      appLogger.info('➕ Creating journal entry');

      final response = await _apiService.post(
        '/journals/',
        data: {
          'content': content,
          if (header != null) 'header': header,
          if (entryType != null) 'entry_type': entryType,
          if (metaData != null) 'meta_data': metaData,
          if (consent != null) 'consent': consent,
        },
      );

      return response.when(
        success: (data, message) {
          final entry = JournalEntry.fromJson(data as Map<String, dynamic>);
          appLogger.info('✅ Created journal entry: ${entry.id}');
          return Result.success(entry);
        },
        error: (message, statusCode, errors) {
          appLogger.error('❌ Failed to create journal entry: $message');
          return Result.failure(AppErrorFactory.network(message: message));
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception creating journal entry: $e');
      return Result.failure(AppErrorFactory.network(message: 'Failed to create journal entry: $e'));
    }
  }

  @override
  Future<Result<JournalEntry>> updateJournalEntry({
    required String id,
    String? content,
    String? header,
    String? entryType,
    Map<String, dynamic>? metaData,
    bool? consent,
  }) async {
    try {
      appLogger.info('✏️ Updating journal entry: $id');

      final response = await _apiService.put(
        '/journals/$id',
        data: {
          if (content != null) 'content': content,
          if (header != null) 'header': header,
          if (entryType != null) 'entry_type': entryType,
          if (metaData != null) 'meta_data': metaData,
          if (consent != null) 'consent': consent,
        },
      );

      return response.when(
        success: (data, message) {
          final entry = JournalEntry.fromJson(data as Map<String, dynamic>);
          appLogger.info('✅ Updated journal entry: ${entry.id}');
          return Result.success(entry);
        },
        error: (message, statusCode, errors) {
          appLogger.error('❌ Failed to update journal entry: $message');
          return Result.failure(AppErrorFactory.network(message: message));
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception updating journal entry: $e');
      return Result.failure(AppErrorFactory.network(message: 'Failed to update journal entry: $e'));
    }
  }

  @override
  Future<Result<void>> deleteJournalEntry(String id) async {
    try {
      appLogger.info('🗑️ Deleting journal entry: $id');

      final response = await _apiService.delete('/journals/$id');

      return response.when(
        success: (data, message) {
          appLogger.info('✅ Deleted journal entry: $id');
          return Result.success(null);
        },
        error: (message, statusCode, errors) {
          appLogger.error('❌ Failed to delete journal entry: $message');
          return Result.failure(AppErrorFactory.network(message: message));
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception deleting journal entry: $e');
      return Result.failure(AppErrorFactory.network(message: 'Failed to delete journal entry: $e'));
    }
  }

  @override
  Future<Result<JournalEntry>> generateAISummary({
    required String sessionId,
    String? purpose,
  }) async {
    try {
      appLogger.info('🤖 Generating AI summary for session: $sessionId');

      // Get conversation history for context
      List<Map<String, dynamic>>? conversationHistory;
      try {
        final chatHistoryResponse = await _apiService.dio.get('/communications/', queryParameters: {
          'session_id': sessionId,
          'item_type': 'chat',
          'limit': 50, // Get last 50 messages for context
        });
        
        if (chatHistoryResponse.statusCode == 200) {
          final data = chatHistoryResponse.data as Map<String, dynamic>;
          final communications = data['communications'] as List<dynamic>? ?? [];
          
          conversationHistory = communications.map((comm) {
            final commData = comm as Map<String, dynamic>;
            return {
              'role': commData['role'] ?? 'user',
              'content': commData['original_content'] ?? commData['content'] ?? '',
              'timestamp': commData['created_at'] ?? '',
            };
          }).toList();
          
          appLogger.info('🤖 Retrieved ${conversationHistory.length} messages for AI summary context');
        }
      } catch (e) {
        appLogger.warning('🤖 Failed to get conversation history for AI summary, proceeding without context: $e');
      }

      final requestData = {
        'session_id': sessionId,
        if (purpose != null) 'purpose': purpose,
        if (conversationHistory != null && conversationHistory.isNotEmpty) 'conversation_history': conversationHistory,
      };

      final response = await _apiService.post(
        '/journals/ai-summary',
        data: requestData,
      );

      return response.when(
        success: (data, message) {
          final summaryEntry = JournalEntry.fromJson(data as Map<String, dynamic>);
          appLogger.info('✅ Generated AI summary: ${summaryEntry.id}');
          return Result.success(summaryEntry);
        },
        error: (message, statusCode, errors) {
          appLogger.error('❌ Failed to generate AI summary: $message');
          return Result.failure(AppErrorFactory.network(message: message));
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception generating AI summary: $e');
      return Result.failure(AppErrorFactory.network(message: 'Failed to generate AI summary: $e'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getTagsConfig() async {
    try {
      appLogger.info('🏷️ Getting journal tags config');

      final response = await _apiService.get('/journals/tags/config');

      return response.when(
        success: (data, message) {
          appLogger.info('✅ Retrieved journal tags config');
          return Result.success(data as Map<String, dynamic>);
        },
        error: (message, statusCode, errors) {
          appLogger.error('❌ Failed to get journal tags config: $message');
          return Result.failure(AppErrorFactory.network(message: message));
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception getting journal tags config: $e');
      return Result.failure(AppErrorFactory.network(message: 'Failed to get journal tags config: $e'));
    }
  }

  @override
  Future<Result<void>> updateJournalTags({
    required String id,
    required List<String> tags,
  }) async {
    try {
      appLogger.info('🏷️ Updating journal tags for entry: $id');

      final response = await _apiService.put(
        '/journals/$id/tags',
        data: {
          'tags': tags,
        },
      );

      return response.when(
        success: (data, message) {
          appLogger.info('✅ Updated journal tags for entry: $id');
          return Result.success(null);
        },
        error: (message, statusCode, errors) {
          appLogger.error('❌ Failed to update journal tags: $message');
          return Result.failure(AppErrorFactory.network(message: message));
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception updating journal tags: $e');
      return Result.failure(AppErrorFactory.network(message: 'Failed to update journal tags: $e'));
    }
  }
}