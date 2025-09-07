import 'package:mindhearth/core/domain/entities/result.dart';
import 'package:mindhearth/core/models/onboarding_data.dart';

abstract class OnboardingRepository {
  Future<Result<OnboardingData?>> getOnboardingData();
  Future<Result<void>> saveSituationData(Map<String, dynamic> situationData);
  Future<Result<void>> saveRedactionProfile(Map<String, dynamic> profileData);
  Future<Result<void>> saveConsentForm(bool accepted);
  Future<Result<void>> clearOnboardingData();
  Future<Result<void>> savePassphrase(String passphrase);
  Future<Result<void>> saveSafetyCodes(Map<String, String> safetyCodes);
  Future<Result<void>> clearSafetyCodes();
  Future<Result<String?>> getPassphrase();
  Future<Result<Map<String, String>?>> getSafetyCodes();
  Future<Result<bool>> validateSafetyCode(String code);
  Future<Result<void>> clearPassphrase();
}
