# Mindhearth Encryption Specification for Backend Team

## Overview

This document outlines how the Mindhearth Flutter application uses passphrase-based encryption for data at rest and how the backend should handle encrypted data for decryption by the frontend.

**Status:** ⚠️ **IMPORTANT NOTE** - The current implementation has encryption capabilities but data is currently being sent to the backend as **plaintext**. This document describes the **intended encryption architecture** that should be implemented.

---

## Encryption Architecture

### 1. Passphrase Management

#### Frontend Passphrase Storage
- **Storage Location**: Flutter Secure Storage (device keychain/keystore)
- **Storage Key**: `user_passphrase`
- **Lifecycle**: 
  - Set during onboarding
  - Stored locally on device (never sent to backend)
  - Cleared on logout or app uninstall

#### Passphrase Characteristics
- **User-Provided**: Set by user during onboarding
- **Minimum Length**: 8 characters (configurable in `AppConfig`)
- **Maximum Length**: 128 characters
- **Never Transmitted**: The passphrase is **never sent to the backend**
- **Device-Only**: Stored only in secure storage on the user's device

---

## Encryption Algorithm

### Key Derivation
The encryption key is derived from the user's passphrase using **SHA-256**:

```dart
// Pseudocode
key = SHA256(UTF8.encode(passphrase))
```

**Implementation Details:**
- Input: User passphrase (UTF-8 encoded string)
- Algorithm: SHA-256
- Output: 32-byte (256-bit) key

### Encryption Method
**Current Implementation**: XOR-based encryption (for demonstration)
**Note**: The code comments indicate this should be upgraded to a more robust encryption library in production.

**Encryption Process:**
1. Convert content to UTF-8 bytes
2. XOR each byte with corresponding key byte (cycling through key)
3. Base64 encode the result

**Pseudocode:**
```dart
encryptedBytes = []
for i in range(len(contentBytes)):
    encryptedBytes.append(contentBytes[i] ^ key[i % len(key)])
encryptedContent = base64.encode(encryptedBytes)
```

**Decryption Process:**
1. Base64 decode encrypted content
2. XOR each byte with corresponding key byte (cycling through key)
3. Convert back to UTF-8 string

**Pseudocode:**
```dart
encryptedBytes = base64.decode(encryptedContent)
decryptedBytes = []
for i in range(len(encryptedBytes)):
    decryptedBytes.append(encryptedBytes[i] ^ key[i % len(key)])
decryptedContent = utf8.decode(decryptedBytes)
```

---

## Data Fields That Should Be Encrypted

### Fields Requiring Encryption

The following fields should be encrypted using the passphrase before being sent to the backend:

1. **`original_content`** - User's original message/journal content
   - Used in: Communications, Journal Entries
   - **Current Status**: ⚠️ Sent as plaintext

2. **`redacted_content`** - Redacted version of content (if applicable)
   - Used in: Communications, Journal Entries
   - **Current Status**: ⚠️ Sent as plaintext (optional field)

3. **`encrypted_profile_data`** - Redaction profile data
   - Used in: Redaction Profiles endpoint
   - **Current Status**: ⚠️ Sent as JSON string (not encrypted with passphrase)

### Fields That Should NOT Be Encrypted

- `session_id` - Session identifier
- `item_type` - Type of communication item
- `role` - User or assistant role
- `consent` - Consent flag
- `created_at` - Timestamp
- `updated_at` - Timestamp
- `id` - Record identifier
- Metadata fields (unless they contain sensitive data)

---

## Backend Requirements

### 1. Data Storage

