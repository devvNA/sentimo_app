import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sentimo/core/entities/journal_entry.dart';

// Mock classes for testing
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockAuthResponse extends Mock implements AuthResponse {}
class MockUser extends Mock implements User {}
class MockSession extends Mock implements Session {}

// Test data
class TestData {
  static const String testEmail = 'test@example.com';
  static const String testPassword = 'Test123!@#';
  static const String testUsername = 'testuser';
  static const String testUserId = 'test-user-id-123';

  static const String testJournalContent = 'Today was a great day! I accomplished a lot.';
  static const String testJournalId = 'test-journal-id-123';
  static const String testSentimentLabel = 'positive';
  static const double testSentimentScore = 0.85;

  static Map<String, dynamic> get mockUser => {
    'id': testUserId,
    'email': testEmail,
    'user_metadata': {'username': testUsername},
  };

  static Map<String, dynamic> get mockJournalEntry => {
    'id': testJournalId,
    'user_id': testUserId,
    'content': testJournalContent,
    'sentiment_label': testSentimentLabel,
    'sentiment_score': testSentimentScore,
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
  };

  static List<Map<String, dynamic>> get mockJournalEntries => [
    mockJournalEntry,
    {
      'id': 'journal-2',
      'user_id': testUserId,
      'content': 'Another entry for testing',
      'sentiment_label': 'neutral',
      'sentiment_score': 0.5,
      'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'updated_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    },
  ];

  static JournalEntry get testEntry => JournalEntry(
    id: testJournalId,
    userId: testUserId,
    content: testJournalContent,
    sentimentLabel: SentimentLabel.positive,
    sentimentScore: testSentimentScore,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  static List<JournalEntry> get testEntries => [
    testEntry,
    JournalEntry(
      id: 'journal-2',
      userId: testUserId,
      content: 'Another entry for testing',
      sentimentLabel: SentimentLabel.neutral,
      sentimentScore: 0.5,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];
}
