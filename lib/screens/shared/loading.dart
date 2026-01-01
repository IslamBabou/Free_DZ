import 'package:flutter/material.dart';

// ==========================================
// 1. LOADING 
// ==========================================
class LoadingScreen extends StatelessWidget {
  final String? message;
  final bool showLogo;

  const LoadingScreen({
    super.key,
    this.message,
    this.showLogo = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showLogo) ...[
              Image.asset(
                'assets/images/logo.png',
                height: 180,
                fit: BoxFit.contain,
              ),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.handshake_outlined,
                  size: 60,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 24),
              
              // App Name
              Text(
                'Free_dz',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              
              // Tagline
              Text(
                'Freelancers meet clients',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 48),
            ],
            
            // Loading Indicator
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? Colors.blue.shade300 : Colors.blue,
                ),
              ),
            ),
            
            if (message != null) ...[
              const SizedBox(height: 24),
              Text(
                message!,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

