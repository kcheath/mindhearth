import 'package:mindhearth/core/domain/entities/result.dart';
import 'package:mindhearth/features/journal/domain/entities/journal_entry.dart';

abstract class JournalRepository {
  /// Get all journal entries
  Future<Result<List<JournalEntry>>> getJournalEntries({
    String? entryType,
    int? limit,
    int? offset,
  });

  /// Get a specific journal entry by ID
  Future<Result<JournalEntry?>> getJournalEntry(String id);

  /// Create a new journal entry
  Future<Result<JournalEntry>> createJournalEntry({
    required String content,
    String? header,
    String? entryType,
    Map<String, dynamic>? metaData,
    bool? consent,
  });

  /// Update an existing journal entry
  Future<Result<JournalEntry>> updateJournalEntry({
    required String id,
    String? content,
    String? header,
    String? entryType,
    Map<String, dynamic>? metaData,
    bool? consent,
  });

  /// Delete a journal entry
  Future<Result<void>> deleteJournalEntry(String id);

  /// Generate AI summary for a journal entry
  Future<Result<JournalEntry>> generateAISummary({
    required String sessionId,
    String? purpose,
  });

  /// Get journal entry tags configuration
  Future<Result<Map<String, dynamic>>> getTagsConfig();

  /// Update journal entry tags
  Future<Result<void>> updateJournalTags({
    required String id,
    required List<String> tags,
  });
}
