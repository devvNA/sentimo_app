/// Input validation utilities for form fields
class Validators {
  // RFC 5322 compliant email regex (simplified)
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Password requirements regex
  static final RegExp _uppercaseRegex = RegExp(r'[A-Z]');
  static final RegExp _lowercaseRegex = RegExp(r'[a-z]');
  static final RegExp _digitRegex = RegExp(r'[0-9]');

  /// Validate email address
  /// Returns null if valid, error message if invalid
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }

    if (email.length > 254) {
      return 'Email is too long';
    }

    if (!_emailRegex.hasMatch(email)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  /// Validate password complexity
  /// Requirements: 8+ chars, uppercase, lowercase, number
  /// Returns null if valid, error message if invalid
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!_uppercaseRegex.hasMatch(password)) {
      return 'Password must contain uppercase letter';
    }

    if (!_lowercaseRegex.hasMatch(password)) {
      return 'Password must contain lowercase letter';
    }

    if (!_digitRegex.hasMatch(password)) {
      return 'Password must contain a number';
    }

    return null;
  }

  /// Validate journal content
  /// Requirements: 5-5000 characters
  /// Returns null if valid, error message if invalid
  static String? validateJournalContent(String? content) {
    if (content == null || content.isEmpty) {
      return 'Content is required';
    }

    final trimmed = content.trim();

    if (trimmed.length < 5) {
      return 'Content must be at least 5 characters';
    }

    if (trimmed.length > 5000) {
      return 'Content must not exceed 5000 characters';
    }

    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate minimum length
  static String? validateMinLength(
    String? value,
    int minLength,
    String fieldName,
  ) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }

    return null;
  }

  /// Validate maximum length
  static String? validateMaxLength(
    String? value,
    int maxLength,
    String fieldName,
  ) {
    if (value == null) return null;

    if (value.length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }

    return null;
  }

  /// Combine multiple validators
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
