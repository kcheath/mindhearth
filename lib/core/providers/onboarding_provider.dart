import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/models/onboarding_state.dart';
import 'package:mindhearth/core/di/service_locator.dart';
import 'package:mindhearth/core/domain/usecases/onboarding_usecases.dart';
import 'package:mindhearth/core/domain/usecases/auth_usecases.dart';
import 'package:mindhearth/core/config/logging_config.dart';
import 'package:mindhearth/core/utils/logger.dart';

/// Onboarding state notifier
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState());

  /// Start onboarding flow
  void startOnboarding() {
    state = state.startOnboarding();
    
    if (LoggingConfig.enableOnboardingLogs) {
      appLogger.onboarding('onboarding_started', {
        'step': state.currentStep,
      });
    }
  }

  /// Move to next step
  void nextStep() {
    if (state.canGoNext) {
      state = state.nextStep();
      
      if (LoggingConfig.enableOnboardingLogs) {
        appLogger.onboarding('onboarding_next_step', {
          'step': state.currentStep,
        });
      }
    }
  }

  /// Move to previous step
  void previousStep() {
    if (state.canGoPrevious) {
      state = state.previousStep();
      
      if (LoggingConfig.enableOnboardingLogs) {
        appLogger.onboarding('onboarding_previous_step', {
          'step': state.currentStep,
        });
      }
    }
  }

  /// Jump to specific step
  void goToStep(int step) {
    if (step >= 0 && step < state.totalSteps) {
      state = state.goToStep(step);
      
      if (LoggingConfig.enableOnboardingLogs) {
        appLogger.onboarding('onboarding_go_to_step', {
          'step': step,
        });
      }
    }
  }

  /// Complete onboarding
  Future<void> completeOnboarding() async {
    state = state.setLoading(true);
    
    try {
      final updateOnboardingStatusUseCase = serviceLocator.get<UpdateOnboardingStatusUseCase>();
      final result = await updateOnboardingStatusUseCase(true);
      
      result.when(
        success: (_) {
          state = state.completeOnboarding();
          
          if (LoggingConfig.enableOnboardingLogs) {
            appLogger.onboarding('onboarding_completed', {
              'step': state.currentStep,
            });
          }
        },
        failure: (error) {
          state = state.setError(error.message);
          
          if (LoggingConfig.enableOnboardingLogs) {
            appLogger.onboarding('onboarding_completion_failed', {
              'error': error.message,
            });
          }
        },
      );
    } catch (e) {
      state = state.setError('Failed to complete onboarding: ${e.toString()}');
      
      if (LoggingConfig.enableOnboardingLogs) {
        appLogger.onboarding('onboarding_completion_error', {
          'error': e.toString(),
        });
      }
    }
  }

  /// Reset onboarding
  Future<void> resetOnboarding() async {
    state = state.setLoading(true);
    
    try {
      final clearOnboardingDataUseCase = serviceLocator.get<ClearOnboardingDataUseCase>();
      final result = await clearOnboardingDataUseCase();
      
      result.when(
        success: (_) {
          state = state.resetOnboarding();
          
          if (LoggingConfig.enableOnboardingLogs) {
            appLogger.onboarding('onboarding_reset', {});
          }
        },
        failure: (error) {
          state = state.setError(error.message);
          
          if (LoggingConfig.enableOnboardingLogs) {
            appLogger.onboarding('onboarding_reset_failed', {
              'error': error.message,
            });
          }
        },
      );
    } catch (e) {
      state = state.setError('Failed to reset onboarding: ${e.toString()}');
      
      if (LoggingConfig.enableOnboardingLogs) {
        appLogger.onboarding('onboarding_reset_error', {
          'error': e.toString(),
        });
      }
    }
  }

  /// Load onboarding data
  Future<void> loadOnboardingData() async {
    state = state.setLoading(true);
    
    try {
      final getOnboardingDataUseCase = serviceLocator.get<GetOnboardingDataUseCase>();
      final result = await getOnboardingDataUseCase();
      
      result.when(
        success: (data) {
          if (data != null) {
            state = state.updateOnboardingData(data);
            
            if (LoggingConfig.enableOnboardingLogs) {
              appLogger.onboarding('onboarding_data_loaded', {
                'hasSituationData': data.situationData != null,
                'hasRedactionProfile': data.redactionProfile != null,
                'hasConsentData': data.consentData != null,
              });
            }
          }
        },
        failure: (error) {
          state = state.setError(error.message);
          
          if (LoggingConfig.enableOnboardingLogs) {
            appLogger.onboarding('onboarding_data_load_failed', {
              'error': error.message,
            });
          }
        },
      );
    } catch (e) {
      state = state.setError('Failed to load onboarding data: ${e.toString()}');
      
      if (LoggingConfig.enableOnboardingLogs) {
        appLogger.onboarding('onboarding_data_load_error', {
          'error': e.toString(),
        });
      }
    }
  }

  /// Save situation data
  Future<void> saveSituationData(Map<String, dynamic> situationData) async {
    state = state.setLoading(true);
    
    try {
      final saveSituationDataUseCase = serviceLocator.get<SaveSituationDataUseCase>();
      final result = await saveSituationDataUseCase(situationData);
      
      result.when(
        success: (_) {
          state = state.clearError();
          
          if (LoggingConfig.enableOnboardingLogs) {
            appLogger.onboarding('situation_data_saved', {
              'data': situationData,
            });
          }
        },
        failure: (error) {
          state = state.setError(error.message);
          
          if (LoggingConfig.enableOnboardingLogs) {
            appLogger.onboarding('situation_data_save_failed', {
              'error': error.message,
            });
          }
        },
      );
    } catch (e) {
      state = state.setError('Failed to save situation data: ${e.toString()}');
      
      if (LoggingConfig.enableOnboardingLogs) {
        appLogger.onboarding('situation_data_save_error', {
          'error': e.toString(),
        });
      }
    }
  }

  /// Save redaction profile
  Future<void> saveRedactionProfile(Map<String, dynamic> profileData) async {
    state = state.setLoading(true);
    
    try {
      final saveRedactionProfileUseCase = serviceLocator.get<SaveRedactionProfileUseCase>();
      final result = await saveRedactionProfileUseCase(profileData);
      
      result.when(
        success: (_) {
          state = state.clearError();
          
          if (LoggingConfig.enableOnboardingLogs) {
            appLogger.onboarding('redaction_profile_saved', {
              'data': profileData,
            });
          }
        },
        failure: (error) {
          state = state.setError(error.message);
          
          if (LoggingConfig.enableOnboardingLogs) {
            appLogger.onboarding('redaction_profile_save_failed', {
              'error': error.message,
            });
          }
        },
      );
    } catch (e) {
      state = state.setError('Failed to save redaction profile: ${e.toString()}');
      
      if (LoggingConfig.enableOnboardingLogs) {
        appLogger.onboarding('redaction_profile_save_error', {
          'error': e.toString(),
        });
      }
    }
  }

  /// Save consent form
  Future<void> saveConsentForm(bool accepted) async {
    state = state.setLoading(true);
    
    try {
      final saveConsentFormUseCase = serviceLocator.get<SaveConsentFormUseCase>();
      final result = await saveConsentFormUseCase(accepted);
      
      result.when(
        success: (_) {
          state = state.clearError();
          
          if (LoggingConfig.enableOnboardingLogs) {
            appLogger.onboarding('consent_updated', {
              'accepted': accepted,
            });
          }
        },
        failure: (error) {
          state = state.setError(error.message);
          
          if (LoggingConfig.enableOnboardingLogs) {
            appLogger.onboarding('consent_save_failed', {
              'error': error.message,
            });
          }
        },
      );
    } catch (e) {
      state = state.setError('Failed to save consent form: ${e.toString()}');
      
      if (LoggingConfig.enableOnboardingLogs) {
        appLogger.onboarding('consent_save_error', {
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

/// Onboarding state provider
final onboardingNotifierProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier();
});

/// Onboarding state provider (read-only)
final onboardingStateProvider = Provider<OnboardingState>((ref) {
  return ref.watch(onboardingNotifierProvider);
});

/// Current onboarding step provider
final currentOnboardingStepProvider = Provider<int>((ref) {
  return ref.watch(onboardingStateProvider).currentStep;
});

/// Onboarding completion status provider
final isOnboardingCompletedProvider = Provider<bool>((ref) {
  return ref.watch(onboardingStateProvider).isOnboardingCompleted;
});
