import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:free_dz/models/client_home_page.dart';
import '../../services/auth_service.dart';
import "client_profile.dart";
import 'package:free_dz/services/api_client.dart';
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
  final List<CategoryItem> _categories = [
    CategoryItem(
      name: 'Design',
      icon: Icons.palette_outlined,
      color: Colors.purple,
    ),
    CategoryItem(
      name: 'Development',
      icon: Icons.code_outlined,
      color: Colors.blue,
    ),
    CategoryItem(
      name: 'Writing',
      icon: Icons.edit_outlined,
      color: Colors.green,
    ),
    CategoryItem(
      name: 'Marketing',
      icon: Icons.campaign_outlined,
      color: Colors.orange,
    ),
    CategoryItem(
      name: 'Video',
      icon: Icons.videocam_outlined,
      color: Colors.red,
    ),
    CategoryItem(
      name: 'Music',
      icon: Icons.music_note_outlined,
      color: Colors.pink,
    ),
  ];



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
      
      // Fetch freelancers from your API
      final response = await ApiClient.get('/client/freelancers');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        // Parse the API response into FreelancerCard objects
        _featuredFreelancers = data.map((json) {
          return FreelancerCard(
            id: json['id'].toString(),
            name: json['name'] ?? 'Unknown',
            title: json['title'] ?? 'Freelancer',
            imageUrl: json['imageUrl'] ?? json['avatar'] ?? 'https://i.pravatar.cc/150?img=1',
            rating: (json['rating'] ?? 4.5).toDouble(),
            reviewCount: json['reviewCount'] ?? json['reviews'] ?? 0,
            hourlyRate: json['hourlyRate'] ?? json['rate'] ?? '0 DA',
            skills: json['skills'] != null 
                ? List<String>.from(json['skills']) 
                : [],
          );
        }).toList();
      } else {
        throw Exception('Failed to load freelancers: ${response.statusCode}');
      }
      if (response.statusCode == 401) {
          await AuthService.logout();
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/login');
          return;
      }
      
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error loading data: $e');
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

    return CustomScrollView(
      slivers: [
        // Header with Search
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Find the perfect freelancer',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSearchBar(isDark),
              ],
            ),
          ),
        ),

        // Categories Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Browse by Category',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                _buildCategoriesGrid(isDark),
              ],
            ),
          ),
        ),

        // Featured Freelancers Section
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
                        // Navigate to all freelancers
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
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return GestureDetector(
      onTap: () {
        // Navigate to SearchFreelancers page
        debugPrint('Navigate to Search');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: Colors.grey.shade500,
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              'Search freelancers or services...',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return _buildCategoryCard(category, isDark);
      },
    );
  }

  Widget _buildCategoryCard(CategoryItem category, bool isDark) {
    return InkWell(
      onTap: () {
        debugPrint('Filter by ${category.name}');
        // Navigate to filtered freelancers
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                category.icon,
                color: category.color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
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
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha:0.6),
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${freelancer.hourlyRate}/hr',
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
          setState(() {
            });
          _pageController.jumpToPage(index);
        },
        kIconSize: 24.0,
      ),
    );
  }
}




