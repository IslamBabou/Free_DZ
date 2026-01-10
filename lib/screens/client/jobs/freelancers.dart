import 'package:flutter/material.dart';
import 'package:free_dz/models/client_home_page.dart';
import 'package:free_dz/services/api_helper.dart';


class FreelancersScreen extends StatefulWidget {
  const FreelancersScreen({super.key});

  @override
  State<FreelancersScreen> createState() => _FreelancersScreenState();
}

class _FreelancersScreenState extends State<FreelancersScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  List<FreelancerCard> _freelancers = [];

  @override
  void initState() {
    super.initState();
    _fetchFreelancers();
  }

  Future<void> _fetchFreelancers() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // ApiHelper.get already returns decoded JSON
      final response = await ApiHelper.get('/freelancer/all');

      // Get the 'data' list
      final List<dynamic> data = response['data'] ?? [];

      // Map to your FreelancerCard model (handles nulls safely)
      _freelancers = data.map((json) => FreelancerCard.fromJson(json)).toList();

      if (!mounted) return;
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error loading freelancers: $e');
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text('Failed to load freelancers', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchFreelancers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('All Freelancers')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _freelancers.length,
        itemBuilder: (context, index) {
          final freelancer = _freelancers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(freelancer.imageUrl),
              ),
              title: Text(freelancer.name),
              subtitle: Text(freelancer.title),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    freelancer.rating.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/freelancer_profile',
                  arguments: freelancer.id,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
