import 'package:get_it/get_it.dart';
import 'package:mindhearth/core/services/api_service.dart';
import 'package:mindhearth/core/services/encryption_service.dart';
import 'package:mindhearth/core/services/chat_service.dart';
import 'package:mindhearth/core/config/app_config.dart';

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
      () => ApiService(
        baseUrl: AppConfig.apiUrl,
        timeout: Duration(milliseconds: AppConfig.requestTimeout),
      ),
    );

    // Encryption Service (static methods, so we register a wrapper)
    serviceLocator.registerLazySingleton<EncryptionServiceWrapper>(
      () => EncryptionServiceWrapper(),
    );

    // Chat Service
    serviceLocator.registerLazySingleton<ChatService>(
      () => ChatService(
        apiService: serviceLocator<ApiService>(),
      ),
    );
  }

  /// Register repositories
  static void _registerRepositories() {
    // Add repository registrations here when implemented
    // Example:
    // serviceLocator.registerLazySingleton<OnboardingRepository>(
    //   () => OnboardingRepositoryImpl(
    //     apiService: serviceLocator<ApiService>(),
    //   ),
    // );
  }

  /// Register use cases
  static void _registerUseCases() {
    // Add use case registrations here when implemented
    // Example:
    // serviceLocator.registerLazySingleton<GetOnboardingDataUseCase>(
    //   () => GetOnboardingDataUseCase(
    //     repository: serviceLocator<OnboardingRepository>(),
    //   ),
    // );
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
  ApiService get apiService => get<ApiService>();
  EncryptionServiceWrapper get encryptionService => get<EncryptionServiceWrapper>();
  ChatService get chatService => get<ChatService>();
}
