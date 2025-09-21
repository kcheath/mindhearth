import 'package:mindhearth/core/domain/entities/result.dart';
import 'package:mindhearth/core/domain/entities/app_error.dart';
import 'package:mindhearth/core/domain/repositories/journal_repository.dart';
import 'package:mindhearth/features/journal/domain/entities/journal_entry.dart';

/// Use case for creating a journal entry
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

/// Use case for getting journal entries
class GetJournalEntriesUseCase {
  final JournalRepository _journalRepository;
  
  GetJournalEntriesUseCase(this._journalRepository);
  
  Future<Result<List<JournalEntry>>> call({
    int? limit,
    int? offset,
    DateTime? fromDate,
    DateTime? toDate,
    String? entryType,
  }) async {
    return await _journalRepository.getEntries(
      limit: limit,
      offset: offset,
      fromDate: fromDate,
      toDate: toDate,
      entryType: entryType,
    );
  }
}

/// Use case for getting a specific journal entry
class GetJournalEntryUseCase {
  final JournalRepository _journalRepository;
  
  GetJournalEntryUseCase(this._journalRepository);
  
  Future<Result<JournalEntry?>> call(String id) async {
    return await _journalRepository.getEntry(id);
  }
}

/// Use case for updating a journal entry
class UpdateJournalEntryUseCase {
  final JournalRepository _journalRepository;
  
  UpdateJournalEntryUseCase(this._journalRepository);
  
  Future<Result<JournalEntry>> call(String id, JournalEntry entry) async {
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
    
    return await _journalRepository.updateEntry(id, entry);
  }
}

/// Use case for deleting a journal entry
class DeleteJournalEntryUseCase {
  final JournalRepository _journalRepository;
  
  DeleteJournalEntryUseCase(this._journalRepository);
  
  Future<Result<void>> call(String id) async {
    return await _journalRepository.deleteEntry(id);
  }
}

/// Use case for creating AI journal summary
class CreateAIJournalSummaryUseCase {
  final JournalRepository _journalRepository;
  final ChatRepository _chatRepository;
  
  CreateAIJournalSummaryUseCase({
    required JournalRepository journalRepository,
    required ChatRepository chatRepository,
  }) : _journalRepository = journalRepository,
       _chatRepository = chatRepository;
  
  Future<Result<JournalEntry>> call({
    required String sessionId,
    String? title,
  }) async {
    // Get session messages for context
    final messagesResult = await _chatRepository.getSessionMessages(
      sessionId: sessionId,
    );
    
    if (messagesResult.isFailure) {
      return Result.failure(messagesResult.error!);
    }
    
    // Create AI summary entry
    final summaryEntry = JournalEntry(
      id: '', // Will be set by repository
      title: title ?? 'AI Summary from Chat',
      content: 'AI-generated summary from chat session',
      entryType: 'ai_summary',
      sessionId: sessionId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      metadata: {
        'source': 'ai_summary',
        'session_id': sessionId,
        'message_count': messagesResult.data!.length,
      },
    );
    
    return await _journalRepository.createEntry(summaryEntry);
  }
}
