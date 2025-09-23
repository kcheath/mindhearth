import 'package:mindhearth/core/domain/repositories/onboarding_repository.dart';
import 'package:mindhearth/core/domain/entities/result.dart';
import 'package:mindhearth/core/domain/entities/app_error.dart';

/// Use case for getting stored safety codes
class GetSafetyCodesUseCase {
  final OnboardingRepository _onboardingRepository;

  GetSafetyCodesUseCase(this._onboardingRepository);

  Future<Result<Map<String, String>?>> call() async {
    return await _onboardingRepository.getSafetyCodes();
  }
}

/// Use case for verifying safety code
class VerifySafetyCodeUseCase {
  final OnboardingRepository _onboardingRepository;

  VerifySafetyCodeUseCase(this._onboardingRepository);

  Future<Result<bool>> call(String safetyCode) async {
    return await _onboardingRepository.verifySafetyCode(safetyCode);
  }
}
