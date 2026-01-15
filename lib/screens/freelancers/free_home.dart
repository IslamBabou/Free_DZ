import 'package:flutter/material.dart';
import 'package:free_dz/models/free_home.dart';
import 'package:free_dz/screens/freelancers/free_setup.dart';
import 'package:free_dz/screens/freelancers/jobs/jobs_details.dart';
import 'package:free_dz/screens/freelancers/notifications_page.dart';
import 'package:free_dz/screens/freelancers/profile.dart';
import 'package:free_dz/services/api_helper.dart';

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
  // Dashboard
  bool _isLoading = true;
  bool _hasError = false;
  int _completedJobs = 0;
  int _unreadNotifications = 0;

  // Jobs
  bool _jobsLoading = false;
  bool _jobsError = false;
  List<Job> _availableJobs = [];

  final PageController _pageController = PageController();


  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _loadAvailableJobs();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ==========================================
  // API CALLS
  // ==========================================

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final data = await ApiHelper.get('/freelancer/profile');

      setState(() {
        _completedJobs = data['completed_jobs'] ?? 0;
        _unreadNotifications = data['unread_notifications'] ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Dashboard error: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAvailableJobs() async {
    setState(() {
      _jobsLoading = true;
      _jobsError = false;
    });

    try {
      final response = await ApiHelper.get('/freelancer/projects');
      final List list = response['data'];
      print('JSON received: ${response['data']}'); // <- Add this


      setState(() {
        _availableJobs = list.map((e) {
          final Map<String, dynamic> json = Map<String, dynamic>.from(e);

          // Normalize budget BEFORE model parsing
          final rawBudget = json['budget'];
          if (rawBudget is String) {
            json['budget'] = double.tryParse(rawBudget)?.toInt() ?? 0;
          } else if (rawBudget is double) {
            json['budget'] = rawBudget.toInt();
          }

          return Job.fromJson(json);
        }).toList();
        _jobsLoading = false;
      });
    } catch (e) {
      debugPrint('Jobs error: $e');
      setState(() {
        _jobsError = true;
        _jobsLoading = false;
      });
    }
  }

  // ==========================================
  // NAVIGATION
  // ==========================================

  void _navigateToProfileSetup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FreelancerProfileSetupPage(isFromSkip: true),
      ),
    );
  }

  void _navigateToNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FreelancerNotificationsPage(),
      ),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FreelancerProfilePage(),
      ),
    );
  }

  // ==========================================
  // UI
  // ==========================================

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
          _buildPlaceholder('Find Jobs', Icons.work_outline, isDark),
          _buildPlaceholder('Messages', Icons.chat_bubble_outline, isDark),
          const FreelancerProfilePage(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      automaticallyImplyLeading: false,

      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: 0,
      title: const Text('Free_dz', style: TextStyle(fontWeight: FontWeight.bold)),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: _navigateToNotifications,
            ),
            if (_unreadNotifications > 0)
              Positioned(
                right: 10,
                top: 10,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.red,
                  child: Text(
                    _unreadNotifications > 9 ? '9+' : '$_unreadNotifications',
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
        GestureDetector(
          onTap: _navigateToProfile,
          child: const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(child: Icon(Icons.person)),
          ),
        ),
      ],
    );
  }

  Widget _buildHomePage(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: ElevatedButton(
          onPressed: _loadDashboardData,
          child: const Text('Retry'),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _loadDashboardData();
        await _loadAvailableJobs();
      },
      child: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          if (widget.showCompletionBanner)
            _buildCompletionBanner(),
            const SizedBox(height: 24),

          _buildCompletedJobsCard(isDark),
          const SizedBox(height: 24),
          _buildAvailableJobs(isDark),
        ],
      ),
    );
  }

  Widget _buildAvailableJobs(bool isDark) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Jobs',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      if (_jobsLoading)
        const Center(child: CircularProgressIndicator())
      else if (_jobsError)
        Center(
          child: ElevatedButton(
            onPressed: _loadAvailableJobs,
            child: const Text('Retry'),
          ),
        )
      else if (_availableJobs.isEmpty)
        _buildEmptyState(isDark)
      else
        Column(
          children: [
            // Show only the first 5 jobs
            ..._availableJobs.take(5).map((job) => Column(
                  children: [
                    _buildJobCardWithFavorite(job, isDark),
                    const SizedBox(height: 12), // spacing between cards
                  ],
                )),
          ],
        ),
    ],
  );
}

  // ==========================================
  // COMPONENTS
  // ==========================================

  
  Widget _buildCompletedJobsCard(bool isDark) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        leading: const Icon(Icons.check_circle_outline, color: Colors.green),
        title: Text('$_completedJobs',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        subtitle: const Text('Completed Jobs'),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: const [
          Icon(Icons.work_outline, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text('No jobs available'),
        ],
      ),
    );
  }

  

  Widget _buildCompletionBanner() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: _navigateToProfileSetup,
        child: const Text('Complete your profile'),
      ),
    );
  }

  Widget _buildPlaceholder(String title, IconData icon, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 24)),
        ],
      ),
    );
  }
  
// ==============================
// JOB CARD WITH FAVORITE
// ==============================
Widget _buildJobCardWithFavorite(Job job, bool isDark) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => JobDetailsPage(jobId: job.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TITLE + FAVORITE
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    job.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                FavoriteButton(
                  job: job,
                  onChanged: () => setState(() {}),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // DESCRIPTION
            Text(
              job.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color:
                    isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 12),

            // FOOTER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // BUDGET CHIP
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${job.budget} DA',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                    ),
                  ),
                ),

                // VIEW DETAILS
                Row(
                      children: [
              const Icon(Icons.schedule, size: 16, color: Colors.orange),
              const SizedBox(width: 6),
              Text(
                '${job.remainingDays} days remaining',
                style: TextStyle(
                  fontSize: 13,
                  color: job.remainingDays == 0 ? Colors.red : Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
}

// ==============================
// FAVORITE BUTTON WIDGET
// ==============================
class FavoriteButton extends StatefulWidget {
  final Job job;
  final VoidCallback onChanged;

  const FavoriteButton({
    super.key,
    required this.job,
    required this.onChanged,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool _loading = false;

  Future<void> _toggleFavorite() async {
    setState(() => _loading = true);

    try {
      await ApiHelper.post(
        '/projects/${widget.job.id}/favorite',
        {},
      );

      widget.job.isFavorite = !widget.job.isFavorite;
      widget.onChanged();
    } catch (e) {
      debugPrint('Favorite toggle error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return IconButton(
      icon: Icon(
        widget.job.isFavorite
            ? Icons.favorite
            : Icons.favorite_border,
        color: Colors.red,
      ),
      onPressed: _toggleFavorite,
    );
  }
}
