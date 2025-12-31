import 'package:flutter/material.dart';
import 'package:free_dz/models/saved_services.dart';




// ==========================================
// SAVED SERVICES PAGE
// ==========================================

class SavedFreelancersPage extends StatefulWidget {
  const SavedFreelancersPage({super.key});

  @override
  State<SavedFreelancersPage> createState() => _SavedFreelancersPageState();
}

class _SavedFreelancersPageState extends State<SavedFreelancersPage> {
  // API Configuration
  static const String _apiBaseUrl = 'https://your-api.com/api';
  
  // State
  bool _isLoading = true;
  bool _hasError = false;
  List<SavedService> _savedServices = [];
  List<SavedService> _filteredServices = [];
  String? _selectedCategory;
  SortOption _sortOption = SortOption.newest;

  // Categories
  final List<String> _categories = [
    'All',
    'Design',
    'Development',
    'Writing',
    'Marketing',
    'Video',
    'Music',
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedServices();
  }

  Future<void> _loadSavedServices() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // TODO: Uncomment when API is ready
      /*
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/client/saved-services'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_TOKEN', // Get from secure storage
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _savedServices = data.map((json) => SavedService.fromJson(json)).toList();
        _applyFiltersAndSort();
        setState(() => _isLoading = false);
      } else if (response.statusCode == 401) {
        _redirectToLogin();
      } else if (response.statusCode == 403) {
        _redirectToRoleDashboard();
      } else {
        throw Exception('Failed to load saved services');
      }
      */

