import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/domain/usecases/unified_chat_usecases.dart';
import 'package:mindhearth/core/providers/repository_providers.dart';

/// Provider for SendUnifiedMessageUseCase
final sendUnifiedMessageUseCaseProvider = Provider<SendUnifiedMessageUseCase>((ref) {
  final chatRepository = ref.read(chatRepositoryProvider);
  return SendUnifiedMessageUseCase(chatRepository);
});

/// Provider for SendUnifiedStreamingMessageUseCase
final sendUnifiedStreamingMessageUseCaseProvider = Provider<SendUnifiedStreamingMessageUseCase>((ref) {
  final chatRepository = ref.read(chatRepositoryProvider);
  return SendUnifiedStreamingMessageUseCase(chatRepository);
});

/// Provider for SendBatchMessagesUseCase
final sendBatchMessagesUseCaseProvider = Provider<SendBatchMessagesUseCase>((ref) {
  final chatRepository = ref.read(chatRepositoryProvider);
  return SendBatchMessagesUseCase(chatRepository);
});

/// Provider for GetUnifiedChatHistoryUseCase
final getUnifiedChatHistoryUseCaseProvider = Provider<GetUnifiedChatHistoryUseCase>((ref) {
  final chatRepository = ref.read(chatRepositoryProvider);
  return GetUnifiedChatHistoryUseCase(chatRepository);
});

/// Provider for CreateRAGOptionsUseCase
final createRAGOptionsUseCaseProvider = Provider<CreateRAGOptionsUseCase>((ref) {
  return CreateRAGOptionsUseCase();
});

/// Provider for CreateChatMetadataUseCase
final createChatMetadataUseCaseProvider = Provider<CreateChatMetadataUseCase>((ref) {
  return CreateChatMetadataUseCase();
});

/// Provider for SelectChatModeUseCase
final selectChatModeUseCaseProvider = Provider<SelectChatModeUseCase>((ref) {
  return SelectChatModeUseCase();
});





