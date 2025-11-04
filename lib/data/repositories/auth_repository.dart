import 'dart:async';
import 'dart:developer';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:sentimo/main.dart';
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

      /// Web Client ID that you registered with Google Cloud.
      const webClientId =
          '574327579297-8oaneej2dqutahok85od8rt55mmkec43.apps.googleusercontent.com';

      /// iOS Client ID that you registered with Google Cloud.
      const iosClientId =
          '574327579297-oore65353egnohc8npivlkhklpc0cpkv.apps.googleusercontent.com';

      // Google sign in on Android will work without providing the Android
      // Client ID registered on Google Cloud.

      final GoogleSignIn signIn = GoogleSignIn.instance;

      // At the start of your app, initialize the GoogleSignIn instance
      unawaited(
        signIn.initialize(clientId: iosClientId, serverClientId: webClientId),
      );

      // Perform the sign in
      final googleAccount = await signIn.authenticate();
      final googleAuthorization = await googleAccount.authorizationClient
          .authorizationForScopes([
            'email',
            'https://www.googleapis.com/auth/userinfo.profile',
          ]);
      final googleAuthentication = googleAccount.authentication;
      final idToken = googleAuthentication.idToken;
      final accessToken = googleAuthorization!.accessToken;

      if (idToken == null) {
        throw 'No ID Token found.';
      }

      log('✅ [AuthRepository] ID Token obtained');
      log('🔑 [AuthRepository] Token details:');
      log('   - Email: ${googleAccount.email}');
      log('   - ID: ${googleAccount.id}');
      log('   - idToken length: ${idToken.length} characters');
      log('   - accessToken: ${accessToken != null ? "present" : "null"}');
      log('🔵 [AuthRepository] Sending to Supabase signInWithIdToken...');

      return supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } on AuthException catch (e) {
      log('❌ [AuthRepository] Google Sign In error: ${e.message}');
      rethrow;
    } catch (e) {
      log('❌ [AuthRepository] Google Sign In unexpected error: $e');
      rethrow;
    }
  }
}
