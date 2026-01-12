import 'package:flutter/material.dart';
import 'package:free_dz/models/saved_services.dart';
import 'package:free_dz/services/api_helper.dart';
import 'package:free_dz/services/auth_service.dart';

// ==========================================
// SAVED SERVICES PAGE
// ==========================================

class SavedFreelancersPage extends StatefulWidget {
  const SavedFreelancersPage({super.key});

  @override
  State<SavedFreelancersPage> createState() => _SavedFreelancersPageState();
}

class _SavedFreelancersPageState extends State<SavedFreelancersPage> {
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
      final response = await ApiHelper.get('/services/favorites');

      if (response['status'] == 200) {
        final List<dynamic> data = response['data'];
        debugPrint('Saved services data: $data');
        _savedServices = data.map((json) => SavedService.fromJson(json)).toList();
        _applyFiltersAndSort();
        
        if (!mounted) return;
        setState(() => _isLoading = false);
      } else if (response['status'] == 401) {
        await AuthService.logout();
        if (!mounted) return;
        _redirectToLogin();
      } else if (response['status'] == 403) {
        if (!mounted) return;
        _redirectToRoleDashboard();
      } else {
        throw Exception('Failed to load saved services');
      }
    } catch (e) {
      debugPrint('Error loading saved services: $e');
      if (!mounted) return;
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

      final response = await ApiHelper.post(
        '/services/${service.id}/favorite',        {},
      );

      if (response['is_favorited'] == false) {
        _loadSavedServices();
        // Successfully removed        
        
        if (!mounted) return;
        setState(() {
          _savedServices.removeWhere((s) => s.id == service.id);
          _applyFiltersAndSort();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service removed'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (response['status'] == 401) {
        await AuthService.logout();
        if (!mounted) return;
        _redirectToLogin();
      } else {
        throw Exception('Failed to remove service');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _redirectToLogin() {
    debugPrint('Redirecting to login...');
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _redirectToRoleDashboard() {
    debugPrint('Redirecting to appropriate dashboard...');
  }

  void _navigateToExplore() {
    debugPrint('Navigate to explore services...');
    // TODO: Navigate to search/explore screen
  }

  void _viewServiceDetails(SavedService service) {
    debugPrint('View service details: ${service.title}');
    // TODO: Navigate to service details screen
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
              color: Colors.black.withAlpha(13),
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
                      backgroundColor: Colors.blue.withAlpha(26),
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
                      color: Colors.green.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      service.price,
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