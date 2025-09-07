# Tsukiyo Backend API Documentation

## Overview

This document provides comprehensive API documentation for the Tsukiyo backend, a specialized AI support platform for protective mothers navigating abusive relationships, post-separation abuse, and custody battles.

**Base URL:** `http://localhost:8000/api` (Development)  
**Authentication:** Bearer Token (JWT)  
**Content-Type:** `application/json`

---

## Table of Contents

1. [Authentication](#authentication)
2. [Health & Monitoring](#health--monitoring)
3. [Chat & AI](#chat--ai)
4. [Sessions](#sessions)
5. [Journal Entries](#journal-entries)
6. [Documents](#documents)
7. [Files](#files)
8. [Users & Profile](#users--profile)
9. [Analytics](#analytics)
10. [Usage Tracking](#usage-tracking)
11. [Billing & Credits](#billing--credits)
12. [Emergency Features](#emergency-features)
13. [Localization](#localization)
14. [Version Management](#version-management)
15. [Background Jobs](#background-jobs)
16. [Privacy & Security](#privacy--security)

---

## Authentication

### POST /api/auth/login

Authenticate user and return JWT token.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "tenant_id": "optional-tenant-id",
  "application_id": "optional-app-id"
}
```

**Response:**
```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "token_type": "bearer",
  "expires_in": 3600,
  "user_id": "user-uuid",
  "tenant_id": "tenant-uuid",
  "application_id": "app-uuid"
}
```

### POST /api/auth/register

Register a new user.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "full_name": "John Doe",
  "tenant_id": "tenant-uuid",
  "application_id": "app-uuid"
}
```

**Response:**
```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "token_type": "bearer",
  "expires_in": 3600,
  "user_id": "user-uuid",
  "tenant_id": "tenant-uuid",
  "application_id": "app-uuid",
  "user": {
    "id": "user-uuid",
    "email": "user@example.com",
    "full_name": "John Doe",
    "tenant_id": "tenant-uuid"
  }
}
```

### GET /api/auth/me

Get current user information.

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "id": "user-uuid",
  "email": "user@example.com",
  "full_name": "John Doe",
  "tenant_id": "tenant-uuid",
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z"
}
```

### GET /api/auth/sync

Sync all user data from backend.

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "user": { /* UserResponse */ },
  "sessions": [ /* SessionResponse[] */ ],
  "journal_entries": [ /* JournalEntryResponse[] */ ],
  "documents": [ /* DocumentResponse[] */ ],
  "communications": [ /* CommunicationItemResponse[] */ ]
}
```

---

## Health & Monitoring

### GET /api/health

Comprehensive health check endpoint.

**Response:**
```json
{
  "status": "healthy",
  "message": "All systems operational",
  "response_time": 0.05,
  "timestamp": "2024-01-01T00:00:00Z",
  "failure_count": 0,
  "checks": [
    {
      "name": "database",
      "status": "healthy",
      "response_time": 0.02
    }
  ],
  "environment": "development",
  "production_mode": false
}
```

### GET /api/health/summary

Quick health summary.

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-01T00:00:00Z",
  "uptime": 3600
}
```

---

## Chat & AI

### POST /api/chat/

Full chat with AI using trauma-informed responses.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "messages": [
    {
      "role": "user",
      "content": "I need help with my custody situation"
    }
  ],
  "session_id": "optional-session-id",
  "purpose": "custody_guidance",
  "max_tokens": 500,
  "temperature": 0.7
}
```

**Response:**
```json
{
  "message": "I understand you're dealing with a custody situation. This can be incredibly stressful and overwhelming. Let me help you think through some important considerations...",
  "session_id": "session-uuid",
  "session_type": "conversation"
}
```

### POST /api/chat/stream

Streaming chat with AI (Server-Sent Events).

**Headers:** `Authorization: Bearer <token>`

**Request Body:** Same as `/api/chat/`

**Response:** Server-Sent Events stream
```
data: {"content": "I understand you're dealing with..."}

data: {"content": " a custody situation. This can be..."}

data: {"done": true}
```

### POST /api/chat/simple

Simple chat endpoint without session management.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "message": "What are my rights in a custody case?"
}
```

**Response:**
```json
{
  "message": "In custody cases, both parents generally have rights to...",
  "session_id": null,
  "session_type": "utility"
}
```

---

## Sessions

### GET /api/sessions/

Get all sessions for the current user.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `limit` (int, default: 100): Number of sessions to return
- `offset` (int, default: 0): Number of sessions to skip
- `session_type` (string, optional): Filter by "conversation" or "utility"

**Response:**
```json
{
  "sessions": [
    {
      "id": "session-uuid",
      "name": "Chat Session 2024-01-01 12:00",
      "session_type": "conversation",
      "purpose": "custody_guidance",
      "created_at": "2024-01-01T12:00:00Z",
      "updated_at": "2024-01-01T12:30:00Z"
    }
  ],
  "total": 1
}
```

### GET /api/sessions/conversations

Get only conversation sessions.

**Headers:** `Authorization: Bearer <token>`

**Response:** Same as `/api/sessions/` but filtered to conversation type.

### GET /api/sessions/utilities

Get only utility sessions.

**Headers:** `Authorization: Bearer <token>`

**Response:** Same as `/api/sessions/` but filtered to utility type.

### GET /api/sessions/{session_id}

Get a specific session by ID.

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "id": "session-uuid",
  "name": "Chat Session 2024-01-01 12:00",
  "session_type": "conversation",
  "purpose": "custody_guidance",
  "created_at": "2024-01-01T12:00:00Z",
  "updated_at": "2024-01-01T12:30:00Z"
}
```

### POST /api/sessions/

Create a new session.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "name": "My New Session",
  "session_type": "conversation",
  "purpose": "custody_guidance"
}
```

**Response:** SessionResponse object.

### PUT /api/sessions/{session_id}

Update a session name.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "name": "Updated Session Name"
}
```

**Response:** SessionResponse object.

### DELETE /api/sessions/{session_id}

Delete a session.

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "message": "Session deleted successfully"
}
```

### DELETE /api/sessions/bulk/clear-all

Clear all sessions for the current user.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `session_type` (string, optional): Clear only sessions of this type

**Response:**
```json
{
  "message": "Deleted 5 sessions and all related data",
  "deleted_count": 5,
  "details": {
    "sessions": 5,
    "usage_logs": 10,
    "communications": 25,
    "journal_entries": 3,
    "documents": 2
  }
}
```

---

## Journal Entries

### GET /api/journals/

Get journal entries for the current user.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `limit` (int, default: 100): Number of entries to return
- `offset` (int, default: 0): Number of entries to skip
- `session_id` (UUID, optional): Filter by session ID
- `entry_type` (string, optional): Filter by entry type

**Response:**
```json
{
  "journal_entries": [
    {
      "id": "entry-uuid",
      "header": "Custody Meeting Notes",
      "entry_type": "general",
      "original_content": "Today I met with my lawyer about...",
      "redacted_content": null,
      "session_id": "session-uuid",
      "meta_data": {
        "tags": ["legal", "custody"],
        "ai_generated": false
      },
      "consent": true,
      "created_at": "2024-01-01T12:00:00Z",
      "updated_at": "2024-01-01T12:00:00Z"
    }
  ],
  "total": 1
}
```

### GET /api/journals/{entry_id}

Get a specific journal entry by ID.

**Headers:** `Authorization: Bearer <token>`

**Response:** JournalEntryResponse object.

### POST /api/journals/

Create a new journal entry.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "original_content": "Today I had a difficult conversation with my ex...",
  "redacted_content": null,
  "entry_type": "general",
  "session_id": "session-uuid",
  "header": "Daily Reflection",
  "tags": ["daily-reflection", "emotional"],
  "consent": true
}
```

**Response:** JournalEntryResponse object.

### POST /api/journals/ai-summary

Create an AI-generated journal entry summary from a conversation session.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "session_id": "session-uuid",
  "custom_content": "Optional custom content to summarize instead of session"
}
```

**Response:** JournalEntryResponse object with AI-generated content.

### PUT /api/journals/{entry_id}

Update a journal entry.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "original_content": "Updated content...",
  "redacted_content": null,
  "header": "Updated Header",
  "entry_type": "general",
  "tags": ["updated-tag"],
  "consent": true
}
```

**Response:** JournalEntryResponse object.

### DELETE /api/journals/{entry_id}

Delete a journal entry.

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "message": "Journal entry deleted successfully"
}
```

### DELETE /api/journals/bulk/clear-all

Delete all journal entries for the current user.

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "message": "Deleted 10 journal entries",
  "deleted_count": 10
}
```

### Journal Tag Configuration

#### GET /api/journals/tags/config

Get journal tag configurations.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `application_id` (UUID, optional): Filter by application

**Response:**
```json
[
  {
    "id": "tag-config-uuid",
    "tag_name": "daily-reflection",
    "tag_description": "Daily thoughts and reflections",
    "application_id": null,
    "is_active": true,
    "sort_order": "0",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
]
```

#### POST /api/journals/tags/config

Create a new journal tag configuration.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "tag_name": "legal-notes",
  "tag_description": "Notes related to legal matters",
  "application_id": "app-uuid",
  "sort_order": "1"
}
```

**Response:** JournalTagConfigurationResponse object.

#### PUT /api/journals/tags/config/{config_id}

Update a journal tag configuration.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "tag_name": "updated-tag-name",
  "tag_description": "Updated description",
  "is_active": true,
  "sort_order": "2"
}
```

**Response:** JournalTagConfigurationResponse object.

#### DELETE /api/journals/tags/config/{config_id}

Delete a journal tag configuration.

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "message": "Tag configuration deleted successfully"
}
```

---

## Documents

### GET /api/documents/

Get all documents for the current user.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `limit` (int, default: 100): Number of documents to return
- `offset` (int, default: 0): Number of documents to skip
- `session_id` (UUID, optional): Filter by session ID
- `file_type` (string, optional): Filter by file type

**Response:**
```json
{
  "documents": [
    {
      "id": "document-uuid",
      "filename": "custody_agreement.pdf",
      "title": "Custody Agreement",
      "file_type": "application/pdf",
      "file_size": 1024000,
      "session_id": "session-uuid",
      "consent": true,
      "created_at": "2024-01-01T12:00:00Z",
      "updated_at": "2024-01-01T12:00:00Z"
    }
  ],
  "total": 1
}
```

### GET /api/documents/{document_id}

Get a specific document by ID.

**Headers:** `Authorization: Bearer <token>`

**Response:** DocumentResponse object.

### POST /api/documents/

Create a new document.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "filename": "legal_document.pdf",
  "title": "Legal Document",
  "original_content": "base64-encoded-content",
  "redacted_content": null,
  "redacted_iv": null,
  "original_file": null,
  "file_type": "application/pdf",
  "file_size": 1024000,
  "session_id": "session-uuid",
  "consent": true
}
```

**Response:** DocumentResponse object.

### POST /api/documents/upload

Upload a document file.

**Headers:** `Authorization: Bearer <token>`

**Request:** Multipart form data
- `file`: The file to upload
- `session_id` (optional): Session ID to associate with

**Response:** DocumentResponse object.

### POST /api/documents/upload-encrypted

Upload an encrypted document.

**Headers:** `Authorization: Bearer <token>`

**Request Body:** Same as POST /api/documents/

**Response:** DocumentResponse object.

### PUT /api/documents/{document_id}

Update a document.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "filename": "updated_filename.pdf",
  "title": "Updated Title",
  "original_content": "updated-content",
  "consent": true
}
```

**Response:** DocumentResponse object.

### DELETE /api/documents/{document_id}

Delete a document.

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "message": "Document deleted successfully"
}
```

### DELETE /api/documents/bulk/clear-all

Delete all documents for the current user.

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "message": "Deleted 5 documents",
  "deleted_count": 5
}
```

---

## Files

### POST /api/files/upload

Upload a file with optional encryption.

**Headers:** `Authorization: Bearer <token>`

**Request:** Multipart form data
- `file`: The file to upload
- `encrypt` (boolean, default: true): Whether to encrypt the file
- `expires_in_days` (int, optional): File expiration in days

**Response:**
```json
{
  "file_id": "file-uuid",
  "filename": "uploaded_file.pdf",
  "file_size": 1024000,
  "file_type": "application/pdf",
  "encrypted": true,
  "expires_at": "2024-02-01T00:00:00Z",
  "download_url": "/api/files/download/file-uuid"
}
```

### GET /api/files/download/{file_id}

Download a file.

**Headers:** `Authorization: Bearer <token>`

**Response:** File download with appropriate headers.

### DELETE /api/files/{file_id}

Delete a file.

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "message": "File deleted successfully"
}
```

---

## Users & Profile

### GET /api/users/test-route

Test route for user authentication.

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "message": "Test route working",
  "user_id": "user-uuid"
}
```

### GET /api/users/current

Get current user information.

**Headers:** `Authorization: Bearer <token>`

**Response:** UserResponse object.

### GET /api/profile/

Get user profile information.

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "user_id": "user-uuid",
  "profile_data": {
    "preferences": {},
    "settings": {}
  }
}
```

---

## Analytics

### POST /api/analytics/track-event

Track a user event.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "event_name": "chat_session_started",
  "event_data": {
    "session_type": "conversation",
    "purpose": "custody_guidance"
  },
  "timestamp": "2024-01-01T12:00:00Z"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Event tracked successfully"
}
```

### POST /api/analytics/report-crash

Report an app crash.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "crash_data": {
    "error_message": "NullPointerException",
    "stack_trace": "...",
    "app_version": "1.0.0",
    "device_info": "iPhone 12, iOS 15.0"
  },
  "timestamp": "2024-01-01T12:00:00Z"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Crash report submitted"
}
```

---

## Usage Tracking

### GET /api/usage/statistics

Get usage statistics for the current user.

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "total_sessions": 10,
  "total_messages": 150,
  "total_tokens_used": 50000,
  "total_cost": 15.50,
  "last_activity": "2024-01-01T12:00:00Z"
}
```

---

## Billing & Credits

### GET /api/billing/mode

Get billing mode information.

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "billing_mode": "credits",
  "tenant_id": "tenant-uuid",
  "credit_balance": 100.50,
  "subscription_status": "active"
}
```

