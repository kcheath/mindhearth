# Flutter UI Architecture

## Project Structure
Flutter applications (fortessa-frontend, mindhearth) are separate repositories from the backend. This document defines the architecture standards for all Flutter projects in the Fortessa workspace.

## API Integration

### Base Configuration
- **API Base URL**: `http://3.150.176.19:3012/api/v1`
- **Endpoint Format**: kebab-case (`/api/v1/auth/login`, `/api/v1/redaction-profiles`)
- **API Client**: Centralized HTTP client with interceptors for auth and error handling

### Authentication
- **Token Type**: JWT tokens
- **Token Storage**: Secure storage (flutter_secure_storage or similar)
- **Auto-refresh**: Automatically refresh tokens on expiration
- **Headers**: Include required headers in all requests:
  - `X-User-ID`: Current user ID
  - `X-Tenant-ID`: Current tenant ID
  - `X-App-ID`: Optional application identifier
  - `Authorization`: Bearer token

### Error Handling
- **401 Responses**: Auto-redirect to login screen
- **Error Messages**: User-friendly error messages with proper localization
- **Network Errors**: Handle offline scenarios gracefully
- **Error Logging**: Log errors to crash reporting service

## State Management

### Pattern
- **Primary**: Provider or Riverpod pattern (choose one per project and be consistent)
- **State Providers**: Use providers for business logic and data fetching
- **Local State**: Use StatefulWidget or local state management for UI-only state
- **Global State**: Use providers for shared application state (auth, user, tenant)

### Best Practices
- Keep providers focused and single-purpose
- Use `Consumer` or `context.watch()` for reactive UI updates
- Avoid prop drilling - use providers for shared state
- Separate business logic from UI components

## UI/UX Patterns

### Loading States
- Show loading indicators for all async operations
- Use skeleton screens for better perceived performance
- Disable interactive elements during loading

### Navigation
- Use named routes with parameter passing
- Implement deep linking support
- Handle navigation state restoration
- Use consistent navigation patterns (Material/Cupertino)

### Responsive Design
- Support multiple screen sizes
- Test on different device types (phone, tablet)
- Use responsive layouts and breakpoints

## Project Structure (Recommended)
```
lib/
  ├── main.dart
  ├── core/
  │   ├── api/          # API client, interceptors
  │   ├── models/        # Data models
  │   ├── providers/     # State providers
  │   ├── services/      # Business logic services
  │   ├── utils/         # Utilities, helpers
  │   └── constants/     # App constants
  ├── features/          # Feature-based modules
  │   ├── auth/
  │   ├── chat/
  │   └── ...
  └── widgets/           # Reusable widgets
```

## Key API Endpoints
- `/api/v1/auth` - Authentication (login, logout, refresh)
- `/api/v1/chat` - AI chat with RAG functionality
- `/api/v1/users` - User management
- `/api/v1/communications` - Chat history and messages
- `/api/v1/documents` - Document management
- `/api/v1/billing` - Credit system and billing

## Testing
- **Unit Tests**: Test business logic, services, and utilities
- **Widget Tests**: Test individual widgets and UI components
- **Integration Tests**: Test user flows and feature interactions
- **Test Commands**: `flutter test` for all tests
- **Coverage**: Aim for ≥80% code coverage

## Design Patterns Reference
- **Flutter Design Patterns Guide**: `/Users/kendrickheath/Projects/fortessa-frontend/flutter_design_patterns.pdf`
- This document contains the canonical design patterns and best practices for all Flutter projects in the Fortessa workspace
- **All Flutter development (fortessa-frontend, mindhearth) MUST follow the patterns and practices defined in this guide**
- Reference this guide for:
  - Architecture patterns
  - Code organization
  - Widget composition
  - State management patterns
  - Error handling strategies
