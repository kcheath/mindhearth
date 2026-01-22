# 🧪 Backend Integration Test Plan

## 📋 **Overview**

This comprehensive test plan ensures all backend endpoints work correctly with the Flutter app after any backend changes. Run this whenever backend changes could impact the frontend.

## 🚀 **Quick Start**

```bash
# Run all tests
flutter test test/integration/

# Run specific test categories
flutter test test/integration/api_endpoints_test.dart
flutter test test/integration/auth_flow_test.dart
flutter test test/integration/session_management_test.dart
```

## 📊 **Test Categories**

### **1. API Endpoint Tests** ✅
- [ ] Authentication endpoints
- [ ] Session management endpoints  
- [ ] Chat endpoints
- [ ] Journal endpoints
- [ ] Billing endpoints
- [ ] User management endpoints

### **2. Authentication Flow Tests** 🔐
- [ ] Login with valid credentials
- [ ] Login with invalid credentials
- [ ] Token refresh
- [ ] Logout
- [ ] Session persistence

### **3. Session Management Tests** 💬
- [ ] Create new session
- [ ] List sessions
- [ ] Switch between sessions
- [ ] Delete session
- [ ] Session persistence

### **4. Chat Functionality Tests** 🤖
- [ ] Send message
- [ ] Receive response
- [ ] Streaming chat
- [ ] Message history
- [ ] Error handling

### **5. UI Integration Tests** 🎨
- [ ] Login page
- [ ] Chat page
- [ ] Sessions page
- [ ] Navigation flow
- [ ] Error displays

## 🔧 **Test Configuration**

### **Test Credentials**
```dart
// From test_config.dart
Email: test@mindhearth.dev
Password: password123
Tenant ID: 50cd82c6-22a2-4532-9743-e9ebef4f21e0
Application ID: 60dd93d7-33b3-5643-0854-f0fcf5f32f1f
Base URL: http://3.150.176.19:8080/api
```

### **Test Environment Setup**
```bash
# 1. Ensure backend is running
curl http://3.150.176.19:8080/api/health

# 2. Run Flutter tests
flutter test test/integration/

# 3. Run manual UI tests
flutter run --debug
```

## 📝 **Detailed Test Cases**

### **Authentication Tests**

#### **Test 1: Valid Login**
```dart
// Expected: Login successful, JWT token received
// Status: ✅ PASS / ❌ FAIL
// Notes: [Any issues or observations]
```

#### **Test 2: Invalid Login**
```dart
// Expected: Login failed, error message displayed
// Status: ✅ PASS / ❌ FAIL
// Notes: [Any issues or observations]
```

#### **Test 3: Token Refresh**
```dart
// Expected: Token automatically refreshed before expiry
// Status: ✅ PASS / ❌ FAIL
// Notes: [Any issues or observations]
```

### **Session Management Tests**

#### **Test 4: Create Session**
```dart
// Expected: New session created successfully
// Status: ✅ PASS / ❌ FAIL
// Notes: [Any issues or observations]
```

#### **Test 5: List Sessions**
```dart
// Expected: All user sessions displayed
// Status: ✅ PASS / ❌ FAIL
// Notes: [Any issues or observations]
```

#### **Test 6: Switch Sessions**
```dart
// Expected: Chat history loads for selected session
// Status: ✅ PASS / ❌ FAIL
// Notes: [Any issues or observations]
```

### **Chat Functionality Tests**

#### **Test 7: Send Message**
```dart
// Expected: Message sent, response received
// Status: ✅ PASS / ❌ FAIL
// Notes: [Any issues or observations]
```

#### **Test 8: Streaming Chat**
```dart
// Expected: Real-time response streaming
// Status: ✅ PASS / ❌ FAIL
// Notes: [Any issues or observations]
```

#### **Test 9: Message History**
```dart
// Expected: Previous messages displayed correctly
// Status: ✅ PASS / ❌ FAIL
// Notes: [Any issues or observations]
```

### **Error Handling Tests**

#### **Test 10: Network Error**
```dart
// Expected: Graceful error handling, retry option
// Status: ✅ PASS / ❌ FAIL
// Notes: [Any issues or observations]
```

#### **Test 11: API Timeout**
```dart
// Expected: Timeout handled gracefully
// Status: ✅ PASS / ❌ FAIL
// Notes: [Any issues or observations]
```

#### **Test 12: Invalid Response**
```dart
// Expected: Error message displayed, app doesn't crash
// Status: ✅ PASS / ❌ FAIL
// Notes: [Any issues or observations]
```

## 🎯 **Critical Success Criteria**

### **Must Pass (Blocking Issues)**
- [ ] **Authentication**: User can login and logout
- [ ] **Sessions**: User can create, list, and switch sessions
- [ ] **Chat**: User can send messages and receive responses
- [ ] **Navigation**: All pages load without crashes
- [ ] **Error Handling**: App handles errors gracefully

