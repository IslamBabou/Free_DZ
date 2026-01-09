import 'package:flutter/material.dart';
import 'package:free_dz/services/api_helper.dart';
import 'package:free_dz/services/auth_service.dart';
import 'dart:convert';
import 'package:free_dz/models/freelancer_profile.dart';
import 'package:free_dz/models/chat_models.dart';
import 'package:free_dz/screens/shared/message.dart';

// ==========================================
// FREELANCER PROFILE SCREEN (CLIENT VIEW)
// ==========================================

class FreelancerProfileScreen extends StatefulWidget {
  final String freelancerId;

  const FreelancerProfileScreen({
    super.key,
    required this.freelancerId,
  });

  @override
  State<FreelancerProfileScreen> createState() =>
      _FreelancerProfileScreenState();
}

class _FreelancerProfileScreenState extends State<FreelancerProfileScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  Freelancer? _profile;

  bool _isSaved = false;
  bool _isSaving = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final response = await ApiHelper.get('/freelancers/${widget.freelancerId}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return;

        setState(() {
          _profile = Freelancer.fromJson(data);
          _isSaved = data['is_saved'] ?? data['isSaved'] ?? false;
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        if (!mounted) return;
        setState(() {
          _hasError = true;
          _errorMessage = 'Session expired. Please login again.';
          _isLoading = false;
        });
      } else if (response.statusCode == 404) {
        if (!mounted) return;
        setState(() {
          _hasError = true;
          _errorMessage = 'Freelancer not found';
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleSave() async {
    if (_isSaving || _profile == null) return;

    setState(() => _isSaving = true);

    try {
      final response = await ApiHelper.post(
        '/freelancers/${widget.freelancerId}/save',
        {'save': !_isSaved},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return;

        setState(() {
          _isSaved = data['saved'] ?? data['is_saved'] ?? !_isSaved;
          _isSaving = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isSaved ? 'Freelancer saved' : 'Freelancer removed'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to toggle save');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ==========================================
  // UI
  // ==========================================

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? _buildErrorState(isDark)
              : _buildContent(isDark),
      bottomNavigationBar:
          _profile != null ? _buildBottomActions(isDark) : null,
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'An error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              onPressed: _loadProfile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: CustomScrollView(
        slivers: [
          _buildAppBar(isDark),
          SliverToBoxAdapter(child: _buildProfileHeader(isDark)),
          SliverToBoxAdapter(child: _buildStatsBar(isDark)),
          SliverToBoxAdapter(child: _buildTabBar(isDark)),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAboutTab(isDark),
                _buildServicesTab(isDark),
                _buildReviewsTab(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      title: const Text('Profile'),
      leading: BackButton(color: isDark ? Colors.white : Colors.black),
      actions: [
        IconButton(
          icon: _isSaving
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  _isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: _isSaved ? Colors.amber : null,
                ),
          onPressed: _isSaving ? null : _toggleSave,
        ),
      ],
    );
  }

  Widget _buildProfileHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: Column(
        children: [
          CircleAvatar(
            radius: 55,
            backgroundImage: _profile!.avatarUrl != null
                ? NetworkImage(_profile!.avatarUrl!)
                : null,
            child: _profile!.avatarUrl == null && _profile!.fullName != null
                ? Text(
                    _profile!.fullName![0].toUpperCase(),
                    style: const TextStyle(fontSize: 32),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            _profile!.fullName ?? 'Unknown',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          if (_profile!.professionalTitle != null)
            Text(
              _profile!.professionalTitle!,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          if (_profile!.location != null) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(_profile!.location!),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (_profile!.hourlyRate != null)
            _stat('${_profile!.hourlyRate} DA/hr', 'Hourly Rate'),
          if (_profile!.yearsOfExperience != null)
            _stat('${_profile!.yearsOfExperience} years', 'Experience'),
          if (_profile!.responseTime != null)
            _stat(_profile!.responseTime!, 'Response'),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'About'),
          Tab(text: 'Services'),
          Tab(text: 'Reviews'),
        ],
      ),
    );
  }

  Widget _buildAboutTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (_profile!.bio != null) ...[
          const Text(
            'Bio',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(_profile!.bio!),
          const SizedBox(height: 16),
        ],
        if (_profile!.yearsOfExperience != null) ...[
          Text(
            'Experience: ${_profile!.yearsOfExperience} years',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
        ],
        if (_profile!.hourlyRate != null) ...[
          Text(
            'Hourly Rate: ${_profile!.hourlyRate} DA',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
        ],
        if (_profile!.languages != null && _profile!.languages!.isNotEmpty) ...[
          const Text(
            'Languages',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(_profile!.languages!.join(', ')),
          const SizedBox(height: 16),
        ],
        if (_profile!.skills != null && _profile!.skills!.isNotEmpty) ...[
          const Text(
            'Skills',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _profile!.skills!
                .map((s) => Chip(
                      label: Text(s),
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      side: BorderSide(color: Colors.blue.withOpacity(0.3)),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildServicesTab(bool isDark) {
    if (_profile!.services == null || _profile!.services!.isEmpty) {
      return const Center(
        child: Text('No services available'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _profile!.services!.length,
      separatorBuilder: (_, __) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final service = _profile!.services![index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab(bool isDark) {
    if (_profile!.reviews == null || _profile!.reviews!.isEmpty) {
      return const Center(
        child: Text('No reviews yet'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _profile!.reviews!.length,
      separatorBuilder: (_, __) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final review = _profile!.reviews![index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(review),
          ),
        );
      },
    );
  }

  Widget _buildBottomActions(bool isDark) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 💬 MESSAGE BUTTON
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.chat),
                label: const Text('Message'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final freelancerInfo = FreelancerInfo(
                    id: _profile!.id,
                    isOnline: false, // Since model doesn't have isOnline
                    name: _profile!.fullName ?? 'Freelancer',
                    avatarUrl: _profile!.avatarUrl,
                  );

                  final String conversationId = 'conv_${widget.freelancerId}';

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        conversationId: conversationId,
                        freelancer: freelancerInfo,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(width: 12),

            // 🧰 VIEW SERVICES BUTTON
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.work),
                label: const Text('View Services'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // Switch to services tab
                  _tabController.animateTo(1);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}