import 'package:flutter/material.dart';
import 'package:free_dz/models/service_model.dart';
import 'package:free_dz/services/api_helper.dart';

class AllServicesScreen extends StatefulWidget {
  const AllServicesScreen({super.key});

  @override
  State<AllServicesScreen> createState() => _AllServicesScreenState();
}

class _AllServicesScreenState extends State<AllServicesScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  List<Service> _services = [];
  String _searchQuery = '';
  String? _selectedCategory;

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
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await ApiHelper.get('/freelancer/services/all');
      final List<dynamic> data = response['data'] ?? [];

      _services = data.map((json) => Service.fromJson(json)).toList();

      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error loading services: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  List<Service> get _filteredServices {
    return _services.where((service) {
      final matchesSearch = service.title
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          service.description.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == null ||
          _selectedCategory == 'All' ||
          service.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'All Services',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                decoration: InputDecoration(
                  hintText: 'Search services...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.primary),
                  ),
                ),
              ),
            ),
          ),

          // Category Filter
          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category ||
                      (_selectedCategory == null && category == 'All');

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category == 'All' ? null : category;
                        });
                      },
                      backgroundColor: isDark
                          ? const Color(0xFF1E1E1E)
                          : Colors.grey.shade100,
                      selectedColor: colorScheme.primary.withOpacity(0.2),
                      checkmarkColor: colorScheme.primary,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? colorScheme.primary
                            : (isDark ? Colors.white : Colors.black87),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? colorScheme.primary
                            : (isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade300),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // Content
          _isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : _hasError
                  ? SliverFillRemaining(
                      child: _buildErrorState(isDark),
                    )
                  : _filteredServices.isEmpty
                      ? SliverFillRemaining(
                          child: _buildEmptyState(isDark),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              mainAxisSpacing: 16,
                              childAspectRatio: 2.5,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final service = _filteredServices[index];
                                return _buildServiceCard(service, isDark);
                              },
                              childCount: _filteredServices.length,
                            ),
                          ),
                        ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Service service, bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/service_details_client',
          arguments: service,
        );
      },
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Price Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        Text(
                          service.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      service.price,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Category and Status
              Row(
                children: [
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.category_outlined,
                          size: 12,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          service.category,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(service.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _getStatusColor(service.status).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(service.status),
                          size: 12,
                          color: _getStatusColor(service.status),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          service.status.displayName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(service.status),
                          ),
                        ),
                      ],
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

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load services',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your internet connection',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              onPressed: _loadServices,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No services found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filter',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.active:
        return Colors.green;
      case ServiceStatus.inactive:
        return Colors.grey;
      case ServiceStatus.pending:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.active:
        return Icons.check_circle_outline;
      case ServiceStatus.inactive:
        return Icons.cancel_outlined;
      case ServiceStatus.pending:
        return Icons.schedule_outlined;
    }
  }
}