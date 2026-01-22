import 'package:mindhearth/core/domain/repositories/billing_repository.dart';
import 'package:mindhearth/core/domain/entities/result.dart';

/// Use case for adding questions to a session
class AddSessionQuestionsUseCase {
  final BillingRepository _billingRepository;

  AddSessionQuestionsUseCase(this._billingRepository);

  Future<Result<void>> call({
    required String sessionId,
    required int questions,
  }) async {
    return await _billingRepository.addSessionQuestions(
      sessionId: sessionId,
      questions: questions,
    );
  }
}

/// Use case for getting session question count
class GetSessionQuestionCountUseCase {
  final BillingRepository _billingRepository;

  GetSessionQuestionCountUseCase(this._billingRepository);

  Future<Result<int>> call(String sessionId) async {
    return await _billingRepository.getSessionQuestionCount(sessionId);
  }
}

/// Use case for getting session question status
class GetSessionQuestionStatusUseCase {
  final BillingRepository _billingRepository;

  GetSessionQuestionStatusUseCase(this._billingRepository);

  Future<Result<Map<String, dynamic>>> call() async {
    return await _billingRepository.getSessionQuestionStatus();
  }
}
