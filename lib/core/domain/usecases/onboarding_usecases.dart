import 'package:mindhearth/core/domain/entities/app_error.dart';
import 'package:mindhearth/core/domain/entities/result.dart';
import 'package:mindhearth/core/domain/repositories/onboarding_repository.dart';
import 'package:mindhearth/core/domain/validators/validators.dart';
import 'package:mindhearth/core/models/onboarding_data.dart';

/// Use case for getting onboarding data
class GetOnboardingDataUseCase {
  final OnboardingRepository _repository;

  GetOnboardingDataUseCase(this._repository);

  Future<Result<OnboardingData?>> call() async {
    return await _repository.getOnboardingData();
  }
}

/// Use case for saving situation data
class SaveSituationDataUseCase {
  final OnboardingRepository _repository;

  SaveSituationDataUseCase(this._repository);

  Future<Result<void>> call(Map<String, dynamic> situationData) async {
    if (situationData.isEmpty) {
      return Result.failure(AppErrorFactory.validation(
        message: 'Situation data cannot be empty',
      ));
    }
    return await _repository.saveSituationData(situationData);
  }
}

/// Use case for saving redaction profile
class SaveRedactionProfileUseCase {
  final OnboardingRepository _repository;

  SaveRedactionProfileUseCase(this._repository);

  Future<Result<void>> call(Map<String, dynamic> profileData) async {
    if (profileData.isEmpty) {
      return Result.failure(AppErrorFactory.validation(
        message: 'Profile data cannot be empty',
      ));
    }
    return await _repository.saveRedactionProfile(profileData);
  }
}

/// Use case for saving consent form
class SaveConsentFormUseCase {
  final OnboardingRepository _repository;

  SaveConsentFormUseCase(this._repository);

  Future<Result<void>> call(bool accepted) async {
    return await _repository.saveConsentForm(accepted);
  }
}

/// Use case for clearing onboarding data
class ClearOnboardingDataUseCase {
  final OnboardingRepository _repository;

  ClearOnboardingDataUseCase(this._repository);

  Future<Result<void>> call() async {
    return await _repository.clearOnboardingData();
  }
}

/// Use case for saving passphrase
class SavePassphraseUseCase {
  final OnboardingRepository _repository;
  final PassphraseValidator _passphraseValidator;

  SavePassphraseUseCase({
    required OnboardingRepository repository,
    PassphraseValidator? passphraseValidator,
  })  : _repository = repository,
        _passphraseValidator = passphraseValidator ?? PassphraseValidator();

  Future<Result<void>> call(String passphrase) async {
    // Validate passphrase
    final validation = _passphraseValidator.validate(passphrase);
    if (!validation.isValid) {
      return Result.failure(ValidationUtils.validationResultToError(validation)!);
    }

    return await _repository.savePassphrase(passphrase);
  }
}

/// Use case for saving safety codes
class SaveSafetyCodesUseCase {
  final OnboardingRepository _repository;
  final SafetyCodeValidator _safetyCodeValidator;

  SaveSafetyCodesUseCase({
    required OnboardingRepository repository,
    SafetyCodeValidator? safetyCodeValidator,
  })  : _repository = repository,
        _safetyCodeValidator = safetyCodeValidator ?? SafetyCodeValidator();

  Future<Result<void>> call(Map<String, String> safetyCodes) async {
    if (safetyCodes.isEmpty) {
      return Result.failure(AppErrorFactory.validation(
        message: 'Safety codes cannot be empty',
      ));
    }
    
    // Validate that all required codes are present and valid
    final requiredCodes = ['journal', 'safe', 'wipe'];
    for (final code in requiredCodes) {
      if (!safetyCodes.containsKey(code) || safetyCodes[code]!.isEmpty) {
        return Result.failure(AppErrorFactory.validation(
          message: 'Missing required safety code: $code',
        ));
      }
      
      // Validate each code format
      final validation = _safetyCodeValidator.validate(safetyCodes[code]!);
      if (!validation.isValid) {
        return Result.failure(ValidationUtils.validationResultToError(validation)!);
      }
    }
    
    return await _repository.saveSafetyCodes(safetyCodes);
  }
}

/// Use case for clearing safety codes
class ClearSafetyCodesUseCase {
  final OnboardingRepository _repository;

  ClearSafetyCodesUseCase(this._repository);

  Future<Result<void>> call() async {
    return await _repository.clearSafetyCodes();
  }
}

/// Use case for getting passphrase
class GetPassphraseUseCase {
  final OnboardingRepository _repository;

  GetPassphraseUseCase(this._repository);

  Future<Result<String?>> call() async {
    return await _repository.getPassphrase();
  }
}

/// Use case for getting safety codes
class GetSafetyCodesUseCase {
  final OnboardingRepository _repository;

  GetSafetyCodesUseCase(this._repository);

  Future<Result<Map<String, String>?>> call() async {
    return await _repository.getSafetyCodes();
  }
}

/// Use case for validating safety code
class ValidateSafetyCodeUseCase {
  final OnboardingRepository _repository;
  final SafetyCodeValidator _safetyCodeValidator;

  ValidateSafetyCodeUseCase({
    required OnboardingRepository repository,
    SafetyCodeValidator? safetyCodeValidator,
  })  : _repository = repository,
        _safetyCodeValidator = safetyCodeValidator ?? SafetyCodeValidator();

  Future<Result<bool>> call(String code) async {
    // Validate code format first
    final validation = _safetyCodeValidator.validate(code);
    if (!validation.isValid) {
      return Result.failure(ValidationUtils.validationResultToError(validation)!);
    }

    // Then validate against stored codes
    return await _repository.validateSafetyCode(code);
  }
}

/// Use case for clearing passphrase
class ClearPassphraseUseCase {
  final OnboardingRepository _repository;

  ClearPassphraseUseCase(this._repository);

  Future<Result<void>> call() async {
    return await _repository.clearPassphrase();
  }
}
