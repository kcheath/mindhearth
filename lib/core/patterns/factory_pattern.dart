import 'package:mindhearth/core/services/logger.dart';

/// Factory pattern implementation for MindHearth
/// 
/// This provides flexible object creation for:
/// - Repository implementations
/// - Service implementations
/// - Widget creation
/// - Configuration objects
class FactoryPattern {
  static final _logger = AppLogger('FactoryPattern');
}

/// Abstract factory interface
abstract class AbstractFactory<T> {
  T create(String type);
  List<String> getSupportedTypes();
}

/// Repository factory
class RepositoryFactory implements AbstractFactory<dynamic> {
  final Map<String, dynamic Function()> _creators = {};

  RepositoryFactory() {
    _registerCreators();
  }

  void _registerCreators() {
    _creators['auth'] = () => MockAuthRepository();
    _creators['chat'] = () => MockChatRepository();
    _creators['journal'] = () => MockJournalRepository();
    _creators['billing'] = () => MockBillingRepository();
    _creators['onboarding'] = () => MockOnboardingRepository();
  }

  @override
  T create<T>(String type) {
    final creator = _creators[type];
    if (creator == null) {
      throw ArgumentError('Repository type $type not supported');
    }
    return creator() as T;
  }

  @override
  List<String> getSupportedTypes() {
    return _creators.keys.toList();
  }

  void registerCreator(String type, dynamic Function() creator) {
    _creators[type] = creator;
  }
}

/// Service factory
class ServiceFactory implements AbstractFactory<dynamic> {
  final Map<String, dynamic Function()> _creators = {};

  ServiceFactory() {
    _registerCreators();
  }

  void _registerCreators() {
    _creators['api'] = () => MockApiService();
    _creators['encryption'] = () => MockEncryptionService();
    _creators['storage'] = () => MockStorageService();
    _creators['logger'] = () => MockLoggerService();
  }

  @override
  T create<T>(String type) {
    final creator = _creators[type];
    if (creator == null) {
      throw ArgumentError('Service type $type not supported');
    }
    return creator() as T;
  }

  @override
  List<String> getSupportedTypes() {
    return _creators.keys.toList();
  }

  void registerCreator(String type, dynamic Function() creator) {
    _creators[type] = creator;
  }
}

/// Widget factory
class WidgetFactory implements AbstractFactory<dynamic> {
  final Map<String, dynamic Function(Map<String, dynamic>)> _creators = {};

  WidgetFactory() {
    _registerCreators();
  }

  void _registerCreators() {
    _creators['button'] = (params) => MockButtonWidget(params);
    _creators['text_field'] = (params) => MockTextFieldWidget(params);
    _creators['card'] = (params) => MockCardWidget(params);
    _creators['list_tile'] = (params) => MockListTileWidget(params);
  }

  @override
  T create<T>(String type, [Map<String, dynamic>? params]) {
    final creator = _creators[type];
    if (creator == null) {
      throw ArgumentError('Widget type $type not supported');
    }
    return creator(params ?? {}) as T;
  }

  @override
  List<String> getSupportedTypes() {
    return _creators.keys.toList();
  }

  void registerCreator(String type, dynamic Function(Map<String, dynamic>) creator) {
    _creators[type] = creator;
  }
}

/// Configuration factory
class ConfigurationFactory implements AbstractFactory<dynamic> {
  final Map<String, dynamic Function(Map<String, dynamic>)> _creators = {};

  ConfigurationFactory() {
    _registerCreators();
  }

  void _registerCreators() {
    _creators['app_config'] = (params) => AppConfig(
      apiBaseUrl: params['apiBaseUrl'] ?? 'https://api.mindhearth.com',
      apiVersion: params['apiVersion'] ?? 'v1',
      timeout: Duration(seconds: params['timeout'] ?? 30),
    );
    _creators['debug_config'] = (params) => DebugConfig(
      enableLogging: params['enableLogging'] ?? true,
      enableDebugMode: params['enableDebugMode'] ?? false,
    );
    _creators['test_config'] = (params) => TestConfig(
      testEmail: params['testEmail'] ?? 'test@example.com',
      testPassword: params['testPassword'] ?? 'password123',
    );
  }

  @override
  T create<T>(String type, [Map<String, dynamic>? params]) {
    final creator = _creators[type];
    if (creator == null) {
      throw ArgumentError('Configuration type $type not supported');
    }
    return creator(params ?? {}) as T;
  }

