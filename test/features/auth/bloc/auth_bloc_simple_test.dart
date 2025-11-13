import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sentimo/data/repositories/auth_repository.dart';
import 'package:sentimo/features/auth/bloc/auth_bloc.dart';
import 'package:sentimo/features/auth/bloc/auth_event.dart';
import 'package:sentimo/features/auth/bloc/auth_state.dart' as app_auth;
import 'package:supabase_flutter/supabase_flutter.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockUser extends Mock implements User {}
class MockAuthResponse extends Mock implements AuthResponse {}

void main() {
  late AuthBloc authBloc;
  late MockAuthRepository mockAuthRepository;
  late MockUser mockUser;
  late MockAuthResponse mockAuthResponse;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockUser = MockUser();
    mockAuthResponse = MockAuthResponse();
    authBloc = AuthBloc(mockAuthRepository);

    // Setup mock user
    when(() => mockUser.id).thenReturn('test-user-id');
    when(() => mockUser.email).thenReturn('test@example.com');
    when(() => mockAuthResponse.user).thenReturn(mockUser);
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      expect(authBloc.state, equals(const app_auth.AuthInitial()));
    });

    group('AuthCheckRequested', () {
      blocTest<AuthBloc, app_auth.AuthState>(
        'emits [AuthAuthenticated] when user is authenticated',
        build: () {
          when(() => mockAuthRepository.currentUser).thenReturn(mockUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [
          app_auth.AuthAuthenticated(mockUser),
        ],
      );

      blocTest<AuthBloc, app_auth.AuthState>(
        'emits [AuthUnauthenticated] when user is not authenticated',
        build: () {
          when(() => mockAuthRepository.currentUser).thenReturn(null);
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [
          const app_auth.AuthUnauthenticated(),
        ],
      );
    });

    group('AuthSignInRequested', () {
      blocTest<AuthBloc, app_auth.AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when sign-in succeeds',
        build: () {
          when(() => mockAuthRepository.signIn(
            email: 'test@example.com',
            password: 'Test123!',
          )).thenAnswer((_) async => mockAuthResponse);
          return authBloc;
        },
        act: (bloc) => bloc.add(
          const AuthSignInRequested(
            email: 'test@example.com',
            password: 'Test123!',
          ),
        ),
        expect: () => [
          const app_auth.AuthLoading(),
          app_auth.AuthAuthenticated(mockUser),
        ],
      );

      blocTest<AuthBloc, app_auth.AuthState>(
        'emits [AuthLoading, AuthError] when sign-in fails',
        build: () {
          when(() => mockAuthRepository.signIn(
            email: 'test@example.com',
            password: 'wrong',
          )).thenThrow(Exception('Invalid credentials'));
          return authBloc;
        },
        act: (bloc) => bloc.add(
          const AuthSignInRequested(
            email: 'test@example.com',
            password: 'wrong',
          ),
        ),
        expect: () => [
          const app_auth.AuthLoading(),
          isA<app_auth.AuthError>(), // Check type instead of message since BloC may wrap it
        ],
      );
    });

    group('AuthSignOutRequested', () {
      blocTest<AuthBloc, app_auth.AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when sign-out succeeds',
        build: () {
          when(() => mockAuthRepository.signOut()).thenAnswer((_) async => {});
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthSignOutRequested()),
        expect: () => [
          const app_auth.AuthLoading(),
          const app_auth.AuthUnauthenticated(),
        ],
      );
    });
  });
}
