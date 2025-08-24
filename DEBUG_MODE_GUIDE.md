# 🐛 Debug Mode Guide

## Overview

The Mindhearth Flutter app includes a comprehensive debug mode that allows developers to test the full application using the real backend. This mode is designed for developer productivity and provides a true production-like experience.

## 🎯 Key Features

### ✅ Real Backend Integration
- **No mocks or stubs** - Uses actual backend API endpoints
- **Real authentication flow** - JWT tokens, user sessions, etc.
- **Real onboarding process** - Complete user onboarding flow
- **Real safety code verification** - Actual safety code validation

### 🔧 Debug Configuration
- **Automatic detection** - Uses `kDebugMode` to enable debug features
- **Environment switching** - Localhost for debug, production for release
- **Test credentials** - Pre-filled login credentials for quick testing
- **Debug UI elements** - Visual indicators and shortcuts

### 📱 Debug UI Features
- **Debug banner** - Shows environment and backend URL
- **Debug info panel** - Login page shows debug information
- **Debug settings** - Accessible from settings page
- **Performance overlay** - Optional performance monitoring

## 🚀 Getting Started

### 1. Prerequisites
- Backend server running on `http://localhost:8000`
- Valid test user credentials in the backend
- Flutter development environment

### 2. Update Test Credentials

Edit `lib/core/config/debug_config.dart`:

```dart
// Update these with actual test user credentials
static const String testEmail = 'test_user@tsukiyo.com';
static const String testPassword = 'your_actual_password';
```

### 3. Run in Debug Mode

```bash
flutter run --debug
```

## 🔍 Debug Mode Features

### Login Page
- **Pre-filled credentials** - Test email and password automatically filled
- **Debug info panel** - Shows backend URL and setup instructions
- **Real authentication** - Uses actual backend login endpoint

### Debug Banner
- **Environment indicator** - Shows "Environment: Debug"
- **Backend URL** - Displays current API endpoint
- **Always visible** - Appears at the top of the app

### Settings Page
- **Debug information** - Tap to view debug details
- **Setup instructions** - Clear guidance for configuration
- **Backend status** - Shows current backend URL

## 🔧 Configuration Options

### DebugConfig Class

```dart
class DebugConfig {
  // Debug mode detection
  static bool get isDebugMode => kDebugMode;
  
  // Test credentials
  static const String testEmail = 'test_user@tsukiyo.com';
  static const String testPassword = 'test123';
  
  // API URLs
  static const String debugApiUrl = 'http://localhost:8000/api';
  static const String productionApiUrl = 'https://api.mindhearth.com/api';
  
  // Features
  static bool get enableDebugLogging => isDebugMode;
  static bool get enableAutoLogin => isDebugMode;
  static bool get showDebugBanner => isDebugMode;
  static bool get enablePerformanceOverlay => isDebugMode;
}
```

### Available Settings

| Setting | Description | Default |
|---------|-------------|---------|
| `isDebugMode` | Automatic debug detection | `kDebugMode` |
| `enableDebugLogging` | Enhanced logging | `true` in debug |
| `enableAutoLogin` | Pre-fill login credentials | `true` in debug |
| `showDebugBanner` | Show debug banner | `true` in debug |
| `enablePerformanceOverlay` | Performance monitoring | `true` in debug |
| `useRealBackend` | Always use real backend | `true` |

## 🛠️ Backend Setup

### Required Backend Features
1. **Authentication endpoint** - `/api/auth/login`
2. **User registration** - `/api/auth/register` (if needed)
3. **Health check** - `/api/health`
4. **Onboarding endpoints** - For user onboarding flow
5. **Safety code endpoints** - For safety code verification

### Test User Requirements
- Valid email and password
- Proper tenant and application IDs
- Access to all required features
- Onboarding status tracking

## 🔍 Troubleshooting

### Common Issues

#### 1. Backend Connection Failed
```
Error: Connection refused
```
**Solution**: Ensure backend is running on `http://localhost:8000`

#### 2. Invalid Credentials
```
Error: Invalid email or password
```
**Solution**: Update test credentials in `DebugConfig`

#### 3. Missing Tenant/Application IDs
```
Error: Invalid tenant ID
```
**Solution**: Get valid IDs from backend team or create test user

#### 4. Debug Mode Not Active
**Solution**: Ensure running with `flutter run --debug`

### Debug Information

Check debug information in the app:
1. **Login page** - Debug info panel
2. **Settings page** - Debug information section
3. **Debug banner** - Environment and backend URL

## 📋 Development Workflow

### 1. Start Development
```bash
# Start backend server
# Update test credentials in DebugConfig
flutter run --debug
```

### 2. Test Flow
1. **Login** - Use pre-filled test credentials
2. **Onboarding** - Complete real onboarding process
3. **Safety Code** - Set up and verify safety code
4. **Main App** - Test all features with real backend

### 3. Debug Features
- **Debug banner** - Always visible in debug mode
- **Debug logging** - Enhanced console output
- **Performance overlay** - Monitor app performance
- **Debug settings** - Access debug information

## 🔒 Security Notes

### Debug Mode Security
- **Only in debug builds** - Debug features disabled in release
- **No production data** - Uses test user account only
- **Local development** - Backend runs on localhost
- **No sensitive data** - Test credentials only

### Best Practices
1. **Never commit real credentials** - Use test accounts only
2. **Keep backend local** - Don't expose debug backend publicly
3. **Regular credential updates** - Update test credentials as needed
4. **Monitor debug usage** - Ensure debug mode is used appropriately

## 📚 Additional Resources

### Backend Documentation
- API endpoints: `http://localhost:8000/docs`
- OpenAPI spec: `http://localhost:8000/openapi.json`
- Health check: `http://localhost:8000/api/health`

### Flutter Debug Tools
- Flutter Inspector
- Performance Profiler
- Network Inspector
- Debug Console

### Configuration Files
- `lib/core/config/debug_config.dart` - Debug configuration
- `lib/core/services/api_service.dart` - API service
- `lib/main.dart` - App configuration

## 🎯 Next Steps

### For Backend Team
1. **Create test user** - Set up dedicated test account
2. **Provide credentials** - Share test user details
3. **Document endpoints** - Ensure all required endpoints are available
4. **Test data setup** - Prepare test data for development

### For Frontend Team
1. **Update credentials** - Use provided test user credentials
2. **Test all flows** - Verify complete user journey
3. **Monitor performance** - Use debug tools for optimization
4. **Document issues** - Report any backend integration problems

---

**Note**: This debug mode is designed for development and testing only. Always use production builds for end-user testing and deployment.
