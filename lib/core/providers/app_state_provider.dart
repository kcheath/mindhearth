import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/services/encryption_service.dart';
import 'package:mindhearth/core/services/api_service.dart';
import 'package:mindhearth/core/models/auth_state.dart';
import 'package:mindhearth/core/models/user.dart';
import 'package:mindhearth/core/models/onboarding_data.dart';
import 'package:mindhearth/core/config/debug_config.dart';
import 'package:mindhearth/core/config/logging_config.dart';
import 'package:mindhearth/core/providers/api_providers.dart';
import 'package:mindhearth/core/utils/logger.dart';
import 'package:mindhearth/core/di/service_locator.dart';
import 'package:mindhearth/core/domain/usecases/auth_usecases.dart';
import 'package:mindhearth/core/domain/usecases/onboarding_usecases.dart';
import 'package:mindhearth/core/domain/validators/validators.dart';

// Unified App State
class AppState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final User? user;
  final String? accessToken;
  
  // Onboarding state
  final bool isOnboarding;
  final int currentStep;
  final bool isOnboardingCompleted;
  
  // Safety code state
  final bool hasSafetyCodes;
  final bool isSafetyCodeVerified;
  final String? currentSafetyCode;
  
  // Passphrase state
  final bool hasPassphrase;
  
  // Additional onboarding data
  final OnboardingData? onboardingData;

  const AppState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.user,
    this.accessToken,
    this.isOnboarding = false,
    this.currentStep = 0,
    this.isOnboardingCompleted = false,
    this.hasSafetyCodes = false,
    this.isSafetyCodeVerified = false,
    this.currentSafetyCode,
    this.hasPassphrase = false,
    this.onboardingData,
  });

  AppState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    User? user,
    String? accessToken,
    bool? isOnboarding,
    int? currentStep,
    bool? isOnboardingCompleted,
    bool? hasSafetyCodes,
    bool? isSafetyCodeVerified,
    String? currentSafetyCode,
    bool? hasPassphrase,
    OnboardingData? onboardingData,
  }) {
    return AppState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      isOnboarding: isOnboarding ?? this.isOnboarding,
      currentStep: currentStep ?? this.currentStep,
      isOnboardingCompleted: isOnboardingCompleted ?? this.isOnboardingCompleted,
      hasSafetyCodes: hasSafetyCodes ?? this.hasSafetyCodes,
      isSafetyCodeVerified: isSafetyCodeVerified ?? this.isSafetyCodeVerified,
      currentSafetyCode: currentSafetyCode ?? this.currentSafetyCode,
      hasPassphrase: hasPassphrase ?? this.hasPassphrase,
      onboardingData: onboardingData ?? this.onboardingData,
    );
  }
}

// Unified App State Notifier
class AppStateNotifier extends StateNotifier<AppState> {
  final Ref ref;

  AppStateNotifier(this.ref) : super(const AppState()) {
    // Initialize state from storage
    _initializeState();
  }

  Future<void> _initializeState() async {
    try {
      // Check for stored passphrase
      final passphrase = await EncryptionService.getPassphrase();
      final hasPassphrase = passphrase != null && passphrase.isNotEmpty;
      
      // Check for stored safety codes
      final safetyCodes = await EncryptionService.getSafetyCodes();
      final hasSafetyCodes = safetyCodes != null && safetyCodes.isNotEmpty;
      
      state = state.copyWith(
        hasPassphrase: hasPassphrase,
        hasSafetyCodes: hasSafetyCodes,
      );
      
      if (LoggingConfig.enableStateLogs) {
        appLogger.stateChange('AppState', 'initialized', {
          'hasPassphrase': hasPassphrase,
          'hasSafetyCodes': hasSafetyCodes,
        });
      }
    } catch (e) {
      appLogger.error('Error initializing app state', null, e is StackTrace ? e : null);
    }
  }

  // Authentication methods
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
                    final loginUseCase = serviceLocator.get<LoginUseCase>();
      final result = await loginUseCase(email, password);
      
      result.when(
        success: (user) {
          state = state.copyWith(
            isAuthenticated: true,
            isLoading: false,
            user: user,
            accessToken: null,
            isOnboardingCompleted: user.isOnboarded,
          );
          
          if (LoggingConfig.enableAuthLogs) {
            appLogger.auth('Login successful', {
              'email': user.email,
              'onboarded': user.isOnboarded,
            });
          }
        },
        failure: (error) {
          state = state.copyWith(
            isLoading: false,
            error: error.message,
          );
          appLogger.error('Login failed', {
            'error': error.message,
            'type': error.runtimeType.toString(),
          });
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
      appLogger.error('Login unexpected error', null, e is StackTrace ? e : null);
    }
  }

