import 'package:free_dz/models/service_model.dart';

class FreelancerProfile {
  final String id;
  final String userId; // <-- add this!
  final String fullName;
  final String professionalTitle;
  final String location;
  final String? avatarUrl;
  final int hourlyRate;
  final bool isOnline;
  final bool isVerified;
  final double rating;
  final int totalReviews;
  final int completedJobs;
  final String responseTime;
  final String bio;
  final int yearsOfExperience;
  final List<String> languages;
  final List<String> skills;
  final List<Service> services;
  final List<dynamic> reviews;

  FreelancerProfile({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.professionalTitle,
    required this.location,
    this.avatarUrl,
    required this.hourlyRate,
    required this.isOnline,
    required this.isVerified,
    required this.rating,
    required this.totalReviews,
    required this.completedJobs,
    required this.responseTime,
    required this.bio,
    required this.yearsOfExperience,
    required this.languages,
    required this.skills,
    required this.services,
    required this.reviews,
  });

  factory FreelancerProfile.fromJson(Map<String, dynamic> json) {
  return FreelancerProfile(
    id: json['id'].toString(),
    userId: json['user_id'].toString(),
    fullName: json['full_name'] ?? '',
    professionalTitle: json['professional_title'] ?? '',
    location: json['location'] ?? '',
    avatarUrl: json['avatar_url'],
    hourlyRate: (json['hourlyRate'] ?? 0).toDouble(),
    isOnline: json['is_online'] ?? false,
    isVerified: json['is_verified'] ?? false,
    rating: (json['rating'] ?? 0).toDouble(),
    totalReviews: (json['total_reviews'] ?? 0).toInt(),
    completedJobs: (json['completed_jobs'] ?? 0).toInt(),
    responseTime: json['response_time'] ?? '',
    bio: json['bio'] ?? '',
    yearsOfExperience: (json['years_of_experience'] ?? 0).toInt(),
    languages: List<String>.from(json['languages'] ?? []),
    skills: List<String>.from(json['skills'] ?? []),
    services: json['services'] != null
    ? List<Service>.from(json['services'].map((s) => Service.fromJson(s)))
    : [],
    reviews: json['reviews'] != null
        ? List<dynamic>.from(json['reviews'])
        : [],
  );
}
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'professional_title': professionalTitle,
      'location': location,
      'avatar_url': avatarUrl,
      'hourlyRate': hourlyRate,
      'is_online': isOnline,
      'is_verified': isVerified,
      'rating': rating,
      'total_reviews': totalReviews,
      'completed_jobs': completedJobs,
      'response_time': responseTime,
      'bio': bio,
      'years_of_experience': yearsOfExperience,
      'languages': languages,
      'skills': skills,
      'services': services,
      'reviews': reviews,
    };
  }
}
