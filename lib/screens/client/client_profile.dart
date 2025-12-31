import 'package:flutter/material.dart';

import 'package:free_dz/models/client_profile.dart';


// ==========================================
// CLIENT PROFILE PAGE
// ==========================================

class ClientProfilePage extends StatefulWidget {
  const ClientProfilePage({super.key});

  @override
  State<ClientProfilePage> createState() => _ClientProfilePageState();
}

class _ClientProfilePageState extends State<ClientProfilePage> {
  // API Configuration
  static const String _apiBaseUrl = 'https://localhost/api';
  
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
  String _selectedLanguage = 'English';
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  ThemeMode _themeMode = ThemeMode.system;

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

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // TODO: Uncomment when API is ready
      /*
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/client/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_TOKEN', // Get from secure storage
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _profile = ClientProfile.fromJson(data);
        
        // Populate controllers
        _fullNameController.text = _profile!.fullName;
        _phoneController.text = _profile!.phoneNumber ?? '';
        _locationController.text = _profile!.location ?? '';
        
        setState(() => _isLoading = false);
      } else if (response.statusCode == 401) {
        // Unauthorized - redirect to login
        _redirectToLogin();
      } else if (response.statusCode == 403) {
        // Forbidden - wrong role
        _redirectToRoleDashboard();
      } else {
        throw Exception('Failed to load profile');
      }
      */

      // TEMPORARY: Mock data
      await Future.delayed(const Duration(seconds: 1));
      _profile = ClientProfile(
        id: 'CLT12345',
        email: 'client@example.com',
        fullName: 'Ahmed Benali',
        phoneNumber: '+213 555 123 456',
        location: 'Algiers, Algeria',
        avatarUrl: 'https://i.pravatar.cc/150?img=8',
        isVerified: true,
        role: 'CLIENT',
        createdAt: DateTime(2023, 1, 15),
      );
      
      _fullNameController.text = _profile!.fullName;
      _phoneController.text = _profile!.phoneNumber ?? '';
      _locationController.text = _profile!.location ?? '';
      
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error loading profile: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // TODO: Uncomment when API is ready
      /*
      final response = await http.put(
        Uri.parse('$_apiBaseUrl/client/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_TOKEN',
        },
        body: json.encode({
          'fullName': _fullNameController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'location': _locationController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _profile = ClientProfile.fromJson(data);
      } else {
        throw Exception('Failed to update profile');
      }
      */

      // TEMPORARY: Mock update
      await Future.delayed(const Duration(seconds: 1));
      _profile = ClientProfile(
        id: _profile!.id,
        email: _profile!.email,
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        location: _locationController.text.trim(),
        avatarUrl: _profile!.avatarUrl,
        isVerified: _profile!.isVerified,
        role: _profile!.role,
        createdAt: _profile!.createdAt,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading
        setState(() => _isEditing = false);
        _showSnackBar('Profile updated successfully', isError: false);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        _showSnackBar('Failed to update profile', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _redirectToLogin() {
    // TODO: Implement navigation to login
    debugPrint('Redirecting to login...');
  }

  void _redirectToRoleDashboard() {
    // TODO: Implement navigation based on role
    debugPrint('Redirecting to appropriate dashboard...');
  }

  Future<void> _showLogoutDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
                    
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _logout();
      Navigator.pushNamed(context, '/login');
    }
  }

  Future<void> _logout() async {
    // TODO: Implement logout API call and clear tokens
    debugPrint('Logging out...');
    _redirectToLogin();
  }

