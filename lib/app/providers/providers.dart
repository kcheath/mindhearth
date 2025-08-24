import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/services/api_service.dart';
import '../../core/models/auth_state.dart';
import '../../core/models/user.dart';

part 'providers.g.dart';

// API Service Provider
@riverpod
ApiService apiService(ApiServiceRef ref) {
  return ApiService();
}

// Auth State Provider
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    return const AuthState();
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.login(email: email, password: password);
      
      response.when(
        success: (data) async {
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

// Auth State Provider
@riverpod
AuthState authState(AuthStateRef ref) {
  return ref.watch(authNotifierProvider);
}
