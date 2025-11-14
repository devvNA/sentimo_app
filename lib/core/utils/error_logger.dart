import 'dart:developer' as developer;

/// Utility class for logging errors throughout the application
class ErrorLogger {
  /// Log an error with context
  static void logError(
    String context,
    dynamic error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalInfo,
    Map<String, dynamic>? additionalData, // Alias for additionalInfo
  }) {
    // Use additionalData if provided, otherwise use additionalInfo
    final info = additionalData ?? additionalInfo;
    final timestamp = DateTime.now().toIso8601String();
    final errorMessage =
        '''
╔════════════════════════════════════════════════════════════════
║ ERROR LOG
╠════════════════════════════════════════════════════════════════
║ Timestamp: $timestamp
║ Context: $context
║ Error: $error
${stackTrace != null ? '║ Stack Trace: $stackTrace' : ''}
${info != null ? '║ Additional Info: $info' : ''}
╚════════════════════════════════════════════════════════════════
''';

    developer.log(
      errorMessage,
      name: 'ErrorLogger',
      error: error,
      stackTrace: stackTrace,
      level: 1000, // Error level
    );
  }

  /// Log a warning
  static void logWarning(String context, String message) {
    developer.log(
      '⚠️ [$context] $message',
      name: 'ErrorLogger',
      level: 900, // Warning level
    );
  }

  /// Log info
  static void logInfo(String context, String message) {
    developer.log(
      'ℹ️ [$context] $message',
      name: 'ErrorLogger',
      level: 800, // Info level
    );
  }

  /// Parse error message to user-friendly format
  static String parseErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') ||
        errorString.contains('socket') ||
        errorString.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    }

    if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    if (errorString.contains('unauthorized') ||
        errorString.contains('authentication')) {
      return 'Authentication error. Please sign in again.';
    }

    if (errorString.contains('permission') ||
        errorString.contains('forbidden')) {
      return 'You don\'t have permission to perform this action.';
    }

    if (errorString.contains('not found')) {
      return 'The requested resource was not found.';
    }

    if (errorString.contains('server') || errorString.contains('500')) {
      return 'Server error. Please try again later.';
    }

    // Default message
    return 'An unexpected error occurred. Please try again.';
  }

  /// Alias for parseErrorMessage for backward compatibility
  static String getUserFriendlyMessage(dynamic error) {
    return parseErrorMessage(error);
  }
}
