import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthGoogleSignInRequested>(_onAuthGoogleSignInRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    log('🔐 [AuthBloc] Checking authentication status...');
    final user = _authRepository.currentUser;
    if (user != null) {
      log('✅ [AuthBloc] User authenticated: ${user.email}');
      emit(AuthAuthenticated(user));
    } else {
      log('❌ [AuthBloc] No user authenticated');
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    log('📝 [AuthBloc] Sign up requested: ${event.email}');
    emit(const AuthLoading());
    try {
      final response = await _authRepository.signUp(
        email: event.email,
        password: event.password,
      );

      if (response.user != null) {
        log('✅ [AuthBloc] Sign up successful: ${event.email}');
        emit(const AuthSuccess('Account created successfully! Please check your email for verification.'));
        emit(AuthAuthenticated(response.user!));
      } else {
        log('❌ [AuthBloc] Sign up failed: No user returned');
        emit(const AuthError('Failed to create account'));
      }
    } catch (e) {
      log('❌ [AuthBloc] Sign up error: $e');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    log('🔑 [AuthBloc] Sign in requested: ${event.email}');
    emit(const AuthLoading());
    try {
      final response = await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );

      if (response.user != null) {
        log('✅ [AuthBloc] Sign in successful: ${event.email}');
        emit(AuthAuthenticated(response.user!));
      } else {
        log('❌ [AuthBloc] Sign in failed: No user returned');
        emit(const AuthError('Failed to sign in'));
      }
    } catch (e) {
      log('❌ [AuthBloc] Sign in error: $e');
      emit(AuthError(_parseError(e.toString())));
    }
  }

  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    log('🚪 [AuthBloc] Sign out requested');
    emit(const AuthLoading());
    try {
      await _authRepository.signOut();
      log('✅ [AuthBloc] Sign out successful');
      emit(const AuthUnauthenticated());
    } catch (e) {
      log('❌ [AuthBloc] Sign out error: $e');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    log('🔵 [AuthBloc] Google Sign In requested');
    emit(const AuthLoading());
    try {
      final response = await _authRepository.signInWithGoogle();
      
      if (response.user != null) {
        log('✅ [AuthBloc] Google Sign In successful: ${response.user!.email}');
        emit(AuthAuthenticated(response.user!));
      } else {
        log('❌ [AuthBloc] Google Sign In failed: No user returned');
        emit(const AuthError('Failed to sign in with Google'));
      }
    } catch (e) {
      log('❌ [AuthBloc] Google Sign In error: $e');
      emit(AuthError(_parseError(e.toString())));
    }
  }

  String _parseError(String error) {
    if (error.contains('Invalid login credentials')) {
      return 'Invalid email or password';
    } else if (error.contains('Email not confirmed')) {
      return 'Please verify your email first';
    } else if (error.contains('User already registered')) {
      return 'Email already in use';
    } else if (error.contains('cancelled')) {
      return 'Google Sign In was cancelled';
    } else if (error.contains('OAuth') || error.contains('google') || error.contains('Google')) {
      return 'Google Sign In failed. Please try again.';
    }
    return 'An error occurred. Please try again.';
  }
}
