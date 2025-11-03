import 'dart:async';
import 'dart:developer';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  User? get currentUser => _supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } on PostgrestException catch (e) {
      log(e.message);
      rethrow;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on PostgrestException catch (e) {
      log(e.message);
      rethrow;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on PostgrestException catch (e) {
      log(e.message);
      rethrow;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<AuthResponse> signInWithGoogle() async {
    try {
      log('🔵 [AuthRepository] Starting Google Sign In...');

      /// TODO: Update the Web client ID with your own.
      /// Web Client ID that you registered with Google Cloud.
      const webClientId = 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';

      /// TODO: Update the iOS client ID with your own.
      /// iOS Client ID that you registered with Google Cloud.
      const iosClientId = 'YOUR_IOS_CLIENT_ID.apps.googleusercontent.com';

      // Google sign in on Android will work without providing the Android
      // Client ID registered on Google Cloud.

      final googleSignIn = GoogleSignIn(
        scopes: <String>['email', 'profile'],
        serverClientId: webClientId,
      );

      log('🔵 [AuthRepository] Initializing GoogleSignIn...');

      // Perform the sign in
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        log('❌ [AuthRepository] Google Sign In cancelled by user');
        throw AuthException('Google Sign In cancelled');
      }

      log('🔵 [AuthRepository] Google user signed in: ${googleUser.email}');
      log('🔵 [AuthRepository] Getting Google authentication...');

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        log('❌ [AuthRepository] No ID Token found');
        throw AuthException('No ID Token found');
      }

      log('✅ [AuthRepository] ID Token obtained');
      log(
        '🔵 [AuthRepository] Signing in to Supabase with Google credentials...',
      );

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      log(
        '✅ [AuthRepository] Google Sign In successful: ${response.user?.email}',
      );
      return response;
    } on AuthException catch (e) {
      log('❌ [AuthRepository] Google Sign In error: ${e.message}');
      rethrow;
    } catch (e) {
      log('❌ [AuthRepository] Google Sign In unexpected error: $e');
      rethrow;
    }
  }
}
