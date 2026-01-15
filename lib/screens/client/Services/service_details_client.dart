import 'package:flutter/material.dart';
import 'package:free_dz/models/service_model.dart';
import 'package:free_dz/services/api_helper.dart';
import 'package:free_dz/services/message_service.dart';

class ServiceDetailsClientPage extends StatefulWidget {
  final Service service;

  const ServiceDetailsClientPage({super.key, required this.service});

  @override
  State<ServiceDetailsClientPage> createState() =>
      _ServiceDetailsClientPageState();
}

class _ServiceDetailsClientPageState extends State<ServiceDetailsClientPage> {
  bool _isFavorite = false;
  bool _isLoading = false;
  FreelancerProfile? _freelancer;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.service.isFavorited ;
    _loadFreelancer();
  }

  Future<void> _loadFreelancer() async {
  setState(() {
    _isLoading = true;
  });

  try {
    final response = await ApiHelper.get(
      '/freelancers/user/${widget.service.userId}',
    );

    final data = response['data'];
    if (data == null) {
      debugPrint('Freelancer ${widget.service.userId} not found');
      setState(() {
        _freelancer = null;
      });
      return;
    }

    // Map the new response structure
    setState(() {
      _freelancer = FreelancerProfile(
        id: data['id'].toString(),
        fullName: data['full_name'] ?? 'Unknown Freelancer',
        avatarUrl: data['avatar_url'],
        isOnline: data['is_online'] ?? false,
        rating: data['rating'] != null
            ? double.tryParse(data['rating'].toString()) ?? 0.0
            : 0.0,
      );
    });
  } catch (e) {
    debugPrint('Failed to load freelancer ${widget.service.userId}: $e');
    setState(() {
      _freelancer = null;
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


  Future<void> _toggleFavorite() async {
    try {
        await ApiHelper.post('/services/${widget.service.id}/favorite', {});
      

      setState(() {
        _isFavorite = !_isFavorite;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _isFavorite ? 'Added to favorites' : 'Removed from favorites'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update favorite: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _messageFreelancer() {
    ConversationService.startConversation(
      context: context,
      freelancerId: widget.service.userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
        appBar: _buildAppBar(isDark),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_freelancer == null) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
        appBar: _buildAppBar(isDark),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.orange.shade400),
              const SizedBox(height: 16),
              const Text(
                'Freelancer info not available',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadFreelancer,
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
      appBar: _buildAppBar(isDark),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildServiceHeader(isDark),
            _buildServiceInfo(isDark),
            _buildDescription(isDark),
            _buildFreelancerCard(isDark),
            _buildActionButtons(isDark),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: isDark ? Colors.white : Colors.black87,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Service Details',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? Colors.red : (isDark ? Colors.white : Colors.black87),
          ),
          onPressed: _toggleFavorite,
        ),
      ],
    );
  }

  Widget _buildServiceHeader(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            widget.service.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),

          // Category and Status Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCategoryChip(widget.service.category),
              _buildStatusChip(widget.service.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceInfo(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
        children: [
          // Price
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.payments_outlined,
                  color: Colors.green.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Service Price',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.service.price.toStringAsFixed(2)} DA',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Dates
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.calendar_today,
                  label: 'Posted',
                  value: _formatDate(widget.service.savedAt),
                  isDark: isDark,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey.shade300,
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.update,
                  label: 'Updated',
                  value: _formatDate(widget.service.updatedAt),
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDescription(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: Colors.blue.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.service.description,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreelancerCard(bool isDark) {
    final freelancer = _freelancer!;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
          Text(
            'About the Freelancer',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: (freelancer.avatarUrl != null &&
                            freelancer.avatarUrl!.isNotEmpty)
                        ? NetworkImage(freelancer.avatarUrl!)
                        : null,
                    child: (freelancer.avatarUrl == null ||
                            freelancer.avatarUrl!.isEmpty)
                        ? Icon(Icons.person, size: 32, color: Colors.grey.shade600)
                        : null,
                  ),
                  if (freelancer.isOnline)
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      freelancer.fullName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.service.email,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Rating
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withAlpha(26),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                freelancer.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _messageFreelancer,
              icon: const Icon(Icons.message_outlined),
              label: const Text('Message Freelancer'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    Color categoryColor;
    switch (category.toLowerCase()) {
      case 'design':
      case 'ui/ux design':
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: categoryColor.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.category_outlined, size: 14, color: categoryColor),
          const SizedBox(width: 6),
          Text(
            category,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: categoryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(ServiceStatus status) {
    Color statusColor;
    String statusText;

    switch (status) {
      case ServiceStatus.active:
        statusColor = Colors.green;
        statusText = 'Active';
        break;
      case ServiceStatus.inactive:
        statusColor = Colors.grey;
        statusText = 'Inactive';
        break;
      case ServiceStatus.pending:
        statusColor = Colors.orange;
        statusText = 'Pending';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
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


//////////////////
/// Model
/// 

class FreelancerProfile {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final bool isOnline;
  final double rating;

  FreelancerProfile({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    required this.isOnline,
    required this.rating,
  });

  factory FreelancerProfile.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return FreelancerProfile(
        id: '',
        fullName: 'Unknown Freelancer',
        avatarUrl: null,
        isOnline: false,
        rating: 0.0,
      );
    }

    return FreelancerProfile(
      id: json['id'].toString(),
      fullName: json['full_name'] ?? 'Unknown Freelancer',
      avatarUrl: json['avatar_url'],
      isOnline: json['is_online'] ?? false,
      rating: (json['rating'] ?? 0).toDouble(),
    );
  }
}