  @override
  List<String> getSupportedTypes() {
    return _creators.keys.toList();
  }

  void registerCreator(String type, dynamic Function(Map<String, dynamic>) creator) {
    _creators[type] = creator;
  }
}

/// Abstract factory for creating other factories
class FactoryProvider {
  static final RepositoryFactory _repositoryFactory = RepositoryFactory();
  static final ServiceFactory _serviceFactory = ServiceFactory();
  static final WidgetFactory _widgetFactory = WidgetFactory();
  static final ConfigurationFactory _configurationFactory = ConfigurationFactory();

  static RepositoryFactory get repositoryFactory => _repositoryFactory;
  static ServiceFactory get serviceFactory => _serviceFactory;
  static WidgetFactory get widgetFactory => _widgetFactory;
  static ConfigurationFactory get configurationFactory => _configurationFactory;
}

/// Builder pattern for complex objects
class ObjectBuilder<T> {
  final Map<String, dynamic> _properties = {};
  final T Function(Map<String, dynamic>) _builder;

  ObjectBuilder(this._builder);

  ObjectBuilder<T> setProperty(String key, dynamic value) {
    _properties[key] = value;
    return this;
  }

  ObjectBuilder<T> setProperties(Map<String, dynamic> properties) {
    _properties.addAll(properties);
    return this;
  }

  T build() {
    return _builder(_properties);
  }
}

/// Prototype pattern for object cloning
abstract class Prototype<T> {
  T clone();
}

/// Concrete prototype implementations
class UserPrototype implements Prototype<UserPrototype> {
  final String id;
  final String email;
  final String name;
  final Map<String, dynamic> metadata;

  const UserPrototype({
    required this.id,
    required this.email,
    required this.name,
    this.metadata = const {},
  });

  @override
  UserPrototype clone() {
    return UserPrototype(
      id: id,
      email: email,
      name: name,
      metadata: Map.from(metadata),
    );
  }

  UserPrototype copyWith({
    String? id,
    String? email,
    String? name,
    Map<String, dynamic>? metadata,
  }) {
    return UserPrototype(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      metadata: metadata ?? this.metadata,
    );
  }
}

class SessionPrototype implements Prototype<SessionPrototype> {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  const SessionPrototype({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
  });

  @override
  SessionPrototype clone() {
    return SessionPrototype(
      id: id,
      name: name,
      createdAt: createdAt,
      updatedAt: updatedAt,
      metadata: Map.from(metadata),
    );
  }

  SessionPrototype copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return SessionPrototype(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Singleton pattern for global access
class SingletonFactory {
  static final SingletonFactory _instance = SingletonFactory._internal();
  static SingletonFactory get instance => _instance;

  SingletonFactory._internal();

  final Map<String, dynamic> _singletons = {};

  T getSingleton<T>(String key, T Function() creator) {
    if (!_singletons.containsKey(key)) {
      _singletons[key] = creator();
    }
    return _singletons[key] as T;
  }

  void clearSingleton(String key) {
    _singletons.remove(key);
  }

  void clearAllSingletons() {
    _singletons.clear();
  }
}

/// Mock classes for testing
class MockAuthRepository {}
class MockChatRepository {}
class MockJournalRepository {}
class MockBillingRepository {}
class MockOnboardingRepository {}
class MockApiService {}
class MockEncryptionService {}
class MockStorageService {}
class MockLoggerService {}
class MockButtonWidget {
  final Map<String, dynamic> params;
  MockButtonWidget(this.params);
}
class MockTextFieldWidget {
  final Map<String, dynamic> params;
  MockTextFieldWidget(this.params);
}
class MockCardWidget {
  final Map<String, dynamic> params;
  MockCardWidget(this.params);
}
class MockListTileWidget {
  final Map<String, dynamic> params;
  MockListTileWidget(this.params);
}

/// Configuration classes
class AppConfig {
  final String apiBaseUrl;
  final String apiVersion;
  final Duration timeout;

  const AppConfig({
    required this.apiBaseUrl,
    required this.apiVersion,
    required this.timeout,
  });
}

class DebugConfig {
  final bool enableLogging;
  final bool enableDebugMode;

  const DebugConfig({
    required this.enableLogging,
    required this.enableDebugMode,
  });
}

class TestConfig {
  final String testEmail;
  final String testPassword;

  const TestConfig({
    required this.testEmail,
    required this.testPassword,
  });
}
