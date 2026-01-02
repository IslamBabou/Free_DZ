import 'package:flutter/material.dart';
import 'package:free_dz/services/api_helper.dart';

// ==========================================
// MODELS
// ==========================================

class Job {
  final String id;
  final String title;
  final String clientName;
  final String budgetRange;
  final String category;
  final String description;
  final DateTime postedDate;
  final int proposalsCount;

  Job({
    required this.id,
    required this.title,
    required this.clientName,
    required this.budgetRange,
    required this.category,
    required this.description,
    required this.postedDate,
    required this.proposalsCount,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      clientName: json['clientName'] ?? 'Anonymous',
      budgetRange: json['budgetRange'] ?? '0 DA',
      category: json['category'] ?? 'General',
      description: json['description'] ?? '',
      postedDate: DateTime.parse(json['postedDate'] ?? DateTime.now().toIso8601String()),
      proposalsCount: json['proposalsCount'] ?? 0,
    );
  }
}

// ==========================================
// JOBS PAGE
// ==========================================

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  bool _isLoading = true;
  bool _hasError = false;
  List<Job> _jobs = [];
  List<Job> _filteredJobs = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadJobs() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // API call using ApiHelper
      final data = await ApiHelper.get('/jobs');
      
      setState(() {
        _jobs = (data['jobs'] as List?)
            ?.map((job) => Job.fromJson(job))
            .toList() ?? [];
        _filteredJobs = _jobs;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading jobs: $e');
      
      // Fallback to mock data
      setState(() {
        _jobs = _getMockJobs();
        _filteredJobs = _jobs;
        _isLoading = false;
        debugPrint('Using mock data due to API error');
      });
    }
  }

  List<Job> _getMockJobs() {
    return [
      Job(
        id: 'JOB001',
        title: 'Mobile App UI/UX Design',
        clientName: 'Ahmed Benali',
        budgetRange: '30,000 - 50,000 DA',
        category: 'Design',
        description: 'Looking for an experienced UI/UX designer to create a modern mobile app design for an e-commerce platform.',
        postedDate: DateTime.now().subtract(const Duration(hours: 2)),
        proposalsCount: 5,
      ),
      Job(
        id: 'JOB002',
        title: 'Flutter Developer for Delivery App',
        clientName: 'Karim Mansouri',
        budgetRange: '80,000 - 120,000 DA',
        category: 'Development',
        description: 'Need a skilled Flutter developer to build a food delivery application with real-time tracking.',
        postedDate: DateTime.now().subtract(const Duration(hours: 5)),
        proposalsCount: 12,
      ),
      Job(
        id: 'JOB003',
        title: 'Content Writing for Tech Blog',
        clientName: 'Sarah Boudiaf',
        budgetRange: '5,000 - 10,000 DA',
        category: 'Writing',
        description: 'Looking for a tech writer to create 10 SEO-optimized blog posts about software development.',
        postedDate: DateTime.now().subtract(const Duration(days: 1)),
        proposalsCount: 8,
      ),
      Job(
        id: 'JOB004',
        title: 'Social Media Marketing Campaign',
        clientName: 'Yacine Belkacem',
        budgetRange: '25,000 - 40,000 DA',
        category: 'Marketing',
        description: 'Need a digital marketer to run a 30-day Instagram and Facebook campaign for a new product launch.',
        postedDate: DateTime.now().subtract(const Duration(days: 1)),
        proposalsCount: 15,
      ),
      Job(
        id: 'JOB005',
        title: 'Logo Design for Startup',
        clientName: 'Lina Amrani',
        budgetRange: '8,000 - 15,000 DA',
        category: 'Design',
        description: 'Startup company needs a professional logo design with brand guidelines.',
        postedDate: DateTime.now().subtract(const Duration(days: 2)),
        proposalsCount: 20,
      ),
      Job(
        id: 'JOB006',
        title: 'Video Editing for YouTube Channel',
        clientName: 'Mehdi Ziane',
        budgetRange: '12,000 - 20,000 DA',
        category: 'Video',
        description: 'Looking for a video editor to edit weekly YouTube videos (10-15 minutes each).',
        postedDate: DateTime.now().subtract(const Duration(days: 3)),
        proposalsCount: 6,
      ),
    ];
  }

  void _searchJobs(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredJobs = _jobs;
      } else {
        _filteredJobs = _jobs.where((job) {
          return job.title.toLowerCase().contains(query.toLowerCase()) ||
                 job.description.toLowerCase().contains(query.toLowerCase()) ||
                 job.category.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            _buildSearchBar(isDark),
            Expanded(
              child: _buildJobsList(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available Jobs',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                'Find your next project',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              // TODO: Navigate to filters
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Filters coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.tune),
            style: IconButton.styleFrom(
              backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
      child: TextField(
        controller: _searchController,
        onChanged: _searchJobs,
        decoration: InputDecoration(
          hintText: 'Search jobs...',
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _searchJobs('');
                  },
                  icon: Icon(Icons.clear, color: Colors.grey.shade500),
                )
              : null,
          filled: true,
          fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildJobsList(bool isDark) {
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
              'Failed to load jobs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadJobs,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline, size: 100, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            Text(
              _searchController.text.isEmpty ? 'No jobs available' : 'No results found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _searchController.text.isEmpty
                  ? 'Check back later for new opportunities'
                  : 'Try searching with different keywords',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadJobs,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredJobs.length,
        itemBuilder: (context, index) {
          return JobCard(job: _filteredJobs[index], isDark: isDark);
        },
      ),
    );
  }
}

// ==========================================
// JOB CARD WIDGET
// ==========================================

class JobCard extends StatelessWidget {
  final Job job;
  final bool isDark;

  const JobCard({
    super.key,
    required this.job,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Header
          Padding(
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildCategoryChip(),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      job.clientName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(job.postedDate),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              job.description,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 16),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budget',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.budgetRange,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${job.proposalsCount} proposals',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate to job details
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Job details coming soon'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('View Details'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip() {
    Color categoryColor;
    switch (job.category.toLowerCase()) {
      case 'design':
        categoryColor = Colors.purple;
        break;
      case 'development':
        categoryColor = Colors.blue;
        break;
      case 'writing':
        categoryColor = Colors.green;
        break;
      case 'marketing':
        categoryColor = Colors.orange;
        break;
      case 'video':
        categoryColor = Colors.red;
        break;
      default:
        categoryColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: categoryColor.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        job.category,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: categoryColor,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}