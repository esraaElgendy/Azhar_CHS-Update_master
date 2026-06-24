import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/bloc/auth_cubit.dart';
import 'core/bloc/settings_cubit.dart';
import 'core/bloc/student_cubit.dart';
import 'core/bloc/course_cubit.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_preferences.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/dashboard/presentation/pages/main_screen.dart';
import 'features/splash/splash_screen.dart';
import 'l10n/app_localizations.dart';

import 'core/bloc/course_registration_cubit.dart';
import 'core/bloc/schedule_cubit.dart';
import 'core/bloc/grades_cubit.dart';
import 'core/repositories/course_repository.dart';
import 'core/repositories/grades_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appPreferences = AppPreferences();
  await appPreferences.init();
  runApp(MyApp(appPreferences: appPreferences));
}

class MyApp extends StatelessWidget {
  final AppPreferences appPreferences;
  const MyApp({super.key, required this.appPreferences});

  @override
  Widget build(BuildContext context) {
    final courseRepository = CourseRepository();
    final gradesRepository = GradesRepository();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SettingsCubit(appPreferences),
        ),
        BlocProvider(
          create: (context) => AuthCubit()..checkAuthStatus(),
        ),
        BlocProvider(
          create: (context) => StudentCubit(),
        ),
        BlocProvider(
          create: (context) => CourseCubit(courseRepository: courseRepository),
        ),
        BlocProvider(
          create: (context) => ScheduleCubit(repository: courseRepository),
        ),
        BlocProvider(
          create: (context) => CourseRegistrationCubit(
            repository: courseRepository,
            prefs: appPreferences,
          ),
        ),
        BlocProvider(
          create: (context) => GradesCubit(repository: gradesRepository),
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Student Portal',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsState.themeMode,
            locale: settingsState.locale,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            home: const SplashWrapper(),
          );
        },
      ),
    );
  }
}

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  @override
  void initState() {
    super.initState();
    _navigateAfterSplash();
  }

  Future<void> _navigateAfterSplash() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final authState = context.read<AuthCubit>().state;

    if (authState is AuthAuthenticated) {
      // User is logged in, load dashboard and go to main screen
      context.read<StudentCubit>().loadDashboard();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      // User is not logged in, go to login screen.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
