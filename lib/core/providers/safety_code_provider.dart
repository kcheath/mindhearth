import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/models/safety_code_state.dart';
import 'package:mindhearth/core/di/service_locator.dart';
import 'package:mindhearth/core/domain/usecases/onboarding_usecases.dart';
import 'package:mindhearth/core/config/logging_config.dart';
import 'package:mindhearth/core/utils/logger.dart';

/// Safety code state notifier
class SafetyCodeNotifier extends StateNotifier<SafetyCodeState> {
  SafetyCodeNotifier() : super(const SafetyCodeState());

  /// Set safety codes
  Future<void> setSafetyCodes(Map<String, String> codes) async {
    state = state.setLoading(true);
    
    try {
      final saveSafetyCodesUseCase = serviceLocator.get<SaveSafetyCodesUseCase>();
      final result = await saveSafetyCodesUseCase(codes);
      
      result.when(
        success: (_) {
          state = state.setSafetyCodes();
          
          if (LoggingConfig.enableSafetyCodeLogs) {
            appLogger.safetyCode('safety_codes_set', {
              'codeCount': codes.length,
            });
          }
        },
        failure: (error) {
          state = state.setError(error.message);
          
          if (LoggingConfig.enableSafetyCodeLogs) {
            appLogger.safetyCode('safety_codes_set_failed', {
              'error': error.message,
            });
          }
        },
      );
    } catch (e) {
      state = state.setError('Failed to set safety codes: ${e.toString()}');
      
      if (LoggingConfig.enableSafetyCodeLogs) {
        appLogger.safetyCode('safety_codes_set_error', {
          'error': e.toString(),
        });
      }
    }
  }

  /// Verify safety code
  Future<void> verifySafetyCode(String code) async {
    state = state.setLoading(true);
    
    try {
      final validateSafetyCodeUseCase = serviceLocator.get<ValidateSafetyCodeUseCase>();
      final result = await validateSafetyCodeUseCase(code);
      
      result.when(
        success: (isValid) {
          if (isValid) {
            state = state.verifySafetyCode(code);
            
            if (LoggingConfig.enableSafetyCodeLogs) {
              appLogger.safetyCode('safety_code_verified', {
                'codeLength': code.length,
              });
            }
          } else {
            state = state.setError('Invalid safety code');
            
            if (LoggingConfig.enableSafetyCodeLogs) {
              appLogger.safetyCode('safety_code_verification_failed', {
                'codeLength': code.length,
              });
            }
          }
        },
        failure: (error) {
          state = state.setError(error.message);
          
          if (LoggingConfig.enableSafetyCodeLogs) {
            appLogger.safetyCode('safety_code_verification_error', {
              'error': error.message,
            });
          }
        },
      );
    } catch (e) {
      state = state.setError('Failed to verify safety code: ${e.toString()}');
      
      if (LoggingConfig.enableSafetyCodeLogs) {
        appLogger.safetyCode('safety_code_verification_error', {
          'error': e.toString(),
        });
      }
    }
  }

  /// Clear safety codes
  Future<void> clearSafetyCodes() async {
    state = state.setLoading(true);
    
    try {
      final clearSafetyCodesUseCase = serviceLocator.get<ClearSafetyCodesUseCase>();
      final result = await clearSafetyCodesUseCase();
      
      result.when(
        success: (_) {
          state = state.clearSafetyCodes();
          
          if (LoggingConfig.enableSafetyCodeLogs) {
            appLogger.safetyCode('safety_codes_cleared', {});
          }
        },
        failure: (error) {
          state = state.setError(error.message);
          
          if (LoggingConfig.enableSafetyCodeLogs) {
            appLogger.safetyCode('safety_codes_clear_failed', {
              'error': error.message,
            });
          }
        },
      );
    } catch (e) {
      state = state.setError('Failed to clear safety codes: ${e.toString()}');
      
      if (LoggingConfig.enableSafetyCodeLogs) {
        appLogger.safetyCode('safety_codes_clear_error', {
          'error': e.toString(),
        });
      }
    }
  }

  /// Load safety codes status
  Future<void> loadSafetyCodesStatus() async {
    state = state.setLoading(true);
    
    try {
      final getSafetyCodesUseCase = serviceLocator.get<GetSafetyCodesUseCase>();
      final result = await getSafetyCodesUseCase();
      
      result.when(
        success: (codes) {
          if (codes != null && codes.isNotEmpty) {
            state = state.setSafetyCodes();
          } else {
            state = state.clearSafetyCodes();
          }
          
          if (LoggingConfig.enableSafetyCodeLogs) {
            appLogger.safetyCode('safety_codes_status_loaded', {
              'hasCodes': codes?.isNotEmpty ?? false,
              'codeCount': codes?.length ?? 0,
            });
          }
        },
        failure: (error) {
          state = state.setError(error.message);
          
          if (LoggingConfig.enableSafetyCodeLogs) {
            appLogger.safetyCode('safety_codes_status_load_failed', {
              'error': error.message,
            });
          }
        },
      );
    } catch (e) {
      state = state.setError('Failed to load safety codes status: ${e.toString()}');
      
      if (LoggingConfig.enableSafetyCodeLogs) {
        appLogger.safetyCode('safety_codes_status_load_error', {
          'error': e.toString(),
        });
      }
    }
  }

  /// Clear error
  void clearError() {
    state = state.clearError();
  }

  /// Set loading state
  void setLoading(bool loading) {
    state = state.setLoading(loading);
  }
}

/// Safety code state provider
final safetyCodeNotifierProvider = StateNotifierProvider<SafetyCodeNotifier, SafetyCodeState>((ref) {
  return SafetyCodeNotifier();
});

/// Safety code state provider (read-only)
final safetyCodeStateProvider = Provider<SafetyCodeState>((ref) {
  return ref.watch(safetyCodeNotifierProvider);
});

/// Safety code verification status provider
final isSafetyCodeVerifiedProvider = Provider<bool>((ref) {
  return ref.watch(safetyCodeStateProvider).isVerified;
});

/// Safety code setup status provider
final hasSafetyCodesProvider = Provider<bool>((ref) {
  return ref.watch(safetyCodeStateProvider).isSetUp;
});
