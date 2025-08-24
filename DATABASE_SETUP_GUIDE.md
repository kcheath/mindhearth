# 🗄️ Database Setup Guide for kch_dev Backend

## Overview

This guide helps you set up the Mindhearth Flutter app to use the database created in the kch_dev backend. The backend is running on `http://localhost:8000` and requires valid tenant and application IDs for user registration.

## 🔍 Current Backend Status

### ✅ Backend is Running
- **URL**: `http://localhost:8000`
- **Status**: Healthy ✅
- **Environment**: Development
- **Version**: 1.0.0
- **Features**: Multi-tenant, encryption, real-time chat, file upload, analytics

### 🔐 Security Requirements
- **Password minimum**: 12 characters
- **Password requirements**: Uppercase, lowercase, digits, special characters
- **Password history**: 5 previous passwords
- **Multi-tenant**: Requires valid tenant and application IDs

## 🚀 Setup Steps

### Step 1: Get Valid Tenant and Application IDs

You need to obtain valid tenant and application IDs from the kch_dev backend. Here are the options:

#### Option A: Check Backend Configuration
Look for default tenant/application IDs in the kch_dev backend configuration:

```bash
# Check if there are any default IDs in the backend
# Look for files like:
# - config/database.py
# - config/tenants.py
# - scripts/seed.py
# - docker-compose.yml
```

#### Option B: Create Test Tenant/Application
If no defaults exist, you may need to create them:

```bash
# Check if there are admin endpoints
curl -X GET "http://localhost:8000/api/admin/tenants"
curl -X GET "http://localhost:8000/api/admin/applications"
```

#### Option C: Database Direct Access
Access the database directly to find or create tenant/application IDs:

```bash
# If using Docker
docker exec -it <backend_container> psql -U <username> -d <database>

# Or connect to the database directly
psql -h localhost -U <username> -d <database>
```

### Step 2: Create Test User

Once you have valid tenant and application IDs, create a test user:

```bash
curl -X POST "http://localhost:8000/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "fullName": "Test User",
    "email": "test_user@tsukiyo.com",
    "password": "TestPassword123!",
    "tenantId": "YOUR_TENANT_ID_HERE",
    "applicationId": "YOUR_APPLICATION_ID_HERE"
  }'
```

### Step 3: Update Flutter App Configuration

Update the debug configuration in `lib/core/config/debug_config.dart`:

```dart
class DebugConfig {
  // Update with your actual test user credentials
  static const String testEmail = 'test_user@tsukiyo.com';
  static const String testPassword = 'TestPassword123!';
  
  // Backend URL (should already be correct)
  static const String debugApiUrl = 'http://localhost:8000/api';
}
```

### Step 4: Test the Connection

Run the Flutter app in debug mode:

```bash
flutter run --debug
```

## 🔧 Alternative Setup Methods

### Method 1: Use Existing kch_dev Database

If the kch_dev backend already has a database with users:

1. **Find existing users**:
   ```bash
   # Check if there are any existing users
   curl -X POST "http://localhost:8000/api/auth/login" \
     -H "Content-Type: application/json" \
     -d '{"email":"existing_user@example.com","password":"existing_password"}'
   ```

2. **Use existing credentials** in the Flutter app

### Method 2: Database Seeding

If you have access to the kch_dev backend code:

1. **Find seeding scripts**:
   ```bash
   # Look for files like:
   # - scripts/seed_database.py
   # - migrations/seed_data.sql
   # - tests/fixtures/users.json
   ```

2. **Run seeding script**:
   ```bash
   # Example
   python scripts/seed_database.py
   ```

### Method 3: Admin Endpoints

If there are admin endpoints available:

1. **Create tenant/application via admin**:
   ```bash
   curl -X POST "http://localhost:8000/api/admin/tenants" \
     -H "Content-Type: application/json" \
     -d '{"name": "Test Tenant", "description": "Test tenant for development"}'
   ```

2. **Create user via admin**:
   ```bash
   curl -X POST "http://localhost:8000/api/admin/users" \
     -H "Content-Type: application/json" \
     -d '{"email": "test_user@tsukiyo.com", "password": "TestPassword123!", "tenantId": "..."}'
   ```

## 🔍 Troubleshooting

### Issue 1: Invalid Tenant ID
```
Error: Invalid tenant ID
```
**Solution**: Get valid tenant ID from backend team or database

### Issue 2: Invalid Application ID
```
Error: Invalid application ID
```
**Solution**: Get valid application ID from backend team or database

### Issue 3: Password Requirements
```
Error: Password does not meet requirements
```
**Solution**: Use password with 12+ chars, uppercase, lowercase, digits, special chars

### Issue 4: Backend Not Running
```
Error: Connection refused
```
**Solution**: Start the kch_dev backend server

### Issue 5: Database Connection Issues
```
Error: Database connection failed
```
**Solution**: Check database configuration in kch_dev backend

## 📋 Required Information

To complete the setup, you need:

1. **Valid Tenant ID** (UUID format)
2. **Valid Application ID** (UUID format)
3. **Test User Credentials** (email + password meeting requirements)
4. **Backend URL** (should be `http://localhost:8000`)

## 🎯 Next Steps

### For Backend Team
1. **Provide tenant/application IDs** for development
2. **Create test user account** with proper permissions
3. **Document database schema** and relationships
4. **Share seeding scripts** if available

### For Frontend Team
1. **Update test credentials** in `DebugConfig`
2. **Test authentication flow** with real backend
3. **Verify all endpoints** are working correctly
4. **Test complete user journey** (login → onboarding → safety code → main app)

## 📚 Additional Resources

### Backend Documentation
- API docs: `http://localhost:8000/docs`
- OpenAPI spec: `http://localhost:8000/openapi.json`
- Health check: `http://localhost:8000/api/health`

### Database Information
- **Type**: PostgreSQL (likely)
- **Host**: localhost
- **Port**: 5432 (default)
- **Database**: Check kch_dev configuration

### Useful Commands
```bash
# Check backend health
curl -X GET "http://localhost:8000/api/health"

# Check version info
curl -X GET "http://localhost:8000/api/version/info"

# Check security status
curl -X GET "http://localhost:8000/api/security/status"

# List all endpoints
curl -X GET "http://localhost:8000/openapi.json" | jq '.paths | keys'
```

---

**Note**: The exact setup process depends on how the kch_dev backend is configured. You may need to consult with the backend team to get the correct tenant and application IDs.
