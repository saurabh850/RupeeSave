import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'services/user_service.dart';
import 'services/streak_service.dart';
import 'models/user.dart';
import 'screens/onboarding.dart';
import 'screens/dashboard.dart';
import 'utils/theme.dart';
import 'providers/theme_provider.dart';

void main() {
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<User?> _checkUser() async {
    try {
      final userService = UserService();
      return await userService.getUser();
    } catch (e) {
      debugPrint('Error loading user: $e');
      // On web, if DB fails, we might want to return null to show onboarding
      // or rethrow to show error screen. For now, let's return null.
      return null;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'RupeeSave',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          home: FutureBuilder<User?>(
            future: _checkUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text("Loading RupeeSave..."),
                      ],
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Scaffold(
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Error initializing app:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                );
              }

              final user = snapshot.data;
              if (user == null) {
                return const OnboardingScreen();
              }
              return const DashboardScreen();
            },
          ),
          routes: {
            '/onboarding': (context) => const OnboardingScreen(),
            '/dashboard': (context) => const DashboardScreen(),
          },
        );
      },
    );
  }
}
