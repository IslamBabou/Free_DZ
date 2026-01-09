import 'package:flutter/material.dart';
import 'package:free_dz/models/service_model.dart';
import 'package:free_dz/screens/freelancers/service_details.dart';
import 'package:free_dz/services/api_helper.dart';
import 'create_service.dart';

// ==========================================
// FREELANCER SERVICES PAGE
// ==========================================

class FreelancerServicesPage extends StatefulWidget {
  const FreelancerServicesPage({super.key});

  @override
  State<FreelancerServicesPage> createState() => _FreelancerServicesPageState();
}

class _FreelancerServicesPageState extends State<FreelancerServicesPage> {
  // State
  bool _isLoading = true;
  bool _hasError = false;
  List<Service> _services = [];

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
      final data = await ApiHelper.get('/freelancer/services');
      debugPrint('SERVICES RESPONSE: $data');

      
      final List<dynamic> servicesJson = data is List ? data : data['services'];
      _services = servicesJson.map((json) => Service.fromJson(json)).toList();
      
      // Sort by date, most recent first
      _services.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      setState(() => _isLoading = false);
    } on Exception catch (e) {
      final errorMsg = e.toString();
      
      if (errorMsg.contains('Unauthorized')) {
        _redirectToLogin();
      } else {
        debugPrint('Error loading services: $e');
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleServiceStatus(Service service) async {
    final newStatus = service.status == ServiceStatus.active 
        ? ServiceStatus.inactive 
        : ServiceStatus.active;

    // Optimistic update
    setState(() {
      final index = _services.indexWhere((s) => s.id == service.id);
      if (index != -1) {
        _services[index] = service.copyWith(status: newStatus);
      }
    });

    try {
      await ApiHelper.put(
        '/freelancer/services/${service.id}/status',
        {'status': newStatus.name},
      );
      
      _showSnackBar('Service ${newStatus.displayName.toLowerCase()} successfully');
    } catch (e) {
      debugPrint('Error toggling service status: $e');
      // Revert on failure
      setState(() {
        final index = _services.indexWhere((s) => s.id == service.id);
        if (index != -1) {
          _services[index] = service;
        }
      });
      _showSnackBar('Failed to update service status', isError: true);
    }
  }

  Future<void> _deleteService(Service service) async {
    final confirmed = await _showDeleteConfirmation(service);
    if (!confirmed) return;

    // Store for potential rollback
    final index = _services.indexOf(service);
    
    // Optimistic removal
    setState(() {
      _services.remove(service);
    });

    try {
      await ApiHelper.delete('/freelancer/services/${service.id}');
      _showSnackBar('Service deleted successfully');
    } catch (e) {
      debugPrint('Error deleting service: $e');
      // Revert on failure
      setState(() {
        _services.insert(index, service);
      });
      _showSnackBar('Failed to delete service', isError: true);
    }
  }

  Future<bool> _showDeleteConfirmation(Service service) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text(
          'Are you sure you want to delete "${service.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _openServiceDetails(Service service) {
    debugPrint('Navigate to service details: ${service.id}');
    
    // TODO: Navigate to service details/edit page
    Navigator.push(
       context,
       MaterialPageRoute(
         builder: (context) => ServiceDetailsPage(service: service),
       ),
     ).then((_) => _loadServices()); // Refresh on return
    
  }

  void _createNewService() {
    debugPrint('Navigate to create service page');
    
      Navigator.push(
       context,
       MaterialPageRoute(
         builder: (context) => CreateServicePage(),
       ),
     ).then((created) {
       if (created == true) {
         _loadServices(); // Refresh list
       }
     });
    
  }

  void _redirectToLogin() {
    debugPrint('Redirecting to login...');
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
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
      body: _buildBody(isDark),
      floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 70), // adjust as needed
            child: FloatingActionButton(
              onPressed: _createNewService,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
      
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: 1,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back),
      ),
      title: const Text(
        'My Services',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
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
              'Failed to load services',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your connection and try again',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadServices,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    if (_services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_center_outlined,
              size: 100,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'No services yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first service to start\nreceiving orders from clients',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _createNewService,
              icon: const Icon(Icons.add),
              label: const Text('Create Service'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadServices,
      child: ListView.builder(
        itemCount: _services.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          return _buildServiceCard(_services[index], isDark);
        },
      ),
    );
  }

  Widget _buildServiceCard(Service service, bool isDark) {
    final isActive = service.status == ServiceStatus.active;
    
    return Dismissible(
      key: Key(service.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(service);
      },
      onDismissed: (direction) {
        _deleteService(service);
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      child: InkWell(
        onTap: () => _openServiceDetails(service),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                  ? Colors.green.withValues(alpha: 0.3)
                  : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
              width: isActive ? 1.5 : 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Category Row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      service.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      service.category,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              
              // Description
              Text(
                service.description,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              
              // Price, Status, and Date Row
              Row(
                children: [
                  // Price
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.payments_outlined,
                          size: 14,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          service.price,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Status Badge
                  InkWell(
                    onTap: () => _toggleServiceStatus(service),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(service.status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getStatusColor(service.status).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(service.status),
                            size: 14,
                            color: _getStatusColor(service.status),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            service.status.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(service.status),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  
                  // Posted date
                  Text(
                    _formatRelativeTime(service.createdAt),
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
        return Icons.check_circle;
      case ServiceStatus.inactive:
        return Icons.cancel;
      case ServiceStatus.pending:
        return Icons.pending;
    }
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '${minutes}m ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '${hours}h ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '${days}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    }
  }
}