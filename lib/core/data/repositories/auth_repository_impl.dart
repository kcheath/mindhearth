import 'package:mindhearth/core/domain/entities/app_error.dart';
import 'package:mindhearth/core/domain/entities/result.dart';
import 'package:mindhearth/core/domain/repositories/auth_repository.dart';
import 'package:mindhearth/core/models/user.dart';
import 'package:mindhearth/core/services/api_service.dart';
import 'package:mindhearth/core/utils/logger.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiService _apiService;

  AuthRepositoryImpl(this._apiService);

  @override
  Future<Result<User>> login(String email, String password) async {
    try {
      final response = await _apiService.login(email: email, password: password);
      
      return response.when(
        success: (data, message) async {
          final token = data['access_token'] as String;
          final userId = data['user_id'] as String;
          final tenantId = data['tenant_id'] as String;
          
          await _apiService.setToken(token);
          
          // Fetch user data from backend to get onboarding status
          final userResponse = await _apiService.getCurrentUser();
          
          return userResponse.when(
            success: (userData, userMessage) {
              final isOnboarded = userData['onboarded'] as bool? ?? false;
              
              final user = User(
                id: userId,
                email: email,
                tenantId: tenantId,
                isOnboarded: isOnboarded,
              );
              
              appLogger.auth('login_success', {'email': email, 'userId': userId});
              return Result.success(user);
            },
            error: (userMessage, userStatusCode, userErrors) {
              // Fallback to basic user data if /users/me fails
              final user = User(
                id: userId,
                email: email,
                tenantId: tenantId,
                isOnboarded: false, // Default to false for safety
              );
              
              appLogger.auth('login_success_fallback', {'email': email, 'userId': userId});
              return Result.success(user);
            },
          );
        },
        error: (message, statusCode, errors) {
          appLogger.auth('login_failed', {'email': email, 'error': message});
          return Result.failure(AppErrorFactory.authentication(message: message));
        },
      );
    } catch (e) {
      appLogger.error('Login error', null, e is StackTrace ? e : null);
      return Result.failure(AppErrorFactory.unknown(
        message: 'Login failed: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _apiService.clearToken();
      appLogger.auth('logout_success', {});
      return const Result.success(null);
    } catch (e) {
      appLogger.error('Logout error', null, e is StackTrace ? e : null);
      return Result.failure(AppErrorFactory.unknown(
        message: 'Logout failed: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      final response = await _apiService.getCurrentUser();
      
      return response.when(
        success: (data, message) {
          final user = User.fromJson(data);
          return Result.success(user);
        },
        error: (message, statusCode, errors) {
          if (statusCode == 401) {
            return Result.failure(AppErrorFactory.authentication(message: message));
          }
          return Result.failure(AppErrorFactory.network(
            message: message,
          ));
        },
      );
    } catch (e) {
      appLogger.error('Get current user error', null, e is StackTrace ? e : null);
      return Result.failure(AppErrorFactory.unknown(
        message: 'Failed to get current user: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Result<bool>> isAuthenticated() async {
    try {
      final token = await _apiService.getToken();
      return Result.success(token != null && token.isNotEmpty);
    } catch (e) {
      appLogger.error('Check authentication error', null, e is StackTrace ? e : null);
      return Result.failure(AppErrorFactory.unknown(
        message: 'Failed to check authentication: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Result<void>> updateOnboardingStatus(bool isOnboarded) async {
    try {
      final response = await _apiService.updateOnboardingStatus(isOnboarded);
      
      return response.when(
        success: (data, message) {
          appLogger.auth('onboarding_status_updated', {'isOnboarded': isOnboarded});
          return const Result.success(null);
        },
        error: (message, statusCode, errors) {
          return Result.failure(AppErrorFactory.network(
            message: message,
          ));
        },
      );
    } catch (e) {
      appLogger.error('Update onboarding status error', null, e is StackTrace ? e : null);
      return Result.failure(AppErrorFactory.unknown(
        message: 'Failed to update onboarding status: ${e.toString()}',
      ));
    }
  }
}

