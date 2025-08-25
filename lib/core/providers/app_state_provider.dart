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
  final String? selectedSituationId;
  final String? selectedRedactionProfileId;
  final bool? consentAccepted;

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
    this.selectedSituationId,
    this.selectedRedactionProfileId,
    this.consentAccepted,
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
    String? selectedSituationId,
    String? selectedRedactionProfileId,
    bool? consentAccepted,
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
      selectedSituationId: selectedSituationId ?? this.selectedSituationId,
      selectedRedactionProfileId: selectedRedactionProfileId ?? this.selectedRedactionProfileId,
      consentAccepted: consentAccepted ?? this.consentAccepted,
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
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.login(email: email, password: password);
      
              response.when(
          success: (data, message) async {
            if (LoggingConfig.enableAuthLogs) {
              appLogger.auth('Login response received', {'data': data});
            }
          
          // Validate required fields with proper null checks
          final token = data['access_token'] as String?;
          final userId = data['user_id'] as String?;
          final tenantId = data['tenant_id'] as String?;
          
                      // Check for required fields
            if (token == null || userId == null || tenantId == null) {
              state = state.copyWith(
                isLoading: false,
                error: 'Invalid response from server: missing required fields',
              );
              appLogger.error('Login failed - missing required fields in response', {'data': data});
              return;
            }
          
          // Use the email from the login request since it's not in the response
          // The email parameter is available in the method scope
          final isOnboarded = data['is_onboarded'] as bool? ?? false;
          
          final user = User(
            id: userId,
            email: email,
            tenantId: tenantId,
            isOnboarded: isOnboarded,
          );
          
          // Store token in secure storage
          await apiService.setToken(token);
          
                      state = state.copyWith(
              isAuthenticated: true,
              isLoading: false,
              user: user,
              accessToken: token,
              isOnboardingCompleted: isOnboarded,
            );
            
            if (LoggingConfig.enableAuthLogs) {
              appLogger.auth('Login successful', {
                'email': user.email,
                'onboarded': isOnboarded,
              });
            }
        },
                  error: (message, statusCode, errors) {
            state = state.copyWith(
              isLoading: false,
              error: message,
            );
            appLogger.error('Login failed', {
              'message': message,
              'statusCode': statusCode,
            });
          },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
    }
  }

  Future<void> logout() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.clearToken();
      
      // Reset all state
      state = const AppState();
      
      // Re-initialize state from storage
      await _initializeState();
      
      if (LoggingConfig.enableStateLogs) {
        appLogger.stateChange('AppState', 'logout_completed', null);
      }
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
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.updateOnboardedStatus(true);
      
      response.when(
        success: (data, message) {
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
        error: (message, statusCode, errors) {
                      appLogger.error('Failed to update onboarding status', {'message': message});
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
      await EncryptionService.storeSafetyCodes(safetyCodes);
      state = state.copyWith(hasSafetyCodes: true);
      if (LoggingConfig.enableStateLogs) {
        appLogger.stateChange('AppState', 'safety_codes_stored', null);
      }
    } catch (e) {
      appLogger.error('Error storing safety codes', {'error': e.toString()});
    }
  }

  Future<void> clearSafetyCodes() async {
    try {
      // Clear from backend
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.clearSafetyCodes();
      
      response.when(
        success: (data, message) {
          if (LoggingConfig.enableStateLogs) {
        appLogger.stateChange('AppState', 'safety_codes_cleared_backend', null);
      }
        },
        error: (message, statusCode, errors) {
                      appLogger.warning('Failed to clear safety codes from backend', {'message': message});
        },
      );
      
      // Clear from local storage
      await EncryptionService.clearSafetyCodes();
      
      // Update state
      state = state.copyWith(
        hasSafetyCodes: false,
        isSafetyCodeVerified: false,
        currentSafetyCode: null,
      );
      
      if (LoggingConfig.enableStateLogs) {
        appLogger.stateChange('AppState', 'safety_codes_cleared_storage', null);
      }
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
      
      final apiService = ref.read(apiServiceProvider);
      
      // 1. Update backend onboarding status
      final onboardingResponse = await apiService.updateOnboardedStatus(false);
      onboardingResponse.when(
        success: (data, message) {
          if (LoggingConfig.enableOnboardingLogs) {
            appLogger.onboarding('backend_status_reset', null);
          }
        },
        error: (message, statusCode, errors) {
          appLogger.warning('Failed to reset backend onboarding status', {'message': message});
        },
      );
      
      // 2. Clear safety codes from backend
      final safetyCodesResponse = await apiService.clearSafetyCodes();
      safetyCodesResponse.when(
        success: (data, message) {
          if (LoggingConfig.enableOnboardingLogs) {
            appLogger.onboarding('backend_safety_codes_cleared', null);
          }
        },
        error: (message, statusCode, errors) {
          appLogger.warning('Failed to clear backend safety codes', {'message': message});
        },
      );
      
      // 3. Clear onboarding data from backend
      final onboardingDataResponse = await apiService.clearOnboardingData();
      onboardingDataResponse.when(
        success: (data, message) {
          if (LoggingConfig.enableOnboardingLogs) {
            appLogger.onboarding('backend_onboarding_data_cleared', null);
          }
        },
        error: (message, statusCode, errors) {
          appLogger.warning('Failed to clear backend onboarding data', {'message': message});
        },
      );
      
      // 4. Clear all local stored data
      await EncryptionService.clearPassphrase();
      await EncryptionService.clearSafetyCodes();
      
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
        selectedSituationId: null,
        selectedRedactionProfileId: null,
        consentAccepted: null,
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
        await EncryptionService.storePassphrase(passphrase);
        state = state.copyWith(hasPassphrase: true);
        if (LoggingConfig.enableStateLogs) {
          appLogger.stateChange('AppState', 'passphrase_stored', null);
        }
      } catch (e) {
        appLogger.error('Error storing passphrase', {'error': e.toString()});
      }
    }

    Future<void> loadOnboardingData() async {
      try {
        final apiService = ref.read(apiServiceProvider);
        final response = await apiService.getOnboardingData();
        
        response.when(
          success: (data, message) {
            final onboardingData = OnboardingData.fromJson(data);
            state = state.copyWith(onboardingData: onboardingData);
            if (LoggingConfig.enableOnboardingLogs) {
              appLogger.onboarding('data_loaded', null);
            }
          },
          error: (message, statusCode, errors) {
            appLogger.error('Failed to load onboarding data', {'message': message, 'statusCode': statusCode});
            // Don't use mock data - let the UI handle the error state
          },
        );
      } catch (e) {
        appLogger.error('Error loading onboarding data', {'error': e.toString()});
        // Don't use mock data - let the UI handle the error state
      }
    }

    Future<void> setCurrentSituation(String situationId) async {
      try {
        final apiService = ref.read(apiServiceProvider);
        final response = await apiService.saveCurrentSituation(situationId);
        
        response.when(
          success: (data, message) {
            state = state.copyWith(selectedSituationId: situationId);
            if (LoggingConfig.enableOnboardingLogs) {
              appLogger.onboarding('situation_selected', {'situationId': situationId});
            }
          },
          error: (message, statusCode, errors) {
            appLogger.error('Failed to save current situation', {'message': message});
          },
        );
      } catch (e) {
        appLogger.error('Error saving current situation', {'error': e.toString()});
      }
    }

    Future<void> setRedactionProfile(String profileId) async {
      try {
        final apiService = ref.read(apiServiceProvider);
        final response = await apiService.saveRedactionProfile(profileId);
        
        response.when(
          success: (data, message) {
            state = state.copyWith(selectedRedactionProfileId: profileId);
            if (LoggingConfig.enableOnboardingLogs) {
              appLogger.onboarding('redaction_profile_selected', {'profileId': profileId});
            }
          },
          error: (message, statusCode, errors) {
            appLogger.error('Failed to save redaction profile', {'message': message});
          },
        );
      } catch (e) {
        appLogger.error('Error saving redaction profile', {'error': e.toString()});
      }
    }

    Future<void> setConsentForm(bool accepted) async {
      try {
        final apiService = ref.read(apiServiceProvider);
        final response = await apiService.saveConsentForm(accepted);
        
        response.when(
          success: (data, message) {
            state = state.copyWith(consentAccepted: accepted);
            if (LoggingConfig.enableOnboardingLogs) {
              appLogger.onboarding('consent_updated', {'accepted': accepted});
            }
          },
          error: (message, statusCode, errors) {
            appLogger.error('Failed to save consent form', {'message': message});
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
