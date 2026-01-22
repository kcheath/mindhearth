# Project Context: MindHearth

## Architecture

### Backend Stack
- **Fortessa Platform API**: REST API with JWT authentication
- **Base URL**: `http://3.150.176.19:3012/api/v1` (configured via `DebugConfig.baseUrl`)
- **Authentication**: Bearer token with secure storage
- **Headers**: `Authorization: Bearer <token>` (backend extracts tenant/app/user from JWT automatically)
- **Database**: PostgreSQL with UUID primary keys
- **RAG Integration**: Document retrieval and context management

### Frontend Stack
- **Framework**: Flutter 3.8.1+ with Dart 3.8.1+
- **State Management**: Riverpod with code generation
- **Navigation**: GoRouter with authentication guards
- **UI Framework**: Material 3 with dynamic theming
- **HTTP Client**: Dio with interceptors
- **Storage**: Flutter Secure Storage for tokens
- **Code Generation**: build_runner, freezed, json_serializable

### Database
- **Backend**: PostgreSQL with UUID-based sessions
- **Local Storage**: Flutter Secure Storage for authentication
- **Caching**: In-memory state management via Riverpod

### Orchestration / LLM Usage
- **AI Chat**: Unified chat endpoint with RAG support
- **Session Management**: UUID-based session tracking
- **Context Retrieval**: Document-based RAG with metadata
- **Streaming**: Real-time chat responses
- **Billing Integration**: Credit-based usage tracking

## Conventions

### Naming Rules
- **Files**: snake_case for Dart files (`chat_provider.dart`)
- **Classes**: PascalCase (`ChatProvider`, `UnifiedChatService`)
- **Variables**: camelCase (`chatState`, `isLoading`)
- **Constants**: SCREAMING_SNAKE_CASE (`API_BASE_URL`)
- **Routes**: kebab-case (`/session-info/:sessionId`)

### Directory Conventions
```
lib/
├── app/                    # Application layer (router, themes, providers)
├── core/                   # Shared layer (models, services, utils, constants)
│   ├── models/            # Domain models and DTOs
│   ├── services/          # Core services (API, storage, billing)
│   ├── utils/             # Utility functions and helpers
│   ├── constants/         # App constants and configuration
│   ├── patterns/          # Design pattern implementations
│   └── domain/            # Domain entities and use cases
└── features/              # Feature modules (auth, chat, journal, etc.)
    ├── auth/              # Authentication feature
    ├── chat/              # AI chat interface
    ├── sessions/          # Session management
    ├── journal/           # Journal entries
    ├── documents/         # Document management
    ├── reports/           # Reports and analytics
    ├── billing/           # Billing and payments
    └── settings/          # App settings
```

### Schema & Model Rules
- **Models**: Use `freezed` for immutable data classes
- **JSON**: Use `json_serializable` for serialization
- **Validation**: Implement validation in model constructors
- **Null Safety**: All models are null-safe with proper defaults
- **API Responses**: Wrap in `Result<T>` pattern for error handling

### Security Standards
- **Authentication**: JWT tokens with secure storage
- **API Keys**: Tenant/application IDs extracted from JWT token by backend (no longer sent in headers)
- **Safety Codes**: 6-digit verification system
- **Data Encryption**: Flutter Secure Storage for sensitive data
- **Input Validation**: Comprehensive validation on all user inputs

## API & Models Index

### API Endpoints
All endpoints are relative to base URL: `http://3.150.176.19:3012/api/v1`

**Authentication**:
- `POST /auth/login` - User authentication
- `GET /auth/me` - Get current user
- `POST /auth/refresh` - Refresh token
- `POST /auth/logout` - Logout

**Chat & Communication**:
- `POST /communications/chat` - Unified AI chat with RAG support
- `POST /communications/chat/stream` - Streaming chat (SSE)
- `GET /communications/` - Get communication history
- `POST /communications/` - Create communication item

**Sessions**:
- `GET /sessions/` - List user sessions
- `POST /sessions/` - Create new session
- `GET /sessions/:id` - Get session details
- `PUT /sessions/:id` - Update session
- `DELETE /sessions/:id` - Delete session

