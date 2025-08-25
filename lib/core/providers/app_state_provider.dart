import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/services/encryption_service.dart';
import 'package:mindhearth/core/services/api_service.dart';
import 'package:mindhearth/core/models/auth_state.dart';
import 'package:mindhearth/core/models/user.dart';
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
  void startOnboarding() {
    state = state.copyWith(isOnboarding: true, currentStep: 0);
  }

  void nextStep() {
    if (state.currentStep < 4) {
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
      
      // Update backend onboarding status
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.updateOnboardedStatus(false);
      
      response.when(
        success: (data, message) {
          if (LoggingConfig.enableOnboardingLogs) {
        appLogger.onboarding('backend_status_reset', null);
      }
        },
        error: (message, statusCode, errors) {
                      appLogger.warning('Failed to reset backend onboarding status', {'message': message});
        },
      );
      
      // Clear all stored data
      await EncryptionService.clearPassphrase();
      await clearSafetyCodes();
      
      // Reset all state
      final updatedUser = state.user?.copyWith(isOnboarded: false);
      state = state.copyWith(
        isOnboarding: false,
        isOnboardingCompleted: false,
        currentStep: 0,
        isSafetyCodeVerified: false,
        currentSafetyCode: null,
        user: updatedUser,
      );
      
      // Re-initialize state from storage
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
}

// Provider
final appStateNotifierProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier(ref);
});

final appStateProvider = Provider<AppState>((ref) {
  return ref.watch(appStateNotifierProvider);
});