  Future<void> logout() async {
    try {
                    final logoutUseCase = serviceLocator.get<LogoutUseCase>();
      final result = await logoutUseCase();
      
      result.when(
        success: (_) {
          // Reset all state
          state = const AppState();
          
          // Re-initialize state from storage
          _initializeState();
          
          if (LoggingConfig.enableStateLogs) {
            appLogger.stateChange('AppState', 'logout_completed', null);
          }
        },
        failure: (error) {
          appLogger.error('Logout failed', {
            'error': error.message,
            'type': error.runtimeType.toString(),
          });
        },
      );
    } catch (e) {
      appLogger.error('Error during logout', {'error': e.toString()});
    }
  }

  // Onboarding methods
  void startOnboarding() async {
    state = state.copyWith(isOnboarding: true, currentStep: 0);
    // Load onboarding data when starting
    await loadOnboardingData();
  }

  void nextStep() {
    if (state.currentStep < 7) { // 8 steps (0-7): Welcome, Privacy, Passphrase, Safety Code, Current Situation, Redaction Profile, Consent, Complete
      state = state.copyWith(currentStep: state.currentStep + 1);
    } else {
      completeOnboarding();
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  Future<void> completeOnboarding() async {
    try {
      // Store passphrase if we have one
      if (state.hasPassphrase) {
        // Passphrase should already be stored during onboarding
        if (LoggingConfig.enableStateLogs) {
        appLogger.stateChange('AppState', 'passphrase_already_stored', null);
      }
      }
      
      // Update backend onboarding status
      final updateOnboardingStatusUseCase = serviceLocator.get<UpdateOnboardingStatusUseCase>();
      final result = await updateOnboardingStatusUseCase(true);
      
      result.when(
        success: (_) {
          final updatedUser = state.user?.copyWith(isOnboarded: true);
          state = state.copyWith(
            isOnboarding: false,
            isOnboardingCompleted: true,
            currentStep: 0,
            user: updatedUser,
          );
          if (LoggingConfig.enableOnboardingLogs) {
        appLogger.onboarding('completed_successfully', null);
      }
        },
        failure: (error) {
          appLogger.error('Failed to update onboarding status', {
            'error': error.message,
            'type': error.runtimeType.toString(),
          });
          // Still update local state for UI consistency
          final updatedUser = state.user?.copyWith(isOnboarded: true);
          state = state.copyWith(
            isOnboarding: false,
            isOnboardingCompleted: true,
            currentStep: 0,
            user: updatedUser,
          );
        },
      );
    } catch (e) {
      appLogger.error('Error completing onboarding', {'error': e.toString()});
    }
  }

  // Safety code methods
  Future<void> setSafetyCodes(Map<String, String> safetyCodes) async {
    try {
      final saveSafetyCodesUseCase = serviceLocator.get<SaveSafetyCodesUseCase>();
              final result = await saveSafetyCodesUseCase(safetyCodes);
      
      result.when(
        success: (_) {
          state = state.copyWith(hasSafetyCodes: true);
          if (LoggingConfig.enableStateLogs) {
            appLogger.stateChange('AppState', 'safety_codes_stored', null);
          }
        },
        failure: (error) {
          appLogger.error('Error storing safety codes', {
            'error': error.message,
            'type': error.runtimeType.toString(),
          });
        },
      );
    } catch (e) {
      appLogger.error('Error storing safety codes', {'error': e.toString()});
    }
  }

  Future<void> clearSafetyCodes() async {
    try {
      final clearSafetyCodesUseCase = serviceLocator.get<ClearSafetyCodesUseCase>();
              final result = await clearSafetyCodesUseCase();
      
      result.when(
        success: (_) {
          // Update state
          state = state.copyWith(
            hasSafetyCodes: false,
            isSafetyCodeVerified: false,
            currentSafetyCode: null,
          );
          
          if (LoggingConfig.enableStateLogs) {
            appLogger.stateChange('AppState', 'safety_codes_cleared', null);
          }
        },
        failure: (error) {
          appLogger.error('Error clearing safety codes', {
            'error': error.message,
            'type': error.runtimeType.toString(),
          });
        },
      );
    } catch (e) {
      appLogger.error('Error clearing safety codes', {'error': e.toString()});
    }
  }

  Future<void> verifySafetyCode(String code) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Try local validation first
      final isValid = await EncryptionService.validateSafetyCode(code);
      
      if (isValid) {
        state = state.copyWith(
          isSafetyCodeVerified: true,
          isLoading: false,
          currentSafetyCode: code,
        );
        if (LoggingConfig.enableSafetyCodeLogs) {
        appLogger.safetyCode('verified_locally', null);
      }
        return;
      }
      
      // Try backend validation
      final apiService = ref.read(apiServiceProvider);
      final passphrase = await EncryptionService.getPassphrase();
      
      if (passphrase == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'No passphrase found. Please complete onboarding first.',
        );
        return;
      }
      
      final response = await apiService.validateSafetyCode(code, passphrase);
      
      response.when(
        success: (data, message) {
          final isValid = data['valid'] as bool? ?? false;
          
          if (isValid) {
            state = state.copyWith(
              isSafetyCodeVerified: true,
              isLoading: false,
              currentSafetyCode: code,
            );
            if (LoggingConfig.enableSafetyCodeLogs) {
        appLogger.safetyCode('verified_via_backend', null);
      }
          } else {
            state = state.copyWith(
              isLoading: false,
              error: 'Invalid safety code. Please try again.',
            );
          }
        },
        error: (message, statusCode, errors) {
          state = state.copyWith(
            isLoading: false,
            error: message,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to verify safety code',
      );
    }
  }

  void resetSafetyCodeVerification() {
    state = state.copyWith(
      isSafetyCodeVerified: false,
      currentSafetyCode: null,
    );
          if (LoggingConfig.enableSafetyCodeLogs) {
        appLogger.safetyCode('verification_reset', null);
      }
  }

  // Reset methods
  Future<void> resetOnboarding() async {
    try {
      if (LoggingConfig.enableOnboardingLogs) {
        appLogger.onboarding('starting_complete_reset', null);
      }
      
      // 1. Update backend onboarding status
      final updateOnboardingStatusUseCase = serviceLocator.get<UpdateOnboardingStatusUseCase>();
              final onboardingResult = await updateOnboardingStatusUseCase(false);
      onboardingResult.when(
        success: (_) {
          if (LoggingConfig.enableOnboardingLogs) {
            appLogger.onboarding('backend_status_reset', null);
          }
        },
        failure: (error) {
          appLogger.warning('Failed to reset backend onboarding status', {
            'error': error.message,
            'type': error.runtimeType.toString(),
          });
        },
      );
      
      // 2. Clear safety codes from backend
      final clearSafetyCodesUseCase = serviceLocator.get<ClearSafetyCodesUseCase>();
              final safetyCodesResult = await clearSafetyCodesUseCase();
      safetyCodesResult.when(
        success: (_) {
          if (LoggingConfig.enableOnboardingLogs) {
            appLogger.onboarding('backend_safety_codes_cleared', null);
          }
        },
        failure: (error) {
          appLogger.warning('Failed to clear backend safety codes', {
            'error': error.message,
            'type': error.runtimeType.toString(),
          });
        },
      );
      
      // 3. Clear onboarding data from backend
      final clearOnboardingDataUseCase = serviceLocator.get<ClearOnboardingDataUseCase>();
              final onboardingDataResult = await clearOnboardingDataUseCase();
      onboardingDataResult.when(
        success: (_) {
          if (LoggingConfig.enableOnboardingLogs) {
            appLogger.onboarding('backend_onboarding_data_cleared', null);
          }
        },
        failure: (error) {
          appLogger.warning('Failed to clear backend onboarding data', {
            'error': error.message,
            'type': error.runtimeType.toString(),
          });
        },
      );
      
      // 4. Clear all local stored data
      final clearPassphraseUseCase = serviceLocator.get<ClearPassphraseUseCase>();
              await clearPassphraseUseCase();
      
      // 5. Reset all onboarding-related state
      final updatedUser = state.user?.copyWith(isOnboarded: false);
      state = state.copyWith(
        isOnboarding: false,
        isOnboardingCompleted: false,
        currentStep: 0,
        isSafetyCodeVerified: false,
        currentSafetyCode: null,
        hasSafetyCodes: false,
        hasPassphrase: false,
        // Clear all new onboarding data
        onboardingData: null,
        user: updatedUser,
      );
      
      // 6. Re-initialize state from storage
      await _initializeState();
      
      if (LoggingConfig.enableOnboardingLogs) {
        appLogger.onboarding('complete_reset_finished', null);
      }
    } catch (e) {
      appLogger.error('Error during onboarding reset', {'error': e.toString()});
    }
  }

  // Utility methods
  void clearError() {
    state = state.copyWith(error: null);
  }

      void setPassphrase(String passphrase) async {
      try {
        final savePassphraseUseCase = serviceLocator.get<SavePassphraseUseCase>();
        final result = await savePassphraseUseCase(passphrase);
        
        result.when(
          success: (_) {
            state = state.copyWith(hasPassphrase: true);
            if (LoggingConfig.enableStateLogs) {
              appLogger.stateChange('AppState', 'passphrase_stored', null);
            }
          },
          failure: (error) {
            appLogger.error('Error storing passphrase', {
              'error': error.message,
              'type': error.runtimeType.toString(),
            });
          },
        );
      } catch (e) {
        appLogger.error('Error storing passphrase', {'error': e.toString()});
      }
    }

    Future<void> loadOnboardingData() async {
      try {
        final getOnboardingDataUseCase = serviceLocator.get<GetOnboardingDataUseCase>();
        final result = await getOnboardingDataUseCase();
        
        result.when(
          success: (onboardingData) {
            state = state.copyWith(onboardingData: onboardingData);
            if (LoggingConfig.enableOnboardingLogs) {
              appLogger.onboarding('data_loaded', null);
            }
          },
          failure: (error) {
            appLogger.error('Failed to load onboarding data', {
              'error': error.message,
              'type': error.runtimeType.toString(),
            });
            // Don't use mock data - let the UI handle the error state
          },
        );
      } catch (e) {
        appLogger.error('Error loading onboarding data', {'error': e.toString()});
        // Don't use mock data - let the UI handle the error state
      }
    }

    Future<void> setSituationData(Map<String, dynamic> situationData) async {
      try {
        final saveSituationDataUseCase = serviceLocator.get<SaveSituationDataUseCase>();
        final result = await saveSituationDataUseCase(situationData);
        
        result.when(
          success: (_) {
            // Data is saved to backend, update local state if needed
            if (LoggingConfig.enableOnboardingLogs) {
              appLogger.onboarding('situation_data_saved', {'data': situationData});
            }
          },
          failure: (error) {
            appLogger.error('Failed to save situation data', {
              'error': error.message,
              'type': error.runtimeType.toString(),
            });
          },
        );
      } catch (e) {
        appLogger.error('Error saving situation data', {'error': e.toString()});
      }
    }

    Future<void> setRedactionProfile(Map<String, dynamic> profileData) async {
      try {
        final saveRedactionProfileUseCase = serviceLocator.get<SaveRedactionProfileUseCase>();
        final result = await saveRedactionProfileUseCase(profileData);
        
        result.when(
          success: (_) {
            // Data is saved to backend, update local state if needed
            if (LoggingConfig.enableOnboardingLogs) {
              appLogger.onboarding('redaction_profile_saved', {'data': profileData});
            }
          },
          failure: (error) {
            appLogger.error('Failed to save redaction profile', {
              'error': error.message,
              'type': error.runtimeType.toString(),
            });
          },
        );
      } catch (e) {
        appLogger.error('Error saving redaction profile', {'error': e.toString()});
      }
    }

    Future<void> setConsentForm(bool accepted) async {
      try {
        final saveConsentFormUseCase = serviceLocator.get<SaveConsentFormUseCase>();
        final result = await saveConsentFormUseCase(accepted);
        
        result.when(
          success: (_) {
            // Data is saved to backend, update local state if needed
            if (LoggingConfig.enableOnboardingLogs) {
              appLogger.onboarding('consent_updated', {'accepted': accepted});
            }
          },
          failure: (error) {
            appLogger.error('Failed to save consent form', {
              'error': error.message,
              'type': error.runtimeType.toString(),
            });
          },
        );
      } catch (e) {
        appLogger.error('Error saving consent form', {'error': e.toString()});
      }
    }
}

// Provider
final appStateNotifierProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier(ref);
});

final appStateProvider = Provider<AppState>((ref) {
  return ref.watch(appStateNotifierProvider);
});
