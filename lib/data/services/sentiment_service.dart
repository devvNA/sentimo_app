import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../../core/config/env_config.dart';
import '../../core/entities/journal_entry.dart';

class SentimentService {
  late final GenerativeModel _model;
  
  // PERFORMANCE: Rate limiting
  DateTime? _lastRequestTime;
  static const _minRequestInterval = Duration(seconds: 2);
  
  // PERFORMANCE: Caching - stores up to 50 recent analyses
  final Map<String, Map<String, dynamic>> _cache = {};
  static const _maxCacheSize = 50;
  
  // PERFORMANCE: Request timeout configuration
  static const _apiTimeout = Duration(seconds: 30);
  
  // SECURITY: Input limits
  static const _maxInputLength = 5000;

  SentimentService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: EnvConfig.geminiApiKey,
    );
  }
  
  /// SECURITY: Sanitize input before sending to API
  String _sanitizeInput(String text) {
    // Remove potential harmful characters
    String sanitized = text
        .trim()
        .replaceAll(RegExp(r'[<>]'), '') // Remove HTML-like tags
        .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), ''); // Remove control chars
    
    // Truncate if too long
    if (sanitized.length > _maxInputLength) {
      sanitized = sanitized.substring(0, _maxInputLength);
      log('⚠️ [SentimentService] Input truncated to $_maxInputLength characters');
    }
    
    return sanitized;
  }
  
  /// PERFORMANCE: Rate limiting - ensures minimum interval between requests
  Future<void> _applyRateLimit() async {
    if (_lastRequestTime != null) {
      final elapsed = DateTime.now().difference(_lastRequestTime!);
      if (elapsed < _minRequestInterval) {
        final waitTime = _minRequestInterval - elapsed;
        log('⏱️ [SentimentService] Rate limit: waiting ${waitTime.inMilliseconds}ms');
        await Future.delayed(waitTime);
      }
    }
    _lastRequestTime = DateTime.now();
  }
  
  /// PERFORMANCE: Cache management
  String _getCacheKey(String text) {
    return text.hashCode.toString();
  }
  
  Map<String, dynamic>? _getFromCache(String text) {
    final key = _getCacheKey(text);
    if (_cache.containsKey(key)) {
      log('💾 [SentimentService] Cache hit for analysis');
      return _cache[key];
    }
    return null;
  }
  
  void _addToCache(String text, Map<String, dynamic> result) {
    final key = _getCacheKey(text);
    
    // Remove oldest entry if cache is full
    if (_cache.length >= _maxCacheSize) {
      _cache.remove(_cache.keys.first);
    }
    
    _cache[key] = result;
    log('💾 [SentimentService] Result cached (${_cache.length}/$_maxCacheSize)');
  }
  
  /// Clear cache (useful for testing or memory management)
  void clearCache() {
    _cache.clear();
    log('🗑️ [SentimentService] Cache cleared');
  }

  Future<SentimentLabel> analyzeSentiment(String text) async {
    // SECURITY: Sanitize input
    final sanitizedText = _sanitizeInput(text);
    
    if (sanitizedText.isEmpty || sanitizedText.length < 5) {
      log('⚠️ [SentimentService] Text too short for analysis');
      return SentimentLabel.neutral;
    }
    
    // PERFORMANCE: Apply rate limiting
    await _applyRateLimit();
    
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
"$sanitizedText"

Respond with ONLY ONE WORD from these options: positive, negative, neutral, mixed
Do not include any explanation or additional text.
''';

      final content = [Content.text(prompt)];
      
      // PERFORMANCE: Add timeout
      final response = await _model
          .generateContent(content)
          .timeout(_apiTimeout, onTimeout: () {
        throw TimeoutException('Gemini API request timed out after ${_apiTimeout.inSeconds}s');
      });

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Empty response from Gemini API');
      }

      final sentiment = response.text!.trim().toLowerCase();

      return SentimentLabel.fromString(sentiment);
    } on TimeoutException catch (e) {
      log('⏱️ [SentimentService] Request timeout: $e');
      return SentimentLabel.neutral;
    } catch (e) {
      log('❌ [SentimentService] Analysis error: $e');
      // Return neutral as fallback on error
      return SentimentLabel.neutral;
    }
  }

  //   Future<String> analyzeSentimentWithExplanation(String text) async {
  //     try {
  //       final prompt =
  //           '''
  // Analyze the sentiment of the following journal entry and provide:
  // 1. Classification: positive, negative, neutral, or mixed
  // 2. Brief explanation (1-2 sentences) about the emotional tone

  // Journal entry:
  // "$text"

  // Format your response as:
  // Sentiment: [classification]
  // Explanation: [brief explanation]
  // ''';

  //       final content = [Content.text(prompt)];
  //       final response = await _model.generateContent(content);

  //       return response.text ?? 'Unable to analyze sentiment';
  //     } catch (e) {
  //       return 'Error analyzing sentiment: ${e.toString()}';
  //     }
  //   }

  // Future<Map<String, dynamic>> analyzeSentimentDetailed(String text) async {
  //   try {
  //     final sentiment = await analyzeSentiment(text);

  //     return {
  //       'sentiment': sentiment.name,
  //       'label': sentiment.toDisplayString(),
  //       'timestamp': DateTime.now().toIso8601String(),
  //     };
  //   } catch (e) {
  //     return {
  //       'sentiment': 'neutral',
  //       'label': 'Neutral',
  //       'error': e.toString(),
  //       'timestamp': DateTime.now().toIso8601String(),
  //     };
  //   }
  // }

  Future<Map<String, dynamic>> analyzeSentimentComplete(String text) async {
    log('🤖 [SentimentService] Starting sentiment analysis...');
    
    // SECURITY: Sanitize input
    final sanitizedText = _sanitizeInput(text);
    log('   Text length: ${sanitizedText.length} characters');
    
    if (sanitizedText.isEmpty || sanitizedText.length < 5) {
      log('⚠️ [SentimentService] Text too short for analysis');
      return {
        'sentiment': SentimentLabel.neutral,
        'score': 5.0,
        'tags': <String>['neutral'],
      };
    }
    
    // PERFORMANCE: Check cache first
    final cached = _getFromCache(sanitizedText);
    if (cached != null) {
      return cached;
    }
    
    // PERFORMANCE: Apply rate limiting
    await _applyRateLimit();

    try {
      final prompt =
          '''
Analyze the sentiment of this journal entry and provide detailed analysis.

Journal entry:
"$sanitizedText"

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

      log('📤 [SentimentService] Sending request to Gemini API...');
      final content = [Content.text(prompt)];
      
      // PERFORMANCE: Add timeout
      final response = await _model
          .generateContent(content)
          .timeout(_apiTimeout, onTimeout: () {
        throw TimeoutException('Gemini API request timed out after ${_apiTimeout.inSeconds}s');
      });

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Empty response from Gemini API');
      }

      log('📥 [SentimentService] Received response from Gemini API');

      // Clean response text - remove markdown code blocks if present
      String jsonText = response.text!.trim();
      jsonText = jsonText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      // SECURITY: Validate JSON response size
      if (jsonText.length > 1000) {
        throw Exception('Response too large, possible injection attack');
      }

      // Parse JSON response
      final jsonData = jsonDecode(jsonText) as Map<String, dynamic>;

      final result = {
        'sentiment': SentimentLabel.fromString(
          jsonData['sentiment'] as String?,
        ),
        'score': (jsonData['score'] as num?)?.toDouble() ?? 5.0,
        'tags': jsonData['tags'] != null
            ? List<String>.from(jsonData['tags'] as List)
            : <String>[],
      };

      log('✅ [SentimentService] Analysis complete:');
      log('   Sentiment: ${result['sentiment']}');
      log('   Score: ${result['score']}');
      log('   Tags: ${result['tags']}');
      
      // PERFORMANCE: Cache the result
      _addToCache(sanitizedText, result);

      return result;
    } on TimeoutException catch (e) {
      log('⏱️ [SentimentService] Request timeout: $e');
      log('   Falling back to basic sentiment analysis...');

      // Fallback to basic sentiment analysis
      try {
        final sentiment = await analyzeSentiment(sanitizedText);
        final fallbackResult = {
          'sentiment': sentiment,
          'score': _getScoreFromSentiment(sentiment),
          'tags': _getDefaultTagsFromSentiment(sentiment),
        };
        
        // Cache fallback result too
        _addToCache(sanitizedText, fallbackResult);
        
        return fallbackResult;
      } catch (e2) {
        log('❌ [SentimentService] Fallback failed: $e2');
        return {
          'sentiment': SentimentLabel.neutral,
          'score': 5.0,
          'tags': <String>['neutral'],
        };
      }
    } catch (e) {
      log('⚠️ [SentimentService] Detailed analysis failed: $e');
      log('   Falling back to basic sentiment analysis...');

      // Fallback to basic sentiment analysis if detailed fails
      try {
        final sentiment = await analyzeSentiment(sanitizedText);
        final fallbackScore = _getScoreFromSentiment(sentiment);

        final fallbackResult = {
          'sentiment': sentiment,
          'score': fallbackScore,
          'tags': _getDefaultTagsFromSentiment(sentiment),
        };

        log('✅ [SentimentService] Fallback analysis complete: $sentiment');
        
        // Cache fallback result
        _addToCache(sanitizedText, fallbackResult);
        
        return fallbackResult;
      } catch (e2) {
        log('❌ [SentimentService] All analysis methods failed: $e2');
        log('   Using ultimate fallback (neutral)');

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
