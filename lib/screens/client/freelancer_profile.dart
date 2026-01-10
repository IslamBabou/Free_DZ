import 'package:flutter/material.dart';
import 'package:free_dz/models/freelancer_profile.dart';
import 'package:free_dz/models/service_model.dart';
import 'package:free_dz/services/api_helper.dart';

class FreelancerProfileScreen extends StatefulWidget {
  final String freelancerId;

  const FreelancerProfileScreen({
    super.key,
    required this.freelancerId,
  });

  @override
  State<FreelancerProfileScreen> createState() =>
      _FreelancerProfileScreenState();
}

class _FreelancerProfileScreenState extends State<FreelancerProfileScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  FreelancerProfile? _profile;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final response =
          await ApiHelper.get('/freelancers/${widget.freelancerId}');

      final data = response['data'];
      if (data == null) throw Exception('Freelancer not found');

      setState(() {
        _profile = FreelancerProfile.fromJson(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasError || _profile == null) {
      return Scaffold(
        body: Center(child: Text(_errorMessage ?? 'Error')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Freelancer Profile')),
      body: Column(
        children: [
          _header(),
          _stats(),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'About'),
              Tab(text: 'Services'),
              Tab(text: 'Reviews'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _aboutTab(),
                _servicesTab(),
                _reviewsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: _profile!.avatarUrl != null
                ? NetworkImage(_profile!.avatarUrl!)
                : null,
            child: _profile!.avatarUrl == null
                ? Text(
                    _profile!.fullName[0].toUpperCase(),
                    style: const TextStyle(fontSize: 32),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            _profile!.fullName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(_profile!.professionalTitle),
        ],
      ),
    );
  }

  Widget _stats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _stat('${_profile!.hourlyRate} DA', 'Rate'),
        _stat('${_profile!.yearsOfExperience} yrs', 'Experience'),
        _stat(_profile!.responseTime, 'Response'),
      ],
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label),
      ],
    );
  }

  Widget _aboutTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(_profile!.bio),
        const SizedBox(height: 12),
        if (_profile!.languages.isNotEmpty)
          Text('Languages: ${_profile!.languages.join(', ')}'),
        if (_profile!.skills.isNotEmpty)
          Text('Skills: ${_profile!.skills.join(', ')}'),
      ],
    );
  }

  Widget _servicesTab() {
      if (_profile!.services.isEmpty) {
        return const Center(child: Text('No services'));
      }

      return ListView.builder(
        itemCount: _profile!.services.length,
        itemBuilder: (_, i) {
          final service = _profile!.services[i]; // already a Service

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                service.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(service.description),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Chip(
                        label: Text(service.category),
                        backgroundColor: Colors.blue.withOpacity(0.1),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(service.status.displayName),
                        backgroundColor: getStatusColor(service.status).withOpacity(0.1),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Text(
                '${service.price.toStringAsFixed(2)} DA',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      );
    }



  Widget _reviewsTab() {
    if (_profile!.reviews.isEmpty) {
      return const Center(child: Text('No reviews yet'));
    }

    return ListView.builder(
      itemCount: _profile!.reviews.length,
      itemBuilder: (_, i) {
        return ListTile(
          title: Text(_profile!.reviews[i].toString()),
        );
      },
    );
  }
}
