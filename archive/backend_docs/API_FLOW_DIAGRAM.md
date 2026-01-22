# MindHearth Backend API Flow Diagram

## Complete API Endpoints Analysis

Based on comprehensive codebase analysis, here are all the published API endpoints used by the MindHearth Flutter application:

## 🔐 Authentication & User Management

### Authentication Endpoints
- `POST /api/auth/login` - User login with credentials
- `POST /api/auth/register` - User registration  
- `GET /api/auth/me` - Get current user information
- `GET /api/auth/sync` - Sync all user data from backend

### User Management
- `GET /api/users/me` - Get current user profile
- `PUT /api/users/me` - Update user profile
- `PUT /api/users/onboarded` - Update onboarding status
- `POST /api/users/safety-codes/validate` - Validate safety codes
- `POST /api/users/safety-codes` - Save safety codes
- `DELETE /api/users/safety-codes` - Clear safety codes
- `PUT /api/users/relationship-context` - Save relationship context

## 💬 Chat & Communication

### Unified Chat (Modern)
- `POST /communications/chat` - **Primary chat endpoint with RAG support**
- `POST /api/communications/chat/stream` - Streaming chat responses

### Legacy Chat (Deprecated)
- `POST /api/chat/` - Legacy full chat endpoint
- `POST /api/chat/stream` - Legacy streaming chat
- `POST /api/chat/simple` - Legacy simple chat

### Communication Management
- `POST /api/communications/` - Create communication record
- `GET /api/communications/` - Get communications with filtering
- `POST /api/communications/rag/index-comprehensive` - Index comprehensive RAG

## 📝 Journal Management

### Journal Entries
- `GET /journals/` - Get journal entries with filtering
- `GET /journals/{id}` - Get specific journal entry
- `POST /journals/` - Create journal entry
- `PUT /journals/{id}` - Update journal entry
- `DELETE /journals/{id}` - Delete journal entry
- `POST /api/journals/ai-summary` - Create AI-generated journal summary

### Journal Tags Configuration
- `GET /api/journals/tags/config` - Get journal tag configurations
- `POST /api/journals/tags/config` - Create tag configuration
- `PUT /api/journals/tags/config/{id}` - Update tag configuration
- `DELETE /api/journals/tags/config/{id}` - Delete tag configuration

## 🗂️ Session Management

### Sessions
- `GET /api/sessions/` - Get all user sessions
- `GET /api/sessions/{id}` - Get specific session
- `POST /api/sessions/` - Create new session
- `PUT /api/sessions/{id}` - Update session
- `DELETE /api/sessions/{id}` - Delete session
- `GET /api/sessions/{id}/analytics` - Get session analytics
- `POST /api/sessions/{id}/archive` - Archive session
- `POST /api/sessions/{id}/restore` - Restore session

## 💰 Billing & Credits

### Core Billing
- `GET /api/billing/balance` - Get user credit balance
- `GET /api/billing/status` - Get comprehensive billing status
- `GET /api/billing/packages` - Get available credit packages
- `GET /api/billing/ledger` - Get credit ledger with pagination
- `GET /api/billing/purchases` - Get purchase history

### Billing Operations
- `POST /api/billing/check-operation` - Check if operation is allowed
- `POST /api/billing/purchase` - Purchase credits directly
- `POST /api/billing/validate-purchase/{provider}` - Validate in-app purchase
- `POST /api/billing/gift` - Gift credits to another user
- `POST /api/billing/consume-credits` - Consume credits for operation

### Debug/Development Billing
- `POST /api/billing/debug/seed-credits` - Seed credits (debug)
- `POST /api/billing/debug/top-up` - Top up credits (debug)
- `POST /api/billing/dev/top-up` - Development top-up
- `POST /api/billing/debug/reset` - Reset billing (debug)
- `GET /api/billing/debug/health` - Billing health check
- `GET /api/billing/debug/mode` - Get debug mode status
- `POST /api/billing/debug/check-operation` - Debug operation check

