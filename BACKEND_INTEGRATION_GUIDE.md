# 🔧 Backend Integration Guide

## 📋 **Updated Test Configuration**

Based on the latest backend changes, here are the verified test credentials and configuration for the MindHearth Flutter app:

### **🌐 API Configuration**
```dart
// Updated in lib/core/config/app_config.dart
API_BASE_URL: "http://localhost:8000"
API_VERSION: "v1"
```

### **👤 Test User Credentials**
```dart
// Updated in lib/core/config/debug_config.dart and test_config.dart
Email: "test@tsukiyo.dev"
Password: "password123"
```

### **🏢 Tenant & Application IDs**
```dart
// Updated in lib/core/services/api_service.dart
TENANT_ID: "1aca2ef7-b1fa-46bb-af08-a8fdb449b1f9"
APPLICATION_ID: "2852276f-16ca-462f-aa46-5e191880eb33"
API_KEY: "test-api-key-12345-new"
```

## 📁 **Updated Files**

### **1. Core Configuration Files**
- ✅ `lib/core/config/app_config.dart` - Updated API base URL
- ✅ `lib/core/config/debug_config.dart` - Added test credentials and IDs
- ✅ `lib/core/config/test_config.dart` - **NEW** - Comprehensive test configuration

### **2. Service Layer**
- ✅ `lib/core/services/api_service.dart` - Updated application ID

### **3. Authentication**
- ✅ `lib/features/auth/presentation/pages/login_page.dart` - Already has correct test credentials

## 🚀 **Quick Start for Development**

### **1. Environment Setup**
The app is already configured with the new backend settings. No additional setup required!

### **2. Test Login Flow**
```dart
// The login page automatically pre-fills with test credentials in debug mode:
Email: test@tsukiyo.dev
Password: password123
```

### **3. API Headers**
The app automatically includes the required headers:
```dart
{
  "Content-Type": "application/json",
  "Authorization": "Bearer {access_token}",
  "X-User-ID": "{user_id}",
  "X-API-Key": "test-api-key-12345-new",
  "X-App-ID": "2852276f-16ca-462f-aa46-5e191880eb33"
}
```

## 🧪 **Available Test Endpoints**

### **Authentication**
- `POST /api/auth/login` - Login with test credentials
- `GET /api/auth/me` - Get current user info
- `POST /api/auth/register` - Register new user

### **Sessions**
- `GET /api/sessions/` - List user sessions
- `POST /api/sessions/` - Create new session
- `GET /api/sessions/{id}` - Get session details

### **Journals**
- `GET /api/journals/` - List journal entries
- `POST /api/journals/` - Create journal entry
- `GET /api/journals/{id}` - Get journal entry

### **Chat**
- `POST /api/chat/` - Send chat message
- `POST /api/chat/simple` - Simple chat
- `POST /api/chat/stream` - Streaming chat

### **Documents**
- `GET /api/documents/` - List documents
- `POST /api/documents/` - Upload document
- `GET /api/documents/{id}` - Get document

## 📚 **API Documentation**
- **Swagger UI**: `http://localhost:8000/docs`
- **ReDoc**: `http://localhost:8000/redoc`
- **OpenAPI JSON**: `http://localhost:8000/openapi.json`

## 🔍 **Verification Steps**

### **1. Check Configuration**
```bash
# Verify the app compiles with new configuration
flutter analyze
```

### **2. Test Login**
1. Run the app in debug mode
2. Login page should auto-fill with test credentials
3. Login should succeed with backend

### **3. Test Core Features**
1. **Sessions**: Create and list sessions
2. **Journals**: Create and view journal entries
3. **Chat**: Send messages and receive responses
4. **Documents**: Upload and manage documents

## ⚠️ **Important Notes**

1. **Development Only**: These credentials are for development testing only
2. **Auto-Configuration**: The app automatically uses the correct settings in debug mode
3. **CORS**: Backend handles CORS for localhost development
4. **HTTPS**: Not required for localhost development
5. **Error Handling**: API returns standard HTTP status codes and JSON responses

## 🎯 **Next Steps**

1. **Start Backend**: Ensure the backend is running on `http://localhost:8000`
2. **Run Flutter App**: The app will automatically connect to the new backend
3. **Test Features**: Verify all core functionality works with the new backend
4. **Monitor Logs**: Check for any integration issues

## 📞 **Support**

If you encounter any issues:
1. Check that the backend is running on the correct port
2. Verify the test credentials are working via Swagger UI
3. Check the Flutter app logs for any API errors
4. Ensure all environment variables are properly set

The Flutter app is now fully configured and ready to integrate with the updated backend! 🚀
