import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../../core/config/env_config.dart';
import '../../core/entities/journal_entry.dart';

class SentimentService {
  late final GenerativeModel _model;

  SentimentService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: EnvConfig.geminiApiKey,
    );
  }

  Future<SentimentLabel> analyzeSentiment(String text) async {
    try {
      final prompt =
          '''
Analyze the sentiment of the following journal entry and classify it into one of these categories: positive, negative, neutral, or mixed.

Guidelines:
- positive: The text expresses happiness, joy, satisfaction, gratitude, or optimism
- negative: The text expresses sadness, anger, frustration, anxiety, or pessimism
- neutral: The text is factual, informative, or lacks strong emotional content
- mixed: The text contains both positive and negative emotions in significant amounts

Journal entry:
"$text"

Respond with ONLY ONE WORD from these options: positive, negative, neutral, mixed
Do not include any explanation or additional text.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Empty response from Gemini API');
      }

      final sentiment = response.text!.trim().toLowerCase();

      return SentimentLabel.fromString(sentiment);
    } catch (e) {
      // Return neutral as fallback on error
      return SentimentLabel.neutral;
    }
  }

  Future<String> analyzeSentimentWithExplanation(String text) async {
    try {
      final prompt =
          '''
Analyze the sentiment of the following journal entry and provide:
1. Classification: positive, negative, neutral, or mixed
2. Brief explanation (1-2 sentences) about the emotional tone

Journal entry:
"$text"

Format your response as:
Sentiment: [classification]
Explanation: [brief explanation]
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return response.text ?? 'Unable to analyze sentiment';
    } catch (e) {
      return 'Error analyzing sentiment: ${e.toString()}';
    }
  }

  Future<Map<String, dynamic>> analyzeSentimentDetailed(String text) async {
    try {
      final sentiment = await analyzeSentiment(text);

      return {
        'sentiment': sentiment.name,
        'label': sentiment.toDisplayString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'sentiment': 'neutral',
        'label': 'Neutral',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<Map<String, dynamic>> analyzeSentimentComplete(String text) async {
    try {
      final prompt =
          '''
Analyze the sentiment of this journal entry and provide detailed analysis.

Journal entry:
"$text"

Provide your analysis in the following JSON format (respond with ONLY valid JSON, no markdown):
{
  "sentiment": "positive|negative|neutral|mixed",
  "score": 7.5,
  "tags": ["emotion1", "emotion2", "emotion3"]
}

Guidelines:
- sentiment: Choose one: positive, negative, neutral, or mixed
- score: Rate from 0-10 (0=very negative, 5=neutral, 10=very positive)
- tags: List 3 primary emotions detected (e.g., "gratitude", "joy", "anxiety", "excitement", "sadness", "optimism", "fear", "contentment", "frustration", "hope")

IMPORTANT: Respond with ONLY the JSON object, no additional text.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Empty response from Gemini API');
      }

      // Clean response text - remove markdown code blocks if present
      String jsonText = response.text!.trim();
      jsonText = jsonText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      // Parse JSON response
      final jsonData = jsonDecode(jsonText) as Map<String, dynamic>;

      return {
        'sentiment': SentimentLabel.fromString(
          jsonData['sentiment'] as String?,
        ),
        'score': (jsonData['score'] as num?)?.toDouble() ?? 5.0,
        'tags': jsonData['tags'] != null
            ? List<String>.from(jsonData['tags'] as List)
            : <String>[],
      };
    } catch (e) {
      // Fallback to basic sentiment analysis if detailed fails
      try {
        final sentiment = await analyzeSentiment(text);
        final fallbackScore = _getScoreFromSentiment(sentiment);

        return {
          'sentiment': sentiment,
          'score': fallbackScore,
          'tags': _getDefaultTagsFromSentiment(sentiment),
        };
      } catch (e2) {
        // Ultimate fallback
        return {
          'sentiment': SentimentLabel.neutral,
          'score': 5.0,
          'tags': <String>['neutral'],
        };
      }
    }
  }

  double _getScoreFromSentiment(SentimentLabel sentiment) {
    switch (sentiment) {
      case SentimentLabel.positive:
        return 7.5;
      case SentimentLabel.negative:
        return 2.5;
      case SentimentLabel.mixed:
        return 5.5;
      case SentimentLabel.neutral:
        return 5.0;
    }
  }

  List<String> _getDefaultTagsFromSentiment(SentimentLabel sentiment) {
    switch (sentiment) {
      case SentimentLabel.positive:
        return ['joy', 'contentment', 'optimism'];
      case SentimentLabel.negative:
        return ['sadness', 'frustration', 'anxiety'];
      case SentimentLabel.mixed:
        return ['mixed emotions', 'reflection', 'contemplation'];
      case SentimentLabel.neutral:
        return ['neutral', 'calm', 'balanced'];
    }
  }
}