**Journals**:
- `GET /journals/` - List journal entries
- `POST /journals/` - Create journal entry
- `GET /journals/:id` - Get journal entry
- `PUT /journals/:id` - Update journal entry
- `DELETE /journals/:id` - Delete journal entry
- `POST /journals/ai-summary` - Generate AI journal summary

**Billing**:
- `GET /billing/balance` - Get user balance
- `GET /billing/status` - Get billing status
- `GET /billing/ledger` - Get credit ledger
- `POST /billing/check-operation` - Check if operation is allowed

**Documents**:
- `POST /documents/` - Upload documents (Note: May need adjustment based on backend clarification)
- `POST /context/retrieve` - Retrieve documents for RAG (Note: May need adjustment)

**Privacy**:
- `GET /redaction-profiles/` - Get redaction profile
- `POST /redaction-profiles/` - Create redaction profile
- `PUT /redaction-profiles/` - Update redaction profile
- `POST /redaction-profiles/consent` - Update consent

### Core Models
- **User**: User profile with tenant ID and onboarding status
- **Session**: Chat session with UUID, name, type, and metadata
- **UnifiedChatData**: Complete chat response with RAG metadata
- **OnboardingData**: User onboarding information (situation, redaction, consent)
- **AuthState**: Authentication state management
- **SessionState**: Session management state
- **BillingState**: Billing and credit management

### Domain Entities
- **Result<T>**: Generic result wrapper for API responses
- **AppError**: Standardized error handling
- **ApiResponse**: API response wrapper
- **UnifiedChatResponse**: Chat response with metadata
- **RAGMetadata**: RAG context and source information

### State Management
- **AuthProvider**: Authentication state and user management
- **ChatProvider**: Chat state and message handling
- **SessionProvider**: Session management and history
- **BillingProvider**: Billing state and credit management
- **OnboardingProvider**: Onboarding flow state

### Dependency Injection Pattern
- **Riverpod Providers**: All dependency injection uses Riverpod providers
- **Constructor Injection**: StateNotifiers use constructor injection for all dependencies
- **Use Case Providers**: Use cases are provided via Riverpod providers in `usecase_providers.dart`
- **Repository Providers**: Repositories are provided via Riverpod providers in `repository_providers.dart`
- **Service Providers**: Core services are provided via Riverpod providers in `core_service_providers.dart`
- **No Service Locator**: Service locator pattern (GetIt) is not used in providers - all dependencies flow through Riverpod

## Change Log

