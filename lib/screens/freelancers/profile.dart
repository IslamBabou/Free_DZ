import 'package:flutter/material.dart';

// ==========================================
// FREELANCER PROFILE PAGE
// ==========================================

class FreelancerProfilePage extends StatelessWidget {
  const FreelancerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
      body: SafeArea(
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
                child: ClipOval(
                  child: Image.network(
                    'https://i.pravatar.cc/150?img=68',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.person, size: 50, color: Colors.blue.shade700);
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
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
            ],
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            'Mehdi Ziane',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),

          // Profession
          Text(
            'Senior Flutter Developer',
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
                return Icon(
                  index < 4 ? Icons.star : Icons.star_half,
                  size: 20,
                  color: Colors.amber.shade600,
                );
              }),
              const SizedBox(width: 8),
              Text(
                '4.8 (127 reviews)',
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
            child: _buildStatCard(
              isDark: isDark,
              icon: Icons.work_outline,
              label: 'Completed',
              value: '45',
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              isDark: isDark,
              icon: Icons.schedule,
              label: 'In Progress',
              value: '3',
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              isDark: isDark,
              icon: Icons.attach_money,
              label: 'Earnings',
              value: '2.5M DA',
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required bool isDark,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
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
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
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
          _buildProfileActionTile(
            isDark: isDark,
            icon: Icons.edit_outlined,
            title: 'Edit Profile',
            subtitle: 'Update your personal information',
            onTap: () {
              // TODO: Navigate to edit profile
            },
          ),
          _buildDivider(isDark),
          _buildProfileActionTile(
            isDark: isDark,
            icon: Icons.star_outline,
            title: 'Skills',
            subtitle: 'Manage your skills and expertise',
            onTap: () {
              // TODO: Navigate to skills
            },
          ),
          _buildDivider(isDark),
          _buildProfileActionTile(
            isDark: isDark,
            icon: Icons.work_outline,
            title: 'Portfolio',
            subtitle: 'Showcase your best work',
            onTap: () {
              // TODO: Navigate to portfolio
            },
          ),
          _buildDivider(isDark),
          _buildProfileActionTile(
            isDark: isDark,
            icon: Icons.done_all_outlined,
            title: 'Completed Jobs',
            subtitle: 'View your work history',
            onTap: () {
              // TODO: Navigate to completed jobs
            },
          ),
          _buildDivider(isDark),
          _buildProfileActionTile(
            isDark: isDark,
            icon: Icons.account_balance_wallet_outlined,
            title: 'Earnings',
            subtitle: 'Track your income and payments',
            onTap: () {
              // TODO: Navigate to earnings
            },
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
          _buildProfileActionTile(
            isDark: isDark,
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'App preferences and notifications',
            onTap: () {
              // TODO: Navigate to settings
            },
          ),
          _buildDivider(isDark),
          _buildProfileActionTile(
            isDark: isDark,
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: () {
              // TODO: Navigate to help
            },
          ),
          _buildDivider(isDark),
          _buildProfileActionTile(
            isDark: isDark,
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'App version and information',
            onTap: () {
              // TODO: Navigate to about
            },
          ),
          _buildDivider(isDark),
          _buildProfileActionTile(
            isDark: isDark,
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            iconColor: Colors.red,
            onTap: () {
              // TODO: Show logout confirmation
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileActionTile({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
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

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
      ),
    );
  }
}