import 'dart:convert';
import 'package:mindhearth/core/domain/entities/app_error.dart';
import 'package:mindhearth/core/domain/entities/result.dart';
import 'package:mindhearth/core/domain/repositories/onboarding_repository.dart';
import 'package:mindhearth/core/models/onboarding_data.dart';
import 'package:mindhearth/core/services/api_service.dart';
import 'package:mindhearth/core/services/encryption_service.dart';
import 'package:mindhearth/core/utils/logger.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final ApiService _apiService;

  OnboardingRepositoryImpl(this._apiService);

  @override
  Future<Result<OnboardingData?>> getOnboardingData() async {
    try {
      final response = await _apiService.getOnboardingData();
      return response.when(
        success: (data, message) => Result.success(OnboardingData.fromJson(data)),
        error: (message, statusCode, errors) {
          appLogger.error('Failed to get onboarding data', null, null);
          return Result.failure(AppErrorFactory.network(
            message: message,
          ));
        },
      );
    } catch (e) {
      appLogger.error('Error getting onboarding data', null, e is StackTrace ? e : null);
      return Result.failure(AppErrorFactory.unknown(
        message: 'Failed to get onboarding data: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Result<void>> saveSituationData(Map<String, dynamic> situationData) async {
    try {
      final response = await _apiService.saveSituationData(situationData);
      return response.when(
        success: (data, message) {
          appLogger.onboarding('situation_data_saved', {'data': situationData});
          return const Result.success(null);
        },
        error: (message, statusCode, errors) {
          appLogger.error('Failed to save situation data', null, null);
          return Result.failure(AppErrorFactory.network(
            message: message,
          ));
        },
      );
    } catch (e) {
      appLogger.error('Error saving situation data', null, e is StackTrace ? e : null);
      return Result.failure(AppErrorFactory.unknown(
        message: 'Failed to save situation data: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Result<void>> saveRedactionProfile(Map<String, dynamic> profileData) async {
    try {
      // Convert profile data to JSON string as expected by backend
      final profileDataString = jsonEncode(profileData);
      
      // Try to create new profile first
      try {
        final response = await _apiService.saveRedactionProfile(profileData);
        return response.when(
          success: (data, message) {
            appLogger.onboarding('redaction_profile_saved', {'data': profileData});
            return const Result.success(null);
          },
          error: (message, statusCode, errors) {
            appLogger.error('Failed to save redaction profile', null, null);
            return Result.failure(AppErrorFactory.network(
              message: message,
            ));
          },
        );
      } catch (e) {
        // If profile already exists (409), try to update it
        if (e.toString().contains('409')) {
          final updateResponse = await _apiService.updateRedactionProfile(profileData);
          return updateResponse.when(
            success: (data, message) {
              appLogger.onboarding('redaction_profile_updated', {'data': profileData});
              return const Result.success(null);
            },
            error: (message, statusCode, errors) {
              appLogger.error('Failed to update redaction profile', null, null);
              return Result.failure(AppErrorFactory.network(
                message: message,
              ));
            },
          );
        }
        rethrow;
      }
    } catch (e) {
      appLogger.error('Error saving redaction profile', null, e is StackTrace ? e : null);
      return Result.failure(AppErrorFactory.unknown(
        message: 'Failed to save redaction profile: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Result<void>> saveConsentForm(bool accepted) async {
    try {
      final response = await _apiService.saveConsentForm(accepted);
      return response.when(
        success: (data, message) {
          appLogger.onboarding('consent_form_saved', {'accepted': accepted});
          return const Result.success(null);
        },
        error: (message, statusCode, errors) {
          appLogger.error('Failed to save consent form', null, null);
          return Result.failure(AppErrorFactory.network(
            message: message,
          ));
        },
      );
    } catch (e) {
      appLogger.error('Error saving consent form', null, e is StackTrace ? e : null);
      return Result.failure(AppErrorFactory.unknown(
        message: 'Failed to save consent form: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Result<void>> clearOnboardingData() async {
    try {
      final response = await _apiService.clearOnboardingData();
      return response.when(
        success: (data, message) {
          appLogger.onboarding('onboarding_data_cleared', {});
          return const Result.success(null);
        },
        error: (message, statusCode, errors) {
          appLogger.error('Failed to clear onboarding data', null, null);
          return Result.failure(AppErrorFactory.network(
            message: message,
          ));
        },
      );
    } catch (e) {
      appLogger.error('Error clearing onboarding data', null, e is StackTrace ? e : null);
      return Result.failure(AppErrorFactory.unknown(
        message: 'Failed to clear onboarding data: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Result<void>> savePassphrase(String passphrase) async {
    try {
      await EncryptionService.storePassphrase(passphrase);
      appLogger.onboarding('passphrase_saved', {});
      return const Result.success(null);
    } catch (e) {
      appLogger.error('Error saving passphrase', null, e is StackTrace ? e : null);
      return Result.failure(AppErrorFactory.encryption(
        message: 'Failed to save passphrase: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Result<void>> saveSafetyCodes(Map<String, String> safetyCodes) async {
    try {
      await EncryptionService.storeSafetyCodes(safetyCodes);
      appLogger.onboarding('safety_codes_saved', {});
      return const Result.success(null);
    } catch (e) {
      appLogger.error('Error saving safety codes', null, e is StackTrace ? e : null);
      return Result.failure(AppErrorFactory.encryption(
        message: 'Failed to save safety codes: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Result<void>> clearSafetyCodes() async {
    try {
      await EncryptionService.clearSafetyCodes();
      appLogger.onboarding('safety_codes_cleared', {});
      return const Result.success(null);
    } catch (e) {
      appLogger.error('Error clearing safety codes', null, e is StackTrace ? e : null);
      return Result.failure(AppErrorFactory.encryption(
        message: 'Failed to clear safety codes: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Result<String?>> getPassphrase() async {
    try {
      final passphrase = await EncryptionService.getPassphrase();
      return Result.success(passphrase);
    } catch (e) {
      appLogger.error('Error getting passphrase', null, e is StackTrace ? e : null);
      return Result.failure(AppErrorFactory.encryption(
        message: 'Failed to get passphrase: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Result<Map<String, String>?>> getSafetyCodes() async {
    try {
      final safetyCodes = await EncryptionService.getSafetyCodes();
      return Result.success(safetyCodes);
    } catch (e) {
      appLogger.error('Error getting safety codes', null, e is StackTrace ? e : null);
      return Result.failure(AppErrorFactory.encryption(
        message: 'Failed to get safety codes: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Result<bool>> validateSafetyCode(String code) async {
    try {
      final isValid = await EncryptionService.validateSafetyCode(code);
      return Result.success(isValid);
    } catch (e) {
      appLogger.error('Error validating safety code', null, e is StackTrace ? e : null);
      return Result.failure(AppErrorFactory.encryption(
        message: 'Failed to validate safety code: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Result<void>> clearPassphrase() async {
    try {
      await EncryptionService.clearPassphrase();
      return const Result.success(null);
    } catch (e) {
      appLogger.error('Error clearing passphrase', null, e is StackTrace ? e : null);
      return Result.failure(AppErrorFactory.encryption(
        message: 'Failed to clear passphrase: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Result<bool>> verifySafetyCode(String code) async {
    try {
      final isValid = await EncryptionService.validateSafetyCode(code);
      return Result.success(isValid);
    } catch (e) {
      appLogger.error('Error verifying safety code', null, e is StackTrace ? e : null);
      return Result.failure(AppErrorFactory.encryption(
        message: 'Failed to verify safety code: ${e.toString()}',
      ));
    }
  }
}
