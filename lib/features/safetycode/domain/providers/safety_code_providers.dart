import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/providers/api_providers.dart';
import 'package:mindhearth/core/services/encryption_service.dart';
import 'package:mindhearth/core/config/logging_config.dart';
import 'package:mindhearth/core/utils/logger.dart';

// Safety Code State
class SafetyCodeState {
  final bool isVerified;
  final bool isLoading;
  final String? error;
  final String? safetyCode;

  const SafetyCodeState({
    this.isVerified = false,
    this.isLoading = false,
    this.error,
    this.safetyCode,
  });

  SafetyCodeState copyWith({
    bool? isVerified,
    bool? isLoading,
    String? error,
    String? safetyCode,
  }) {
    return SafetyCodeState(
      isVerified: isVerified ?? this.isVerified,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      safetyCode: safetyCode ?? this.safetyCode,
    );
  }
}

// Safety Code Notifier
class SafetyCodeNotifier extends StateNotifier<SafetyCodeState> {
  final Ref ref;

  SafetyCodeNotifier(this.ref) : super(const SafetyCodeState());

  Future<void> verifySafetyCode(String code) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // First try to validate locally using the encryption service
      final isValid = await EncryptionService.validateSafetyCode(code);
      
      if (isValid) {
        state = state.copyWith(
          isVerified: true,
          isLoading: false,
          safetyCode: code,
        );
        return;
      }
      
      // If local validation fails, try the backend API
      final apiService = ref.read(apiServiceProvider);
      
      // Get the passphrase from secure storage
      final passphrase = await EncryptionService.getPassphrase();
      if (passphrase == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'No passphrase found. Please complete onboarding first.',
        );
        return;
      }
      
      if (LoggingConfig.enableSafetyCodeLogs) {
        appLogger.safetyCode('verifying_with_passphrase', null);
      }
      
      final response = await apiService.validateSafetyCode(code, passphrase);
      
      response.when(
        success: (data, message) {
          final isValid = data['valid'] as bool? ?? false;
          
          if (isValid) {
            state = state.copyWith(
              isVerified: true,
              isLoading: false,
              safetyCode: code,
            );
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

  void setSafetyCode(String code) {
    state = state.copyWith(safetyCode: code);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const SafetyCodeState();
  }
}

// Safety Code State Provider
final safetyCodeNotifierProvider = StateNotifierProvider<SafetyCodeNotifier, SafetyCodeState>((ref) {
  return SafetyCodeNotifier(ref);
});

final safetyCodeVerifiedProvider = Provider<SafetyCodeState>((ref) {
  return ref.watch(safetyCodeNotifierProvider);
});
