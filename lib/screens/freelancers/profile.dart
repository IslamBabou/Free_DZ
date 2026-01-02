import 'package:flutter/material.dart';
import 'package:free_dz/services/api_helper.dart';
import 'package:free_dz/services/auth_service.dart';

// ==========================================
// FREELANCER PROFILE MODEL
// ==========================================

class FreelancerProfileData {
  final String id;
  final String fullName;
  final String title;
  final String? avatarUrl;
  final double rating;
  final int reviewsCount;
  final int completedJobs;
  final int inProgressJobs;
  final String earnings;

  FreelancerProfileData({
    required this.id,
    required this.fullName,
    required this.title,
    this.avatarUrl,
    required this.rating,
    required this.reviewsCount,
    required this.completedJobs,
    required this.inProgressJobs,
    required this.earnings,
  });

  factory FreelancerProfileData.fromJson(Map<String, dynamic> json) {
    return FreelancerProfileData(
      id: json['id'].toString(),
      fullName: json['fullName'] ?? 'Unknown User',
      title: json['title'] ?? 'Freelancer',
      avatarUrl: json['avatarUrl'],
      rating: (json['rating'] ?? 0).toDouble(),
      reviewsCount: json['reviewsCount'] ?? 0,
      completedJobs: json['completedJobs'] ?? 0,
      inProgressJobs: json['inProgressJobs'] ?? 0,
      earnings: json['earnings'] ?? '0 DA',
    );
  }
}

// ==========================================
// FREELANCER PROFILE PAGE
// ==========================================

class FreelancerProfilePage extends StatefulWidget {
  final String? freelancerId; // If null, fetch current user's profile

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
  FreelancerProfileData? _profileData;

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
      // Determine endpoint based on whether we have a specific ID
      final endpoint = widget.freelancerId != null
          ? '/freelancer/${widget.freelancerId}'
          : '/freelancer/me';

      final data = await ApiHelper.get(endpoint);

      setState(() {
        _profileData = FreelancerProfileData.fromJson(data);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading profile: $e');

      // Fallback to mock data for development
      setState(() {
        _profileData = FreelancerProfileData(
          id: widget.freelancerId ?? 'FREELANCER_123',
          fullName: 'Mehdi Ziane',
          title: 'Senior Flutter Developer',
          avatarUrl: 'https://i.pravatar.cc/150?img=68',
          rating: 4.8,
          reviewsCount: 127,
          completedJobs: 45,
          inProgressJobs: 3,
          earnings: '2,500,000 DA',
        );
        _isLoading = false;
        debugPrint('Using mock data due to API error');
      });
    }
  }

  void _navigateToEditProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit Profile coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToSkills() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Skills management coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToPortfolio() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Portfolio coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToCompletedJobs() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Job history coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToEarnings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Earnings page coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToHelp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Help & Support coming soon'),
        behavior: SnackBarBehavior.floating,
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                // Navigate to login screen
                // Navigator.pushReplacementNamed(context, '/login');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logged out successfully'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
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
      body: SafeArea(
        child: _buildBody(isDark),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
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

    if (_profileData == null) {
      return const Center(child: Text('No profile data available'));
    }

    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: ListView(
        children: [
          _buildProfileHeader(isDark),
          const SizedBox(height: 16),
          _buildStatsSection(isDark),
          const SizedBox(height: 24),
          _buildProfileActionsSection(isDark),
          const SizedBox(height: 16),
          _buildAccountSection(isDark),
          const SizedBox(height: 100), // Space for bottom nav
        ],
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Photo
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue.shade100,
                child: _profileData!.avatarUrl != null
                    ? ClipOval(
                        child: Image.network(
                          _profileData!.avatarUrl!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.blue.shade700,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.blue.shade700,
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Photo upload coming soon'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        width: 2,
                      ),
                    ),
                    child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            _profileData!.fullName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),

          // Profession
          Text(
            _profileData!.title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),

          // Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(5, (index) {
                final fullStars = _profileData!.rating.floor();
                final hasHalfStar = (_profileData!.rating - fullStars) >= 0.5;

                if (index < fullStars) {
                  return Icon(Icons.star, size: 20, color: Colors.amber.shade600);
                } else if (index == fullStars && hasHalfStar) {
                  return Icon(Icons.star_half, size: 20, color: Colors.amber.shade600);
                } else {
                  return Icon(Icons.star_border, size: 20, color: Colors.amber.shade600);
                }
              }),
              const SizedBox(width: 8),
              Text(
                '${_profileData!.rating.toStringAsFixed(1)} (${_profileData!.reviewsCount} reviews)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              isDark: isDark,
              icon: Icons.work_outline,
              label: 'Completed',
              value: _profileData!.completedJobs.toString(),
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              isDark: isDark,
              icon: Icons.schedule,
              label: 'In Progress',
              value: _profileData!.inProgressJobs.toString(),
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              isDark: isDark,
              icon: Icons.attach_money,
              label: 'Earnings',
              value: _profileData!.earnings,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileActionsSection(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
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
              'Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          _ActionTile(
            isDark: isDark,
            icon: Icons.edit_outlined,
            title: 'Edit Profile',
            subtitle: 'Update your personal information',
            onTap: _navigateToEditProfile,
          ),
          _Divider(isDark: isDark),
          _ActionTile(
            isDark: isDark,
            icon: Icons.star_outline,
            title: 'Skills',
            subtitle: 'Manage your skills and expertise',
            onTap: _navigateToSkills,
          ),
          _Divider(isDark: isDark),
          _ActionTile(
            isDark: isDark,
            icon: Icons.work_outline,
            title: 'Portfolio',
            subtitle: 'Showcase your best work',
            onTap: _navigateToPortfolio,
          ),
          _Divider(isDark: isDark),
          _ActionTile(
            isDark: isDark,
            icon: Icons.done_all_outlined,
            title: 'Completed Jobs',
            subtitle: 'View your work history',
            onTap: _navigateToCompletedJobs,
          ),
          _Divider(isDark: isDark),
          _ActionTile(
            isDark: isDark,
            icon: Icons.account_balance_wallet_outlined,
            title: 'Earnings',
            subtitle: 'Track your income and payments',
            onTap: _navigateToEarnings,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
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
              'Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          _ActionTile(
            isDark: isDark,
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'App preferences and notifications',
            onTap: _navigateToSettings,
          ),
          _Divider(isDark: isDark),
          _ActionTile(
            isDark: isDark,
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: _navigateToHelp,
          ),
          _Divider(isDark: isDark),
          _ActionTile(
            isDark: isDark,
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'App version and information',
            onTap: _showAbout,
          ),
          _Divider(isDark: isDark),
          _ActionTile(
            isDark: isDark,
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            iconColor: Colors.red,
            onTap: _showLogoutDialog,
          ),
        ],
      ),
    );
  }
}

// ==========================================
// REUSABLE WIDGETS
// ==========================================

class _StatCard extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.isDark,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  const _ActionTile({
    required this.isDark,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? Colors.blue).withAlpha(26),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: iconColor ?? Colors.blue,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: iconColor ?? (isDark ? Colors.white : Colors.black87),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey.shade400,
      ),
      onTap: onTap,
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;

  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
      ),
    );
  }
}