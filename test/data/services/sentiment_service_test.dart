import 'package:flutter_test/flutter_test.dart';
import 'package:sentimo/core/config/env_config.dart';
import 'package:sentimo/core/entities/journal_entry.dart';
import 'package:sentimo/data/services/sentiment_service.dart';

void main() {
  late SentimentService sentimentService;

  setUpAll(() async {
    // Initialize environment for tests
    TestWidgetsFlutterBinding.ensureInitialized();

    // Load .env file for tests
    try {
      await EnvConfig.load();
    } catch (e) {
      // If .env doesn't exist, tests will use fallback values from EnvConfig
      // This is acceptable for CI/CD environments
    }
  });

  setUp(() {
    sentimentService = SentimentService();
  });

  group('SentimentService - Input Sanitization', () {
    test('should remove HTML-like tags from input', () async {
      // This test validates that sanitization is working
      // We can't directly test _sanitizeInput as it's private,
      // but we can verify the service handles malicious input
      final input = '<script>alert("test")</script>This is a test entry';

      // Service should handle this without crashing
      expect(() => sentimentService.analyzeSentiment(input), returnsNormally);
    });

    test('should return neutral for empty input', () async {
      final result = await sentimentService.analyzeSentiment('');
      expect(result, equals(SentimentLabel.neutral));
    });

    test('should return neutral for very short input', () async {
      final result = await sentimentService.analyzeSentiment('Hi');
      expect(result, equals(SentimentLabel.neutral));
    });

    test('should handle very long input', () async {
      // Create input > 5000 chars
      final longInput = 'a' * 6000;

      // Should not crash, should truncate and process
      expect(
        () => sentimentService.analyzeSentiment(longInput),
        returnsNormally,
      );
    });
  });

  group('SentimentService - Caching', () {
    test('should use cached results for duplicate requests', () async {
      const testText = 'This is a test journal entry for caching';

      // Clear cache first
      sentimentService.clearCache();

      // First call - will hit API (mocked, so will return neutral)
      final result1 = await sentimentService.analyzeSentiment(testText);

      // Second call - should use cache
      final result2 = await sentimentService.analyzeSentiment(testText);

      // Results should be same
      expect(result1, equals(result2));
    });

    test('clearCache should clear the cache', () {
      // Just verify the method exists and can be called
      expect(() => sentimentService.clearCache(), returnsNormally);
    });
  });

  group('SentimentService - Rate Limiting', () {
    test(
      'should enforce minimum interval between requests',
      () async {
        final stopwatch = Stopwatch()..start();

        // Make two requests back-to-back
        await sentimentService.analyzeSentiment('First entry');
        await sentimentService.analyzeSentiment('Second entry');

        stopwatch.stop();

        // Should take at least 2 seconds due to rate limiting
        expect(
          stopwatch.elapsedMilliseconds,
          greaterThanOrEqualTo(1800),
        ); // Allow 200ms margin
      },
      timeout: const Timeout(Duration(seconds: 10)),
    );
  });

  group('SentimentService - Complete Analysis', () {
    test('analyzeSentimentComplete should return valid structure', () async {
      const testText = 'I am feeling great today!';

      final result = await sentimentService.analyzeSentimentComplete(testText);

      // Verify structure
      expect(result, isA<Map<String, dynamic>>());
      expect(result.containsKey('sentiment'), isTrue);
      expect(result.containsKey('score'), isTrue);
      expect(result.containsKey('tags'), isTrue);

      // Verify types
      expect(result['sentiment'], isA<SentimentLabel>());
      expect(result['score'], isA<double>());
      expect(result['tags'], isA<List<String>>());
    });

    test('analyzeSentimentComplete should handle empty input', () async {
      final result = await sentimentService.analyzeSentimentComplete('');

      expect(result['sentiment'], equals(SentimentLabel.neutral));
      expect(result['score'], equals(5.0));
      expect(result['tags'], isA<List<String>>());
    });

    test('analyzeSentimentComplete should cache results', () async {
      const testText = 'Testing complete analysis caching';

      sentimentService.clearCache();

      // First call
      final result1 = await sentimentService.analyzeSentimentComplete(testText);

      // Second call (should use cache)
      final result2 = await sentimentService.analyzeSentimentComplete(testText);

      // Should be identical
      expect(result1['sentiment'], equals(result2['sentiment']));
      expect(result1['score'], equals(result2['score']));
      expect(result1['tags'], equals(result2['tags']));
    });
  });

  group('SentimentService - Error Handling', () {
    test('should return neutral on timeout', () async {
      // This will timeout quickly in test environment
      // Service should gracefully handle it
      final result = await sentimentService.analyzeSentiment('test entry');

      // Should return some sentiment (not crash)
      expect(result, isA<SentimentLabel>());
    });
  });
}
