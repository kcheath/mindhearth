# Session Selection Debugging Enhancements

## 🔍 **Debugging Issues Added**

### **1. Enhanced Data Structure Logging**
**File:** `lib/core/data/repositories/chat_repository_impl.dart`

**Added comprehensive logging to debug:**
- Full API response data structure
- Communications list length and content
- Individual communication item structure
- Parsing success/failure for each item

```dart
// Enhanced logging to debug data structure
appLogger.debug('📊 Communications API response data structure:', {'data': data});
appLogger.debug('📊 Communications list length: ${communicationsList.length}');

if (communicationsList.isNotEmpty) {
  appLogger.debug('📊 First communication item structure:', {'item': communicationsList.first});
}
```

### **2. Flexible Data Parsing**
**Enhanced the ChatMessage parsing to handle different field names:**

```dart
// Handle different field names from communications endpoint
final chatMessage = ChatMessage(
  id: item['id'] as String? ?? 'comm_${DateTime.now().millisecondsSinceEpoch}',
  sessionId: item['session_id'] as String? ?? sessionId,
  content: item['original_content'] as String? ?? item['content'] as String? ?? '',
  role: item['role'] as String? ?? 'user',
  timestamp: item['created_at'] != null 
      ? DateTime.tryParse(item['created_at'] as String) ?? DateTime.now()
      : DateTime.now(),
  messageType: item['item_type'] as String?,
  metadata: {
    'redacted_content': item['redacted_content'],
    'consent': item['consent'],
    'created_at': item['created_at'],
    'updated_at': item['updated_at'],
  },
);
```

### **3. Enhanced Session Switching Logging**
**File:** `lib/features/chat/providers/chat_provider.dart`

**Added detailed logging for:**
- Session switch initiation with previous/current session IDs
- Message count loaded for each session
- Conversation history population
- Success/failure status with detailed error information

```dart
appLogger.info('🔄 Starting session switch', {'sessionId': sessionId, 'previousSessionId': state.currentSessionId});
appLogger.debug('📊 Loaded ${messages.length} messages for session $sessionId');
appLogger.debug('📊 Populated conversation history with ${_conversationHistory.length} items');
```

## 🎯 **What This Will Help Debug**

### **1. Data Structure Issues**
- **API Response Format** - See exactly what the communications endpoint returns
- **Field Name Mismatches** - Identify if field names differ from expected
- **Data Type Issues** - Catch type conversion problems

### **2. Session Switching Issues**
- **Session ID Tracking** - See which session is being switched to/from
- **Message Loading** - Verify how many messages are loaded per session
- **Conversation History** - Track conversation history population

### **3. Parsing Issues**
- **Individual Item Parsing** - See which communication items fail to parse
- **Field Mapping** - Verify correct field mapping from API to ChatMessage
- **Error Handling** - Catch and log parsing errors with context

## 📊 **Expected Log Output**

When you switch sessions, you should now see logs like:

```
🔄 Starting session switch - {sessionId: abc123, previousSessionId: def456}
📊 Communications API response data structure: {data: {communications: [...], total: 5}}
📊 Communications list length: 5
📊 First communication item structure: {item: {id: comm1, role: user, original_content: Hello...}}
📊 Parsed communication item: {id: comm1, role: user, content_length: 5}
📊 Loaded 5 messages for session abc123
📊 Populated conversation history with 5 items
✅ Session switch successful - {sessionId: abc123, messageCount: 5}
```

## 🚀 **Next Steps**

1. **Test session switching** - Try switching between different sessions
2. **Check logs** - Look for the new debug information in the console
3. **Identify issues** - Use the enhanced logging to pinpoint any problems
4. **Verify data flow** - Ensure messages are loading and displaying correctly

The enhanced debugging should help identify exactly where the session selection and message loading process might be failing.
