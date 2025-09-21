import 'package:mindhearth/core/domain/entities/result.dart';
import 'package:mindhearth/core/domain/entities/app_error.dart';
import 'package:mindhearth/core/domain/repositories/chat_repository.dart';
import 'package:mindhearth/core/domain/repositories/billing_repository.dart';
import 'package:mindhearth/features/chat/domain/entities/chat_message.dart';
import 'package:mindhearth/features/chat/domain/entities/session.dart';

/// Use case for sending a chat message
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
    return await _chatRepository.sendMessage(
      sessionId: sessionId,
      content: content,
    );
  }
}

/// Use case for getting chat sessions
class GetSessionsUseCase {
  final ChatRepository _chatRepository;
  
  GetSessionsUseCase(this._chatRepository);
  
  Future<Result<List<Session>>> call({
    int? limit,
    int? offset,
  }) async {
    return await _chatRepository.getSessions(
      limit: limit,
      offset: offset,
    );
  }
}

/// Use case for creating a new chat session
class CreateSessionUseCase {
  final ChatRepository _chatRepository;
  
  CreateSessionUseCase(this._chatRepository);
  
  Future<Result<Session>> call({
    required String name,
    String? sessionType,
    String? purpose,
  }) async {
    // Validate input
    if (name.trim().isEmpty) {
      return Result.failure(AppErrorFactory.validation(
        message: 'Session name cannot be empty',
      ));
    }
    
    return await _chatRepository.createSession(
      name: name,
      sessionType: sessionType,
      purpose: purpose,
    );
  }
}

/// Use case for updating a chat session
class UpdateSessionUseCase {
  final ChatRepository _chatRepository;
  
  UpdateSessionUseCase(this._chatRepository);
  
  Future<Result<Session>> call({
    required String id,
    String? name,
    String? sessionType,
    String? purpose,
  }) async {
    return await _chatRepository.updateSession(
      id: id,
      name: name,
      sessionType: sessionType,
      purpose: purpose,
    );
  }
}

/// Use case for deleting a chat session
class DeleteSessionUseCase {
  final ChatRepository _chatRepository;
  
  DeleteSessionUseCase(this._chatRepository);
  
  Future<Result<void>> call(String sessionId) async {
    return await _chatRepository.deleteSession(sessionId);
  }
}

/// Use case for getting session messages
class GetSessionMessagesUseCase {
  final ChatRepository _chatRepository;
  
  GetSessionMessagesUseCase(this._chatRepository);
  
  Future<Result<List<ChatMessage>>> call({
    required String sessionId,
    int? limit,
    int? offset,
  }) async {
    return await _chatRepository.getSessionMessages(
      sessionId: sessionId,
      limit: limit,
      offset: offset,
    );
  }
}

/// Use case for starting streaming chat
class StartStreamingChatUseCase {
  final ChatRepository _chatRepository;
  final BillingRepository _billingRepository;
  
  StartStreamingChatUseCase({
    required ChatRepository chatRepository,
    required BillingRepository billingRepository,
  }) : _chatRepository = chatRepository,
       _billingRepository = billingRepository;
  
  Future<Result<Stream<ChatMessage>>> call({
    required String sessionId,
    required String content,
    String? messageType,
  }) async {
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
    
    // Start streaming
    return await _chatRepository.sendStreamingMessage(
      sessionId: sessionId,
      content: content,
      messageType: messageType,
    );
  }
}
