import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/services/api_service.dart';
import 'package:mindhearth/core/services/mock_api_service.dart';
import 'package:mindhearth/core/models/auth_state.dart';
import 'package:mindhearth/core/models/user.dart';
import 'package:mindhearth/features/onboarding/domain/providers/onboarding_providers.dart';
import 'package:mindhearth/features/safetycode/domain/providers/safety_code_providers.dart';

// API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Auth State Provider
class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(const AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.login(email: email, password: password);
      
      response.when(
        success: (data, message) async {
          final token = data['access_token'] as String;
          final userId = data['user_id'] as String;
          final tenantId = data['tenant_id'] as String;
          
          await apiService.setToken(token);
          
          final user = User(
            id: userId,
            email: email,
            tenantId: tenantId,
          );
          
          state = state.copyWith(
            isLoading: false,
            isAuthenticated: true,
            user: user,
            accessToken: token,
          );
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
        error: 'An unexpected error occurred',
      );
    }
  }

  Future<void> logout() async {
    final apiService = ref.read(apiServiceProvider);
    await apiService.clearToken();
    
    state = const AuthState();
  }

  Future<void> updateOnboardingStatus(bool isOnboarded) async {
    if (state.user != null) {
      final updatedUser = state.user!.copyWith(isOnboarded: isOnboarded);
      state = state.copyWith(user: updatedUser);
    }
  }

  Future<void> checkAuthStatus() async {
    final apiService = ref.read(apiServiceProvider);
    final token = await apiService.getToken();
    
    if (token != null) {
      // TODO: Validate token with backend
      state = state.copyWith(
        isAuthenticated: true,
        accessToken: token,
      );
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

// Auth State Provider
final authStateProvider = Provider<AuthState>((ref) {
  return ref.watch(authNotifierProvider);
});

// Export all providers for easy access
final appProviders = [
  apiServiceProvider,
  authNotifierProvider,
  authStateProvider,
  onboardingNotifierProvider,
  onboardingStateProvider,
  safetyCodeNotifierProvider,
  safetyCodeVerifiedProvider,
];
