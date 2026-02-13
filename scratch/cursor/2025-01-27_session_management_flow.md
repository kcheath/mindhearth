# Mindhearth Session Management Flow

## Overview
This document outlines when and how chat sessions are created and retrieved from the backend in the Mindhearth application.

## Session Creation

### When Sessions Are Created

1. **User-Initiated Session Creation**
   - **Trigger**: User clicks "Start New Session" button in the chat UI
   - **Location**: `lib/features/chat/presentation/pages/chat_page.dart` → `_startNewSession()`
   - **Flow**:
     ```
     ChatPage._startNewSession()
       → ChatNotifier.createNewSession()
         → CreateSessionUseCase
           → ChatRepositoryImpl.createSession()
             → ApiService.post('/sessions/')
     ```
   - **Backend Endpoint**: `POST /sessions/`
   - **Request Payload**:
     ```json
     {
       "name": "New Chat" (or user-provided name),
       "session_type": "conversation",
       "purpose": "AI-assisted therapy conversation"
     }
     ```
   - **Response**: Session object with `id`, `name`, `session_type`, `purpose`, `created_at`, `updated_at`

2. **Automatic Session Creation After Deletion**
   - **Trigger**: User deletes the currently active session
   - **Location**: `lib/features/chat/providers/chat_provider.dart` → `deleteSession()`
   - **Flow**: After successful deletion of current session, automatically calls `createNewSession()`
   - **Code Reference**:
     ```692:693:lib/features/chat/providers/chat_provider.dart
     await createNewSession();
     ```

3. **Fallback Session Creation**
   - **Trigger**: When loading last session but no sessions exist
   - **Location**: `lib/features/chat/providers/chat_provider.dart` → `loadLastSession()`
   - **Flow**: If `state.sessions.isEmpty`, creates a new session
   - **Code Reference**:
     ```742:745:lib/features/chat/providers/chat_provider.dart
     } else {
       // No sessions available, create a new one
       await createNewSession();
     ```

### Session Creation Implementation Details

**Frontend Layer (ChatProvider)**:
- **File**: `lib/features/chat/providers/chat_provider.dart`
- **Method**: `createNewSession({String? name})`
- **Behavior**:
  - Sets loading state
  - Calls `CreateSessionUseCase` with timeout (5 seconds)
  - On success:
    - Updates `currentSessionId` to new session ID
    - Clears messages array
    - Adds new session to sessions list
    - Validates session ID format
  - On failure: Sets error state

**Repository Layer**:
- **File**: `lib/core/data/repositories/chat_repository_impl.dart`
- **Method**: `createSession({required String name, String? sessionType, String? purpose})`
- **Backend Call**: `POST /sessions/` via `ApiService.post()`
- **Response Handling**: Parses JSON response into `Session` entity

**API Service Layer**:
- **File**: `lib/core/services/api_service.dart`
- **Method**: `createSession({String? name, String sessionType = 'conversation', String? purpose})`
- **Endpoint**: `POST /sessions/`
- **Request Body**:
  ```dart
  {
    if (name != null) 'name': name,
    'session_type': sessionType,
    if (purpose != null) 'purpose': purpose,
  }
  ```

## Session Retrieval

### When Sessions Are Retrieved

1. **Chat Initialization (Automatic)**
   - **Trigger**: When `ChatNotifier` is first created
   - **Location**: `lib/features/chat/providers/chat_provider.dart` → `_initializeChat()`
   - **Flow**:
     ```
     ChatNotifier constructor
       → _initializeChat() (delayed 500ms)
         → loadSessions()
           → GetSessionsUseCase
             → ChatRepositoryImpl.getSessions()
               → ApiService.get('/sessions/')
     ```
   - **Backend Endpoint**: `GET /sessions/`
   - **Query Parameters**: 
     - `limit`: 100 (default)
     - `offset`: 0 (default)
     - `session_type`: optional filter
   - **Response Handling**: Handles both direct array response and wrapped `{"sessions": [...]}` format
   - **Code Reference**:
     ```108:120:lib/features/chat/providers/chat_provider.dart
     Future<void> _initializeChat() async {
       try {
         appLogger.info('Initializing chat...');
         
         // Only load sessions, don't create new session automatically
         await loadSessions();
         
         appLogger.info('Chat initialization completed with ${state.sessions.length} sessions');
       } catch (e) {
         appLogger.error('Error initializing chat', {'error': e.toString()});
         state = state.copyWith(error: 'Failed to initialize chat');
       }
     }
     ```

