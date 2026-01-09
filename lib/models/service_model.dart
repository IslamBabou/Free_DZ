// ==========================================
// SERVICE MODEL
// ==========================================

import 'package:free_dz/models/freelancer_profile.dart';

enum ServiceStatus {
  active,
  inactive,
  pending;

  static ServiceStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return ServiceStatus.active;
      case 'inactive':
        return ServiceStatus.inactive;
      case 'pending':
        return ServiceStatus.pending;
      default:
        return ServiceStatus.inactive;
    }
  }

  String get displayName {
    switch (this) {
      case ServiceStatus.active:
        return 'Active';
      case ServiceStatus.inactive:
        return 'Inactive';
      case ServiceStatus.pending:
        return 'Pending';
    }
  }
}



class Service {
  final String id;
  final String title;
  final String description;
  final String category;
  final String price;
  final ServiceStatus status;
  final DateTime createdAt;
  final Freelancer? freelancer; // link to the full freelancer profile

  Service({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.status,
    required this.createdAt,
    this.freelancer,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'].toString(),
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      price: json['price'].toString(),
      status: ServiceStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      freelancer: json['freelancer'] != null
          ? Freelancer.fromJson(json['freelancer'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      if (freelancer != null) 'freelancer': freelancer!.toJson(),
    };
  }

  Service copyWith({required ServiceStatus status}) {
    return Service(
      id: id,
      title: title,
      description: description,
      category: category,
      price: price,
      status: status,
      createdAt: createdAt,
      freelancer: freelancer,
    );
  }
}