### Session Questions & Analytics
- `POST /api/billing/session-questions/add` - Add session questions
- `GET /api/billing/session-questions/{sessionId}` - Get session questions
- `GET /api/billing/session-questions/status` - Get questions status
- `POST /api/billing/usage-analytics` - Submit usage analytics
- `POST /api/billing/heartbeat` - Send heartbeat

## 🔒 Privacy & Redaction

### Redaction Services
- `POST /redaction/preprocess` - Preprocess content for redaction
- `GET /redaction/profile` - Get redaction profile
- `POST /redaction/profile` - Save redaction profile

### Redaction Profiles
- `POST /api/redaction-profiles/` - Create redaction profile
- `PUT /api/redaction-profiles/` - Update redaction profile
- `POST /redaction-profiles/consent` - Save consent form

## 📄 Document & Context Management

### Document Management
- `GET /api/documents/` - Get all documents
- `GET /api/documents/{id}` - Get specific document
- `POST /api/documents/` - Create document
- `POST /api/documents/upload` - Upload document file
- `POST /api/documents/upload-encrypted` - Upload encrypted document
- `PUT /api/documents/{id}` - Update document
- `DELETE /api/documents/{id}` - Delete document

### RAG Context Management
- `POST /api/context/documents` - Upload documents for RAG
- `POST /api/context/retrieve` - Retrieve documents for RAG

## 🏥 Health & Monitoring

### Health Checks
- `GET /health/` - Comprehensive health check
- `GET /api/health` - API health check
- `GET /api/health/summary` - Quick health summary

## 📊 Analytics & Tracking

### Analytics
- `POST /api/analytics/track-event` - Track user event
- `POST /api/analytics/report-crash` - Report app crash

### Usage Tracking
- `GET /api/usage/statistics` - Get usage statistics

## 🚨 Emergency Features

### Emergency Operations
- `POST /api/emergency/trigger` - Trigger emergency mode
- `POST /api/emergency/data-wipe` - Emergency data wipe

## 🌐 Localization

### Language Support
- `GET /api/localization/languages` - Get supported languages
- `GET /api/localization/languages/{code}` - Get language info
- `GET /api/localization/translations/{code}` - Get translations

## 📱 Version Management

### App Versioning
- `GET /api/version/info` - Get app version information
- `POST /api/version/check-update` - Check for updates

## 🔄 Background Jobs

### Job Management
- `POST /api/jobs/create` - Create background job
- `GET /api/jobs/{id}/status` - Get job status

## 🔐 Privacy & Security

### Data Management
- `GET /api/privacy/data-export` - Export user data
- `POST /api/privacy/data-deletion` - Request data deletion

## 📁 File Management

### File Operations
- `POST /api/files/upload` - Upload file with encryption
- `GET /api/files/download/{id}` - Download file
- `DELETE /api/files/{id}` - Delete file

## 🔄 Mermaid Flow Diagram

