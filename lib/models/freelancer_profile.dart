// ==========================================
// MODELS
// ==========================================

class FreelancerProfile {
  final String id;
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
  final List<SkillTag> skills;
  final List<ServiceCard> services;
  final List<PortfolioItem> portfolio;
  final List<Review> reviews;
  final Map<int, int> ratingDistribution;

  FreelancerProfile({
    required this.id,
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
  });

  // =========================
  // fromJson factory
  // =========================
  factory FreelancerProfile.fromJson(Map<String, dynamic> json) {
    return FreelancerProfile(
      id: json['id'].toString(),
      fullName: json['fullName'] ?? json['name'] ?? 'Unknown',
      professionalTitle: json['professionalTitle'] ?? json['title'] ?? 'Freelancer',
      location: json['location'] ?? 'Unknown',
      avatarUrl: json['avatarUrl'] ?? json['avatar'],
      isOnline: json['isOnline'] ?? false,
      isVerified: json['isVerified'] ?? false,
      rating: (json['rating'] ?? 4.5).toDouble(),
      totalReviews: json['totalReviews'] ?? json['reviewCount'] ?? 0,
      completedJobs: json['completedJobs'] ?? 0,
      responseTime: json['responseTime'] ?? 'N/A',
      bio: json['bio'] ?? '',
      yearsOfExperience: json['yearsOfExperience'] ?? 0,
      languages: json['languages'] != null
          ? List<String>.from(json['languages'])
          : [],
      skills: json['skills'] != null
          ? List<SkillTag>.from(
              json['skills'].map((s) => SkillTag.fromJson(s)),
            )
          : [],
      services: json['services'] != null
          ? List<ServiceCard>.from(
              json['services'].map((s) => ServiceCard.fromJson(s)),
            )
          : [],
      portfolio: json['portfolio'] != null
          ? List<PortfolioItem>.from(
              json['portfolio'].map((p) => PortfolioItem.fromJson(p)),
            )
          : [],
      reviews: json['reviews'] != null
          ? List<Review>.from(
              json['reviews'].map((r) => Review.fromJson(r)),
            )
          : [],
      ratingDistribution: json['ratingDistribution'] != null
          ? Map<int, int>.from(json['ratingDistribution'].map(
              (k, v) => MapEntry(int.parse(k), v),
            ))
          : {},
    );
  }
}


class SkillTag {
  final String name;
  final String category;

  SkillTag({required this.name, required this.category});

  factory SkillTag.fromJson(Map<String, dynamic> json) {
    return SkillTag(
      name: json['name'] ?? 'Unknown',
      category: json['category'] ?? '',
    );
  }
}

class ServiceCard {
  final String id;
  final String title;
  final String description;
  final int priceFrom;
  final int priceTo;
  final int deliveryDays;
  final double rating;
  final int reviewCount;

  ServiceCard({
    required this.id,
    required this.title,
    required this.description,
    required this.priceFrom,
    required this.priceTo,
    required this.deliveryDays,
    required this.rating,
    required this.reviewCount,
  });

  factory ServiceCard.fromJson(Map<String, dynamic> json) {
    return ServiceCard(
      id: json['id'].toString(),
      title: json['title'] ?? 'Untitled',
      description: json['description'] ?? '',
      priceFrom: json['priceFrom'] ?? 0,
      priceTo: json['priceTo'] ?? 0,
      deliveryDays: json['deliveryDays'] ?? 0,
      rating: (json['rating'] ?? 4.5).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
    );
  }
}

class PortfolioItem {
  final String id;
  final String imageUrl;
  final String title;

  PortfolioItem({
    required this.id,
    required this.imageUrl,
    required this.title,
  });

  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    return PortfolioItem(
      id: json['id'].toString(),
      imageUrl: json['imageUrl'] ?? '',
      title: json['title'] ?? '',
    );
  }
}

class Review {
  final String id;
  final String clientName;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final String? serviceName;

  Review({
    required this.id,
    required this.clientName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.serviceName,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'].toString(),
      clientName: json['clientName'] ?? 'Anonymous',
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      serviceName: json['serviceName'],
    );
  }
}
