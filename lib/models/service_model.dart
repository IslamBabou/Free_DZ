
// models/service_model.dart
import 'dart:ui';

import 'package:flutter/material.dart';

import 'freelancer_profile.dart';

enum ServiceStatus { active, inactive, pending }

Color getStatusColor(ServiceStatus status) {
  switch (status) {
    case ServiceStatus.active:
      return Colors.green;
    case ServiceStatus.inactive:
      return Colors.grey;
    case ServiceStatus.pending:
      return Colors.orange;
  }
}

extension ServiceStatusExtension on ServiceStatus {
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
  final String userId;
  final String title;
  final String description;
  final String category;
  final double price;
  final ServiceStatus status;
  final FreelancerProfile? freelancer;

  Service({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.status,
    this.freelancer,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
  return Service(
    id: json['id'].toString(),
    userId: json['user_id'].toString(),
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    category: json['category'] ?? '',
    price: json['price'] != null
        ? double.tryParse(json['price'].toString()) ?? 0.0
        : 0.0,
    status: ServiceStatusExtension.fromString(json['status'] ?? 'inactive'),
    freelancer: json['freelancer'] != null
        ? FreelancerProfile.fromJson(json['freelancer'])
        : null,
  );
}

  Service copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? category,
    double? price,
    ServiceStatus? status,
    FreelancerProfile? freelancer,
  }) {
    return Service(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      status: status ?? this.status,
      freelancer: freelancer ?? this.freelancer,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'status': status.toString().split('.').last,
      'freelancer': freelancer?.toJson(),
    };
  }
}