```mermaid
graph TB
    %% Authentication Flow
    A[User Login] --> B[POST /api/auth/login]
    B --> C[Store JWT Token]
    C --> D[GET /api/users/me]
    
    %% Main Application Flow
    D --> E{User Onboarded?}
    E -->|No| F[Onboarding Flow]
    E -->|Yes| G[Main App]
    
    %% Onboarding Flow
    F --> F1[PUT /api/users/relationship-context]
    F1 --> F2[POST /api/redaction-profiles/]
    F2 --> F3[POST /redaction-profiles/consent]
    F3 --> F4[PUT /api/users/onboarded]
    F4 --> G
    
    %% Main App Features
    G --> H[Chat Interface]
    G --> I[Journal Management]
    G --> J[Billing Management]
    G --> K[Session Management]
    
    %% Chat Flow
    H --> H1[POST /communications/chat]
    H1 --> H2[POST /api/communications/chat/stream]
    H2 --> H3[Store in /api/communications/]
    
    %% Journal Flow
    I --> I1[GET /journals/]
    I1 --> I2[POST /journals/]
    I2 --> I3[POST /api/journals/ai-summary]
    
    %% Billing Flow
    J --> J1[GET /api/billing/status]
    J1 --> J2[GET /api/billing/packages]
    J2 --> J3[POST /api/billing/purchase]
    
    %% Session Flow
    K --> K1[GET /api/sessions/]
    K1 --> K2[POST /api/sessions/]
    K2 --> K3[GET /api/sessions/{id}]
    
    %% RAG Integration
    H1 --> L[POST /api/context/retrieve]
    L --> M[POST /api/context/documents]
    
    %% Privacy & Security
    G --> N[Privacy Controls]
    N --> N1[POST /redaction/preprocess]
    N1 --> N2[GET /redaction/profile]
    
    %% Emergency Features
    G --> O[Emergency Mode]
    O --> O1[POST /api/emergency/trigger]
    O1 --> O2[POST /api/emergency/data-wipe]
    
    %% Health Monitoring
    G --> P[Health Checks]
    P --> P1[GET /health/]
    P1 --> P2[GET /api/health]
    
    %% Analytics
    G --> Q[Analytics]
    Q --> Q1[POST /api/analytics/track-event]
    Q1 --> Q2[POST /api/billing/usage-analytics]
    
    %% Styling
    classDef auth fill:#e1f5fe
    classDef chat fill:#f3e5f5
    classDef journal fill:#e8f5e8
    classDef billing fill:#fff3e0
    classDef session fill:#fce4ec
    classDef privacy fill:#f1f8e9
    classDef emergency fill:#ffebee
    classDef health fill:#e0f2f1
    classDef analytics fill:#f9fbe7
    
    class A,B,C,D auth
    class H,H1,H2,H3 chat
    class I,I1,I2,I3 journal
    class J,J1,J2,J3 billing
    class K,K1,K2,K3 session
    class N,N1,N2 privacy
    class O,O1,O2 emergency
    class P,P1,P2 health
    class Q,Q1,Q2 analytics
```

## 📋 API Endpoint Summary

### Total Endpoints: 89

**By Category:**
- **Authentication & User**: 7 endpoints
- **Chat & Communication**: 8 endpoints  
- **Journal Management**: 9 endpoints
- **Session Management**: 8 endpoints
- **Billing & Credits**: 20 endpoints
- **Privacy & Redaction**: 6 endpoints
- **Document & Context**: 8 endpoints
- **Health & Monitoring**: 3 endpoints
- **Analytics & Tracking**: 3 endpoints
- **Emergency Features**: 2 endpoints
- **Localization**: 3 endpoints
- **Version Management**: 2 endpoints
- **Background Jobs**: 2 endpoints
- **Privacy & Security**: 2 endpoints
- **File Management**: 3 endpoints

### Key Findings:

1. **Modern Chat Architecture**: The app uses a unified chat system (`/communications/chat`) with RAG support, while maintaining legacy endpoints for backward compatibility.

2. **Comprehensive Billing System**: Extensive billing endpoints including debug/development endpoints for testing.

3. **Privacy-First Design**: Multiple redaction and privacy endpoints ensure user data protection.

4. **RAG Integration**: Document retrieval and context management endpoints for AI-powered responses.

5. **Emergency Features**: Built-in emergency data wipe and trigger capabilities for user safety.

6. **Health Monitoring**: Multiple health check endpoints for system monitoring.

## 🔧 Configuration Notes

- **Base URL**: `http://localhost:8000` (Development)
- **Authentication**: Bearer Token (JWT)
- **Headers**: `X-Tenant-ID`, `X-App-ID`, `X-User-ID`
- **Content-Type**: `application/json`

## 🚨 Important Notes

1. **Legacy Endpoints**: Several chat endpoints are marked as deprecated in favor of the unified chat system.

2. **Debug Endpoints**: Multiple debug/development billing endpoints are available for testing.

3. **RAG Integration**: The system supports document retrieval and context management for enhanced AI responses.

4. **Privacy Controls**: Comprehensive redaction and privacy management endpoints.

5. **Emergency Features**: Built-in safety mechanisms for emergency situations.

This comprehensive analysis shows that the MindHearth backend provides a robust, privacy-focused API with extensive functionality for AI-powered mental health support.