### GET /api/billing/credit-status

Get credit status for the current user.

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "user_id": "user-uuid",
  "credit_balance": 50.25,
  "last_transaction": "2024-01-01T12:00:00Z",
  "transaction_history": []
}
```

### In-App Purchases

#### POST /api/iap/validate-purchase/{provider}

Validate an in-app purchase.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "receipt_data": "base64-receipt-data",
  "product_id": "credits_100",
  "transaction_id": "transaction-uuid"
}
```

**Response:**
```json
{
  "valid": true,
  "credits_added": 100,
  "new_balance": 150.25
}
```

---

## Emergency Features

### POST /api/emergency/trigger

Trigger emergency mode.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "emergency_type": "data_wipe",
  "confirmation_code": "EMERGENCY123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Emergency mode activated",
  "actions_taken": ["data_encryption", "session_termination"]
}
```

### POST /api/emergency/data-wipe

Emergency data wipe.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "confirmation_code": "WIPE123",
  "wipe_type": "complete"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Data wipe completed",
  "items_wiped": {
    "sessions": 10,
    "journal_entries": 25,
    "documents": 5
  }
}
```

---

## Localization

### GET /api/localization/languages

Get list of supported languages.

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "success": true,
  "languages": [
    {
      "code": "en",
      "name": "English",
      "native_name": "English",
      "flag": "🇺🇸",
      "is_rtl": false,
      "is_default": true
    }
  ],
  "total_count": 1,
  "message": "Found 1 supported languages"
}
```

### GET /api/localization/languages/{language_code}

Get information about a specific language.

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "code": "en",
  "name": "English",
  "native_name": "English",
  "flag": "🇺🇸",
  "is_rtl": false,
  "is_default": true
}
```

