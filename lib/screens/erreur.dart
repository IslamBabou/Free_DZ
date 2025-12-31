import 'package:flutter/material.dart';
import 'loading.dart';

// ==========================================
// 2. ERROR STATE SCREEN
// ==========================================
class ErrorStateScreen extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onSecondaryAction;
  final String? secondaryActionLabel;
  final IconData icon;

  const ErrorStateScreen({
    super.key,
    this.title = 'Something went wrong',
    this.message = 'We encountered an error. Please try again.',
    this.onRetry,
    this.onSecondaryAction,
    this.secondaryActionLabel,
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 60,
                  color: Colors.orange.shade400,
                ),
              ),
              const SizedBox(height: 32),
              
              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Message
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Primary Action Button
              if (onRetry != null)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              
              // Secondary Action Button
              if (onSecondaryAction != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: onSecondaryAction,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: BorderSide(
                        color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(secondaryActionLabel ?? 'Go Back'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 3. EMPTY STATE SCREEN
// ==========================================
class EmptyStateScreen extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onAction;
  final String? actionLabel;
  final IconData icon;

  const EmptyStateScreen({
    super.key,
    this.title = 'Nothing here yet',
    this.message = 'Start by creating your first item',
    this.onAction,
    this.actionLabel,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Empty State Illustration
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: isDark 
                      ? Colors.grey.shade800
                      : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 70,
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 32),
              
              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Message
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Call-to-Action Button
              if (onAction != null)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: onAction,
                    icon: const Icon(Icons.add_rounded),
                    label: Text(actionLabel ?? 'Get Started'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// USAGE EXAMPLES
// ==========================================

// Example 1: Loading Screen
class LoadingScreenExample extends StatelessWidget {
  const LoadingScreenExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoadingScreen(
      message: 'Loading your data...',
    );
  }
}

// Example 2: Error Screen
class ErrorScreenExample extends StatelessWidget {
  const ErrorScreenExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ErrorStateScreen(
      title: 'Connection Failed',
      message: 'Unable to connect to the server. Please check your internet connection and try again.',
      onRetry: () {
        // Retry logic here
        debugPrint('Retry pressed');
      },
      onSecondaryAction: () {
        Navigator.pop(context);
      },
      secondaryActionLabel: 'Go Back',
    );
  }
}

// Example 3: Empty State Screen
class EmptyScreenExample extends StatelessWidget {
  const EmptyScreenExample({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyStateScreen(
      title: 'No Projects Yet',
      message: 'Start your freelancing journey by creating your first project',
      icon: Icons.work_outline_rounded,
      actionLabel: 'Create Project',
      onAction: () {
        // Navigate to create project
        debugPrint('Create project pressed');
      },
    );
  }
}

// ==========================================
// REUSABLE COMPONENTS
// ==========================================

// Inline Loading Widget (for use in other screens)
class InlineLoader extends StatelessWidget {
  final String? message;
  final double size;

  const InlineLoader({
    super.key,
    this.message,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(strokeWidth: 3),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Empty State Widget (for use within other widgets)
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}