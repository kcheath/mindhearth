# MindHearth Flutter App - API Endpoints Documentation

## Overview
This document provides a comprehensive list of all API endpoints used by the MindHearth Flutter application, including request/response data structures and authentication requirements.

## Base Configuration
- **Base URL**: `http://localhost:8080/api`
- **Content-Type**: `application/json`
- **Accept**: `application/json`

## Authentication Headers
All authenticated requests include:
- `Authorization: Bearer {access_token}`
- `X-Tenant-ID: 4de48d40-bbdf-4f43-83f7-01e1c102dde8`
- `X-App-ID: 50cd82c6-22a2-4532-9743-e9ebef4f21e0`

## API Endpoints

### 1. Authentication Endpoints

#### POST `/auth/login`
**Purpose**: User authentication
**Authentication**: Not required
**Request Data**:
```json
{
  "email": "test@mindhearth.dev",
  "password": "password123",
  "tenant_id": "4de48d40-bbdf-4f43-83f7-01e1c102dde8",
  "application_id": "50cd82c6-22a2-4532-9743-e9ebef4f21e0"
}
```
**Response Data**:
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "expires_in": 1440,
  "user": {
    "id": "c9380306-ea04-47de-bd14-3e26afa0063f",
    "email": "test@mindhearth.dev",
    "first_name": "Debug",
    "last_name": "User",
    "tenant_id": "4de48d40-bbdf-4f43-83f7-01e1c102dde8"
  }
}
```

#### GET `/users/me`
**Purpose**: Get current user information
**Authentication**: Required
**Request Data**: None
**Response Data**: User object with complete profile information

### 2. Health Check

#### GET `/health`
**Purpose**: API health check
**Authentication**: Not required
**Request Data**: None
**Response Data**: Health status information

### 3. Chat Endpoints

#### POST `/chat/`
**Purpose**: Send AI chat message with trauma-informed responses
**Authentication**: Required
**Request Data**:
```json
{
  "messages": [
    {
      "role": "user",
      "content": "Hello, I need help with anxiety"
    }
  ],
  "session_id": "optional-session-id",
  "session_type": "conversation",
  "purpose": "chat"
}
```
**Response Data**: AI response with trauma-informed content

#### POST `/chat/simple`
**Purpose**: Simple chat without session management
**Authentication**: Required
**Request Data**:
```json
{
  "message": "Hello, I need help"
}
```
**Response Data**: Simple AI response

### 4. Session Management

#### POST `/sessions/`
**Purpose**: Create new chat session
**Authentication**: Required
**Request Data**:
```json
{
  "name": "Session Name (optional)",
  "session_type": "conversation",
  "purpose": "Purpose (optional)"
}
```
**Response Data**: Created session object

#### GET `/sessions/`
**Purpose**: Get user sessions
**Authentication**: Required
**Query Parameters**:
- `limit`: Number of sessions to return (default: 100)
- `offset`: Number of sessions to skip (default: 0)
- `session_type`: Filter by session type (optional)

**Response Data**: List of session objects

#### PUT `/sessions/{id}`
**Purpose**: Update session name
**Authentication**: Required
**Request Data**:
```json
{
  "name": "New Session Name"
}
```
**Response Data**: Updated session object

#### DELETE `/sessions/{id}`
**Purpose**: Delete session
**Authentication**: Required
**Request Data**: None
**Response Data**: Deletion confirmation

### 5. Communication Management

#### POST `/communications/`
**Purpose**: Create communication record
**Authentication**: Required
**Request Data**:
```json
{
  "session_id": "session-id",
  "item_type": "message",
  "role": "user",
  "original_content": "User message content",
  "redacted_content": "Redacted content (optional)",
  "consent": false
}
```
**Response Data**: Created communication object

#### GET `/communications/`
**Purpose**: Get communications
**Authentication**: Required
**Query Parameters**:
- `session_id`: Filter by session (optional)
- `item_type`: Filter by item type (optional)
- `limit`: Number of records to return (default: 100)
- `offset`: Number of records to skip (default: 0)

**Response Data**: List of communication objects

### 6. User Management

#### PUT `/users/onboarded`
**Purpose**: Update user onboarding status
**Authentication**: Required
**Request Data**:
```json
{
  "onboarded": true
}
```
**Response Data**: Updated user status

#### POST `/users/safety-codes/validate`
**Purpose**: Validate safety code
**Authentication**: Required
**Request Data**:
```json
{
  "code": "safety-code",
  "passphrase": "user-passphrase"
}
```
**Response Data**: Validation result

#### POST `/users/safety-codes`
**Purpose**: Save safety codes
**Authentication**: Required
**Request Data**:
```json
{
  "codes": {
    "emergency": "emergency-code",
    "support": "support-code"
  },
  "passphrase": "user-passphrase"
}
```
**Response Data**: Confirmation

#### DELETE `/users/safety-codes`
**Purpose**: Clear safety codes
**Authentication**: Required
**Request Data**: None
**Response Data**: Confirmation

### 7. Onboarding Data Management

#### PUT `/users/relationship-context`
**Purpose**: Save situation/relationship data
**Authentication**: Required
**Request Data**:
```json
{
  "relationship_context": {
    "situation": "user-situation-data",
    "relationships": "relationship-information"
  }
}
```
**Response Data**: Updated user data

#### POST `/redaction-profiles/`
**Purpose**: Create redaction profile
**Authentication**: Required
**Request Data**:
```json
{
  "encrypted_profile_data": "json-encoded-profile-data"
}
```
**Response Data**: Created profile object

#### PUT `/redaction-profiles/`
**Purpose**: Update redaction profile
**Authentication**: Required
**Request Data**:
```json
{
  "encrypted_profile_data": "json-encoded-profile-data"
}
```
**Response Data**: Updated profile object

#### POST `/redaction-profiles/consent`
**Purpose**: Save consent form
**Authentication**: Required
**Request Data**:
```json
{
  "consent": true
}
```
**Response Data**: Consent confirmation

### 8. Journal Management

#### GET `/journals/`
**Purpose**: Get journal entries
**Authentication**: Required
**Query Parameters**:
- `entry_type`: Filter by entry type (optional)
- `limit`: Number of entries to return (default: 100)
- `offset`: Number of entries to skip (default: 0)

**Response Data**: List of journal entries

#### GET `/journals/{id}`
**Purpose**: Get specific journal entry
**Authentication**: Required
**Request Data**: None
**Response Data**: Journal entry object

#### POST `/journals/`
**Purpose**: Create journal entry
**Authentication**: Required
**Request Data**:
```json
{
  "header": "Journal Entry Title",
  "entry_type": "reflection",
  "session_id": "session-id (optional)",
  "meta_data": {
    "mood": "anxious",
    "triggers": ["work", "relationships"]
  },
  "original_content": "User's journal content",
  "consent": false
}
```
**Response Data**: Created journal entry

#### POST `/journals/ai-summary`
**Purpose**: Create AI-generated journal summary
**Authentication**: Required
**Request Data**:
```json
{
  "session_id": "session-id",
  "custom_content": "Additional context (optional)"
}
```
**Response Data**: AI-generated journal entry

#### PUT `/journals/{id}`
**Purpose**: Update journal entry
**Authentication**: Required
**Request Data**:
```json
{
  "header": "Updated Title (optional)",
  "entry_type": "reflection (optional)",
  "original_content": "Updated content (optional)",
  "meta_data": {
    "mood": "calm"
  },
  "consent": true
}
```
**Response Data**: Updated journal entry

#### DELETE `/journals/{id}`
**Purpose**: Delete journal entry
**Authentication**: Required
**Request Data**: None
**Response Data**: Deletion confirmation

### 9. Billing Endpoints

#### GET `/billing/balance`
**Purpose**: Get user credit balance
**Authentication**: Required
**Request Data**: None
**Response Data**:
```json
{
  "balance": 100
}
```

#### GET `/billing/status`
**Purpose**: Get billing status
**Authentication**: Required
**Request Data**: None
**Response Data**: Billing status information

## Error Responses

All endpoints may return error responses with the following structure:
```json
{
  "detail": "Error message description",
  "status_code": 400
}
```

## Common HTTP Status Codes
- `200`: Success
- `201`: Created
- `400`: Bad Request
- `401`: Unauthorized
- `404`: Not Found
- `409`: Conflict
- `500`: Internal Server Error

## Rate Limiting
- All endpoints are subject to rate limiting
- Authentication endpoints have stricter limits
- Chat endpoints may have usage-based limits

## Security Notes
- All sensitive data is encrypted in transit (HTTPS in production)
- Access tokens are stored securely using Flutter Secure Storage
- User data is redacted according to user preferences
- Safety codes are encrypted with user-provided passphrases

## Development Configuration
- Debug mode uses test credentials: `test@mindhearth.dev` / `password123`
- All requests include debug headers in development
- Enhanced logging is enabled for all API calls in debug mode
