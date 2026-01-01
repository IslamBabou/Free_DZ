import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:free_dz/models/freelancer_profile.dart';
import 'package:free_dz/models/chat_models.dart';
import 'package:free_dz/screens/client/message.dart';

// ==========================================
// API SERVICE
// ==========================================

class FreelancerApiService {
  static const String baseUrl = 'https://localhost/api'; // Replace with your API URL
  
  // Fetch freelancer profile
  static Future<FreelancerProfile> getFreelancerProfile(String freelancerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/freelancers/$freelancerId'),
        headers: {
          'Content-Type': 'application/json',
          // Add authentication token if needed
          // 'Authorization': 'Bearer ${YourAuthService.token}',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return _parseFreelancerProfile(data);
      } else if (response.statusCode == 404) {
        throw Exception('Freelancer not found');
      } else if (response.statusCode == 403) {
        throw Exception('Access denied');
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Parse FreelancerProfile from JSON
  static FreelancerProfile _parseFreelancerProfile(Map<String, dynamic> json) {
    return FreelancerProfile(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      professionalTitle: json['professional_title'] ?? json['professionalTitle'] ?? '',
      location: json['location'] ?? '',
      avatarUrl: json['avatar_url'] ?? json['avatarUrl'],
      isOnline: json['is_online'] ?? json['isOnline'] ?? false,
      isVerified: json['is_verified'] ?? json['isVerified'] ?? false,
      rating: (json['rating'] ?? 0).toDouble(),
      totalReviews: json['total_reviews'] ?? json['totalReviews'] ?? 0,
      completedJobs: json['completed_jobs'] ?? json['completedJobs'] ?? 0,
      responseTime: json['response_time'] ?? json['responseTime'] ?? '',
      bio: json['bio'] ?? '',
      yearsOfExperience: json['years_of_experience'] ?? json['yearsOfExperience'] ?? 0,
      languages: List<String>.from(json['languages'] ?? []),
      skills: (json['skills'] as List<dynamic>?)
              ?.map((skill) => SkillTag(
                    name: skill['name'] ?? '',
                    category: skill['category'] ?? '',
                  ))
              .toList() ??
          [],
      services: (json['services'] as List<dynamic>?)
              ?.map((service) => ServiceCard(
                    id: service['id'] ?? '',
                    title: service['title'] ?? '',
                    description: service['description'] ?? '',
                    priceFrom: service['price_from'] ?? service['priceFrom'] ?? 0,
                    priceTo: service['price_to'] ?? service['priceTo'] ?? 0,
                    deliveryDays: service['delivery_days'] ?? service['deliveryDays'] ?? 0,
                    rating: (service['rating'] ?? 0).toDouble(),
                    reviewCount: service['review_count'] ?? service['reviewCount'] ?? 0,
                  ))
              .toList() ??
          [],
      portfolio: (json['portfolio'] as List<dynamic>?)
              ?.map((item) => PortfolioItem(
                    id: item['id'] ?? '',
                    imageUrl: item['image_url'] ?? item['imageUrl'] ?? '',
                    title: item['title'] ?? '',
                  ))
              .toList() ??
          [],
      reviews: (json['reviews'] as List<dynamic>?)
              ?.map((review) => Review(
                    id: review['id'] ?? '',
                    clientName: review['client_name'] ?? review['clientName'] ?? '',
                    rating: review['rating'] ?? 0,
                    comment: review['comment'] ?? '',
                    createdAt: DateTime.parse(
                      review['created_at'] ?? review['createdAt'] ?? DateTime.now().toIso8601String(),
                    ),
                    serviceName: review['service_name'] ?? review['serviceName'],
                  ))
              .toList() ??
          [],
      ratingDistribution: _parseRatingDistribution(json['rating_distribution'] ?? json['ratingDistribution']),
    );
  }

  // Parse rating distribution
  static Map<int, int> _parseRatingDistribution(dynamic distribution) {
    if (distribution == null) return {};
    if (distribution is Map) {
      return distribution.map((key, value) => MapEntry(
            int.tryParse(key.toString()) ?? 0,
            value is int ? value : 0,
          ));
    }
    return {};
  }

  // Toggle save/bookmark freelancer
  static Future<bool> toggleSaveFreelancer(String freelancerId, bool currentState) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/freelancers/$freelancerId/save'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer ${YourAuthService.token}',
        },
        body: json.encode({'saved': !currentState}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['saved'] ?? !currentState;
      }
      throw Exception('Failed to save freelancer');
    } catch (e) {
      throw Exception('Error saving: $e');
    }
  }
}

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
  FreelancerProfile? _profile;

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
      final profile = await FreelancerApiService.getFreelancerProfile(widget.freelancerId);
      
      setState(() {
        _profile = profile;
        _isSaved = false; // You can add this to your API response if needed
        _isLoading = false;
      });
    } catch (e) {
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
      final newSavedState = await FreelancerApiService.toggleSaveFreelancer(
        widget.freelancerId,
        _isSaved,
      );

      setState(() {
        _isSaved = newSavedState;
        _isSaving = false;
      });

      // Show feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isSaved ? 'Freelancer saved' : 'Freelancer removed'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
          Stack(
            children: [
              CircleAvatar(
                radius: 55,
                backgroundImage: _profile!.avatarUrl != null
                    ? NetworkImage(_profile!.avatarUrl!)
                    : null,
                child: _profile!.avatarUrl == null
                    ? Text(
                        _profile!.fullName[0].toUpperCase(),
                        style: const TextStyle(fontSize: 32),
                      )
                    : null,
              ),
              if (_profile!.isOnline)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _profile!.fullName,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              if (_profile!.isVerified) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.verified,
                  size: 20,
                  color: Colors.blue.shade400,
                ),
              ],
            ],
          ),
          Text(
            _profile!.professionalTitle,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 6),
          Text(_profile!.location),
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
          _stat('${_profile!.rating}', 'Rating'),
          _stat('${_profile!.completedJobs}', 'Jobs'),
          _stat(_profile!.responseTime, 'Response'),
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
        Text(_profile!.bio),
        const SizedBox(height: 16),
        if (_profile!.yearsOfExperience != null) ...[
          Text(
            'Experience: ${_profile!.yearsOfExperience} years',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
        ],
        if (_profile!.languages.isNotEmpty) ...[
          const Text(
            'Languages',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(_profile!.languages.join(', ')),
          const SizedBox(height: 16),
        ],
        if (_profile!.skills.isNotEmpty) ...[
          const Text(
            'Skills',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _profile!.skills
                .map((s) => Chip(label: Text(s.name)))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildServicesTab(bool isDark) {
    if (_profile!.services.isEmpty) {
      return const Center(
        child: Text('No services available'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _profile!.services.length,
      separatorBuilder: (_, _) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final service = _profile!.services[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            service.title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(service.description),
              const SizedBox(height: 8),
              Text(
                'Delivery: ${service.deliveryDays} days',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${service.priceFrom}${service.priceTo != null ? ' - \$${service.priceTo}' : '+'}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (service.rating != null) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(
                      '${service.rating}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab(bool isDark) {
    if (_profile!.reviews.isEmpty) {
      return const Center(
        child: Text('No reviews yet'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _profile!.reviews.length,
      separatorBuilder: (_, _) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final review = _profile!.reviews[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    review.clientName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < review.rating ? Icons.star : Icons.star_border,
                      size: 16,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (review.serviceName != null)
              Text(
                review.serviceName!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            const SizedBox(height: 8),
            Text(review.comment),
            const SizedBox(height: 4),
            Text(
              _formatDate(review.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
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
                onPressed: () {
                  final freelancerInfo = FreelancerInfo(
                    id: _profile!.id,
                    isOnline: _profile!.isOnline,
                    name: _profile!.fullName,
                    avatarUrl: _profile!.avatarUrl,
                  );

                  final String conversationId = 'client_${freelancerInfo.id}';

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ClientChatPage(
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