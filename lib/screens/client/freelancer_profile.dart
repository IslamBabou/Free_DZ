import 'package:flutter/material.dart';
import 'package:free_dz/models/service_model.dart';
import 'package:free_dz/models/profile.dart';
import 'package:free_dz/services/api_helper.dart';
import 'package:free_dz/services/message_service.dart';

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

  FreelancerPortfolio? _profile;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
    });

    try {
      final response =
          await ApiHelper.get('/freelancers/${widget.freelancerId}');

      final data = response['data'];
      if (data == null) throw Exception('Freelancer not found');

      setState(() {
        _profile = FreelancerPortfolio.fromJson(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasError || _profile == null) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.orange.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage ?? 'Unknown error occurred',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadProfile,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeader(isDark),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            Container(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: isDark ? Colors.white : Colors.black87,
                unselectedLabelColor: Colors.grey.shade600,
                indicatorColor: Theme.of(context).colorScheme.primary,
                tabs: const [
                  Tab(text: 'About'),
                  Tab(text: 'Services'),
                  Tab(text: 'Portfolio'),
                  Tab(text: 'Reviews'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAboutTab(isDark),
                  _buildServicesTab(isDark),
                  _buildPortfolioTab(isDark),
                  _buildReviewsTab(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue.shade100,
                  backgroundImage: _profile!.avatarUrl != null
                      ? NetworkImage(_profile!.avatarUrl!)
                      : null,
                  child: _profile!.avatarUrl == null
                      ? Text(
                          _profile!.fullName.isNotEmpty
                              ? _profile!.fullName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: 32,
                            color: Colors.blue.shade700,
                          ),
                        )
                      : null,
                ),
                if (_profile!.isOnline)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF1E1E1E)
                              : Colors.white,
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
                Flexible(
                  child: Text(
                    _profile!.fullName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (_profile!.isVerified) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.verified,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _profile!.bio,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  _profile!.location,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...List.generate(5, (index) {
                  final fullStars = _profile!.rating.floor();
                  final hasHalfStar = (_profile!.rating - fullStars) >= 0.5;

                  if (index < fullStars) {
                    return Icon(Icons.star,
                        size: 16, color: Colors.amber.shade600);
                  } else if (index == fullStars && hasHalfStar) {
                    return Icon(Icons.star_half,
                        size: 16, color: Colors.amber.shade600);
                  } else {
                    return Icon(Icons.star_border,
                        size: 16, color: Colors.amber.shade600);
                  }
                }),
                const SizedBox(width: 8),
                Text(
                  '${_profile!.rating.toStringAsFixed(1)} (${_profile!.totalReviews} reviews)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.chat),
                label: const Text('Message Freelancer'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  ConversationService.startConversation(
                    context: context,
                    freelancerId: _profile!.userId.toString(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Stats Cards
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                isDark,
                '${_profile!.hourlyRate} DA',
                'Hourly Rate',
                Icons.attach_money,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                isDark,
                '${_profile!.yearsOfExperience} yrs',
                'Experience',
                Icons.work_history,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                isDark,
                _profile!.responseTime,
                'Response Time' '(days)',
                Icons.access_time,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                isDark,
                _profile!.completedJobs.toString(),
                'Completed Jobs',
                Icons.task_alt,
              ),
            ),
          ],
        ),

        // Bio Section
        _buildSectionTitle(isDark, 'About'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            _profile!.bio,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Languages
        if (_profile!.languages.isNotEmpty) ...[
          _buildSectionTitle(isDark, 'Languages'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _profile!.languages
                .map((lang) => Chip(
                      label: Text(lang),
                      backgroundColor: isDark
                          ? Colors.blue.shade900.withOpacity(0.3)
                          : Colors.blue.shade50,
                      labelStyle: TextStyle(
                        color: isDark ? Colors.blue.shade200 : Colors.blue.shade900,
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
        ],

        // Skills
        if (_profile!.skills.isNotEmpty) ...[
          _buildSectionTitle(isDark, 'Skills'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _profile!.skills
                .map((skill) => Chip(
                      label: Text(skill),
                      backgroundColor: isDark
                          ? Colors.green.shade900.withOpacity(0.3)
                          : Colors.green.shade50,
                      labelStyle: TextStyle(
                        color: isDark ? Colors.green.shade200 : Colors.green.shade900,
                      ),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildStatCard(bool isDark, String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
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

  Widget _buildSectionTitle(bool isDark, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildServicesTab(bool isDark) {
    if (_profile!.services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_off_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No services available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _profile!.services.length,
      itemBuilder: (context, index) {
        final service = _profile!.services[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        service.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      '${service.price.toStringAsFixed(2)} DA',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  service.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Chip(
                      label: Text(service.category),
                      backgroundColor: isDark
                          ? Colors.blue.shade900.withOpacity(0.3)
                          : Colors.blue.shade50,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.blue.shade200 : Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(service.status.displayName),
                      backgroundColor: getStatusColor(service.status).withOpacity(0.2),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: getStatusColor(service.status),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPortfolioTab(bool isDark) {
    if (_profile!.portfolio.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_off_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No portfolio projects',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _profile!.portfolio.length,
      itemBuilder: (context, index) {
        final project = _profile!.portfolio[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (project.imageUrl != null)
                Image.network(
                  project.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200,
                      color: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                    );
                  },
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      project.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab(bool isDark) {
    if (_profile!.reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No reviews yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _profile!.reviews.length,
      itemBuilder: (context, index) {
        final review = _profile!.reviews[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.blue.shade100,
                      backgroundImage: review.clientAvatar != null
                          ? NetworkImage(review.clientAvatar!)
                          : null,
                      child: review.clientAvatar == null
                          ? Text(
                              review.clientName.isNotEmpty
                                  ? review.clientName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.clientName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Row(
                            children: [
                              ...List.generate(
                                5,
                                (i) => Icon(
                                  i < review.rating.floor()
                                      ? Icons.star
                                      : Icons.star_border,
                                  size: 14,
                                  color: Colors.amber.shade600,
                                ),
                              ),
                              if (review.date != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  review.date!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  review.comment,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Color getStatusColor(ServiceStatus status) {
  switch (status) {
    case ServiceStatus.active:
      return Colors.green;
    case ServiceStatus.pending:
      return Colors.orange;
    case ServiceStatus.inactive:
      return Colors.red;
  }
}