### GET /api/localization/translations/{language_code}

Get translations for a specific language.

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "language_code": "en",
  "translations": {
    "welcome": "Welcome",
    "chat": "Chat",
    "journal": "Journal"
  },
  "last_updated": "2024-01-01T00:00:00Z"
}
```

---

## Version Management

### GET /api/version/info

Get current app version information.

**Response:**
```json
{
  "success": true,
  "data": {
    "version": "1.0.0",
    "build_number": "100",
    "release_date": "2024-01-01T00:00:00Z",
    "changelog": "Initial release"
  }
}
```

### POST /api/version/check-update

Check for app updates.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "current_version": "1.0.0",
  "platform": "ios",
  "device_info": "iPhone 12, iOS 15.0"
}
```

**Response:**
```json
{
  "update_available": true,
  "latest_version": "1.1.0",
  "update_url": "https://apps.apple.com/app/update",
  "force_update": false,
  "release_notes": "Bug fixes and improvements"
}
```

---

## Background Jobs

### POST /api/jobs/create

Create a background job.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "job_type": "data_export",
  "priority": "normal",
  "parameters": {
    "export_format": "pdf",
    "date_range": "2024-01-01 to 2024-01-31"
  }
}
```

**Response:**
```json
{
  "job_id": "job-uuid",
  "status": "queued",
  "estimated_completion": "2024-01-01T12:05:00Z"
}
```

### GET /api/jobs/{job_id}/status

Get job status.

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "job_id": "job-uuid",
  "status": "completed",
  "progress": 100,
  "result": {
    "download_url": "/api/files/download/export-uuid"
  },
  "created_at": "2024-01-01T12:00:00Z",
  "completed_at": "2024-01-01T12:05:00Z"
}
```

