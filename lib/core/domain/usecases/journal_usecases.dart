import 'package:mindhearth/core/domain/entities/result.dart';
import 'package:mindhearth/core/domain/entities/app_error.dart';
import 'package:mindhearth/core/domain/repositories/journal_repository.dart';
import 'package:mindhearth/core/domain/repositories/chat_repository.dart';
import 'package:mindhearth/features/journal/domain/entities/journal_entry.dart';

/// Use case for creating a journal entry
class CreateJournalEntryUseCase {
  final JournalRepository _journalRepository;
  
  CreateJournalEntryUseCase(this._journalRepository);
  
  Future<Result<JournalEntry>> call({
    required String content,
    String? header,
    String? entryType,
    Map<String, dynamic>? metaData,
    bool? consent,
  }) async {
    // Validate entry
    if (content.trim().isEmpty) {
      return Result.failure(AppErrorFactory.validation(
        message: 'Journal entry content is required',
      ));
    }
    
    return await _journalRepository.createJournalEntry(
      content: content,
      header: header,
      entryType: entryType,
      metaData: metaData,
      consent: consent,
    );
  }
}

/// Use case for getting journal entries
class GetJournalEntriesUseCase {
  final JournalRepository _journalRepository;
  
  GetJournalEntriesUseCase(this._journalRepository);
  
  Future<Result<List<JournalEntry>>> call({
    int? limit,
    int? offset,
    String? entryType,
  }) async {
    return await _journalRepository.getJournalEntries(
      limit: limit,
      offset: offset,
      entryType: entryType,
    );
  }
}

/// Use case for getting a specific journal entry
class GetJournalEntryUseCase {
  final JournalRepository _journalRepository;
  
  GetJournalEntryUseCase(this._journalRepository);
  
  Future<Result<JournalEntry?>> call(String id) async {
    return await _journalRepository.getJournalEntry(id);
  }
}

/// Use case for updating a journal entry
class UpdateJournalEntryUseCase {
  final JournalRepository _journalRepository;
  
  UpdateJournalEntryUseCase(this._journalRepository);
  
  Future<Result<JournalEntry>> call({
    required String id,
    String? content,
    String? header,
    String? entryType,
    Map<String, dynamic>? metaData,
    bool? consent,
  }) async {
    return await _journalRepository.updateJournalEntry(
      id: id,
      content: content,
      header: header,
      entryType: entryType,
      metaData: metaData,
      consent: consent,
    );
  }
}

/// Use case for deleting a journal entry
class DeleteJournalEntryUseCase {
  final JournalRepository _journalRepository;
  
  DeleteJournalEntryUseCase(this._journalRepository);
  
  Future<Result<void>> call(String id) async {
    return await _journalRepository.deleteJournalEntry(id);
  }
}

/// Use case for creating AI journal summary
class CreateAIJournalSummaryUseCase {
  final JournalRepository _journalRepository;
  
  CreateAIJournalSummaryUseCase({
    required JournalRepository journalRepository,
  }) : _journalRepository = journalRepository;
  
  Future<Result<JournalEntry>> call({
    required String sessionId,
    String? purpose,
  }) async {
    return await _journalRepository.generateAISummary(
      sessionId: sessionId,
      purpose: purpose,
    );
  }
}
