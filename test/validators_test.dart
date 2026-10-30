// UNIT tests for lib/utils/validators.dart
//
// A unit test checks plain Dart code. No screen, no widgets, no tester.
// We just call a function and compare the answer with what we expect.

import 'package:flutter_test/flutter_test.dart';

// IMPORTANT: "todo_app" must match `name:` in pubspec.yaml.
import 'package:todo_app/utils/validators.dart';

void main() {
  // `group` puts related tests together so the output is easy to read.
  group('Validators.email', () {
    test('accepts a normal email', () {
      // null means "valid, no error message".
      expect(Validators.email('test@example.com'), isNull);
    });

    test('ignores spaces around the email', () {
      expect(Validators.email('  test@example.com  '), isNull);
    });

    test('rejects an empty email', () {
      expect(Validators.email(''), 'Email is required');
      expect(Validators.email(null), 'Email is required');
    });

    test('rejects emails with a wrong shape', () {
      expect(Validators.email('abc'), 'Enter a valid email');
      expect(Validators.email('abc@'), 'Enter a valid email');
      expect(Validators.email('abc@site'), 'Enter a valid email'); // no ".com"
      expect(Validators.email('a b@site.com'), 'Enter a valid email');
    });
  });

  group('Validators.newPassword (used when creating an account)', () {
    test('accepts a strong password', () {
      expect(Validators.newPassword('Hello@2026'), isNull);
    });

    test('rejects an empty password', () {
      expect(Validators.newPassword(''), 'Password is required');
      expect(Validators.newPassword(null), 'Password is required');
    });

    test('rejects a password shorter than 8 characters', () {
      expect(Validators.newPassword('Ab1!'), 'Use at least 8 characters');
    });

    test('rejects a password longer than 64 characters', () {
      final tooLong = 'A' * 65 + 'a1!'; // 68 characters
      expect(Validators.newPassword(tooLong), 'Use at most 64 characters');
    });

    test('rejects spaces', () {
      expect(
        Validators.newPassword('Hello @2026'),
        'Password cannot contain spaces',
      );
    });

    test('requires an uppercase letter', () {
      expect(
        Validators.newPassword('hello@2026'),
        'Add at least 1 uppercase letter (A-Z)',
      );
    });

    test('requires a lowercase letter', () {
      expect(
        Validators.newPassword('HELLO@2026'),
        'Add at least 1 lowercase letter (a-z)',
      );
    });

    test('requires a number', () {
      expect(
        Validators.newPassword('Hello@world'),
        'Add at least 1 number (0-9)',
      );
    });

    test('requires a special character', () {
      // `contains` = the message only has to include this word.
      expect(Validators.newPassword('Hello2026x'), contains('special'));
    });
  });

  group('Validators.loginPassword (used when signing in)', () {
    test('rejects an empty password', () {
      expect(Validators.loginPassword(''), 'Password is required');
      expect(Validators.loginPassword(null), 'Password is required');
    });

    test('accepts ANY non-empty password (old weak passwords must work)', () {
      expect(Validators.loginPassword('abc'), isNull);
    });
  });
}