---

## Privacy & Security

### GET /api/privacy/data-export

Export user data.

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "export_id": "export-uuid",
  "download_url": "/api/files/download/export-uuid",
  "expires_at": "2024-01-08T00:00:00Z"
}
```

### POST /api/privacy/data-deletion

Request data deletion.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "confirmation": "DELETE_MY_DATA",
  "reason": "account_closure"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Data deletion request submitted",
  "estimated_completion": "2024-01-08T00:00:00Z"
}
```

---

## Error Responses

All endpoints may return the following error responses:

### 400 Bad Request
```json
{
  "detail": "Invalid request data",
  "error_code": "VALIDATION_ERROR"
}
```

### 401 Unauthorized
```json
{
  "detail": "Invalid or expired token",
  "error_code": "AUTHENTICATION_ERROR"
}
```

### 403 Forbidden
```json
{
  "detail": "Insufficient permissions",
  "error_code": "AUTHORIZATION_ERROR"
}
```

### 404 Not Found
```json
{
  "detail": "Resource not found",
  "error_code": "NOT_FOUND"
}
```

### 429 Too Many Requests
```json
{
  "detail": "Rate limit exceeded",
  "error_code": "RATE_LIMIT_EXCEEDED",
  "retry_after": 60
}
```

### 500 Internal Server Error
```json
{
  "detail": "Internal server error",
  "error_code": "INTERNAL_ERROR"
}
```

