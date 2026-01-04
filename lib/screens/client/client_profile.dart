import 'package:flutter/material.dart';
import 'package:free_dz/models/client_profile.dart';
import 'package:free_dz/services/api_helper.dart';
import 'package:free_dz/services/auth_service.dart';

// ==========================================
// CLIENT PROFILE PAGE
// ==========================================

class ClientProfilePage extends StatefulWidget {
  const ClientProfilePage({super.key});

  @override
  State<ClientProfilePage> createState() => _ClientProfilePageState();
}

class _ClientProfilePageState extends State<ClientProfilePage> {
  // State
  bool _isLoading = true;
  bool _hasError = false;
  bool _isEditing = false;
  ClientProfile? _profile;
  
  // Controllers
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  
  // Form key
  final _formKey = GlobalKey<FormState>();
  
  // Preferences
  final String _selectedLanguage = 'English';
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  final ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  /// =================================
  /// Load profile using ApiHelper
  /// =================================
  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final data = await ApiHelper.get('/client/profile'); // returns decoded Map

      if (data['status'] == 200 && data['profile'] != null) {
        final profileJson = data['profile'];

        debugPrint('Profile JSON: $profileJson');
        _profile = ClientProfile.fromJson(profileJson);

        // Populate controllers
        _fullNameController.text = _profile!.fullName;
        _phoneController.text = _profile!.phoneNumber ?? '';
        _locationController.text = _profile!.location ?? '';

        if (!mounted) return;
        setState(() => _isLoading = false);
      } else if (data['status'] == 401) {
        await AuthService.logout();
        if (!mounted) return;
        _redirectToLogin();
      } else if (data['status'] == 403) {
        if (!mounted) return;
        _redirectToRoleDashboard();
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  /// =================================
  /// Update profile
  /// =================================
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Prepare data to update
      final body = {
        "full_name": _fullNameController.text.trim(),
        "phone_number": _phoneController.text.trim(),
        "location": _locationController.text.trim(),
      };

      final data = await ApiHelper.post('/client/profile/update', body);

      if (data['status'] == 200 && data['profile'] != null) {
        _profile = ClientProfile.fromJson(data['profile']);

        if (mounted) {
          Navigator.pop(context); // Close loading
          setState(() => _isEditing = false);
          _showSnackBar('Profile updated successfully', isError: false);
        }
      } else if (data['status'] == 401) {
        await AuthService.logout();
        if (mounted) {
          Navigator.pop(context);
          _redirectToLogin();
        }
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        _showSnackBar('Failed to update profile', isError: true);
      }
    }
  }

  /// =================================
  /// Delete account
  /// =================================
  Future<void> _deleteAccount() async {
    try {
      final data = await ApiHelper.post('/client/profile/delete', {});

      if (data['status'] == 200) {
        await AuthService.logout();
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else {
        throw Exception('Failed to delete account');
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Failed to delete account', isError: true);
    }
  }

  /// =================================
  /// Helpers
  /// =================================
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _redirectToLogin() {
    debugPrint('Redirecting to login...');
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _redirectToRoleDashboard() {
    debugPrint('Redirecting to appropriate dashboard...');
  }

  Future<void> _showLogoutDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) await _logout();
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<void> _showDeleteAccountDialog() async {
    final firstConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (firstConfirm != true) return;

    final secondConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Final Confirmation'),
        content: const Text('This is your last chance. Deleting your account will remove all your data permanently. Are you absolutely sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );

    if (secondConfirm == true) await _deleteAccount();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_hasError || _profile == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.orange.shade400),
            const SizedBox(height: 16),
            const Text('Failed to load profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadProfile,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Remaining widgets remain the same as your current code
    // Just make sure anywhere you access response.statusCode or json.decode(response.body)
    // is removed because ApiHelper already returns Map<String, dynamic>
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // AppBar and rest of UI...
        ],
      ),
    );
  }
}
