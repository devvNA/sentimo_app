import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sentimo/data/repositories/auth_repository.dart';
import '../../helpers/test_helpers.dart';

class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockAuthResponse extends Mock implements AuthResponse {}
class MockUser extends Mock implements User {}
class MockSession extends Mock implements Session {}

void main() {
  late AuthRepository authRepository;
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();
    
    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    
    authRepository = AuthRepository(mockSupabaseClient);
  });

  group('AuthRepository - Sign Up', () {
    test('signUp should return AuthResponse on success', () async {
      // Arrange
      final mockResponse = MockAuthResponse();
      final mockUser = MockUser();
      final mockSession = MockSession();
      
      when(() => mockResponse.user).thenReturn(mockUser);
      when(() => mockResponse.session).thenReturn(mockSession);
      when(() => mockUser.id).thenReturn(TestData.testUserId);
      when(() => mockUser.email).thenReturn(TestData.testEmail);
      
      when(() => mockGoTrueClient.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      final result = await authRepository.signUp(
        email: TestData.testEmail,
        password: TestData.testPassword,
      );

      // Assert
      expect(result, isA<AuthResponse>());
      expect(result.user, isNotNull);
      verify(() => mockGoTrueClient.signUp(
        email: TestData.testEmail,
        password: TestData.testPassword,
      )).called(1);
    });

    test('signUp should throw AuthException on invalid credentials', () async {
      // Arrange
      when(() => mockGoTrueClient.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenThrow(AuthException('Invalid email'));

      // Act & Assert
      expect(
        () => authRepository.signUp(
          email: 'invalid-email',
          password: 'weak',
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('signUp should throw on network error', () async {
      // Arrange
      when(() => mockGoTrueClient.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => authRepository.signUp(
          email: TestData.testEmail,
          password: TestData.testPassword,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('AuthRepository - Sign In', () {
    test('signIn should return AuthResponse on success', () async {
      // Arrange
      final mockResponse = MockAuthResponse();
      final mockUser = MockUser();
      final mockSession = MockSession();
      
      when(() => mockResponse.user).thenReturn(mockUser);
      when(() => mockResponse.session).thenReturn(mockSession);
      when(() => mockUser.id).thenReturn(TestData.testUserId);
      when(() => mockUser.email).thenReturn(TestData.testEmail);
      
      when(() => mockGoTrueClient.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      final result = await authRepository.signIn(
        email: TestData.testEmail,
        password: TestData.testPassword,
      );

      // Assert
      expect(result, isA<AuthResponse>());
      expect(result.user, isNotNull);
      verify(() => mockGoTrueClient.signInWithPassword(
        email: TestData.testEmail,
        password: TestData.testPassword,
      )).called(1);
    });

    test('signIn should throw AuthException on wrong credentials', () async {
      // Arrange
      when(() => mockGoTrueClient.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenThrow(AuthException('Invalid credentials'));

      // Act & Assert
      expect(
        () => authRepository.signIn(
          email: TestData.testEmail,
          password: 'wrong-password',
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('signIn should throw on network error', () async {
      // Arrange
      when(() => mockGoTrueClient.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => authRepository.signIn(
          email: TestData.testEmail,
          password: TestData.testPassword,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('AuthRepository - Sign Out', () {
    test('signOut should complete successfully', () async {
      // Arrange
      when(() => mockGoTrueClient.signOut()).thenAnswer((_) async => {});

      // Act
      await authRepository.signOut();

      // Assert
      verify(() => mockGoTrueClient.signOut()).called(1);
    });

    test('signOut should throw on error', () async {
      // Arrange
      when(() => mockGoTrueClient.signOut())
          .thenThrow(Exception('Sign out failed'));

      // Act & Assert
      expect(
        () => authRepository.signOut(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('AuthRepository - Password Reset', () {
    test('resetPassword should complete successfully', () async {
      // Arrange
      when(() => mockGoTrueClient.resetPasswordForEmail(any()))
          .thenAnswer((_) async => {});

      // Act
      await authRepository.resetPassword(TestData.testEmail);

      // Assert
      verify(() => mockGoTrueClient.resetPasswordForEmail(TestData.testEmail))
          .called(1);
    });

    test('resetPassword should throw on invalid email', () async {
      // Arrange
      when(() => mockGoTrueClient.resetPasswordForEmail(any()))
          .thenThrow(AuthException('Invalid email'));

      // Act & Assert
      expect(
        () => authRepository.resetPassword('invalid-email'),
        throwsA(isA<AuthException>()),
      );
    });

    test('resetPassword should throw on network error', () async {
      // Arrange
      when(() => mockGoTrueClient.resetPasswordForEmail(any()))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => authRepository.resetPassword(TestData.testEmail),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('AuthRepository - Current User', () {
    test('currentUser should return user when authenticated', () {
      // Arrange
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn(TestData.testUserId);
      when(() => mockUser.email).thenReturn(TestData.testEmail);
      when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);

      // Act
      final user = authRepository.currentUser;

      // Assert
      expect(user, isNotNull);
      expect(user?.id, equals(TestData.testUserId));
      expect(user?.email, equals(TestData.testEmail));
    });

    test('currentUser should return null when not authenticated', () {
      // Arrange
      when(() => mockGoTrueClient.currentUser).thenReturn(null);

      // Act
      final user = authRepository.currentUser;

      // Assert
      expect(user, isNull);
    });
  });

  group('AuthRepository - Auth State Changes', () {
    test('authStateChanges should emit auth state stream', () {
      // Arrange
      final mockSession = MockSession();
      when(() => mockSession.accessToken).thenReturn('test-token');
      
      final authStateStream = Stream<AuthState>.value(
        AuthState(AuthChangeEvent.signedIn, mockSession),
      );
      
      when(() => mockGoTrueClient.onAuthStateChange).thenAnswer(
        (_) => authStateStream,
      );

      // Act
      final stream = authRepository.authStateChanges;

      // Assert
      expect(stream, isA<Stream<AuthState>>());
    });
  });

  group('AuthRepository - Edge Cases', () {
    test('signUp with empty email should throw', () async {
      // Arrange
      when(() => mockGoTrueClient.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenThrow(AuthException('Email required'));

      // Act & Assert
      expect(
        () => authRepository.signUp(email: '', password: TestData.testPassword),
        throwsA(isA<AuthException>()),
      );
    });

    test('signUp with empty password should throw', () async {
      // Arrange
      when(() => mockGoTrueClient.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenThrow(AuthException('Password required'));

      // Act & Assert
      expect(
        () => authRepository.signUp(email: TestData.testEmail, password: ''),
        throwsA(isA<AuthException>()),
      );
    });

    test('signIn after signOut should work', () async {
      // Arrange
      final mockResponse = MockAuthResponse();
      final mockUser = MockUser();
      
      when(() => mockResponse.user).thenReturn(mockUser);
      when(() => mockGoTrueClient.signOut()).thenAnswer((_) async => {});
      when(() => mockGoTrueClient.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      await authRepository.signOut();
      final result = await authRepository.signIn(
        email: TestData.testEmail,
        password: TestData.testPassword,
      );

      // Assert
      expect(result, isA<AuthResponse>());
      verify(() => mockGoTrueClient.signOut()).called(1);
      verify(() => mockGoTrueClient.signInWithPassword(
        email: TestData.testEmail,
        password: TestData.testPassword,
      )).called(1);
    });
  });
}
