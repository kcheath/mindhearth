import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/config/debug_config.dart';

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

  SafetyCodeNotifier(this.ref) : super(SafetyCodeState(
    // In debug mode, auto-verify safety code for test user
    isVerified: DebugConfig.isDebugMode,
  ));

  Future<void> verifySafetyCode(String code) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // TODO: Implement actual safety code verification with backend
      // For now, simulate verification
      await Future.delayed(const Duration(seconds: 1));
      
      if (code.length >= 4) {
        state = state.copyWith(
          isVerified: true,
          isLoading: false,
          safetyCode: code,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Safety code must be at least 4 characters long',
        );
      }
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
