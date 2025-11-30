import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/config/firebase/firebase_config.dart';
import 'src/config/firebase/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await FirebaseConfig.initialize();
  
  // Configure Firestore
  await FirebaseService.configureFirestore();
  
  // Initialize Cloudinary
  CloudinaryService.instance.initialize(
    cloudName: 'YOUR_CLOUD_NAME', // From Cloudinary dashboard
    uploadPreset: 'freedz_preset', // The preset you created
  );
  
  runApp(
    const ProviderScope(
      child: FreeDZApp(),
    ),
  );
}

class FreeDZApp extends StatelessWidget {
  const FreeDZApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FreeDZ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006C51), // Algerian flag green
          secondary: const Color(0xFFD62828), // Algerian flag red
        ),
        useMaterial3: true,
        fontFamily: 'Cairo', // Good for Arabic support
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Check authentication state and navigate accordingly
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_outline,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'FreeDZ',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Plateforme de freelances locaux',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}