- [2025-01-27] Initial creation of PROJECT_CONTEXT.md
- [2025-01-27] **Chat API Analysis**: Identified mixed implementation - Enhanced Chat Page uses unified methods, main Chat Page still uses legacy methods. Legacy endpoints marked as deprecated.
- [2025-01-27] **Chat Migration Complete**: Successfully migrated all chat components to unified chat service. Legacy methods deprecated and removed from active use. All chat pages now use `sendUnifiedMessage()` and `sendUnifiedStreamingMessage()` methods.
- [2025-01-27] **Authentication Fixes**: Fixed missing authentication headers (X-User-ID, X-Tenant-ID, X-App-ID) in API requests. Added JWT token decoder to extract user ID from tokens. Updated request format for unified chat API to match backend expectations.
- [2025-01-27] **Response Parsing Fix**: Fixed UnifiedChatResponse parsing to handle flat backend response format. Updated UnifiedChatData and RAGMetadata models to correctly map backend fields (id→communicationId, message→response, etc.).
- [2025-01-27] **Billing Endpoints Fix**: Fixed missing `/api` prefix in billing service endpoints. Updated all billing URLs from `/billing/*` to `/api/billing/*` to match backend API structure.
- [2025-01-27] **Balance Refresh Fix**: Fixed balance not refreshing after credit top-up by using billing status endpoint instead of separate balance endpoint. The `/api/billing/balance` endpoint returns 500 error, but `/api/billing/status` includes balance information and works correctly.
- [2025-01-27] **Debug Purchase Endpoint Fix**: Fixed debug purchase simulation by updating endpoint from `/api/billing/debug/simulate-purchase` (404 error) to `/api/billing/dev/top-up` (working endpoint). Both endpoints have identical functionality for adding credits.
- [2025-01-27] **AI Journal Summary Endpoint Fix**: Fixed AI journal summary endpoint by adding `/api` prefix. Updated endpoints from `/journals/ai-summary` (404 error) to `/api/journals/ai-summary` (working endpoint) in journal service and repository.
- [2025-01-27] **AI Journal Summary Response Parsing Fix**: Fixed response parsing error by creating dedicated `AIJournalSummaryResponse` model to handle backend response format. Backend returns `{id, ai_summary, created_at}` but app expected full `JournalEntry` structure. Updated journal service and provider to use new response model.
- [2025-01-27] **Journal Entry Deletion Fix**: Fixed missing journal entry deletion functionality. Added `deleteJournalEntry` method to `JournalService` and `JournalNotifier`. Updated UI to handle deletion success/failure properly and refresh journal list after deletion.
- [2025-01-27] **Journal Entry Deletion Compilation Fix**: Fixed compilation error where `deleteJournalEntry` method was returning `void` instead of `bool`. Updated core journal provider method to return `bool` for proper success/failure handling in UI.
- [2025-01-27] **Journal Entry Deletion Response Parsing Fix**: Fixed response parsing error in `deleteJournalEntry` API service method. Backend returns string/empty response but frontend expected JSON object. Changed return type from `Map<String, dynamic>` to `void` and return `null` for successful deletions.
- [2025-01-27] **Journal Tags Config Endpoint Fix**: Fixed missing `/api` prefix in journal tags configuration endpoint. Updated endpoints from `/journals/tags/config` (404 error) to `/api/journals/tags/config` (working endpoint) in journal repository and provider.
- [2025-01-27] **AI Journal Summary Context Fix**: Fixed AI journal summary to include conversation history for proper context. Added chat history retrieval and passing to backend. Updated `createAIJournalEntry`, `createAIJournalSummary`, and `generateAISummary` methods to fetch and send conversation history (last 50 messages) to provide meaningful context for AI summary generation.
- [2025-01-27] **Journal Entries Sorting Fix**: Added automatic sorting of journal entries by creation date (most recent first) in the journal state management. Updated `loadEntries`, `addEntry`, and `updateEntry` methods to maintain chronological order for better user experience.
- [2025-01-27] **Complete API Endpoints Analysis**: Conducted comprehensive analysis of all published API endpoints in the backend. Identified 89 total endpoints across 15 categories including authentication, chat, journal, session, billing, privacy, document management, health monitoring, analytics, emergency features, localization, version management, background jobs, and file management. Created detailed API flow diagram and documentation in `archive/backend_docs/API_FLOW_DIAGRAM.md` showing complete backend API architecture with modern unified chat system, RAG integration, privacy controls, and emergency features.
- [2025-01-27] **Backend Documentation Archive**: Moved all backend-related documentation files to `archive/backend_docs/` folder. Archived documents include: API_DOCUMENTATION.md, API_ENDPOINTS_DOCUMENTATION.md, API_ENDPOINT_FIXES.md, API_FLOW_DIAGRAM.md, BACKEND_INTEGRATION_GUIDE.md, and BACKEND_INTEGRATION_TEST_PLAN.md. Going forward, all API contract documents and integration documents should be placed in the `/fortessa_shared` folder for centralized management.
- [2026-01-28] **API Migration to Fortessa Platform**: Migrated all API endpoints to align with Fortessa Platform API specification. Updated base URL from `http://3.150.176.19:8080` to `http://3.150.176.19:3012/api/v1`. Removed unnecessary headers (X-Tenant-ID, X-App-ID, X-User-ID) as backend extracts these from JWT token. Updated all endpoint paths to use `/api/v1/` prefix pattern. Removed all deprecated chat methods. Cleaned up unused imports and orphaned code. All endpoints now follow the documented API structure.
- [2026-01-28] **Dependency Injection Standardization**: Standardized all StateNotifier providers to use constructor injection with Riverpod providers instead of GetIt service locator pattern. Refactored `AuthNotifier`, `OnboardingNotifier`, and `SafetyCodeNotifier` to inject use cases via constructors. Added missing use case providers for auth and onboarding use cases. Updated `core_service_providers.dart` to create services directly instead of wrapping service locator. All providers now follow consistent dependency injection pattern improving testability and maintainability.
- Future changes will be appended here automatically

---

*This document serves as the authoritative context for the MindHearth project. It should be updated whenever significant architectural changes are made.*
