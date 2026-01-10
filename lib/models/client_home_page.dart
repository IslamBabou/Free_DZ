import 'package:flutter/material.dart';

class CategoryItem {
  final String name;
  final IconData icon;
  final Color color;

  CategoryItem({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class FreelancerCard {
  final String id;
  final String name;
  final String title;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String hourlyRate;
  final List<String> skills;

  FreelancerCard({
    required this.id,
    required this.name,
    required this.title,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.hourlyRate,
    required this.skills,
  });

  factory FreelancerCard.fromJson(Map<String, dynamic> json) {
    return FreelancerCard(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['image_url'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      hourlyRate: json['hourly_rate'] != null
          ? '\$${(json['hourly_rate'] as num).toStringAsFixed(2)}/hr'
          : '\$0.00/hr',
      skills: List<String>.from(json['skills'] ?? []),
    );
  }
  
}