import 'package:flutter/material.dart';
import 'package:free_dz/models/service_model.dart';
import 'package:free_dz/services/api_helper.dart';
import 'service_details_client.dart';

class ClientServicePage extends StatefulWidget {
  const ClientServicePage({super.key});

  @override
  State<ClientServicePage> createState() => _ClientServicePageState();
}

class _ClientServicePageState extends State<ClientServicePage> {
  List<Service> _services = [];
  bool _isLoading = true;
  bool _hasError = false;

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
      final data = await ApiHelper.get('/freelancer/services/all'); // public endpoint returning all active services
      final List<dynamic> servicesJson = data is List ? data : data['services'];
      _services = servicesJson.map((json) => Service.fromJson(json)).toList();
      _services.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error loading services: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _openServiceDetails(Service service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceDetailsClientPage(service: service),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_hasError) return Center(child: Text('Failed to load services'));

    if (_services.isEmpty) return Center(child: Text('No services available'));

    return RefreshIndicator(
      onRefresh: _loadServices,
      child: ListView.builder(
        itemCount: _services.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final service = _services[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              onTap: () => _openServiceDetails(service),
              title: Text(service.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(service.category),
              trailing: Text(service.price),
            ),
          );
        },
      ),
    );
  }
}
