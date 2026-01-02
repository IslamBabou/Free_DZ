import 'package:flutter/material.dart';
import 'package:free_dz/screens/client/client_home_page.dart';
import 'package:free_dz/screens/freelancers/free_home.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // Replace with your actual API URL
  final String apiUrl = 'http://localhost/api';

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Login successful: $data');
        
        // Store token
        final token = data['token'] ?? data['accessToken'];
        if (token != null) {
          final storage = const FlutterSecureStorage();
          await storage.write(key: 'auth_token', value: token);

          debugPrint('Token saved: $token');
        }

        // Extract user role and data
        final userRole = data['user']?['role'] ?? data['role'];
        /* final userId = data['user']?['id'] ?? data['id']; */
        final isProfileComplete = data['user']?['isProfileComplete'] ?? data['isProfileComplete'] ?? true;
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login successful! Welcome back'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Small delay for better UX
          await Future.delayed(const Duration(milliseconds: 500));
          
          if (!mounted) return;

          // Role-based navigation
          if (userRole == 'FREELANCER' || userRole == 'freelancer') {
            // Check if profile is complete
            if (isProfileComplete) {
              // Profile complete → Freelancer Home
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const FreelancerHomePage(
                    showCompletionBanner: false,
                  ),
                ),
              );
            } else {
              // Profile incomplete → Show banner
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const FreelancerHomePage(
                    showCompletionBanner: true,
                  ),
                ),
              );
            }
          } else if (userRole == 'CLIENT' || userRole == 'client') {
            // Client → Client Home
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ClientHomePage(),
              ),
            );
          } /* else if (userRole == 'ADMIN' || userRole == 'admin') {
            // Admin → Admin Dashboard
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminDashboardPage(),
              ),
            );
          } */ else {
            // Unknown role → Default login
            debugPrint('Warning: Unknown role "$userRole"');
            Navigator.pushReplacementNamed(context, '/login');
          }
        }
      } else {
        final error = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error['message'] ?? 'Login failed'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset(
                'assets/images/logo.png',
                height: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
                const Text(
                  'Free_dz',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Freelancers meet clients',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    if (!value.contains('@')) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE2B025),
                    foregroundColor: Colors.black, // good contrast
                  ),
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Login'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text('Create an account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}