import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/services/api_service.dart';
import 'package:mindhearth/core/models/auth_state.dart';
import 'package:mindhearth/core/models/user.dart';
import 'package:mindhearth/core/config/debug_config.dart';
import 'package:mindhearth/core/services/chat_service.dart';
import 'package:mindhearth/features/onboarding/domain/providers/onboarding_providers.dart';
import 'package:mindhearth/features/safetycode/domain/providers/safety_code_providers.dart';
import 'package:mindhearth/core/providers/api_providers.dart';

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
          
          // Fetch user data from backend to get onboarding status
          final userResponse = await apiService.getCurrentUser();
          
          userResponse.when(
            success: (userData, userMessage) {
              final isOnboarded = userData['onboarded'] as bool? ?? false;
              
              final user = User(
                id: userId,
                email: email,
                tenantId: tenantId,
                isOnboarded: isOnboarded,
              );
              
              state = state.copyWith(
                isLoading: false,
                isAuthenticated: true,
                user: user,
                accessToken: token,
              );
            },
            error: (userMessage, userStatusCode, userErrors) {
              // Fallback to basic user data if /users/me fails
              final user = User(
                id: userId,
                email: email,
                tenantId: tenantId,
                isOnboarded: false, // Default to false for safety
              );
              
              state = state.copyWith(
                isLoading: false,
                isAuthenticated: true,
                user: user,
                accessToken: token,
              );
            },
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
      try {
        final apiService = ref.read(apiServiceProvider);
        final response = await apiService.updateOnboardedStatus(isOnboarded);
        
        response.when(
          success: (data, message) {
            // Update local state with the response from backend
            final updatedUser = state.user!.copyWith(isOnboarded: isOnboarded);
            state = state.copyWith(user: updatedUser);
          },
          error: (message, statusCode, errors) {
            // Log error but still update local state for UI consistency
            print('Failed to update onboarding status on backend: $message');
            final updatedUser = state.user!.copyWith(isOnboarded: isOnboarded);
            state = state.copyWith(user: updatedUser);
          },
        );
      } catch (e) {
        // Log error but still update local state for UI consistency
        print('Error updating onboarding status: $e');
        final updatedUser = state.user!.copyWith(isOnboarded: isOnboarded);
        state = state.copyWith(user: updatedUser);
      }
    }
  }

  Future<void> checkAuthStatus() async {
    // In debug mode, always start with no authentication to force login
    if (DebugConfig.isDebugMode) {
      // Clear any stored tokens to force fresh login
      final apiService = ref.read(apiServiceProvider);
      await apiService.clearToken();
      state = const AuthState();
      return;
    }
    
    // For production, check stored tokens
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
  chatServiceProvider,
  onboardingNotifierProvider,
  onboardingStateProvider,
  safetyCodeNotifierProvider,
  safetyCodeVerifiedProvider,
];
