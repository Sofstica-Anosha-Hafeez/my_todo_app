// CHANGE (NEW FILE): All form validation rules now live in one place.
// Before, the rules were written directly inside sign_in_screen.dart.
// Keeping them here makes them easy to find, reuse and change.

/// Each function returns:
///   - null          -> the value is valid
///   - a String text -> the error message to show under the text field
class Validators {
  // Private constructor: nobody should create a `Validators()` object,
  // we only use the static functions like `Validators.email(...)`.
  Validators._();

  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 64;

 
  static final RegExp _hasUppercase = RegExp(r'[A-Z]');
  static final RegExp _hasLowercase = RegExp(r'[a-z]');
  static final RegExp _hasDigit = RegExp(r'[0-9]');
  // Special character = anything that is NOT a letter, number or space.
  static final RegExp _hasSpecial = RegExp(r'[^A-Za-z0-9\s]');
  static final RegExp _hasSpace = RegExp(r'\s');
  // Simple email shape: something@something.something (no spaces).
  static final RegExp _emailShape = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// CHANGE: stricter email check (old code only checked for an "@").
  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email is required';
    if (!_emailShape.hasMatch(text)) return 'Enter a valid email';
    return null;
  }

  /// CHANGE: strong password rules. Used ONLY when creating an account.
  /// Rules: 8-64 chars, 1 uppercase, 1 lowercase, 1 number,
  /// 1 special character, and no spaces.
  static String? newPassword(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Password is required';
    if (text.length < minPasswordLength) {
      return 'Use at least $minPasswordLength characters';
    }
    if (text.length > maxPasswordLength) {
      return 'Use at most $maxPasswordLength characters';
    }
    if (_hasSpace.hasMatch(text)) return 'Password cannot contain spaces';
    if (!_hasUppercase.hasMatch(text)) {
      return 'Add at least 1 uppercase letter (A-Z)';
    }
    if (!_hasLowercase.hasMatch(text)) {
      return 'Add at least 1 lowercase letter (a-z)';
    }
    if (!_hasDigit.hasMatch(text)) return 'Add at least 1 number (0-9)';
    if (!_hasSpecial.hasMatch(text)) {
      return 'Add at least 1 special character (e.g. ! @ # \$ %)';
    }
    return null;
  }

  /// Why: users who created their account before these rules existed
  /// may have an older, weaker password. They must still be able to log in.
  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    return null;
  }
}
