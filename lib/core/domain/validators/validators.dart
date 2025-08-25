import 'package:mindhearth/core/config/app_config.dart';
import 'package:mindhearth/core/domain/entities/app_error.dart';

/// Validation result
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final Map<String, String> fieldErrors;

  const ValidationResult({
    required this.isValid,
    this.errors = const [],
    this.fieldErrors = const {},
  });

  factory ValidationResult.success() {
    return const ValidationResult(isValid: true);
  }

  factory ValidationResult.failure({
    List<String> errors = const [],
    Map<String, String> fieldErrors = const {},
  }) {
    return ValidationResult(
      isValid: false,
      errors: errors,
      fieldErrors: fieldErrors,
    );
  }

  ValidationResult merge(ValidationResult other) {
    return ValidationResult(
      isValid: isValid && other.isValid,
      errors: [...errors, ...other.errors],
      fieldErrors: {...fieldErrors, ...other.fieldErrors},
    );
  }
}

/// Base validator class
abstract class Validator<T> {
  ValidationResult validate(T value);
}

/// Email validator
class EmailValidator implements Validator<String> {
  @override
  ValidationResult validate(String email) {
    if (email.isEmpty) {
      return ValidationResult.failure(
        errors: ['Email is required'],
      );
    }

    if (!AppConfig.isValidEmail(email)) {
      return ValidationResult.failure(
        errors: ['Please enter a valid email address'],
      );
    }

    return ValidationResult.success();
  }
}

/// Passphrase validator
class PassphraseValidator implements Validator<String> {
  @override
  ValidationResult validate(String passphrase) {
    if (passphrase.isEmpty) {
      return ValidationResult.failure(
        errors: ['Passphrase is required'],
      );
    }

    if (passphrase.length < AppConfig.minPassphraseLength) {
      return ValidationResult.failure(
        errors: ['Passphrase must be at least ${AppConfig.minPassphraseLength} characters long'],
      );
    }

    if (passphrase.length > AppConfig.maxPassphraseLength) {
      return ValidationResult.failure(
        errors: ['Passphrase must be no more than ${AppConfig.maxPassphraseLength} characters long'],
      );
    }

    if (!AppConfig.isValidPassphrase(passphrase)) {
      return ValidationResult.failure(
        errors: ['Passphrase contains invalid characters'],
      );
    }

    return ValidationResult.success();
  }
}

/// Safety code validator
class SafetyCodeValidator implements Validator<String> {
  @override
  ValidationResult validate(String code) {
    if (code.isEmpty) {
      return ValidationResult.failure(
        errors: ['Safety code is required'],
      );
    }

    if (code.length != AppConfig.safetyCodeLength) {
      return ValidationResult.failure(
        errors: ['Safety code must be ${AppConfig.safetyCodeLength} characters long'],
      );
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(code)) {
      return ValidationResult.failure(
        errors: ['Safety code must contain only numbers'],
      );
    }

    return ValidationResult.success();
  }
}

/// Required field validator
class RequiredValidator implements Validator<String> {
  final String fieldName;

  RequiredValidator(this.fieldName);

  @override
  ValidationResult validate(String value) {
    if (value.isEmpty) {
      return ValidationResult.failure(
        fieldErrors: {fieldName: '$fieldName is required'},
      );
    }

    return ValidationResult.success();
  }
}

/// Length validator
class LengthValidator implements Validator<String> {
  final int minLength;
  final int maxLength;
  final String fieldName;

  LengthValidator({
    required this.minLength,
    required this.maxLength,
    required this.fieldName,
  });

  @override
  ValidationResult validate(String value) {
    if (value.length < minLength) {
      return ValidationResult.failure(
        fieldErrors: {fieldName: '$fieldName must be at least $minLength characters long'},
      );
    }

    if (value.length > maxLength) {
      return ValidationResult.failure(
        fieldErrors: {fieldName: '$fieldName must be no more than $maxLength characters long'},
      );
    }

    return ValidationResult.success();
  }
}

/// Composite validator
class CompositeValidator<T> implements Validator<T> {
  final List<Validator<T>> validators;

  CompositeValidator(this.validators);

  @override
  ValidationResult validate(T value) {
    ValidationResult result = ValidationResult.success();

    for (final validator in validators) {
      final validationResult = validator.validate(value);
      result = result.merge(validationResult);
    }

    return result;
  }
}

/// Validation utilities
class ValidationUtils {
  /// Validate email
  static ValidationResult validateEmail(String email) {
    return EmailValidator().validate(email);
  }

  /// Validate passphrase
  static ValidationResult validatePassphrase(String passphrase) {
    return PassphraseValidator().validate(passphrase);
  }

  /// Validate safety code
  static ValidationResult validateSafetyCode(String code) {
    return SafetyCodeValidator().validate(code);
  }

  /// Validate required field
  static ValidationResult validateRequired(String value, String fieldName) {
    return RequiredValidator(fieldName).validate(value);
  }

  /// Validate field length
  static ValidationResult validateLength(
    String value,
    String fieldName, {
    int? minLength,
    int? maxLength,
  }) {
    final validators = <Validator<String>>[];

    if (minLength != null && maxLength != null) {
      validators.add(LengthValidator(
        minLength: minLength,
        maxLength: maxLength,
        fieldName: fieldName,
      ));
    } else if (minLength != null) {
      validators.add(LengthValidator(
        minLength: minLength,
        maxLength: 1000, // Arbitrary large number
        fieldName: fieldName,
      ));
    } else if (maxLength != null) {
      validators.add(LengthValidator(
        minLength: 0,
        maxLength: maxLength,
        fieldName: fieldName,
      ));
    }

    if (validators.isEmpty) {
      return ValidationResult.success();
    }

    return CompositeValidator(validators).validate(value);
  }

  /// Convert validation result to AppError
  static AppError? validationResultToError(ValidationResult result) {
    if (result.isValid) return null;

    if (result.fieldErrors.isNotEmpty) {
      return AppError.validation(
        message: 'Validation failed',
        fieldErrors: result.fieldErrors,
      );
    }

    if (result.errors.isNotEmpty) {
      return AppError.validation(
        message: result.errors.first,
      );
    }

    return AppError.validation(
      message: 'Validation failed',
    );
  }
}
