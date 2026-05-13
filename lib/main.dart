import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/main_scaffold.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';
import 'services/auth_service.dart';
import 'services/fitness_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var firebaseReady = false;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    firebaseReady = true;
  } catch (e) {
    debugPrint('Firebase not initialized: Check your google-services.json / GoogleService-Info.plist');
    debugPrint('$e');
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FitnessService(useFirebase: firebaseReady)),
        ChangeNotifierProvider(create: (_) => AuthService(useFirebase: firebaseReady)),
      ],
      child: const OurFitnessApp(),
    ),
  );
}

class OurFitnessApp extends StatelessWidget {
  const OurFitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OurFitness',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/auth': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainScaffold(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    if (authService.isAuthenticated) {
      return const MainScaffold();
    }
    return const LoginScreen();
  }
}