---

## Rate Limiting

The API implements rate limiting to ensure fair usage:

- **Login attempts**: 5 attempts per 15 minutes per IP
- **Chat requests**: 100 requests per hour per user
- **File uploads**: 10 uploads per hour per user
- **General API**: 1000 requests per hour per user

Rate limit headers are included in responses:
- `X-RateLimit-Limit`: Maximum requests allowed
- `X-RateLimit-Remaining`: Remaining requests in current window
- `X-RateLimit-Reset`: Time when the rate limit resets

---

## Authentication Flow

1. **Login**: POST `/api/auth/login` with email/password
2. **Store Token**: Save the `access_token` from response
3. **Include Token**: Add `Authorization: Bearer <token>` header to all requests
4. **Handle Expiry**: Token expires after `expires_in` seconds (default: 1 hour)
5. **Refresh**: Re-authenticate when token expires

---

## Data Models

### User
```json
{
  "id": "uuid",
  "email": "string",
  "full_name": "string",
  "tenant_id": "uuid",
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

### Session
```json
{
  "id": "uuid",
  "name": "string",
  "session_type": "conversation|utility",
  "purpose": "string",
  "user_id": "uuid",
  "application_id": "uuid",
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

### Journal Entry
```json
{
  "id": "uuid",
  "header": "string",
  "entry_type": "string",
  "original_content": "string",
  "redacted_content": "string|null",
  "session_id": "uuid|null",
  "meta_data": "object",
  "consent": "boolean",
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

### Document
```json
{
  "id": "uuid",
  "filename": "string",
  "title": "string",
  "file_type": "string",
  "file_size": "integer",
  "session_id": "uuid|null",
  "consent": "boolean",
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

---

## SDK Examples

### JavaScript/TypeScript
```typescript
class TsukiyoAPI {
  private baseURL = 'http://localhost:8000/api';
  private token: string | null = null;

  async login(email: string, password: string) {
    const response = await fetch(`${this.baseURL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password })
    });
    
    const data = await response.json();
    this.token = data.access_token;
    return data;
  }

  async chat(messages: Array<{role: string, content: string}>) {
    const response = await fetch(`${this.baseURL}/chat/`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.token}`
      },
      body: JSON.stringify({ messages })
    });
    
    return response.json();
  }
}
```

### Flutter/Dart
```dart
class TsukiyoAPI {
  static const String baseURL = 'http://localhost:8000/api';
  String? _token;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseURL/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    
    final data = jsonDecode(response.body);
    _token = data['access_token'];
    return data;
  }

  Future<Map<String, dynamic>> chat(List<Map<String, String>> messages) async {
    final response = await http.post(
      Uri.parse('$baseURL/chat/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: jsonEncode({'messages': messages}),
    );
    
    return jsonDecode(response.body);
  }
}
```

---

## Support

For technical support or questions about the API:

- **Documentation**: This document
- **OpenAPI Spec**: Available at `/docs` endpoint
- **Health Check**: `/api/health`
- **Version Info**: `/api/version/info`

---

*Last Updated: January 2024*  
*API Version: 1.0.0*
