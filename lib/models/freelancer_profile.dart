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
}

class SkillTag {
  final String name;
  final String category;

  SkillTag({required this.name, required this.category});
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
}
