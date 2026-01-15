import 'package:flutter/material.dart';
import 'package:free_dz/screens/freelancers/portfolio.dart';
import 'package:free_dz/services/api_helper.dart';
import 'package:free_dz/services/auth_service.dart';
import 'package:free_dz/services/theme_provider.dart';
import 'package:free_dz/widgets/reusable_widgets.dart';
import 'package:free_dz/models/profile.dart';
import 'package:provider/provider.dart';

class FreelancerProfilePage extends StatefulWidget {
  final String? freelancerId;

  const FreelancerProfilePage({
    super.key,
    this.freelancerId,
  });

  @override
  State<FreelancerProfilePage> createState() => _FreelancerProfilePageState();
}

class _FreelancerProfilePageState extends State<FreelancerProfilePage> {
  bool _isLoading = true;
  bool _hasError = false;
  FreelancerPortfolio? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await ApiHelper.get('/freelancer/profile');
      final data = response['user']['freelancer_profile'];

      if (data == null) {
        throw Exception('Profile data missing');
      }

      setState(() {
        _profile = FreelancerPortfolio.fromJson(data);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _openPortfolio() {
    if (_profile == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FreelancerProfileEditPage(portfolio: _profile!),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
      body: SafeArea(child: _buildBody(isDark)),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return _buildErrorState();
    }

    if (_profile == null) {
      return const Center(child: Text('No profile data'));
    }

    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: ListView(
        children: [
          _buildHeader(isDark),
          const SizedBox(height: 16),
          _buildStats(isDark),
          const SizedBox(height: 24),
          _buildProfileActions(isDark),
          const SizedBox(height: 16),
          _buildAccountSection(isDark),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.orange.shade400),
          const SizedBox(height: 16),
          const Text(
            'Failed to load profile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
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

  // ================= HEADER =================

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue.shade100,
            backgroundImage:
                _profile!.avatarUrl != null ? NetworkImage(_profile!.avatarUrl!) : null,
            child: _profile!.avatarUrl == null
                ? Icon(Icons.person, size: 50, color: Colors.blue.shade700)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            _profile!.fullName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _profile!.professionalTitle,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 6),
          Text(
            _profile!.location,
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                '${_profile!.rating.toStringAsFixed(1)} '
                '(${_profile!.totalReviews} reviews)',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Free_dz'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Version: 1.0.0'),
            const SizedBox(height: 8),
            Text(
              'A freelance marketplace connecting clients with talented freelancers in Algeria.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ================= STATS =================

  Widget _buildStats(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              isDark: isDark,
              icon: Icons.work_outline,
              label: 'Completed',
              value: _profile!.completedJobs.toString(),
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              isDark: isDark,
              icon: Icons.attach_money,
              label: 'Hourly Rate',
              value: '${_profile!.hourlyRate} DA',
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  // ================= PROFILE ACTIONS =================

  Widget _buildProfileActions(bool isDark) {
    return _buildCard(
      isDark,
      title: 'Profile',
      children: [
        ActionTile(
          isDark: isDark,
          icon: Icons.work_outline,
          title: 'Portfolio',
          subtitle: 'View your work and experience',
          onTap: _openPortfolio,
        ),
      ],
    );
  }

  // ================= ACCOUNT =================

  Widget _buildAccountSection(bool isDark) {
    return _buildCard(
      isDark,
      title: 'Account',
      children: [
        ActionTile(
          isDark: isDark,
          icon: Icons.dark_mode_outlined,
          title: 'Mode',
          subtitle: Provider.of<ThemeProvider>(context)
              .themeMode
              .name
              .replaceFirstMapped(RegExp(r'^.'), (m) => m[0]!.toUpperCase()),
          onTap: () => switchMode(context),
        ),
          AppDivider(isDark: isDark),
          ActionTile(
            isDark: isDark,
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'App version and information',
            onTap: _showAbout,
          ),
        AppDivider(isDark: isDark),
        ActionTile(
          isDark: isDark,
          icon: Icons.logout,
          title: 'Logout',
          subtitle: 'Sign out of your account',
          iconColor: Colors.red,
          onTap: _logout,
        ),
      ],
    );
  }

  // ================= SHARED CARD =================

  Widget _buildCard(
    bool isDark, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
