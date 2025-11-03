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
}
