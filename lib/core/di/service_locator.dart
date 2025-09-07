import 'package:get_it/get_it.dart';
import 'package:mindhearth/core/services/api_service.dart';
import 'package:mindhearth/core/services/encryption_service.dart';
import 'package:mindhearth/core/services/chat_service.dart';
import 'package:mindhearth/core/config/app_config.dart';
import 'package:mindhearth/core/domain/repositories/auth_repository.dart';
import 'package:mindhearth/core/domain/repositories/onboarding_repository.dart';
import 'package:mindhearth/core/data/repositories/auth_repository_impl.dart';
import 'package:mindhearth/core/data/repositories/onboarding_repository_impl.dart';
import 'package:mindhearth/core/domain/usecases/auth_usecases.dart';
import 'package:mindhearth/core/domain/usecases/onboarding_usecases.dart';

/// Global service locator instance
final GetIt serviceLocator = GetIt.instance;

/// Service locator configuration
class ServiceLocator {
  static bool _isInitialized = false;

  /// Initialize all services
  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Register services as singletons
    _registerServices();
    
    // Register repositories
    _registerRepositories();
    
    // Register use cases
    _registerUseCases();
    
    // Register external dependencies
    await _registerExternalDependencies();

    _isInitialized = true;
  }

  /// Register core services
  static void _registerServices() {
    // API Service
    serviceLocator.registerLazySingleton<ApiService>(
      () => ApiService(),
    );

    // Encryption Service (static methods, so we register a wrapper)
    serviceLocator.registerLazySingleton<EncryptionServiceWrapper>(
      () => EncryptionServiceWrapper(),
    );

    // Chat Service
    serviceLocator.registerLazySingleton<ChatService>(
      () => ChatService(
        serviceLocator<ApiService>(),
      ),
    );
  }

  /// Register repositories
  static void _registerRepositories() {
    // Auth Repository
    serviceLocator.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        serviceLocator<ApiService>(),
      ),
    );

    // Onboarding Repository
    serviceLocator.registerLazySingleton<OnboardingRepository>(
      () => OnboardingRepositoryImpl(
        serviceLocator<ApiService>(),
      ),
    );
  }

  /// Register use cases
  static void _registerUseCases() {
    // Auth Use Cases
    serviceLocator.registerLazySingleton<LoginUseCase>(
      () => LoginUseCase(
        repository: serviceLocator<AuthRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<LogoutUseCase>(
      () => LogoutUseCase(
        serviceLocator<AuthRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<GetCurrentUserUseCase>(
      () => GetCurrentUserUseCase(
        serviceLocator<AuthRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<IsAuthenticatedUseCase>(
      () => IsAuthenticatedUseCase(
        serviceLocator<AuthRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<UpdateOnboardingStatusUseCase>(
      () => UpdateOnboardingStatusUseCase(
        serviceLocator<AuthRepository>(),
      ),
    );

    // Onboarding Use Cases
    serviceLocator.registerLazySingleton<GetOnboardingDataUseCase>(
      () => GetOnboardingDataUseCase(
        serviceLocator<OnboardingRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<SaveSituationDataUseCase>(
      () => SaveSituationDataUseCase(
        serviceLocator<OnboardingRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<SaveRedactionProfileUseCase>(
      () => SaveRedactionProfileUseCase(
        serviceLocator<OnboardingRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<SaveConsentFormUseCase>(
      () => SaveConsentFormUseCase(
        serviceLocator<OnboardingRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<ClearOnboardingDataUseCase>(
      () => ClearOnboardingDataUseCase(
        serviceLocator<OnboardingRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<SavePassphraseUseCase>(
      () => SavePassphraseUseCase(
        repository: serviceLocator<OnboardingRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<SaveSafetyCodesUseCase>(
      () => SaveSafetyCodesUseCase(
        repository: serviceLocator<OnboardingRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<ClearSafetyCodesUseCase>(
      () => ClearSafetyCodesUseCase(
        serviceLocator<OnboardingRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<GetPassphraseUseCase>(
      () => GetPassphraseUseCase(
        serviceLocator<OnboardingRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<GetSafetyCodesUseCase>(
      () => GetSafetyCodesUseCase(
        serviceLocator<OnboardingRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<ValidateSafetyCodeUseCase>(
      () => ValidateSafetyCodeUseCase(
        repository: serviceLocator<OnboardingRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<ClearPassphraseUseCase>(
      () => ClearPassphraseUseCase(
        serviceLocator<OnboardingRepository>(),
      ),
    );
  }

  /// Register external dependencies
  static Future<void> _registerExternalDependencies() async {
    // Add external service registrations here
    // Example: Analytics, Crash reporting, etc.
  }

  /// Reset all registrations (useful for testing)
  static Future<void> reset() async {
    await serviceLocator.reset();
    _isInitialized = false;
  }

  /// Check if service locator is initialized
  static bool get isInitialized => _isInitialized;
}

/// Wrapper for EncryptionService static methods
class EncryptionServiceWrapper {
  Future<void> storePassphrase(String passphrase) async {
    await EncryptionService.storePassphrase(passphrase);
  }

  Future<String?> getPassphrase() async {
    return await EncryptionService.getPassphrase();
  }

  Future<void> clearPassphrase() async {
    await EncryptionService.clearPassphrase();
  }

  Future<void> storeSafetyCodes(Map<String, String> codes) async {
    await EncryptionService.storeSafetyCodes(codes);
  }

  Future<Map<String, String>?> getSafetyCodes() async {
    return await EncryptionService.getSafetyCodes();
  }

  Future<void> clearSafetyCodes() async {
    await EncryptionService.clearSafetyCodes();
  }

  Future<bool> validateSafetyCode(String code) async {
    return await EncryptionService.validateSafetyCode(code);
  }

  String encryptContent(String content, String passphrase) {
    return EncryptionService.encryptContent(content, passphrase);
  }

  String decryptContent(String encryptedContent, String passphrase) {
    return EncryptionService.decryptContent(encryptedContent, passphrase);
  }

  Future<bool> isEncryptionReady() async {
    return await EncryptionService.isEncryptionReady();
  }
}

/// Extension methods for easier service access
extension ServiceLocatorExtension on GetIt {
  // Services
  ApiService get apiService => get<ApiService>();
  EncryptionServiceWrapper get encryptionService => get<EncryptionServiceWrapper>();
  ChatService get chatService => get<ChatService>();
  
  // Repositories
  AuthRepository get authRepository => get<AuthRepository>();
  OnboardingRepository get onboardingRepository => get<OnboardingRepository>();
  
  // Auth Use Cases
  LoginUseCase get loginUseCase => get<LoginUseCase>();
  LogoutUseCase get logoutUseCase => get<LogoutUseCase>();
  GetCurrentUserUseCase get getCurrentUserUseCase => get<GetCurrentUserUseCase>();
  IsAuthenticatedUseCase get isAuthenticatedUseCase => get<IsAuthenticatedUseCase>();
  UpdateOnboardingStatusUseCase get updateOnboardingStatusUseCase => get<UpdateOnboardingStatusUseCase>();
  
  // Onboarding Use Cases
  GetOnboardingDataUseCase get getOnboardingDataUseCase => get<GetOnboardingDataUseCase>();
  SaveSituationDataUseCase get saveSituationDataUseCase => get<SaveSituationDataUseCase>();
  SaveRedactionProfileUseCase get saveRedactionProfileUseCase => get<SaveRedactionProfileUseCase>();
  SaveConsentFormUseCase get saveConsentFormUseCase => get<SaveConsentFormUseCase>();
  ClearOnboardingDataUseCase get clearOnboardingDataUseCase => get<ClearOnboardingDataUseCase>();
  SavePassphraseUseCase get savePassphraseUseCase => get<SavePassphraseUseCase>();
  SaveSafetyCodesUseCase get saveSafetyCodesUseCase => get<SaveSafetyCodesUseCase>();
  ClearSafetyCodesUseCase get clearSafetyCodesUseCase => get<ClearSafetyCodesUseCase>();
  GetPassphraseUseCase get getPassphraseUseCase => get<GetPassphraseUseCase>();
  GetSafetyCodesUseCase get getSafetyCodesUseCase => get<GetSafetyCodesUseCase>();
  ValidateSafetyCodeUseCase get validateSafetyCodeUseCase => get<ValidateSafetyCodeUseCase>();
}