  Future<void> _showDeleteAccountDialog() async {
    final firstConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
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
        content: const Text(
          'This is your last chance. Deleting your account will remove all your data permanently. Are you absolutely sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );

    if (secondConfirm == true) {
      _deleteAccount();
    }
  }

  Future<void> _deleteAccount() async {
    // TODO: Implement delete account API call
    debugPrint('Deleting account...');
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              centerTitle: true,
            ),
            actions: [
              if (_isEditing)
                TextButton(
                  onPressed: () {
                    setState(() => _isEditing = false);
                    _fullNameController.text = _profile!.fullName;
                    _phoneController.text = _profile!.phoneNumber ?? '';
                    _locationController.text = _profile!.location ?? '';
                  },
                  child: const Text('Cancel'),
                )
              else
                IconButton(
                  onPressed: () => setState(() => _isEditing = true),
                  icon: const Icon(Icons.edit_outlined),
                ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Header
                  _buildProfileHeader(isDark),
                  const SizedBox(height: 24),

                  // Account Information
                  _buildAccountInformation(isDark),
                  const SizedBox(height: 16),

                  // Preferences
                  _buildPreferences(isDark),
                  const SizedBox(height: 16),

                  // Security & Privacy
                  _buildSecurity(isDark),
                  const SizedBox(height: 16),

                  // Account Actions
                  _buildAccountActions(isDark),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue.shade100,
                child: _profile!.avatarUrl != null
                    ? ClipOval(
                        child: Image.network(
                          _profile!.avatarUrl!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.person, size: 50, color: Colors.blue.shade700);
                          },
                        ),
                      )
                    : Icon(Icons.person, size: 50, color: Colors.blue.shade700),
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: isDark ? const Color(0xFF1E1E1E) : Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Name
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _profile!.fullName,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              if (_profile!.isVerified) ...[
                const SizedBox(width: 6),
                Icon(Icons.verified, size: 20, color: Colors.blue.shade600),
              ],
            ],
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            _profile!.email,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),

          // Account ID
          Text(
            'ID: ${_profile!.id}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInformation(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            // Full Name
            TextFormField(
              controller: _fullNameController,
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Full name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Phone Number
            TextFormField(
              controller: _phoneController,
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: const Icon(Icons.phone_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (!RegExp(r'^\+?[\d\s\-()]+$').hasMatch(value)) {
                    return 'Invalid phone number format';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Location
            TextFormField(
              controller: _locationController,
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: 'Location',
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // Email (Read-only)
            TextFormField(
              initialValue: _profile!.email,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: const Icon(Icons.lock_outline, size: 18),
              ),
            ),

            if (_isEditing) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Changes', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreferences(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferences',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Language
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: Text(_selectedLanguage),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Show language selection dialog
            },
          ),
          const Divider(),

          // Push Notifications
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Push Notifications'),
            value: _pushNotifications,
            onChanged: (value) {
              setState(() => _pushNotifications = value);
            },
          ),
          const Divider(),

          // Email Notifications
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.email_outlined),
            title: const Text('Email Notifications'),
            value: _emailNotifications,
            onChanged: (value) {
              setState(() => _emailNotifications = value);
            },
          ),
          const Divider(),

          // Theme
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme'),
            subtitle: Text(_themeMode == ThemeMode.system ? 'System' : _themeMode == ThemeMode.dark ? 'Dark' : 'Light'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Show theme selection dialog
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSecurity(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Security & Privacy',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Change Password
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to change password screen
            },
          ),
          const Divider(),

          // Manage Sessions
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.devices_outlined),
            title: const Text('Manage Sessions'),
            subtitle: const Text('View and manage your active sessions'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to sessions screen
            },
          ),
          const Divider(),

          // Two-Factor Authentication
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.security_outlined),
            title: const Text('Two-Factor Authentication'),
            subtitle: const Text('Not enabled'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to 2FA setup
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActions(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Logout
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.logout, color: Colors.orange),
            title: const Text('Logout', style: TextStyle(color: Colors.orange)),
            trailing: const Icon(Icons.chevron_right, color: Colors.orange),
            onTap: _showLogoutDialog,
          ),
          const Divider(),

          // Delete Account
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Permanently delete your account and data'),
            trailing: const Icon(Icons.chevron_right, color: Colors.red),
            onTap: _showDeleteAccountDialog,
          ),
        ],
      ),
    );
  }
}