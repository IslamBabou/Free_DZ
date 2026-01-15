import 'service_model.dart';

// models/freelancer_portfolio.dart
class FreelancerPortfolio {
  final int userId;
  final String fullName;
  final String professionalTitle;
  final String location;
  final String? avatarUrl;
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
  final List<PortfolioProject> portfolio;
  final List<Review> reviews;
  final RatingDistribution ratingDistribution;
  final double hourlyRate;

  FreelancerPortfolio({
    required this.userId,
    required this.fullName,
    required this.professionalTitle,
    required this.location,
    this.avatarUrl,
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
    required this.portfolio,
    required this.reviews,
    required this.ratingDistribution,
    required this.hourlyRate,
  });

  factory FreelancerPortfolio.fromJson(Map<String, dynamic> json) {
    return FreelancerPortfolio(
      userId: json['user_id'] as int,
      fullName: json['full_name'] as String,
      professionalTitle: json['professional_title'] as String,
      location: json['location'] as String,
      avatarUrl: json['avatar_url'] as String?,
      isOnline: json['is_online'] == 1 || json['is_online'] == true,
      isVerified: json['is_verified'] == 1 || json['is_verified'] == true,
      rating: (json['rating'] as num).toDouble(),
      totalReviews: json['total_reviews'] as int,
      completedJobs: json['completed_jobs'] as int,
      responseTime: json['response_time'] as String,
      bio: json['bio'] as String,
      yearsOfExperience: json['years_of_experience'] as int,
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      services: (json['services'] as List<dynamic>?)
              ?.map((e) => Service.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      portfolio: (json['portfolio'] as List<dynamic>?)
              ?.map((e) => PortfolioProject.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      reviews: (json['reviews'] as List<dynamic>?)
              ?.map((e) => Review.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      ratingDistribution: json['rating_distribution'] is Map<String, dynamic>
        ? RatingDistribution.fromJson(
            json['rating_distribution'] as Map<String, dynamic>,
      )
    : RatingDistribution.empty(),
      hourlyRate: (json['hourlyRate'] as num).toDouble(),
    );
  }
}



class PortfolioProject {
  final String title;
  final String description;
  final String? imageUrl;

  PortfolioProject({
    required this.title,
    required this.description,
    this.imageUrl,
  });

  factory PortfolioProject.fromJson(Map<String, dynamic> json) {
    return PortfolioProject(
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String?,
    );
  }
}

class Review {
  final String clientName;
  final double rating;
  final String comment;
  final String? clientAvatar;
  final String? date;

  Review({
    required this.clientName,
    required this.rating,
    required this.comment,
    this.clientAvatar,
    this.date,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      clientName: json['client_name'] as String,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      clientAvatar: json['client_avatar'] as String?,
      date: json['date'] as String?,
    );
  }
}

class RatingDistribution {
  final int fiveStar;
  final int fourStar;
  final int threeStar;
  final int twoStar;
  final int oneStar;

  RatingDistribution({
    required this.fiveStar,
    required this.fourStar,
    required this.threeStar,
    required this.twoStar,
    required this.oneStar,
  });

  factory RatingDistribution.fromJson(Map<String, dynamic> json) {
    return RatingDistribution(
      fiveStar: json['5'] as int? ?? 0,
      fourStar: json['4'] as int? ?? 0,
      threeStar: json['3'] as int? ?? 0,
      twoStar: json['2'] as int? ?? 0,
      oneStar: json['1'] as int? ?? 0,
    );
  }

  factory RatingDistribution.empty() {
    return RatingDistribution(
      fiveStar: 0,
      fourStar: 0,
      threeStar: 0,
      twoStar: 0,
      oneStar: 0,
    );
  }
}