import 'package:flutter_test/flutter_test.dart';
import 'package:mindhearth/core/services/encryption_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('EncryptionService', () {
    test('should encrypt and decrypt content correctly', () {
      const passphrase = 'test_passphrase_123';
      const originalContent = 'This is a test message that should be encrypted and decrypted correctly.';
      
      final encrypted = EncryptionService.encryptContent(originalContent, passphrase);
      final decrypted = EncryptionService.decryptContent(encrypted, passphrase);
      
      expect(encrypted, isNot(equals(originalContent)));
      expect(decrypted, equals(originalContent));
    });

    test('should handle special characters in passphrase', () {
      const passphrase = r'test@#$%^&*()_+-=[]{}|;:,.<>?';
      
      final encrypted = EncryptionService.encryptContent('test content', passphrase);
      final decrypted = EncryptionService.decryptContent(encrypted, passphrase);
      
      expect(decrypted, equals('test content'));
    });

    test('should handle empty content', () {
      const passphrase = 'test_passphrase_123';
      const originalContent = '';
      
      final encrypted = EncryptionService.encryptContent(originalContent, passphrase);
      final decrypted = EncryptionService.decryptContent(encrypted, passphrase);
      
      expect(decrypted, equals(originalContent));
    });

    test('should encrypt and decrypt content correctly', () {
      const passphrase = 'test_passphrase_123';
      const originalContent = 'This is a test message that should be encrypted and decrypted correctly.';
      
      final encrypted = EncryptionService.encryptContent(originalContent, passphrase);
      final decrypted = EncryptionService.decryptContent(encrypted, passphrase);
      
      expect(encrypted, isNot(equals(originalContent)));
      expect(decrypted, equals(originalContent));
    });

    test('should handle special characters in passphrase', () {
      const passphrase = r'test@#$%^&*()_+-=[]{}|;:,.<>?';
      
      final encrypted = EncryptionService.encryptContent('test content', passphrase);
      final decrypted = EncryptionService.decryptContent(encrypted, passphrase);
      
      expect(decrypted, equals('test content'));
    });
  });
}