#### Encrypted Fields Storage
The backend should:
- **Store encrypted data as-is** - Do not attempt to decrypt
- **Preserve Base64 encoding** - The encrypted content is Base64-encoded
- **No decryption on backend** - Backend cannot decrypt (doesn't have passphrase)

#### Database Schema
Encrypted fields should be stored as:
- **Type**: `TEXT` or `VARCHAR` (sufficient length for Base64-encoded data)
- **Encoding**: UTF-8
- **Example**: 
  ```sql
  original_content TEXT,  -- Stores Base64-encoded encrypted content
  redacted_content TEXT,  -- Stores Base64-encoded encrypted content (nullable)
  ```

### 2. API Endpoints

#### Sending Data to Backend (POST/PUT)

**Current Implementation** (needs encryption):
```json
{
  "session_id": "uuid",
  "item_type": "chat",
  "role": "user",
  "original_content": "User's plaintext message",  // ⚠️ Should be encrypted
  "redacted_content": "Redacted message",          // ⚠️ Should be encrypted (optional)
  "consent": true
}
```

**Expected Implementation** (with encryption):
```json
{
  "session_id": "uuid",
  "item_type": "chat",
  "role": "user",
  "original_content": "Base64EncryptedString==",  // ✅ Encrypted with passphrase
  "redacted_content": "Base64EncryptedString==",  // ✅ Encrypted with passphrase (optional)
  "consent": true
}
```

#### Receiving Data from Backend (GET)

**Backend Response Format:**
```json
{
  "id": "uuid",
  "session_id": "uuid",
  "item_type": "chat",
  "role": "user",
  "original_content": "Base64EncryptedString==",  // ✅ Encrypted (frontend will decrypt)
  "redacted_content": "Base64EncryptedString==",  // ✅ Encrypted (optional)
  "consent": true,
  "created_at": "2025-01-27T19:00:00Z"
}
```

**Frontend Decryption:**
- Frontend receives encrypted Base64 string
- Frontend retrieves passphrase from secure storage
- Frontend decrypts using `decryptContent(encryptedContent, passphrase)`
- Frontend displays decrypted content to user

### 3. Backend Validation

The backend should:
- ✅ **Accept Base64-encoded strings** for encrypted fields
- ✅ **Validate Base64 format** (optional but recommended)
- ✅ **Store without modification** - Do not decode or decrypt
- ❌ **Do NOT attempt decryption** - Backend doesn't have passphrase
- ❌ **Do NOT store passphrase** - Never request or store user passphrase

### 4. Error Handling

#### Invalid Encrypted Data
If encrypted data is malformed:
- Backend should return validation error
- Frontend should handle decryption failures gracefully
- Consider logging (without sensitive data) for debugging

#### Missing Passphrase
If frontend cannot retrieve passphrase:
- Frontend cannot decrypt data
- Frontend should prompt user to re-enter passphrase
- Consider recovery mechanisms (if implemented)

---

## Implementation Reference

### Frontend Encryption Service

**Location**: `lib/core/services/encryption_service.dart`

**Key Methods:**
```dart
// Encrypt content before sending to backend
static String encryptContent(String content, String passphrase)

// Decrypt content received from backend
static String decryptContent(String encryptedContent, String passphrase)

// Derive encryption key from passphrase
static List<int> _deriveKeyFromPassphrase(String passphrase)
```

### Encryption Flow (Intended)

#### Sending Data to Backend:
```
1. User enters content
2. Frontend retrieves passphrase from secure storage
3. Frontend encrypts content: encrypted = encryptContent(content, passphrase)
4. Frontend sends encrypted content to backend
5. Backend stores encrypted content as-is
```

#### Receiving Data from Backend:
```
1. Frontend requests data from backend
2. Backend returns encrypted content
3. Frontend retrieves passphrase from secure storage
4. Frontend decrypts: content = decryptContent(encryptedContent, passphrase)
5. Frontend displays decrypted content to user
```

---

## Security Considerations

### Current Limitations

⚠️ **Important Security Notes:**

1. **XOR Encryption**: The current implementation uses XOR-based encryption which is **not cryptographically secure** for production use. The code includes comments indicating this should be upgraded.

2. **No Encryption in Transit**: This document describes encryption at rest. Data is still transmitted over HTTPS, but the backend receives encrypted data.

3. **Passphrase Recovery**: There is no mechanism to recover data if the user forgets their passphrase. The passphrase is device-only and never stored on the backend.

### Recommended Improvements

For production, consider:
- Upgrading to AES-256 encryption
- Using proper key derivation (PBKDF2, Argon2)
- Implementing proper IV/nonce for each encryption
- Adding integrity checks (HMAC)

---

## API Endpoints Affected

### Communications Endpoints
- `POST /communications/` - Create communication (needs encryption)
- `GET /communications/` - Get communications (returns encrypted, frontend decrypts)

### Journal Endpoints
- `POST /journals/` - Create journal entry (needs encryption)
- `GET /journals/` - Get journal entries (returns encrypted, frontend decrypts)
- `PUT /journals/{id}` - Update journal entry (needs encryption)

### Redaction Profile Endpoints
- `POST /redaction-profiles/` - Create profile (needs encryption)
- `PUT /redaction-profiles/` - Update profile (needs encryption)
- `GET /redaction-profiles/` - Get profile (returns encrypted, frontend decrypts)

---

## Testing Considerations

### Backend Testing
- Test that Base64-encoded encrypted strings are accepted
- Test that encrypted data is stored without modification
- Test that encrypted data is returned unchanged
- Test validation of Base64 format (optional)

### Integration Testing
- Test end-to-end: encrypt → send → store → retrieve → decrypt
- Test with various content lengths
- Test with special characters and Unicode
- Test error handling for malformed encrypted data

---

## Migration Path

### Current State
- ⚠️ Data is sent as plaintext
- ⚠️ Encryption service exists but is not used for API calls
- ⚠️ Backend receives unencrypted data

### Target State
- ✅ Frontend encrypts sensitive fields before sending
- ✅ Backend stores encrypted data as-is
- ✅ Frontend decrypts data after receiving
- ✅ Backend never sees plaintext sensitive data

### Migration Steps
1. **Phase 1**: Update frontend to encrypt `original_content` and `redacted_content` before API calls
2. **Phase 2**: Update backend to accept and store Base64-encoded encrypted strings
3. **Phase 3**: Update frontend to decrypt received data
4. **Phase 4**: Migrate existing plaintext data (if needed) - requires user passphrase re-entry

---

## Code References

### Frontend Files
- `lib/core/services/encryption_service.dart` - Encryption implementation
- `lib/core/services/api_service.dart` - API calls (needs encryption integration)
- `lib/core/data/repositories/chat_repository_impl.dart` - Chat data handling
- `lib/core/data/repositories/journal_repository_impl.dart` - Journal data handling

### Test Files
- `test/unit/encryption_service_test.dart` - Encryption service tests

---

## Questions for Backend Team

1. **Base64 Validation**: Should the backend validate Base64 format, or just accept any string?

2. **Field Length**: What is the maximum length for encrypted fields? (Base64 encoding increases size by ~33%)

3. **Migration**: How should existing plaintext data be handled? Should we:
   - Leave it as-is (backward compatibility)
   - Require re-encryption on next update
   - Provide migration endpoint

4. **Error Handling**: How should the backend handle decryption failures? (Frontend-side, but backend may need to handle edge cases)

5. **Performance**: Are there any performance concerns with storing Base64-encoded strings vs. binary data?

---

## Summary

- **Passphrase**: User-provided, stored only on device, never sent to backend
- **Encryption**: SHA-256 key derivation + XOR encryption (needs upgrade for production)
- **Format**: Base64-encoded encrypted strings
- **Backend Role**: Store encrypted data as-is, never decrypt
- **Frontend Role**: Encrypt before sending, decrypt after receiving
- **Current Status**: ⚠️ Encryption exists but is not currently used in API calls

**Next Steps**: Implement encryption in frontend API calls and ensure backend accepts Base64-encoded encrypted strings.
