import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  
  // Google OAuth Client IDs (SECURITY FIX: Moved from hardcoded values)
  static String get googleWebClientId => dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? 
    '574327579297-8oaneej2dqutahok85od8rt55mmkec43.apps.googleusercontent.com';
  static String get googleIosClientId => dotenv.env['GOOGLE_IOS_CLIENT_ID'] ?? 
    '574327579297-oore65353egnohc8npivlkhklpc0cpkv.apps.googleusercontent.com';

  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  static bool validate() {
    if (supabaseUrl.isEmpty) {
      throw Exception('SUPABASE_URL is not set in .env file');
    }
    if (supabaseAnonKey.isEmpty) {
      throw Exception('SUPABASE_ANON_KEY is not set in .env file');
    }
    if (geminiApiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY is not set in .env file');
    }
    // Google Client IDs have fallback values for development
    return true;
  }
}
