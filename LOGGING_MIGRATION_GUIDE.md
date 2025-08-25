# 🔧 Logging Migration Guide

This guide helps you migrate from `print()` statements to the new structured logging system.

## 🚀 New Logging System Features

### ✅ **Benefits**
- **Structured logging** with different levels (debug, info, warning, error, fatal)
- **Security-conscious** - automatically redacts sensitive data
- **Performance-optimized** - conditional compilation for production
- **Consistent formatting** across the application
- **Easy filtering** and debugging capabilities

### 🔧 **Usage Examples**

#### Basic Logging
```dart
// Old way
print('🐛 Debug: User logged in');

// New way
appLogger.info('User logged in');
appLogger.debug('Detailed debug info');
appLogger.warning('Something to watch out for');
appLogger.error('An error occurred');
```

#### Structured Logging with Data
```dart
// Old way
print('🐛 Debug: Login response data: $data');

// New way
appLogger.auth('Login response received', {'data': data});
```

#### Specialized Logging Methods
```dart
// API logging
appLogger.apiRequest('POST', '/auth/login', headers);
appLogger.apiResponse('POST', '/auth/login', 200, responseData);
appLogger.apiError('POST', '/auth/login', 401, 'Unauthorized');

// Authentication logging
appLogger.auth('Login attempt', {'email': email});
appLogger.auth('Login successful', {'email': email});

// Navigation logging
appLogger.navigation('/login', '/onboarding');

// State change logging
appLogger.stateChange('AppState', 'user_authenticated', {'userId': userId});

// Safety code logging (automatically redacts codes)
appLogger.safetyCode('verification_attempt', {'code_length': code.length});

// Encryption logging (automatically redacts data)
appLogger.encryption('content_encrypted', {'content_length': content.length});
```

## 📋 Migration Checklist

### Phase 1: Core Services ✅
- [x] `lib/core/utils/logger.dart` - New logging system
- [x] `lib/core/config/logging_config.dart` - Configuration
- [x] `lib/main.dart` - Logger initialization
- [x] `lib/core/services/api_service.dart` - API logging
- [x] `lib/core/providers/app_state_provider.dart` - Partial migration

### Phase 2: Remaining Files
- [ ] `lib/app/router/app_router.dart`
- [ ] `lib/features/auth/presentation/pages/login_page.dart`
- [ ] `lib/features/onboarding/domain/providers/onboarding_providers.dart`
- [ ] `lib/features/onboarding/presentation/pages/onboarding_page.dart`
- [ ] `lib/features/onboarding/presentation/widgets/onboarding_step_passphrase.dart`
- [ ] `lib/features/onboarding/presentation/widgets/onboarding_step_safety_code.dart`
- [ ] `lib/features/safetycode/domain/providers/safety_code_providers.dart`
- [ ] `lib/features/safetycode/presentation/pages/safety_code_page.dart`
- [ ] `lib/features/settings/presentation/pages/privacy_security_settings_page.dart`
- [ ] `lib/core/services/encryption_service.dart`
- [ ] `lib/core/services/chat_service.dart`

## 🔄 Migration Patterns

### Pattern 1: Simple Debug Messages
```dart
// Before
print('🐛 Debug: Something happened');

// After
appLogger.debug('Something happened');
```

### Pattern 2: Debug Messages with Data
```dart
// Before
print('🐛 Debug: User data: $userData');

// After
appLogger.debug('User data received', {'data': userData});
```

### Pattern 3: Error Messages
```dart
// Before
print('🐛 Error: Login failed: $error');

// After
appLogger.error('Login failed', {'error': error});
```

### Pattern 4: State Changes
```dart
// Before
print('🐛 Debug: State changed - authenticated: $isAuthenticated');

// After
appLogger.stateChange('AuthState', 'authentication_changed', {
  'isAuthenticated': isAuthenticated
});
```

### Pattern 5: API Calls
```dart
// Before
print('🐛 Request: POST /auth/login');
print('🐛 Response: 200 /auth/login');

// After
appLogger.apiRequest('POST', '/auth/login');
appLogger.apiResponse('POST', '/auth/login', 200, responseData);
```

## 🛡️ Security Considerations

### ✅ **Automatically Redacted**
The new logging system automatically redacts sensitive information:
- Passwords, tokens, API keys
- Safety codes, passphrases
- Personal information
- Encryption keys and data

### ✅ **Conditional Logging**
- Debug logs only appear in debug mode
- Production builds have minimal logging
- Configurable per log type

## 🎯 Best Practices

### ✅ **Do**
- Use appropriate log levels
- Include relevant context data
- Use specialized logging methods when available
- Keep messages concise and clear

### ❌ **Don't**
- Log sensitive information directly
- Use print() statements
- Log in production builds unnecessarily
- Create overly verbose log messages

## 🔧 Configuration

### Enable/Disable Log Types
```dart
// In lib/core/config/logging_config.dart
static bool get enableApiLogs => kDebugMode && _defaultEnableApiLogs;
static bool get enableAuthLogs => kDebugMode && _defaultEnableAuthLogs;
// etc.
```

### Add New Sensitive Keys
```dart
// In lib/core/config/logging_config.dart
static const List<String> sensitiveKeys = [
  'password',
  'passphrase',
  'access_token',
  // Add new sensitive keys here
];
```

## 📊 Log Levels

| Level | Usage | Production |
|-------|-------|------------|
| **debug** | Detailed debugging info | ❌ Disabled |
| **info** | General application flow | ❌ Disabled |
| **warning** | Potentially harmful situations | ✅ Enabled |
| **error** | Error conditions | ✅ Enabled |
| **fatal** | Severe errors | ✅ Enabled |

## 🚀 Next Steps

1. **Complete Phase 2 migration** - Update remaining files
2. **Test logging output** - Verify logs appear correctly
3. **Configure production logging** - Set appropriate levels
4. **Add log monitoring** - Consider external logging services
5. **Document logging patterns** - Create team guidelines

## 📝 Notes

- All existing `print()` statements should be replaced
- The new system is backward compatible during migration
- Logs are automatically formatted and colored in debug mode
- Production builds will have minimal logging impact
