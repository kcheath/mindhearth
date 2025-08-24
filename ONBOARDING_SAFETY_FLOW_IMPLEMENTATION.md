# Onboarding and Safety Code Flow Implementation

## 🎯 Overview

This document describes the implementation of the full onboarding and safety code flow using real backend logic and provider-driven navigation. The implementation ensures that users follow the proper sequence: **Login → Onboarding → Safety Code → Main App**.

## ✅ Objectives Achieved

### 1. **Authentication Reset Behavior**
- ✅ In `kDebugMode`, always start on the login screen
- ✅ Uses real backend API calls with test credentials (`test@tsukiyo.dev`, `password123`)
- ✅ Does **not** persist login between app restarts
- ✅ Does **not** mock or skip any part of onboarding or safety code flows

### 2. **Onboarding Flow**
- ✅ After login, fetches user data (`/users/me`) and checks `user.onboarded` status
- ✅ If `onboarded: false`, directs to onboarding pages and marks onboarding complete at the end
- ✅ If `onboarded: true`, continues to safety code check
- ✅ Uses Riverpod providers to manage onboarding state

### 3. **Safety Code Flow**
- ✅ After onboarding, checks whether the safety code is verified
- ✅ If not, shows the safety code screen and requires code entry
- ✅ Maintains existing logic for safety code setup/validation — does not skip this in debug mode
- ✅ Uses Riverpod providers and triggers state transitions appropriately

### 4. **Routing Flow**
- ✅ Ensures routing follows the sequence:
  ```
  Start →
    Login →
      Fetch /users/me →
        Check `onboarded` →
          If false → onboarding →
          Then → safety code →
            Then → main app
  ```
- ✅ In debug mode, test user follows this same sequence
- ✅ No fast-forwarding or default completion flags applied just because debug mode is enabled

### 5. **Debug Mode Enhancements**
- ✅ Enabled more verbose logging where helpful for development
- ✅ Shows a debug badge in the top app bar
- ✅ Pre-fills login fields with test user credentials for convenience, but does not auto-login or skip steps

## 🔧 Technical Implementation

### Backend API Endpoints Added

#### 1. **GET /api/users/me**
- **Purpose**: Fetch current user information including onboarding status
- **Response**: User data with `onboarded` boolean field
- **Usage**: Called after login to determine next step in flow

#### 2. **PUT /api/users/onboarded**
- **Purpose**: Update user's onboarding status
- **Request**: `{"onboarded": boolean}`
- **Response**: Updated user data
- **Usage**: Called when onboarding is completed

#### 3. **POST /api/users/safety-codes/validate**
- **Purpose**: Validate safety code against stored codes
- **Request**: `{"code": "string", "passphrase": "string"}`
- **Response**: `{"valid": boolean, "code_type": "string"}`
- **Usage**: Called when user enters safety code

#### 4. **POST /api/users/safety-codes**
- **Purpose**: Save encrypted safety codes for the user
- **Request**: `{"codes": {"type": "code"}, "passphrase": "string"}`
- **Response**: Success message
- **Usage**: Called when setting up new safety codes

### Provider Updates

#### 1. **AuthNotifier** (`lib/app/providers/providers.dart`)
- **Updated `login()` method**: Now fetches user data from `/users/me` after successful login
- **Updated `updateOnboardingStatus()` method**: Now calls backend to update onboarding status
- **Maintained debug mode behavior**: Always clears tokens on app restart

#### 2. **OnboardingNotifier** (`lib/features/onboarding/domain/providers/onboarding_providers.dart`)
- **Updated `completeOnboarding()` method**: Now calls `AuthNotifier.updateOnboardingStatus(true)`
- **Added integration**: Links onboarding completion to auth state

#### 3. **SafetyCodeNotifier** (`lib/features/safetycode/domain/providers/safety_code_providers.dart`)
- **Updated `verifySafetyCode()` method**: Now calls backend validation endpoint
- **Removed debug shortcuts**: No longer auto-verifies in debug mode
- **Added real backend integration**: Uses `/users/safety-codes/validate`

### Router Updates

#### 1. **GoRouterRefreshStream** (`lib/app/router/app_router.dart`)
- **Added onboarding state listener**: Now listens to `onboardingStateProvider`
- **Enhanced state management**: Properly handles all state transitions

#### 2. **Redirect Logic**
- **Authentication check**: Redirects to `/login` if not authenticated
- **Onboarding check**: Redirects to `/onboarding` if authenticated but not onboarded
- **Safety code check**: Redirects to `/safety` if authenticated and onboarded but safety not verified
- **Main app redirect**: Redirects to `/chat` if all conditions are met

## 🧪 Testing

### Test User Configuration
- **Email**: `test@tsukiyo.dev`
- **Password**: `password123`
- **Current Status**: 
  - `onboarded: true` (will skip onboarding)
  - `access_codes: {"journal": "0101190"}` (has safety code)

### Test Scenarios

#### Scenario 1: New User (onboarded: false)
1. Login with test credentials
2. Fetch `/users/me` → `onboarded: false`
3. Redirect to onboarding
4. Complete onboarding → Update backend
5. Redirect to safety code
6. Enter safety code → Validate with backend
7. Redirect to main app

#### Scenario 2: Existing User (onboarded: true)
1. Login with test credentials
2. Fetch `/users/me` → `onboarded: true`
3. Skip onboarding
4. Redirect to safety code
5. Enter safety code → Validate with backend
6. Redirect to main app

### Backend Endpoint Testing

All endpoints have been tested and verified:

```bash
# Test /users/me
curl -X GET http://localhost:8000/api/users/me -H "Authorization: Bearer <token>"

# Test /users/onboarded
curl -X PUT http://localhost:8000/api/users/onboarded -H "Authorization: Bearer <token>" -d '{"onboarded":false}'

# Test /users/safety-codes/validate
curl -X POST http://localhost:8000/api/users/safety-codes/validate -H "Authorization: Bearer <token>" -d '{"code":"0101190","passphrase":"default_passphrase"}'
```

## 🚀 Usage

### For Development
1. **Debug Mode**: App always starts fresh (no persisted login)
2. **Test Credentials**: Pre-filled in login form for convenience
3. **Real Backend**: All flows use actual backend endpoints
4. **Verbose Logging**: Enhanced logging for debugging

### For Production
1. **Persistent Login**: Tokens are stored and validated
2. **Real User Data**: All user data comes from backend
3. **Proper Flow**: Users must complete onboarding and safety code setup
4. **Error Handling**: Robust error handling for all API calls

## 📁 Files Modified

- ✅ `lib/core/services/api_service.dart` - Added user management endpoints
- ✅ `lib/app/providers/providers.dart` - Updated auth notifier with real backend integration
- ✅ `lib/features/onboarding/domain/providers/onboarding_providers.dart` - Added auth integration
- ✅ `lib/features/safetycode/domain/providers/safety_code_providers.dart` - Added real backend validation
- ✅ `lib/app/router/app_router.dart` - Enhanced routing with onboarding state
- ✅ `lib/core/config/debug_config.dart` - Maintained debug mode settings

## 🎉 Success Criteria

- ✅ **Real Backend Integration**: All flows use actual backend endpoints
- ✅ **Proper State Management**: Riverpod providers manage all state transitions
- ✅ **Declarative Navigation**: GoRouter handles routing based on state
- ✅ **Debug Mode Compliance**: Debug mode forces fresh login but doesn't skip flows
- ✅ **Error Handling**: Robust error handling for all API calls
- ✅ **User Experience**: Smooth transitions between authentication, onboarding, and safety code flows

The implementation is now complete and ready for testing! 🚀
