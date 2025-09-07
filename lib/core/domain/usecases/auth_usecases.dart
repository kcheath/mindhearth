import 'package:mindhearth/core/domain/entities/app_error.dart';
import 'package:mindhearth/core/domain/entities/result.dart';
import 'package:mindhearth/core/domain/repositories/auth_repository.dart';
import 'package:mindhearth/core/domain/validators/validators.dart';
import 'package:mindhearth/core/models/user.dart';

/// Use case for user login
class LoginUseCase {
  final AuthRepository _repository;
  final EmailValidator _emailValidator;

  LoginUseCase({
    required AuthRepository repository,
    EmailValidator? emailValidator,
  })  : _repository = repository,
        _emailValidator = emailValidator ?? EmailValidator();

  Future<Result<User>> call(String email, String password) async {
    // Validate email
    final emailValidation = _emailValidator.validate(email);
    if (!emailValidation.isValid) {
      return Result.failure(ValidationUtils.validationResultToError(emailValidation)!);
    }

    // Validate password
    if (password.isEmpty) {
      return Result.failure(AppErrorFactory.validation(
        message: 'Password is required',
      ));
    }

    // Perform login
    return await _repository.login(email, password);
  }
}

/// Use case for user logout
class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<Result<void>> call() async {
    return await _repository.logout();
  }
}

/// Use case for getting current user
class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  Future<Result<User?>> call() async {
    return await _repository.getCurrentUser();
  }
}

/// Use case for checking authentication status
class IsAuthenticatedUseCase {
  final AuthRepository _repository;

  IsAuthenticatedUseCase(this._repository);

  Future<Result<bool>> call() async {
    return await _repository.isAuthenticated();
  }
}

/// Use case for updating onboarding status
class UpdateOnboardingStatusUseCase {
  final AuthRepository _repository;

  UpdateOnboardingStatusUseCase(this._repository);

  Future<Result<void>> call(bool isOnboarded) async {
    return await _repository.updateOnboardingStatus(isOnboarded);
  }
}