2. **Session Switching**
   - **Trigger**: User selects a different session from session history
   - **Location**: `lib/features/chat/providers/chat_provider.dart` → `switchToSession()`
   - **Flow**:
     ```
     ChatNotifier.switchToSession(sessionId)
       → GetSessionMessagesUseCase
         → ChatRepositoryImpl.getSessionMessages()
           → ApiService.get('/communications/')
     ```
   - **Backend Endpoint**: `GET /communications/` with query params:
     - `session_id`: the session ID
     - `item_type`: 'chat'
     - `limit`: optional
     - `offset`: optional
   - **Behavior**:
     - Loads all messages for the session
     - Sorts messages chronologically (oldest first)
     - Clears and repopulates conversation history
     - Updates `currentSessionId` in state
   - **Code Reference**:
     ```217:268:lib/features/chat/providers/chat_provider.dart
     Future<void> switchToSession(String sessionId) async {
       try {
         // Validate session ID format
         if (!SessionValidator.validateSessionId(sessionId, context: 'session_switch')) {
           appLogger.warning('⚠️ Using legacy session ID format', {'sessionId': sessionId});
         }
         
         appLogger.info('🔄 Starting session switch', {'sessionId': sessionId, 'previousSessionId': state.currentSessionId});
         state = state.copyWith(isLoading: true, error: null);
         
         // Switch to session - load its messages
         final result = await _getSessionMessagesUseCase(sessionId: sessionId);
         if (result.isSuccess && result.data != null) {
           final messages = result.data!;
           appLogger.debug('📊 Loaded ${messages.length} messages for session $sessionId');
           
           // Sort messages chronologically (oldest first) for proper conversation flow
           messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
           appLogger.debug('📊 Sorted ${messages.length} messages chronologically');
           
           // Clear conversation history for new session
           _conversationHistory.clear();
           
           // Populate conversation history from loaded messages (already sorted)
           _conversationHistory = messages.map((msg) => {
             'role': msg.role ?? 'user',
             'content': msg.content ?? '',
           }).toList();
           
           appLogger.debug('📊 Populated conversation history with ${_conversationHistory.length} items');
           
           state = state.copyWith(
             currentSessionId: sessionId,
             messages: messages,
             isLoading: false,
           );
           appLogger.info('✅ Session switch successful', {'sessionId': sessionId, 'messageCount': messages.length});
         } else {
           appLogger.error('❌ Session switch failed', {'sessionId': sessionId, 'error': result.error?.message});
           state = state.copyWith(
             isLoading: false,
             error: result.error?.message ?? 'Failed to load session messages',
           );
         }
       } catch (e) {
         appLogger.error('💥 Error switching to session', {'sessionId': sessionId, 'error': e.toString()});
         state = state.copyWith(
           isLoading: false,
           error: 'Failed to switch to session',
         );
       }
     }
     ```

3. **Manual Session Refresh**
   - **Trigger**: After session deletion, update, or other operations
   - **Location**: `lib/features/chat/providers/chat_provider.dart` → `loadSessions()`
   - **Called After**:
     - Session name update
     - Session deletion
   - **Code Reference**:
     ```122:162:lib/features/chat/providers/chat_provider.dart
     Future<void> loadSessions() async {
       try {
         state = state.copyWith(isLoading: true, error: null);
         
         // Add timeout to prevent hanging
         final result = await _getSessionsUseCase().timeout(
           const Duration(seconds: 5),
           onTimeout: () {
             throw Exception('Session loading timed out');
           },
         );
         
         if (result.isSuccess) {
           final sessions = result.data!.map((session) => {
             'id': session.id,
             'name': session.name,
             'session_type': session.sessionType,
             'purpose': session.purpose,
             'created_at': session.createdAt.toIso8601String(),
             'updated_at': session.updatedAt.toIso8601String(),
           }).toList();
         
         state = state.copyWith(
           sessions: sessions,
           isLoading: false,
         );
         
         appLogger.info('Loaded ${sessions.length} sessions');
         } else {
           final errorMessage = result.error?.message ?? 'Failed to load sessions';
           throw Exception(errorMessage);
         }
       } catch (e) {
         appLogger.error('Error loading sessions', {'error': e.toString()});
         state = state.copyWith(
           isLoading: false,
           error: 'Failed to load sessions: ${e.toString()}',
         );
       }
     }
     ```

4. **Single Session Retrieval**
   - **Trigger**: When detailed session information is needed
   - **Location**: `lib/core/data/repositories/chat_repository_impl.dart` → `getSession(String id)`
   - **Backend Endpoint**: `GET /sessions/{id}`
   - **Use Case**: Retrieves a single session by ID (not commonly used in chat flow)

