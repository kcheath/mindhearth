import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Simple Tests', () {
    test('should pass basic test', () {
      expect(1 + 1, equals(2));
    });

    test('should handle strings correctly', () {
      const String testString = 'Hello, World!';
      expect(testString, isA<String>());
      expect(testString.length, equals(13));
    });

    test('should handle lists correctly', () {
      final List<int> numbers = [1, 2, 3, 4, 5];
      expect(numbers.length, equals(5));
      expect(numbers.first, equals(1));
      expect(numbers.last, equals(5));
    });

    test('should handle maps correctly', () {
      final Map<String, dynamic> data = {
        'name': 'Test',
        'age': 25,
        'isActive': true,
      };
      
      expect(data['name'], equals('Test'));
      expect(data['age'], equals(25));
      expect(data['isActive'], equals(true));
    });

    test('should handle async operations', () async {
      final Future<String> future = Future.delayed(
        Duration(milliseconds: 100),
        () => 'Async result',
      );
      
      final result = await future;
      expect(result, equals('Async result'));
    });
  });
}
