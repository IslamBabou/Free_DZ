import 'package:flutter/material.dart';
import 'package:free_dz/models/client_home_page.dart';
import 'package:free_dz/models/service_model.dart';
import 'package:free_dz/screens/client/jobs/freelancers.dart';
import 'package:free_dz/screens/client/jobs/my_jobs.dart';
import 'package:free_dz/screens/client/services/services.dart';
import "client_profile.dart";
import 'package:free_dz/services/api_helper.dart';
import "../shared/chat_list.dart";
import "saved_screen.dart";
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';

// ==========================================
// CLIENT HOME PAGE
// ==========================================

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  bool _isLoading = true;
  bool _hasError = false;
  List<FreelancerCard> _featuredFreelancers = [];
  List<Service> _featuredServices = [];
  
  

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Load freelancers
      final freelancersResponse = await ApiHelper.get('/freelancer/all');
      final List<dynamic> freelancersData = freelancersResponse['data'] ?? [];

      _featuredFreelancers = freelancersData.map((json) {
        return FreelancerCard(
          id: json['id']?.toString() ?? '',
          name: json['full_name']?.toString().isNotEmpty == true 
              ? json['full_name'] 
              : 'Unknown',
          title: json['professional_title']?.toString().isNotEmpty == true
              ? json['professional_title']
              : 'Freelancer',
          imageUrl: json['avatar_url'] ?? 'https://i.pravatar.cc/150?img=1',
          rating: (json['rating'] != null ? json['rating'] : 0.0).toDouble(),
          reviewCount: json['total_reviews'] ?? 0,
          hourlyRate: (json['hourlyRate']?.toString() ?? '0'),
          skills: json['skills'] != null ? List<String>.from(json['skills']) : [],
        );
      }).toList();

      // Load services
      final servicesResponse = await ApiHelper.get('/freelancer/services/all');
      final List<dynamic> servicesData = servicesResponse['data'] ?? [];

      _featuredServices = servicesData.take(10).map((json) {
        return Service.fromJson(json);
      }).toList();

      if (!mounted) return;
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
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
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.orange.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your internet connection',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        slivers: [
          // Header with App Name
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade700,
                    Colors.blue.shade500,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.work_outline,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Free DZ',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Find the perfect freelancer for your project',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),

          
          // Featured Services Section
          if (_featuredServices.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Featured Services',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AllServicesScreen(),
                              ),
                            );
                          },
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildFeaturedServices(isDark),
                  ],
                ),
              ),
            ),

          // Featured Freelancers Section
          if (_featuredFreelancers.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Featured Freelancers',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FreelancersScreen(),
                              ),
                            );
                          },
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildFeaturedFreelancers(isDark),
                  ],
                ),
              ),
            ),

          // Bottom padding for navigation bar
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }

  

  

  

  Widget _buildFeaturedServices(bool isDark) {
    if (_featuredServices.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.work_outline,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No services available',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _featuredServices.length,
        itemBuilder: (context, index) {
          final service = _featuredServices[index];
          return _buildServiceCard(service, isDark);
        },
      ),
    );
  }

  Widget _buildServiceCard(Service service, bool isDark) {
    return GestureDetector(
      onTap: () {
        debugPrint('View service: ${service.title}');
        Navigator.pushNamed(
          context,
          '/service_details_client',
          arguments: service,
        );
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                service.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                service.description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),

              // Bottom row with category, price, and status
              Row(
                children: [
                  // Category chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      service.category,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const Spacer(),

                  // Price
                  Text(
                    '${service.price.toStringAsFixed(2)} ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedFreelancers(bool isDark) {
    if (_featuredFreelancers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.person_search_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No freelancers available',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _featuredFreelancers.length,
        itemBuilder: (context, index) {
          final freelancer = _featuredFreelancers[index];
          return _buildFreelancerCard(freelancer, isDark);
        },
      ),
    );
  }

  Widget _buildFreelancerCard(FreelancerCard freelancer, bool isDark) {
    return GestureDetector(
      onTap: () {
        debugPrint('View freelancer: ${freelancer.name}');
        Navigator.pushNamed(
          context,
          '/freelancer_profile',
          arguments: freelancer.id,
        );
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Freelancer Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    color: Colors.grey.shade300,
                    child: Icon(
                      Icons.person,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
                if (freelancer.rating > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            freelancer.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // Freelancer Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    freelancer.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    freelancer.title,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (freelancer.reviewCount > 0)
                    Row(
                      children: [
                        Icon(
                          Icons.reviews_outlined,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${freelancer.reviewCount} reviews',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  if (freelancer.hourlyRate != '0')
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${freelancer.hourlyRate} DA/hr',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// CLIENT BOTTOM NAVIGATION
// ==========================================

class ClientMainScreen extends StatefulWidget {
  const ClientMainScreen({super.key});

  @override
  State<ClientMainScreen> createState() => _ClientMainScreenState();
}

class _ClientMainScreenState extends State<ClientMainScreen> {
  final _pageController = PageController(initialPage: 0);
  final _controller = NotchBottomBarController(index: 0);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final List<Widget> _pages = [
    const ClientHomePage(),
    const ChatListPage(),
    const SavedFreelancersPage(),
    const MyJobsPage(),
    const ClientProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      extendBody: true,
      bottomNavigationBar: AnimatedNotchBottomBar(
        notchBottomBarController: _controller,
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E1E)
            : Colors.white,
        showLabel: true,
        textOverflow: TextOverflow.visible,
        maxLine: 1,
        shadowElevation: 5,
        kBottomRadius: 28.0,
        notchColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.blue.shade700
            : Colors.blue,
        removeMargins: false,
        bottomBarWidth: 500,
        showShadow: true,
        durationInMilliSeconds: 300,
        itemLabelStyle: const TextStyle(fontSize: 10),
        elevation: 1,
        bottomBarItems: const [
          BottomBarItem(
            inActiveItem: Icon(
              Icons.home_outlined,
              color: Colors.grey,
            ),
            activeItem: Icon(
              Icons.home,
              color: Colors.white,
            ),
            itemLabel: 'Home',
          ),
          BottomBarItem(
            inActiveItem: Icon(
              Icons.chat_outlined,
              color: Colors.grey,
            ),
            activeItem: Icon(
              Icons.chat_outlined,
              color: Colors.white,
            ),
            itemLabel: 'Chat',
          ),
          BottomBarItem(
            inActiveItem: Icon(
              Icons.favorite_border,
              color: Colors.grey,
            ),
            activeItem: Icon(
              Icons.favorite,
              color: Colors.white,
            ),
            itemLabel: 'Saved',
          ),
          BottomBarItem(
            inActiveItem: Icon(
              Icons.work_outline,
              color: Colors.grey,
            ),
            activeItem: Icon(
              Icons.work_history,
              color: Colors.white,
            ),
            itemLabel: 'MY Jobs',
          ),
          BottomBarItem(
            inActiveItem: Icon(
              Icons.person_outline,
              color: Colors.grey,
            ),
            activeItem: Icon(
              Icons.person,
              color: Colors.white,
            ),
            itemLabel: 'Profile',
          ),
        ],
        onTap: (index) {
          setState(() {});
          _pageController.jumpToPage(index);
        },
        kIconSize: 24.0,
      ),
    );
  }
}