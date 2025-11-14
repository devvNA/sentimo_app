import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentimo/features/auth/bloc/auth_event.dart';
import 'package:sentimo/features/home/presentation/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/env_config.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/journal_repository.dart';
import 'data/repositories/quick_checkin_repository.dart';
import 'data/repositories/streak_repository.dart';
import 'data/services/sentiment_service.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_state.dart' as auth_state;
import 'features/auth/presentation/login_page.dart';
import 'features/journal/bloc/journal_bloc.dart';
import 'features/streak/bloc/streak_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EnvConfig.load();
  EnvConfig.validate();

  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository(supabase)),
        RepositoryProvider(create: (context) => JournalRepository(supabase)),
        RepositoryProvider(create: (context) => StreakRepository(supabase)),
        RepositoryProvider(
          create: (context) => QuickCheckInRepository(supabase),
        ),
        RepositoryProvider(create: (context) => SentimentService()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(context.read<AuthRepository>()),
          ),
          BlocProvider(
            create: (context) => JournalBloc(
              context.read<JournalRepository>(),
              context.read<SentimentService>(),
            ),
          ),
          BlocProvider(
            create: (context) =>
                StreakBloc(streakRepository: context.read<StreakRepository>()),
          ),
        ],
        child: MaterialApp(
          title: 'Sentimo',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          themeMode: ThemeMode.dark,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    context.read<AuthBloc>().add(const AuthCheckRequested());

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthWrapper()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/logo-sentimo-nobg.png",
              width: 250.0,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 48),
            CircularProgressIndicator(color: AppTheme.offWhite),
          ],
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, auth_state.AuthState>(
      builder: (context, state) {
        if (state is auth_state.AuthAuthenticated) {
          return const HomePage();
        } else if (state is auth_state.AuthUnauthenticated ||
            state is auth_state.AuthError) {
          return const LoginPage();
        }
        return Scaffold(
          backgroundColor: AppTheme.background,
          body: Center(child: CircularProgressIndicator(color: AppTheme.blue)),
        );
      },
    );
  }
}
