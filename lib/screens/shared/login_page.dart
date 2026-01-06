import 'package:flutter/material.dart';
import 'package:free_dz/screens/client/client_home_page.dart';
import 'package:free_dz/screens/freelancers/free_home.dart';
import 'package:free_dz/services/api_helper.dart';
import 'package:free_dz/services/auth_service.dart';

// ==========================================
// LOGIN PAGE
// ==========================================

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

  Future<void> _login() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  try {
    // ApiHelper.post() now returns a Map, not http.Response
    final response = await ApiHelper.post(
      '/login',
      {
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
      },
    );

    // Check your API's status field or token existence
    if (response['status'] == true || response['token'] != null) {
      debugPrint('Login successful: $response');

      // Store token
      final token = response['token'] ?? response['accessToken'];
      if (token != null) {
        await AuthService.saveToken(token);
        debugPrint('Token saved: $token');
      }

      // Extract user role and profile completion
      final userRole = response['user']?['role'] ?? response['role'];
      final isProfileComplete = response['user']?['is_profile_complete'] ??
                                response['user']?['isProfileComplete'] ??
                                response['is_profile_complete'] ??
                                response['isProfileComplete'] ??
                                true;

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful! Welcome back'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      // Navigate based on role
      if (userRole == 'FREELANCER' || userRole == 'freelancer') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FreelancerHomePage(
              showCompletionBanner: !isProfileComplete,
            ),
          ),
        );
      } else if (userRole == 'CLIENT' || userRole == 'client') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ClientMainScreen(),
          ),
        );
      } else {
        debugPrint('Warning: Unknown role "$userRole"');
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      // Login failed, show message from API
      final message = response['message'] ?? 'Login failed';
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  } catch (e) {
    debugPrint('Error: $e');
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
                      foregroundColor: Colors.black,
                    ),
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
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