### Session Retrieval Implementation Details

**Repository Layer**:
- **File**: `lib/core/data/repositories/chat_repository_impl.dart`
- **Method**: `getSessions({int? limit, int? offset})`
- **Backend Call**: `GET /sessions/` via `ApiService.get()`
- **Response Handling**: 
  - Handles both direct array `[...]` and wrapped `{"sessions": [...]}` formats
  - Maps JSON to `Session` entities
  - Returns `Result<List<Session>>`

**API Service Layer**:
- **File**: `lib/core/services/api_service.dart`
- **Method**: `getSessions({int limit = 100, int offset = 0, String? sessionType})`
- **Endpoint**: `GET /sessions/`
- **Query Parameters**:
  ```dart
  {
    'limit': limit,
    'offset': offset,
    if (sessionType != null) 'session_type': sessionType,
  }
  ```

## Session State Management

### Current Session Tracking
- **State Variable**: `ChatState.currentSessionId` (nullable String)
- **Initialization**: Set to `null` on chat initialization
- **Updates When**:
  - New session created → set to new session ID
  - Session switched → set to selected session ID
  - Session cleared → set to `null`
  - Current session deleted → set to `null`, then new session created

### Session List Management
- **State Variable**: `ChatState.sessions` (List<Map<String, dynamic>>)
- **Initialization**: Empty list `[]`
- **Updates When**:
  - Sessions loaded from backend → replaced with full list
  - New session created → appended to existing list (optimistic update)
  - Session deleted → reloaded from backend
  - Session updated → reloaded from backend

## Message Sending and Session Context

### Session ID in Message Sending
- **When Sending Messages**: `state.currentSessionId` is passed to backend
- **If Session ID is Null**: 
  - The `sessionId` parameter is passed as `null` to the unified chat endpoint
  - Backend may handle session creation automatically (backend behavior)
  - Frontend does NOT automatically create a session before sending first message
- **Code Reference**:
  ```393:400:lib/features/chat/providers/chat_provider.dart
  final result = await _sendUnifiedMessageUseCase(
    message: content,
    sessionId: state.currentSessionId,
    mode: mode,
    ragOptions: ragOptions,
    metadata: metadata,
    conversationHistory: _conversationHistory,
  );
  ```

## Backend API Endpoints Summary

### Session Creation
- **Endpoint**: `POST /sessions/`
- **Request Body**:
  ```json
  {
    "name": "string",
    "session_type": "conversation",
    "purpose": "string (optional)"
  }
  ```
- **Response**: Session object with `id`, `name`, `session_type`, `purpose`, `created_at`, `updated_at`

### Session Retrieval (List)
- **Endpoint**: `GET /sessions/`
- **Query Parameters**:
  - `limit`: integer (default: 100)
  - `offset`: integer (default: 0)
  - `session_type`: string (optional)
- **Response**: Array of session objects or `{"sessions": [...]}`

### Session Retrieval (Single)
- **Endpoint**: `GET /sessions/{id}`
- **Response**: Single session object

### Session Messages Retrieval
- **Endpoint**: `GET /communications/`
- **Query Parameters**:
  - `session_id`: string (required)
  - `item_type`: "chat"
  - `limit`: integer (optional)
  - `offset`: integer (optional)
- **Response**: Array of communication items (messages)

## Key Design Decisions

1. **No Automatic Session Creation on First Message**
   - Sessions must be explicitly created by user action
   - If `currentSessionId` is null when sending message, it's passed as null to backend
   - Backend may handle session creation (backend responsibility)

2. **Optimistic Updates**
   - New sessions are added to state immediately without reloading full list
   - Improves perceived performance

3. **Session Loading on Initialization**
   - Sessions are loaded automatically when chat provider initializes
   - No automatic session selection - user must explicitly select or create

4. **Session Switching Loads Messages**
   - Switching sessions automatically loads all messages for that session
   - Messages are sorted chronologically
   - Conversation history is rebuilt from loaded messages

5. **Timeout Protection**
   - Session operations have 5-second timeouts to prevent hanging
   - Graceful error handling with user-visible error messages

## Related Files

- **Chat Provider**: `lib/features/chat/providers/chat_provider.dart`
- **Chat Repository**: `lib/core/data/repositories/chat_repository_impl.dart`
- **API Service**: `lib/core/services/api_service.dart`
- **Session Provider**: `lib/core/providers/session_provider.dart`
- **Chat Page UI**: `lib/features/chat/presentation/pages/chat_page.dart`
- **Session Entity**: `lib/features/chat/domain/entities/session.dart`
