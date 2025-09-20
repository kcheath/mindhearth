import 'package:mindhearth/core/domain/entities/result.dart';
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
      appLogger.info('📖 Getting journal entries', extra: {
        'entryType': entryType,
        'limit': limit,
        'offset': offset,
      });

      final response = await _apiService.get(
        '/journals/',
        queryParameters: {
          if (entryType != null) 'entry_type': entryType,
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        },
      );

      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        final entries = (data['journal_entries'] as List)
            .map((json) => JournalEntry.fromJson(json as Map<String, dynamic>))
            .toList();

        appLogger.info('✅ Retrieved ${entries.length} journal entries');
        return Result.success(entries);
      } else {
        appLogger.error('❌ Failed to get journal entries: ${response.error}');
        return Result.failure(response.error ?? 'Failed to get journal entries');
      }
    } catch (e) {
      appLogger.error('💥 Exception getting journal entries: $e');
      return Result.failure('Failed to get journal entries: $e');
    }
  }

  @override
  Future<Result<JournalEntry?>> getJournalEntry(String id) async {
    try {
      appLogger.info('📖 Getting journal entry: $id');

      final response = await _apiService.get('/journals/$id');

      if (response.isSuccess) {
        final entry = JournalEntry.fromJson(response.data as Map<String, dynamic>);
        appLogger.info('✅ Retrieved journal entry: ${entry.id}');
        return Result.success(entry);
      } else {
        appLogger.error('❌ Failed to get journal entry: ${response.error}');
        return Result.failure(response.error ?? 'Failed to get journal entry');
      }
    } catch (e) {
      appLogger.error('💥 Exception getting journal entry: $e');
      return Result.failure('Failed to get journal entry: $e');
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
      appLogger.info('📝 Creating journal entry', extra: {
        'header': header,
        'entryType': entryType,
        'hasContent': content.isNotEmpty,
      });

      final response = await _apiService.post(
        '/journals/',
        data: {
          'original_content': content,
          if (header != null) 'header': header,
          if (entryType != null) 'entry_type': entryType,
          if (metaData != null) 'meta_data': metaData,
          if (consent != null) 'consent': consent,
        },
      );

      if (response.isSuccess) {
        final entry = JournalEntry.fromJson(response.data as Map<String, dynamic>);
        appLogger.info('✅ Created journal entry: ${entry.id}');
        return Result.success(entry);
      } else {
        appLogger.error('❌ Failed to create journal entry: ${response.error}');
        return Result.failure(response.error ?? 'Failed to create journal entry');
      }
    } catch (e) {
      appLogger.error('💥 Exception creating journal entry: $e');
      return Result.failure('Failed to create journal entry: $e');
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
      appLogger.info('📝 Updating journal entry: $id', extra: {
        'header': header,
        'entryType': entryType,
      });

      final response = await _apiService.put(
        '/journals/$id',
        data: {
          if (content != null) 'original_content': content,
          if (header != null) 'header': header,
          if (entryType != null) 'entry_type': entryType,
          if (metaData != null) 'meta_data': metaData,
          if (consent != null) 'consent': consent,
        },
      );

      if (response.isSuccess) {
        final entry = JournalEntry.fromJson(response.data as Map<String, dynamic>);
        appLogger.info('✅ Updated journal entry: ${entry.id}');
        return Result.success(entry);
      } else {
        appLogger.error('❌ Failed to update journal entry: ${response.error}');
        return Result.failure(response.error ?? 'Failed to update journal entry');
      }
    } catch (e) {
      appLogger.error('💥 Exception updating journal entry: $e');
      return Result.failure('Failed to update journal entry: $e');
    }
  }

  @override
  Future<Result<void>> deleteJournalEntry(String id) async {
    try {
      appLogger.info('🗑️ Deleting journal entry: $id');

      final response = await _apiService.delete('/journals/$id');

      if (response.isSuccess) {
        appLogger.info('✅ Deleted journal entry: $id');
        return Result.success(null);
      } else {
        appLogger.error('❌ Failed to delete journal entry: ${response.error}');
        return Result.failure(response.error ?? 'Failed to delete journal entry');
      }
    } catch (e) {
      appLogger.error('💥 Exception deleting journal entry: $e');
      return Result.failure('Failed to delete journal entry: $e');
    }
  }

  @override
  Future<Result<JournalEntry>> generateAISummary({
    required String sessionId,
    String? purpose,
  }) async {
    try {
      appLogger.info('🤖 Generating AI summary for session: $sessionId', extra: {
        'purpose': purpose,
      });

      final response = await _apiService.post(
        '/journals/ai-summary',
        data: {
          'session_id': sessionId,
          if (purpose != null) 'purpose': purpose,
        },
      );

      if (response.isSuccess) {
        final entry = JournalEntry.fromJson(response.data as Map<String, dynamic>);
        appLogger.info('✅ Generated AI summary: ${entry.id}');
        return Result.success(entry);
      } else {
        appLogger.error('❌ Failed to generate AI summary: ${response.error}');
        return Result.failure(response.error ?? 'Failed to generate AI summary');
      }
    } catch (e) {
      appLogger.error('💥 Exception generating AI summary: $e');
      return Result.failure('Failed to generate AI summary: $e');
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getTagsConfig() async {
    try {
      appLogger.info('🏷️ Getting journal tags configuration');

      final response = await _apiService.get('/journals/tags/config');

      if (response.isSuccess) {
        appLogger.info('✅ Retrieved tags configuration');
        return Result.success(response.data as Map<String, dynamic>);
      } else {
        appLogger.error('❌ Failed to get tags config: ${response.error}');
        return Result.failure(response.error ?? 'Failed to get tags configuration');
      }
    } catch (e) {
      appLogger.error('💥 Exception getting tags config: $e');
      return Result.failure('Failed to get tags configuration: $e');
    }
  }

  @override
  Future<Result<void>> updateJournalTags({
    required String id,
    required List<String> tags,
  }) async {
    try {
      appLogger.info('🏷️ Updating journal tags for entry: $id', extra: {
        'tags': tags,
      });

      final response = await _apiService.put(
        '/journals/$id/tags',
        data: {
          'tags': tags,
        },
      );

      if (response.isSuccess) {
        appLogger.info('✅ Updated journal tags for entry: $id');
        return Result.success(null);
      } else {
        appLogger.error('❌ Failed to update journal tags: ${response.error}');
        return Result.failure(response.error ?? 'Failed to update journal tags');
      }
    } catch (e) {
      appLogger.error('💥 Exception updating journal tags: $e');
      return Result.failure('Failed to update journal tags: $e');
    }
  }
}
