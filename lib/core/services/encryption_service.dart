import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

class EncryptionService {
  static const String _passphraseKey = 'user_passphrase';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static final Logger _logger = Logger();

  /// Store the passphrase securely
  static Future<void> storePassphrase(String passphrase) async {
    try {
      await _storage.write(key: _passphraseKey, value: passphrase);
      _logger.d('Passphrase stored securely');
    } catch (e) {
      _logger.e('Failed to store passphrase: $e');
      rethrow;
    }
  }

  /// Retrieve the stored passphrase
  static Future<String?> getPassphrase() async {
    try {
      return await _storage.read(key: _passphraseKey);
    } catch (e) {
      _logger.e('Failed to retrieve passphrase: $e');
      return null;
    }
  }

  /// Clear the stored passphrase
  static Future<void> clearPassphrase() async {
    try {
      await _storage.delete(key: _passphraseKey);
      _logger.d('Passphrase cleared');
    } catch (e) {
      _logger.e('Failed to clear passphrase: $e');
    }
  }

  /// Encrypt content using the raw passphrase
  /// This uses a simple but consistent encryption method for demonstration
  /// In production, consider using more robust encryption libraries
  static String encryptContent(String content, String passphrase) {
    try {
      // Create a simple encryption key from the passphrase
      final key = _deriveKeyFromPassphrase(passphrase);
      
      // Simple XOR-based encryption (for demonstration purposes)
      // In production, use proper encryption libraries like encrypt or pointycastle
      final bytes = utf8.encode(content);
      final encryptedBytes = <int>[];
      
      for (int i = 0; i < bytes.length; i++) {
        encryptedBytes.add(bytes[i] ^ key[i % key.length]);
      }
      
      return base64.encode(encryptedBytes);
    } catch (e) {
      _logger.e('Encryption failed: $e');
      rethrow;
    }
  }

  /// Decrypt content using the raw passphrase
  static String decryptContent(String encryptedContent, String passphrase) {
    try {
      // Create the same key from the passphrase
      final key = _deriveKeyFromPassphrase(passphrase);
      
      // Decrypt using the same XOR method
      final encryptedBytes = base64.decode(encryptedContent);
      final decryptedBytes = <int>[];
      
      for (int i = 0; i < encryptedBytes.length; i++) {
        decryptedBytes.add(encryptedBytes[i] ^ key[i % key.length]);
      }
      
      return utf8.decode(decryptedBytes);
    } catch (e) {
      _logger.e('Decryption failed: $e');
      rethrow;
    }
  }

  /// Derive a consistent key from the passphrase
  static List<int> _deriveKeyFromPassphrase(String passphrase) {
    // Use SHA-256 to create a consistent key from the passphrase
    final hash = sha256.convert(utf8.encode(passphrase));
    return hash.bytes;
  }

  /// Store user-entered safety codes
  static Future<void> storeSafetyCodes(Map<String, String> codes) async {
    try {
      await _storage.write(key: 'safety_codes', value: jsonEncode(codes));
      _logger.d('Safety codes stored securely');
    } catch (e) {
      _logger.e('Failed to store safety codes: $e');
      rethrow;
    }
  }

  /// Retrieve stored safety codes
  static Future<Map<String, String>?> getSafetyCodes() async {
    try {
      final codesJson = await _storage.read(key: 'safety_codes');
      if (codesJson != null) {
        final Map<String, dynamic> codesMap = jsonDecode(codesJson);
        return codesMap.map((key, value) => MapEntry(key, value.toString()));
      }
      return null;
    } catch (e) {
      _logger.e('Failed to retrieve safety codes: $e');
      return null;
    }
  }

  /// Clear stored safety codes
  static Future<void> clearSafetyCodes() async {
    try {
      // Check what's stored before clearing
      final beforeClear = await _storage.read(key: 'safety_codes');
      print('🐛 Debug: Safety codes before clear: $beforeClear');
      
      await _storage.delete(key: 'safety_codes');
      _logger.d('Safety codes cleared');
      
      // Verify clearing worked
      final afterClear = await _storage.read(key: 'safety_codes');
      print('🐛 Debug: Safety codes after clear: $afterClear');
    } catch (e) {
      _logger.e('Failed to clear safety codes: $e');
    }
  }

  /// Validate a safety code against stored user codes
  static Future<bool> validateSafetyCode(String code) async {
    try {
      final storedCodes = await getSafetyCodes();
      if (storedCodes == null || storedCodes.isEmpty) {
        _logger.w('No safety codes found for validation');
        return false;
      }
      
      final isValid = storedCodes.values.contains(code);
      _logger.d('Safety code validation: $isValid (code: $code, stored codes: ${storedCodes.values})');
      return isValid;
    } catch (e) {
      _logger.e('Safety code validation failed: $e');
      return false;
    }
  }

  /// Check if encryption is properly set up
  static Future<bool> isEncryptionReady() async {
    try {
      final passphrase = await getPassphrase();
      return passphrase != null && passphrase.isNotEmpty;
    } catch (e) {
      _logger.e('Failed to check encryption readiness: $e');
      return false;
    }
  }
}
