# Agent Version Creation Error - model_name Invalid Argument

## Error Summary

**Error Message:**
```
'model_name' is an invalid keyword argument for AgentVersion
```

**Location:**
- Backend: `fortessa_admin/features/agents/data/datasources/agent_version_service.dart:246:15`
- API Endpoint: `POST /api/v1/agents/{agentId}/versions`
- Status Code: `500 Internal Server Error`

**Error Context:**
The error occurs when attempting to create a new agent version. The backend is receiving `model_name` as a parameter, but the `AgentVersion` model does not accept this field.

## Root Cause Analysis

The error indicates that:
1. The frontend (fortessa_admin) is sending `model_name` in the request payload
2. The backend `AgentVersion` model/class does not have a `model_name` field
3. When the backend tries to instantiate `AgentVersion` with `model_name`, it raises a TypeError

## Investigation Steps

### 1. Check AgentVersion Model Definition
**Location:** Backend codebase (fortessa_admin or backend API)
- Review the `AgentVersion` model/class definition
- Identify what fields are actually accepted
- Check if there's a similar field with a different name (e.g., `model`, `llm_model`, `model_id`)

### 2. Check Frontend Request Payload
**Location:** `fortessa_admin/features/agents/data/datasources/agent_version_service.dart:212-246`
- Review the `createVersion` method
- Identify where `model_name` is being set in the request data
- Check if this field should be renamed or removed

### 3. Check API Schema/Validation
- Review the API endpoint schema for creating agent versions
- Verify what fields are expected vs. what's being sent
- Check if there's API documentation that specifies the correct field names

## Potential Solutions

### Solution 1: Remove model_name from Request
If `model_name` is not needed or is deprecated:
```dart
// In agent_version_service.dart createVersion method
// Remove or comment out model_name from request data
final requestData = {
  // ... other fields
  // 'model_name': modelName,  // REMOVE THIS LINE
};
```

### Solution 2: Rename Field to Match Backend
If the backend expects a different field name:
```dart
// Change model_name to the correct field name
final requestData = {
  // ... other fields
  'model': modelName,  // or 'llm_model', 'model_id', etc.
};
```

### Solution 3: Update Backend Model
If `model_name` should be a valid field:
- Add `model_name` field to the `AgentVersion` model in the backend
- Update database schema if needed
- Update API validation/serialization

### Solution 4: Map Field Name
If there's a mismatch between frontend and backend naming:
```dart
// Map frontend field to backend field
final requestData = {
  // ... other fields
  'llm_model_name': modelName,  // Use correct backend field name
};
```

## Recommended Action

1. **Immediate Fix:** Check the backend `AgentVersion` model to see what fields it actually accepts
2. **Verify:** Compare the frontend request payload with the backend model definition
3. **Fix:** Either:
   - Remove `model_name` from the frontend request if it's not needed
   - Rename it to match the backend field name
   - Add `model_name` to the backend model if it should be supported

## Related Files (in fortessa_admin codebase)

- `features/agents/data/datasources/agent_version_service.dart` (lines 212-246)
- Backend `AgentVersion` model definition
- Backend API endpoint handler for `POST /agents/{id}/versions`

## Error Log Context

From the error log:
```
🐛 Creating new version for agent: 696774ce-b5f1-4754-9466-a00e83c9f06a
POST http://3.150.176.19:3012/api/v1/agents/696774ce-b5f1-4754-9466-a00e83c9f06a/versions 500 (Internal Server Error)
⛔ Error creating version for agent 696774ce-b5f1-4754-9466-a00e83c9f06a: Exception: Failed to create version: Version creation failed: 'model_name' is an invalid keyword argument for AgentVersion
Error auto-creating first version: Exception: Failed to create version: Version creation failed: 'model_name' is an invalid keyword argument for AgentVersion
```

This indicates the error occurs during automatic version creation when an agent is first loaded/accessed.
