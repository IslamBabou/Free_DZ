import 'package:flutter/material.dart';
import 'package:free_dz/models/free_home.dart';
import 'package:free_dz/screens/freelancers/free_setup.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'dart:async';

// ==========================================
// FREELANCER HOME PAGE
// ==========================================

class FreelancerHomePage extends StatefulWidget {
  final bool showCompletionBanner;

  const FreelancerHomePage({
    super.key,
    this.showCompletionBanner = false,
  });

  @override
  State<FreelancerHomePage> createState() => _FreelancerHomePageState();
}

class _FreelancerHomePageState extends State<FreelancerHomePage> {
  // API Configuration
  static const String _apiBaseUrl = 'https://localhost/api';
  
  // State
  bool _isLoading = true;
  bool _hasError = false;
  
  // Dashboard data
  int _completedJobs = 0;
  List<Job> _availableJobs = [];
  int _unreadNotifications = 0;

  // Bottom Bar Controller
  final _pageController = PageController(initialPage: 0);
  final NotchBottomBarController _bottomBarController = NotchBottomBarController(index: 0);
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // TODO: Uncomment when API is ready
      /*
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/freelancer/dashboard'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_TOKEN',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _completedJobs = data['completedJobs'] ?? 0;
          _unreadNotifications = data['unreadNotifications'] ?? 0;
          _availableJobs = (data['availableJobs'] as List?)
              ?.map((job) => Job.fromJson(job))
              .toList() ?? [];
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        _redirectToLogin();
      } else {
        throw Exception('Failed to load dashboard');
      }
      */

