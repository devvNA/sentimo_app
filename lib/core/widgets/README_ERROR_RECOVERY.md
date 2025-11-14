# Error Recovery Implementation

## Overview

This document describes the error recovery mechanisms implemented in the Sentimo app.

## Components

### 1. ErrorLogger (`lib/core/utils/error_logger.dart`)

Centralized error logging utility with the following features:

**Methods:**
- `logError()` - Log errors with context and stack trace
- `logWarning()` - Log warnings
- `logInfo()` - Log informational messages
- `parseErrorMessage()` - Convert technical errors to user-friendly messages

**Usage:**
```dart
try {
  // Some operation
} catch (e, stackTrace) {
  ErrorLogger.logError(
    'FeatureName',
    e,
    stackTrace: stackTrace,
    additionalInfo: {'userId': userId},
  );
}
```

### 2. ErrorRetryWidget (`lib/core/widgets/error_retry_widget.dart`)

Full-screen error display with retry functionality.

**Usage:**
```dart
if (state is ErrorState) {
  return ErrorRetryWidget(
    message: state.message,
    onRetry: () {
      context.read<MyBloc>().add(RetryEvent());
    },
  );
}
```

### 3. InlineErrorWidget

Compact error display for inline errors.

**Usage:**
```dart
if (hasError) {
  return InlineErrorWidget(
    message: errorMessage,
    onRetry: () => _retry(),
  );
}
```

## Error Handling Patterns

### BLoC Error Handling

All BLoCs implement consistent error handling:

```dart
try {
  // Operation
  emit(SuccessState(data));
} catch (e, stackTrace) {
  ErrorLogger.logError('BlocName', e, stackTrace: stackTrace);
  emit(ErrorState(ErrorLogger.parseErrorMessage(e)));
}
```

### Repository Error Handling

Repositories log errors and rethrow for BLoC handling:

```dart
try {
  // Database operation
  return result;
} catch (e) {
  log('❌ [Repository] Error: $e');
  rethrow;
}
```

### UI Error Handling

UI components use BlocConsumer for error feedback:

```dart
BlocConsumer<MyBloc, MyState>(
  listener: (context, state) {
    if (state is ErrorState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => context.read<MyBloc>().add(RetryEvent()),
          ),
        ),
      );
    }
  },
  builder: (context, state) {
    if (state is ErrorState) {
      return ErrorRetryWidget(
        message: state.message,
        onRetry: () => context.read<MyBloc>().add(RetryEvent()),
      );
    }
    // Normal UI
  },
)
```

## Error Types and Messages

### Network Errors
- **Detection:** Contains "network", "socket", "connection"
- **Message:** "Network error. Please check your internet connection."
- **Recovery:** Retry button, check connectivity

### Timeout Errors
- **Detection:** Contains "timeout"
- **Message:** "Request timed out. Please try again."
- **Recovery:** Retry with exponential backoff

### Authentication Errors
- **Detection:** Contains "unauthorized", "authentication"
- **Message:** "Authentication error. Please sign in again."
- **Recovery:** Redirect to login

### Permission Errors
- **Detection:** Contains "permission", "forbidden"
- **Message:** "You don't have permission to perform this action."
- **Recovery:** Show message, no retry

### Not Found Errors
- **Detection:** Contains "not found"
- **Message:** "The requested resource was not found."
- **Recovery:** Navigate back or refresh

### Server Errors
- **Detection:** Contains "server", "500"
- **Message:** "Server error. Please try again later."
- **Recovery:** Retry with delay

## Retry Strategies

### Immediate Retry
For user-initiated actions:
```dart
onRetry: () {
  context.read<MyBloc>().add(RetryEvent());
}
```

### Exponential Backoff
For automatic retries:
```dart
Future<void> _retryWithBackoff(int attempt) async {
  final delay = Duration(seconds: math.pow(2, attempt).toInt());
  await Future.delayed(delay);
  // Retry operation
}
```

### Limited Retries
Maximum 3 automatic retries:
```dart
int _retryCount = 0;
const maxRetries = 3;

if (_retryCount < maxRetries) {
  _retryCount++;
  // Retry
} else {
  // Show error to user
}
```

## Best Practices

1. **Always log errors** with context
2. **Parse errors** to user-friendly messages
3. **Provide retry options** when appropriate
4. **Show loading states** during retry
5. **Limit automatic retries** to prevent loops
6. **Clear error states** after successful retry
7. **Preserve user data** during errors (optimistic updates)

## Implementation Status

✅ Error logging utility
✅ Error retry widgets
✅ User-friendly error messages
✅ Retry buttons in all error states
✅ BLoC error handling patterns
✅ Repository error handling
✅ UI error feedback (SnackBars, dialogs)

## Future Enhancements

- [ ] Offline error queue
- [ ] Error analytics/reporting
- [ ] Automatic retry with exponential backoff
- [ ] Network connectivity monitoring
- [ ] Error recovery suggestions based on error type
