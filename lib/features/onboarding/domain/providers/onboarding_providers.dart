import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/app/providers/providers.dart';
import 'package:mindhearth/core/providers/api_providers.dart';
import 'package:mindhearth/core/services/encryption_service.dart';


// Onboarding State
class OnboardingState {
  final bool isOnboarding;
  final int currentStep;
  final bool isCompleted;
  final String? error;
  final String? passphrase;
  final Map<String, String>? safetyCodes;

  const OnboardingState({
    this.isOnboarding = false,
    this.currentStep = 0,
    this.isCompleted = false,
    this.error,
    this.passphrase,
    this.safetyCodes,
  });

  OnboardingState copyWith({
    bool? isOnboarding,
    int? currentStep,
    bool? isCompleted,
    String? error,
    String? passphrase,
    Map<String, String>? safetyCodes,
  }) {
    return OnboardingState(
      isOnboarding: isOnboarding ?? this.isOnboarding,
      currentStep: currentStep ?? this.currentStep,
      isCompleted: isCompleted ?? this.isCompleted,
      error: error ?? this.error,
      passphrase: passphrase ?? this.passphrase,
      safetyCodes: safetyCodes ?? this.safetyCodes,
    );
  }
}

// Onboarding Notifier
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final Ref ref;

  OnboardingNotifier(this.ref) : super(const OnboardingState());

  void startOnboarding() {
    state = state.copyWith(isOnboarding: true, currentStep: 0);
  }

  void nextStep() {
    if (state.currentStep < 4) { // 5 steps (0-4): Welcome, Privacy, Passphrase, Safety Code, Complete
      state = state.copyWith(currentStep: state.currentStep + 1);
    } else {
      completeOnboarding();
    }
  }

  void setPassphrase(String passphrase) {
    state = state.copyWith(passphrase: passphrase);
  }

  void setSafetyCodes(Map<String, String> safetyCodes) {
    state = state.copyWith(safetyCodes: safetyCodes);
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  Future<void> completeOnboarding() async {
    try {
      // Store the passphrase securely if we have one
      if (state.passphrase != null) {
        await EncryptionService.storePassphrase(state.passphrase!);
        print('🐛 Passphrase stored securely');
      }
      
      // Store safety codes if user entered them
      if (state.safetyCodes != null && state.safetyCodes!.isNotEmpty) {
        await EncryptionService.storeSafetyCodes(state.safetyCodes!);
        print('🐛 Safety codes stored securely');
        
        // Safety codes are now managed by the unified app state
        print('🐛 Debug: Safety codes stored successfully');
      }
      
      // Update onboarding status in auth notifier
      final authNotifier = ref.read(authNotifierProvider.notifier);
      await authNotifier.updateOnboardingStatus(true);
      
      state = state.copyWith(
        isOnboarding: false,
        isCompleted: true,
        currentStep: 0,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to complete onboarding: $e');
    }
  }

  Future<void> _saveSafetyCodesToBackend(Map<String, String> safetyCodes) async {
    try {
      // Save safety codes to backend
      final apiService = ref.read(apiServiceProvider);
      final passphrase = state.passphrase ?? '';
      await apiService.saveSafetyCodes(safetyCodes, passphrase);
      
      print('🐛 Safety codes saved to backend successfully');
    } catch (e) {
      print('🐛 Error saving safety codes to backend: $e');
      // Don't fail onboarding if backend save fails
    }
  }

  void setError(String error) {
    state = state.copyWith(error: error);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const OnboardingState();
  }
}

// Onboarding State Provider
final onboardingNotifierProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier(ref);
});

final onboardingStateProvider = Provider<OnboardingState>((ref) {
  return ref.watch(onboardingNotifierProvider);
});
