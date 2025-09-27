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
          // Debug: Log the actual response structure
          appLogger.debug('Login response data: $data', 'AuthRepositoryImpl');
          
          final token = data['access_token'] as String?;
          
          // Validate token
          if (token == null || token.isEmpty) {
            appLogger.auth('login_failed', {'email': email, 'error': 'Missing access token'});
            return Result.failure(AppErrorFactory.authentication(message: 'Missing access token'));
          }
          
          await _apiService.setToken(token);
          
          // Fetch user data from backend to get user details and onboarding status
          final userResponse = await _apiService.getCurrentUser();
          
          return userResponse.when(
            success: (userData, userMessage) {
              // Extract user information from /users/me response
              final userId = userData['id'] as String?;
              final userEmail = userData['email'] as String?;
              final tenantId = userData['tenant_id'] as String?;
              final isOnboarded = userData['onboarded'] as bool? ?? false;
              
              if (userId == null || userId.isEmpty) {
                appLogger.auth('login_failed', {'email': email, 'error': 'Missing user ID in user data'});
                return Result.failure(AppErrorFactory.authentication(message: 'Missing user ID in user data'));
              }
              
              final user = User(
                id: userId,
                email: userEmail ?? email, // Use email from user data or fallback to login email
                tenantId: tenantId ?? 'unknown', // Use tenant ID from user data
                isOnboarded: isOnboarded,
              );
              
              appLogger.auth('login_success', {'email': email, 'userId': userId});
              return Result.success(user);
            },
            error: (userMessage, userStatusCode, userErrors) {
              appLogger.auth('login_failed', {'email': email, 'error': 'Failed to get user data: $userMessage'});
              return Result.failure(AppErrorFactory.authentication(message: 'Failed to get user data: $userMessage'));
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

