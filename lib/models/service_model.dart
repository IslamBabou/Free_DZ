
// models/service_model.dart

import 'package:flutter/material.dart';
import 'package:free_dz/models/freelancer_profile.dart';


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
  final String userId; // freelancer user id
  final String title;
  final String description;
  final String category;
  final double price;
  final ServiceStatus status;
  final String? freelancerName;
  final String? avatarUrl;
  final double rating;
  final String email;

  bool isFavorited;
  final DateTime savedAt;
  final DateTime updatedAt;
  final FreelancerProfile? freelancer;


  Service({
    required this.id,
    required this.userId,
    required this.email,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.status,
    required this.avatarUrl,
    required this.rating,
    required this.freelancerName,
    required this.savedAt,
    required this.updatedAt,
    this.isFavorited = false, 
    this.freelancer,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
  final user = json['user'];
  final freelancerJson = user != null ? user['freelancer_profile'] : null;
  final freelancerProfile = user != null ? user['freelancer_profile'] : null;

  return Service(
    id: json['id'].toString(),
    userId: json['user_id'].toString(),
    email: user != null ? user['email'] ?? 'Null' : 'Null',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    category: json['category'] ?? '',
    price: json['price'] != null
        ? double.tryParse(json['price'].toString()) ?? 0.0
        : 0.0,
    rating: freelancerJson?['rating'] != null
        ? double.tryParse(freelancerJson['rating'].toString()) ?? 0.0
        : 0.0,
    status: ServiceStatusExtension.fromString(json['status'] ?? 'inactive'),
    freelancerName: json['user']['full_name'] ?? 'Unkown freelancer',
    avatarUrl: freelancerProfile != null ? freelancerProfile['avatar_url'] : null,
    isFavorited: json['is_favorited'] == true,
    savedAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : DateTime.now(),
    updatedAt: json['updated_at'] != null
        ? DateTime.parse(json['updated_at'])
        : DateTime.now(),   
    freelancer: null,
     
  );
  }

  factory Service.fromJson1(Map<String, dynamic> json) {
  final user = json['user'];
  final freelancerJson = user != null ? user['freelancer_profile'] : null;

  return Service(
    id: json['id'].toString(),
    userId: json['user_id'].toString(),
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    category: json['category'] ?? '',
    price: json['price'] != null
        ? double.tryParse(json['price'].toString()) ?? 0.0
        : 0.0,
    rating: freelancerJson?['rating'] != null
        ? double.tryParse(freelancerJson['rating'].toString()) ?? 0.0
        : 0.0,
    status: ServiceStatusExtension.fromString(json['status'] ?? 'inactive'),
    freelancer: freelancerJson != null
        ? FreelancerProfile.fromJson(freelancerJson)
        : null,
    isFavorited: json['is_favorited'] == true,
    savedAt: json['pivot']?['created_at'] != null
        ? DateTime.parse(json['pivot']['created_at'])
        : DateTime.now(), email: '', avatarUrl: '', freelancerName: 'unkown', updatedAt: DateTime(000),
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
    String? freelancerName,
    String? avatarUrl,
    FreelancerProfile? freelancer,

    bool? isFavorited,
  }) {
    return Service(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      email: email,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      status: status ?? this.status,
      freelancerName: freelancerName,
      avatarUrl: avatarUrl,
      rating: rating,
      savedAt: savedAt,
      updatedAt: updatedAt,
      isFavorited: isFavorited ?? this.isFavorited,
      freelancer: freelancer ?? this.freelancer,
    );
  }
}
enum SortOption { newest, oldest, priceHighToLow, priceLowToHigh, rating }
