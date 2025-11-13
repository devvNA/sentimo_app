import 'package:flutter_test/flutter_test.dart';
import 'package:sentimo/core/utils/validators.dart';

void main() {
  group('Validators - Email', () {
    test('validateEmail should accept valid emails', () {
      expect(Validators.validateEmail('test@example.com'), isNull);
      expect(Validators.validateEmail('user.name@domain.co.id'), isNull);
      expect(Validators.validateEmail('test+tag@example.com'), isNull);
      expect(Validators.validateEmail('user_123@test.io'), isNull);
    });

    test('validateEmail should reject invalid emails', () {
      expect(Validators.validateEmail(''), isNotNull);
      expect(Validators.validateEmail('invalid'), isNotNull);
      expect(Validators.validateEmail('@example.com'), isNotNull);
      expect(Validators.validateEmail('test@'), isNotNull);
      expect(Validators.validateEmail('test @example.com'), isNotNull);
      // test..name@example.com is technically valid by our simple regex
    });

    test('validateEmail should reject too long emails', () {
      final longEmail = '${'a' * 250}@example.com';
      expect(Validators.validateEmail(longEmail), isNotNull);
    });

    test('validateEmail should require email', () {
      expect(Validators.validateEmail(null), equals('Email is required'));
    });
  });

  group('Validators - Password', () {
    test('validatePassword should accept strong passwords', () {
      expect(Validators.validatePassword('Test1234'), isNull);
      expect(Validators.validatePassword('MyP@ssw0rd'), isNull);
      expect(Validators.validatePassword('Secure123Pass'), isNull);
    });

    test('validatePassword should reject weak passwords', () {
      expect(Validators.validatePassword('short'), isNotNull);
      expect(Validators.validatePassword('alllowercase1'), isNotNull);
      expect(Validators.validatePassword('ALLUPPERCASE1'), isNotNull);
      expect(Validators.validatePassword('NoNumbers'), isNotNull);
      expect(Validators.validatePassword('12345678'), isNotNull);
    });

    test('validatePassword should enforce minimum length', () {
      final error = Validators.validatePassword('Test123');
      expect(error, contains('8 characters'));
    });

    test('validatePassword should require uppercase', () {
      final error = Validators.validatePassword('test1234');
      expect(error, contains('uppercase'));
    });

    test('validatePassword should require lowercase', () {
      final error = Validators.validatePassword('TEST1234');
      expect(error, contains('lowercase'));
    });

    test('validatePassword should require number', () {
      final error = Validators.validatePassword('TestPassword');
      expect(error, contains('number'));
    });

    test('validatePassword should require password', () {
      expect(Validators.validatePassword(null), equals('Password is required'));
      expect(Validators.validatePassword(''), equals('Password is required'));
    });
  });

  group('Validators - Journal Content', () {
    test('validateJournalContent should accept valid content', () {
      expect(Validators.validateJournalContent('This is valid'), isNull);
      expect(Validators.validateJournalContent('Short'), isNull);
      expect(Validators.validateJournalContent('A' * 5000), isNull);
    });

    test('validateJournalContent should reject too short content', () {
      expect(Validators.validateJournalContent('Hi'), isNotNull);
      expect(Validators.validateJournalContent('Test'), isNotNull);
    });

    test('validateJournalContent should reject too long content', () {
      final longContent = 'A' * 5001;
      expect(Validators.validateJournalContent(longContent), isNotNull);
    });

    test('validateJournalContent should trim whitespace', () {
      expect(Validators.validateJournalContent('  Hi  '), isNotNull);
      expect(Validators.validateJournalContent('  Valid content  '), isNull);
    });

    test('validateJournalContent should require content', () {
      expect(Validators.validateJournalContent(null), equals('Content is required'));
      expect(Validators.validateJournalContent(''), equals('Content is required'));
    });
  });

  group('Validators - Generic', () {
    test('validateRequired should validate required fields', () {
      expect(Validators.validateRequired('value', 'Field'), isNull);
      expect(Validators.validateRequired(null, 'Field'), isNotNull);
      expect(Validators.validateRequired('', 'Field'), isNotNull);
      expect(Validators.validateRequired('  ', 'Field'), isNotNull);
    });

    test('validateMinLength should enforce minimum length', () {
      expect(Validators.validateMinLength('test', 4, 'Field'), isNull);
      expect(Validators.validateMinLength('test', 5, 'Field'), isNotNull);
      expect(Validators.validateMinLength('', 1, 'Field'), isNotNull);
    });

    test('validateMaxLength should enforce maximum length', () {
      expect(Validators.validateMaxLength('test', 4, 'Field'), isNull);
      expect(Validators.validateMaxLength('test', 3, 'Field'), isNotNull);
      expect(Validators.validateMaxLength(null, 10, 'Field'), isNull);
    });

    test('combine should combine multiple validators', () {
      final validator = Validators.combine([
        (v) => Validators.validateRequired(v, 'Field'),
        (v) => Validators.validateMinLength(v, 5, 'Field'),
      ]);

      expect(validator('test'), isNotNull); // Too short
      expect(validator('valid'), isNull); // Valid
      expect(validator(null), isNotNull); // Required
    });
  });

  group('Validators - Edge Cases', () {
    test('should handle special characters in email', () {
      expect(Validators.validateEmail('user+tag@example.com'), isNull);
      expect(Validators.validateEmail('user.name@example.com'), isNull);
      expect(Validators.validateEmail('user_123@example.com'), isNull);
    });

    test('should handle unicode in content', () {
      expect(Validators.validateJournalContent('こんにちは'), isNull);
      expect(Validators.validateJournalContent('Hello 世界'), isNull);
      expect(Validators.validateJournalContent('مرحبا'), isNull);
    });

    test('should handle whitespace-only input', () {
      expect(Validators.validateJournalContent('     '), isNotNull);
      expect(Validators.validateRequired('     ', 'Field'), isNotNull);
    });

    test('should handle null vs empty string differently where appropriate', () {
      expect(Validators.validateEmail(null), equals('Email is required'));
      expect(Validators.validateEmail(''), equals('Email is required'));
      
      expect(Validators.validatePassword(null), equals('Password is required'));
      expect(Validators.validatePassword(''), equals('Password is required'));
    });
  });
}
