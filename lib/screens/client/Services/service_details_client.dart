import 'package:flutter/material.dart';
import 'package:free_dz/models/service_model.dart';
import 'package:free_dz/services/api_helper.dart';

class ServiceDetailsClientPage extends StatefulWidget {
  final Service service;

  const ServiceDetailsClientPage({super.key, required this.service});

  @override
  State<ServiceDetailsClientPage> createState() => _ServiceDetailsClientPageState();
}

class _ServiceDetailsClientPageState extends State<ServiceDetailsClientPage> {
  bool _isFavorite = false;

  Future<void> _toggleFavorite() async {
    try {
      // Replace with your actual endpoint for favorites
      if (_isFavorite) {
        await ApiHelper.delete('/favorites/${widget.service.id}');
      } else {
        await ApiHelper.post('/favorites', {'service_id': widget.service.id});
      }

      setState(() {
        _isFavorite = !_isFavorite;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite ? 'Added to favorites' : 'Removed from favorites'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update favorite: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _messageFreelancer() {
    // TODO: Navigate to chat screen with freelancer
    
  }

  @override
  Widget build(BuildContext context) {
    final service = widget.service;
    final freelancer = service.freelancer;
    if (freelancer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Service Details')),
        body: const Center(child: Text('Freelancer info not available')),
      );
}
    
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Details'),
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(service.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            Row(
              children: [
                _chip(service.category, Colors.blue),
                const SizedBox(width: 8),
                _chip(service.status.displayName, _statusColor(service.status)),
              ],
            ),
            const SizedBox(height: 20),

            // Price
            Row(
              children: [
                const Icon(Icons.payments_outlined),
                const SizedBox(width: 8),
                Text(service.price, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),

            // Description
            Text('Description', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 8),
            Text(service.description, style: const TextStyle(fontSize: 15, height: 1.5)),

            const SizedBox(height: 24),
            Divider(),

            // Freelancer info
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 25,
                backgroundImage: (freelancer.avatarUrl != null && freelancer.avatarUrl!.isNotEmpty)
                ? NetworkImage(freelancer.avatarUrl!)
                : null,
              child: (freelancer.avatarUrl == null || freelancer.avatarUrl!.isEmpty)
                ? const Icon(Icons.person)
                : null,
              ),
              title: Text(
                freelancer.fullName ?? 'Unnamed Freelancer',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(freelancer.rating.toStringAsFixed(1)),
                ],
              ),
              trailing: ElevatedButton.icon(
                onPressed: _messageFreelancer,
                icon: const Icon(Icons.message),
                label: const Text('Message'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Color _statusColor(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.active:
        return Colors.green;
      case ServiceStatus.inactive:
        return Colors.grey;
      case ServiceStatus.pending:
        return Colors.orange;
    }
  }
  
}
