import 'package:flutter/material.dart';
import 'package:free_dz/screens/client/Services/client_services.dart';
import 'package:free_dz/screens/client/client_home_page.dart';
import 'package:free_dz/screens/freelancers/free_main.dart';
import 'package:free_dz/services/theme_provider.dart';
import 'screens/shared/login_page.dart';
import 'screens/shared/register_page.dart';
import 'screens/client/client_profile.dart';
import 'screens/client/freelancer_profile.dart';
import 'screens/freelancers/free_setup.dart';
import 'package:provider/provider.dart';

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
  final themeProvider = ThemeProvider();
  await themeProvider.loadThemeFromPrefs();

   runApp(
    ChangeNotifierProvider.value(
      value: themeProvider, 
      child: const FreeDzApp(),
    ),
  );
}

class FreeDzApp extends StatelessWidget {
  const FreeDzApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the themeProvider from Provider
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Free_dz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue,
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.themeMode, // <- reactive now
      initialRoute: '/login',
      routes: {
        '/': (context) => const ClientServicePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/client_home': (context) => const ClientMainScreen(),
        '/client_profile': (context) => const ClientProfilePage(),
        '/freelancer_home': (context) => const FreelancerMainScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/freelancer_profile') {
          final freelancerId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => FreelancerProfileScreen(freelancerId: freelancerId),
          );
        }
        if (settings.name == '/freelancer_setup') {
          return MaterialPageRoute(
            builder: (_) => FreelancerProfileSetupPage(),
          );
        }
        return null;
      },
    );
  }
}
