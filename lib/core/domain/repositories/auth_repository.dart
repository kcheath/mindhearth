import 'package:mindhearth/core/domain/entities/result.dart';
import 'package:mindhearth/core/models/user.dart';

abstract class AuthRepository {
  Future<Result<User>> login(String email, String password);
  Future<Result<void>> logout();
  Future<Result<User?>> getCurrentUser();
  Future<Result<bool>> isAuthenticated();
  Future<Result<void>> updateOnboardingStatus(bool isOnboarded);
}