      // TEMPORARY: Mock data
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _completedJobs = 15;
        _unreadNotifications = 5;
        _availableJobs = [
          Job(
            id: 'job_1',
            title: 'Mobile App UI/UX Design',
            clientName: 'Tech Startup Inc.',
            budget: 1500,
            description: 'Looking for an experienced UI/UX designer to create a modern mobile app design for our fintech startup. Must include user research and prototyping.',
            location: 'Remote',
            postedAt: DateTime.now().subtract(const Duration(hours: 2)),
            categoryBadge: 'Design',
          ),
          Job(
            id: 'job_2',
            title: 'Flutter Developer for E-commerce App',
            clientName: 'Fashion Store',
            budget: 3000,
            description: 'Need a skilled Flutter developer to build a complete e-commerce mobile application with payment integration and admin panel.',
            location: 'Algiers',
            postedAt: DateTime.now().subtract(const Duration(hours: 5)),
            categoryBadge: 'Development',
          ),
          Job(
            id: 'job_3',
            title: 'Logo Design for Tech Company',
            clientName: 'Innovation Labs',
            budget: 500,
            description: 'Create a professional and modern logo for our AI technology company. Should convey innovation and trust.',
            location: 'Remote',
            postedAt: DateTime.now().subtract(const Duration(days: 1)),
            categoryBadge: 'Design',
          ),
          Job(
            id: 'job_4',
            title: 'Content Writer for Blog Posts',
            clientName: 'Digital Marketing Agency',
            budget: 800,
            description: 'We need a talented content writer to produce 10 high-quality blog posts about digital marketing and SEO.',
            location: 'Remote',
            postedAt: DateTime.now().subtract(const Duration(days: 2)),
            categoryBadge: 'Writing',
          ),
          Job(
            id: 'job_5',
            title: 'WordPress Website Development',
            clientName: 'Small Business Owner',
            budget: 1200,
            description: 'Looking for a WordPress developer to create a professional business website with contact forms and SEO optimization.',
            location: 'Oran',
            postedAt: DateTime.now().subtract(const Duration(days: 3)),
            categoryBadge: 'Development',
          ),
        ];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading dashboard: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _navigateToProfileSetup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FreelancerProfileSetupPage(
          freelancerId: 'FREELANCER_123',
          isFromSkip: true,
        ),
      ),
    );
  }

  void _navigateToNotifications() {
    _showSnackBar('Notifications page coming soon');
  }

  void _viewJobDetails(Job job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildJobDetailsSheet(job),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
      appBar: _buildAppBar(isDark),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildHomePage(isDark),
          _buildJobsPage(isDark),
          _buildMessagesPage(isDark),
          _buildProfilePage(isDark),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: _buildAnimatedBottomBar(isDark),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.work, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            'Free_dz',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              onPressed: _navigateToNotifications,
              icon: const Icon(Icons.notifications_outlined),
            ),
            if (_unreadNotifications > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    _unreadNotifications > 9 ? '9+' : '$_unreadNotifications',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12, left: 4),
          child: GestureDetector(
            onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => _buildProfilePage(isDark),
                      ),
                    );
                    },
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blue.shade100,
              child: const Icon(Icons.person, color: Colors.blue, size: 20),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHomePage(bool isDark) {
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
              'Failed to load dashboard',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDashboardData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 100),
        children: [
          if (widget.showCompletionBanner) _buildCompletionBanner(isDark),
          _buildCompletedJobsCard(isDark),
          const SizedBox(height: 24),
          _buildAvailableJobs(isDark),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildJobsPage(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_outline, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Find Jobs',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Browse and search for jobs',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesPage(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Messages',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your conversations with clients',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePage(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'View and edit your profile',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionBanner(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade400],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.info_outline, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Complete your profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Attract more clients and get hired faster',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _navigateToProfileSetup,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue.shade600,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text(
              'Complete',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedJobsCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_completedJobs',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Completed Jobs',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.trending_up,
            color: Colors.green,
            size: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableJobs(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Jobs',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  _pageController.jumpToPage(1);
                  _bottomBarController.jumpTo(1);
                },
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_availableJobs.isEmpty)
          _buildEmptyState(isDark)
        else
          ..._availableJobs.take(5).map((job) => _buildJobCard(job, isDark)),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.work_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No jobs available right now',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back soon for new opportunities',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(Job job, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _viewJobDetails(job),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        job.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        job.categoryBadge,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  job.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.attach_money, size: 16, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      '\$${job.budget}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      job.location,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatJobTime(job.postedAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJobDetailsSheet(Job job) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  job.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Posted by ${job.clientName}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildDetailChip(
                icon: Icons.attach_money,
                label: '\$${job.budget}',
                color: Colors.green,
              ),
              const SizedBox(width: 12),
              _buildDetailChip(
                icon: Icons.location_on,
                label: job.location,
                color: Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Description',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            job.description,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showSnackBar('Proposal submission coming soon');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Submit Proposal',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBottomBar(bool isDark) {
    return AnimatedNotchBottomBar(
      notchBottomBarController: _bottomBarController,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      showLabel: true,
      textOverflow: TextOverflow.visible,
      maxLine: 1,
      shadowElevation: 5,
      kBottomRadius: 28.0,
      notchColor: Colors.blue,
      removeMargins: false,
      bottomBarWidth: 500,
      showShadow: true,
      durationInMilliSeconds: 300,
      itemLabelStyle: TextStyle(
        fontSize: 10,
        color: isDark ? Colors.white : Colors.black87,
      ),
      elevation: 1,
      bottomBarItems: [
        BottomBarItem(
          inActiveItem: Icon(
            Icons.home_outlined,
            color: isDark ? Colors.white70 : Colors.grey.shade600,
          ),
          activeItem: const Icon(
            Icons.home,
            color: Colors.white,
          ),
          itemLabel: 'Home',
        ),
        BottomBarItem(
          inActiveItem: Icon(
            Icons.work_outline,
            color: isDark ? Colors.white70 : Colors.grey.shade600,
          ),
          activeItem: const Icon(
            Icons.work,
            color: Colors.white,
          ),
          itemLabel: 'Jobs',
        ),
        BottomBarItem(
          inActiveItem: Icon(
            Icons.chat_bubble_outline,
            color: isDark ? Colors.white70 : Colors.grey.shade600,
          ),
          activeItem: const Icon(
            Icons.chat_bubble,
            color: Colors.white,
          ),
          itemLabel: 'Messages',
        ),
        BottomBarItem(
          inActiveItem: Icon(
            Icons.person_outline,
            color: isDark ? Colors.white70 : Colors.grey.shade600,
          ),
          activeItem: const Icon(
            Icons.person,
            color: Colors.white,
          ),
          itemLabel: 'Profile',
        ),
      ],
      onTap: (index) {
        _pageController.jumpToPage(index);
      },
      kIconSize: 24.0,
    );
  }

  String _formatJobTime(DateTime time) {
    final difference = DateTime.now().difference(time);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}