### **Should Pass (Important Issues)**
- [ ] **Performance**: API calls complete within 5 seconds
- [ ] **UI Responsiveness**: App remains responsive during API calls
- [ ] **Data Persistence**: User data persists across app restarts
- [ ] **Offline Handling**: App handles network issues gracefully

### **Nice to Have (Enhancement Issues)**
- [ ] **Loading States**: Proper loading indicators
- [ ] **Error Messages**: User-friendly error messages
- [ ] **Retry Logic**: Automatic retry for failed requests
- [ ] **Caching**: Efficient data caching

## 🚨 **Common Issues & Solutions**

### **Issue 1: Sessions Not Loading**
```dart
// Problem: type 'List<dynamic>' is not a subtype of type 'Map<String, dynamic>'
// Solution: Backend returns direct array, app expects wrapped object
// Fix: Update response parsing in all session-related code
```

### **Issue 2: Authentication Failures**
```dart
// Problem: Login fails with "Invalid credentials"
// Solution: Check credentials and field names
// Fix: Ensure using correct email/password and field names
```

### **Issue 3: API Timeouts**
```dart
// Problem: Requests timeout after 30 seconds
// Solution: Increase timeout or optimize backend
// Fix: Update timeout settings or backend performance
```

### **Issue 4: Navigation Issues**
```dart
// Problem: App redirects unexpectedly
// Solution: Check authentication state and routing logic
// Fix: Verify auth state management and route guards
```

## 📊 **Test Results Template**

### **Test Run: [DATE]**
**Backend Version:** [VERSION]  
**Flutter Version:** [VERSION]  
**Test Environment:** [ENVIRONMENT]

#### **Summary**
- **Total Tests:** [NUMBER]
- **Passed:** [NUMBER] ✅
- **Failed:** [NUMBER] ❌
- **Skipped:** [NUMBER] ⏭️

#### **Critical Issues**
- [ ] [Issue description]
- [ ] [Issue description]

#### **Recommendations**
- [ ] [Action item]
- [ ] [Action item]

## 🔄 **Automated Test Scripts**

### **Pre-Test Setup**
```bash
#!/bin/bash
# setup_tests.sh

echo "🧪 Setting up backend integration tests..."

# Check if backend is running
curl -f http://3.150.176.19:8080/api/health || {
    echo "❌ Backend not running. Please start the backend first."
    exit 1
}

echo "✅ Backend is running"

# Run Flutter tests
echo "🧪 Running Flutter tests..."
flutter test test/integration/

echo "✅ Tests completed"
```

### **Post-Test Cleanup**
```bash
#!/bin/bash
# cleanup_tests.sh

echo "🧹 Cleaning up test data..."

# Clear test sessions
# Clear test messages
# Clear test user data

echo "✅ Cleanup completed"
```

## 📱 **Manual Testing Checklist**

### **Login Flow**
- [ ] Open app
- [ ] Enter test credentials
- [ ] Tap login
- [ ] Verify successful login
- [ ] Check navigation to main app

### **Session Management**
- [ ] Navigate to sessions page
- [ ] Verify sessions list loads
- [ ] Create new session
- [ ] Switch between sessions
- [ ] Delete session

### **Chat Functionality**
- [ ] Select a session
- [ ] Send a message
- [ ] Verify response received
- [ ] Check message history
- [ ] Test streaming chat

### **Error Scenarios**
- [ ] Test with invalid credentials
- [ ] Test with network disconnected
- [ ] Test with backend down
- [ ] Verify error messages displayed

## 🎯 **Success Metrics**

### **Performance Targets**
- **API Response Time:** < 2 seconds
- **App Launch Time:** < 3 seconds
- **Navigation Speed:** < 1 second
- **Memory Usage:** < 100MB

### **Reliability Targets**
- **Test Pass Rate:** > 95%
- **Critical Path Success:** 100%
- **Error Recovery:** 100%
- **Data Consistency:** 100%

## 📚 **Resources**

### **Test Data**
- **Test User:** test@mindhearth.dev
- **Test Password:** password123
- **Test Sessions:** 5 pre-created sessions
- **Test Messages:** Sample conversation data

### **Backend Documentation**
- **API Docs:** http://3.150.176.19:8080/docs
- **ReDoc:** http://3.150.176.19:8080/redoc
- **OpenAPI:** http://3.150.176.19:8080/openapi.json

### **Flutter Test Commands**
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/integration/api_endpoints_test.dart

# Run with coverage
flutter test --coverage

# Run in verbose mode
flutter test --verbose
```

---

## 🎉 **Test Completion**

When all tests pass, the backend integration is working correctly and the Flutter app is ready for production use! 🚀