      // TEMPORARY: Mock data
      await Future.delayed(const Duration(seconds: 1));
      _savedServices = [
        SavedService(
          id: '1',
          serviceId: 'SRV001',
          title: 'Modern Logo Design',
          description: 'Professional logo design with unlimited revisions',
          category: 'Design',
          priceRange: '5,000 - 15,000 DA',
          rating: 4.9,
          reviewCount: 127,
          freelancer: FreelancerInfo(
            id: 'FR001',
            name: 'Sarah Ahmed',
            avatarUrl: 'https://i.pravatar.cc/150?img=1',
          ),
          savedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        SavedService(
          id: '2',
          serviceId: 'SRV002',
          title: 'Flutter Mobile App Development',
          description: 'Cross-platform mobile app with modern UI/UX',
          category: 'Development',
          priceRange: '50,000 - 200,000 DA',
          rating: 4.8,
          reviewCount: 89,
          freelancer: FreelancerInfo(
            id: 'FR002',
            name: 'Karim Benali',
            avatarUrl: 'https://i.pravatar.cc/150?img=2',
          ),
          savedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        SavedService(
          id: '3',
          serviceId: 'SRV003',
          title: 'SEO-Optimized Content Writing',
          description: 'High-quality blog posts and articles',
          category: 'Writing',
          priceRange: '3,000 - 8,000 DA',
          rating: 5.0,
          reviewCount: 156,
          freelancer: FreelancerInfo(
            id: 'FR003',
            name: 'Amina Boudiaf',
            avatarUrl: 'https://i.pravatar.cc/150?img=3',
          ),
          savedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        SavedService(
          id: '4',
          serviceId: 'SRV004',
          title: 'Social Media Marketing',
          description: 'Complete social media management and growth',
          category: 'Marketing',
          priceRange: '10,000 - 30,000 DA',
          rating: 4.7,
          reviewCount: 92,
          freelancer: FreelancerInfo(
            id: 'FR004',
            name: 'Yacine Mansouri',
            avatarUrl: 'https://i.pravatar.cc/150?img=4',
          ),
          savedAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
        SavedService(
          id: '5',
          serviceId: 'SRV005',
          title: 'Video Editing & Post-Production',
          description: 'Professional video editing for YouTube and social media',
          category: 'Video',
          priceRange: '8,000 - 25,000 DA',
          rating: 4.9,
          reviewCount: 134,
          freelancer: FreelancerInfo(
            id: 'FR005',
            name: 'Lina Boukhari',
            avatarUrl: 'https://i.pravatar.cc/150?img=5',
          ),
          savedAt: DateTime.now().subtract(const Duration(hours: 12)),
        ),
      ];
      
      _applyFiltersAndSort();
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error loading saved services: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _applyFiltersAndSort() {
    _filteredServices = _savedServices;

    // Apply category filter
    if (_selectedCategory != null && _selectedCategory != 'All') {
      _filteredServices = _filteredServices
          .where((service) => service.category == _selectedCategory)
          .toList();
    }

    // Apply sorting
    switch (_sortOption) {
      case SortOption.newest:
        _filteredServices.sort((a, b) => b.savedAt.compareTo(a.savedAt));
        break;
      case SortOption.oldest:
        _filteredServices.sort((a, b) => a.savedAt.compareTo(b.savedAt));
        break;
      case SortOption.rating:
        _filteredServices.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.priceHighToLow:
      case SortOption.priceLowToHigh:
        // Price sorting would require parsing price ranges - simplified here
        break;
    }
  }

  Future<void> _removeService(SavedService service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Service'),
        content: Text('Remove "${service.title}" from your saved services?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Show loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removing service...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      // TODO: Uncomment when API is ready
      /*
      final response = await http.delete(
        Uri.parse('$_apiBaseUrl/client/saved-services/${service.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_TOKEN',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to remove service');
      }
      */

      // TEMPORARY: Mock removal
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _savedServices.removeWhere((s) => s.id == service.id);
        _applyFiltersAndSort();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service removed'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to remove service'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _redirectToLogin() {
    // TODO: Implement navigation to login
    debugPrint('Redirecting to login...');
  }

  void _redirectToRoleDashboard() {
    // TODO: Implement navigation based on role
    debugPrint('Redirecting to appropriate dashboard...');
  }

  void _navigateToExplore() {
    // TODO: Navigate to search/explore screen
    debugPrint('Navigate to explore services...');
  }

  void _viewServiceDetails(SavedService service) {
    // TODO: Navigate to service details screen
    debugPrint('View service details: ${service.title}');
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildFilterSheet(),
    );
  }

  Widget _buildFilterSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter & Sort',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Category Filter
          Text(
            'Category',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((category) {
              final isSelected = _selectedCategory == category ||
                  (_selectedCategory == null && category == 'All');
              return FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = category == 'All' ? null : category;
                    _applyFiltersAndSort();
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Sort Options
          Text(
            'Sort By',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          RadioGroup<SortOption>(
            groupValue: _sortOption,
            onChanged: (SortOption? value) {
              if (value != null) {
                setState(() {
                  _sortOption = value;
                  _applyFiltersAndSort();
                });
                Navigator.pop(context);
              }
            },
            child: Column(
              children: SortOption.values.map((option) {
                final isSelected = _sortOption == option;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _sortOption = option;
                      _applyFiltersAndSort();
                    });
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Radio<SortOption>(
                          value: option,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _getSortOptionLabel(option),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _getSortOptionLabel(SortOption option) {
    switch (option) {
      case SortOption.newest:
        return 'Newest First';
      case SortOption.oldest:
        return 'Oldest First';
      case SortOption.priceHighToLow:
        return 'Price: High to Low';
      case SortOption.priceLowToHigh:
        return 'Price: Low to High';
      case SortOption.rating:
        return 'Highest Rated';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(isDark),
            Expanded(child: _buildBody(isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isDark) {
    return Container(
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Saved Services',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              if (_filteredServices.isNotEmpty)
                Text(
                  '${_filteredServices.length} ${_filteredServices.length == 1 ? 'service' : 'services'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
            style: IconButton.styleFrom(
              backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_hasError) {
      return _buildErrorState(isDark);
    }

    if (_filteredServices.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return RefreshIndicator(
      onRefresh: _loadSavedServices,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredServices.length,
        itemBuilder: (context, index) {
          return _buildServiceCard(_filteredServices[index], isDark);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => _buildSkeletonCard(),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
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
            'Failed to load saved services',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your connection and try again',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadSavedServices,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border_rounded,
              size: 100,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'No saved services yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start saving services to quickly access them later',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _navigateToExplore,
              icon: const Icon(Icons.explore_outlined),
              label: const Text('Explore Services'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(SavedService service, bool isDark) {
    return GestureDetector(
      onTap: () => _viewServiceDetails(service),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            // Header with freelancer info and save button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Freelancer avatar
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blue.shade100,
                    child: service.freelancer.avatarUrl != null
                        ? ClipOval(
                            child: Image.network(
                              service.freelancer.avatarUrl!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.person, color: Colors.blue.shade700);
                              },
                            ),
                          )
                        : Icon(Icons.person, color: Colors.blue.shade700),
                  ),
                  const SizedBox(width: 12),
                  // Freelancer name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.freelancer.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          service.category,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Save button
                  IconButton(
                    onPressed: () => _removeService(service),
                    icon: const Icon(Icons.bookmark, color: Colors.blue),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue.withValues(alpha:0.1),
                    ),
                  ),
                ],
              ),
            ),

            // Service title and description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Footer with rating and price
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
                  // Rating
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        service.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${service.reviewCount})',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  // Price
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      service.priceRange,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
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