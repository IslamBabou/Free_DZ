// ==========================================
// MODELS
// ==========================================

class SavedService {
  final String id;
  final String serviceId;
  final String title;
  final String description;
  final String category;
  final String priceRange;
  final double rating;
  final int reviewCount;
  final FreelancerInfo freelancer;
  final DateTime savedAt;

  SavedService({
    required this.id,
    required this.serviceId,
    required this.title,
    required this.description,
    required this.category,
    required this.priceRange,
    required this.rating,
    required this.reviewCount,
    required this.freelancer,
    required this.savedAt,
  });

  factory SavedService.fromJson(Map<String, dynamic> json) {
    return SavedService(
      id: json['id'].toString(),
      serviceId: json['serviceId'].toString(),
      title: json['title'] ?? json['serviceName'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'General',
      priceRange: json['priceRange'] ?? json['price'] ?? 'Contact for price',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? json['reviews'] ?? 0,
      freelancer: FreelancerInfo.fromJson(json['freelancer'] ?? {}),
      savedAt: DateTime.parse(json['savedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class FreelancerInfo {
  final String id;
  final String name;
  final String? avatarUrl;

  FreelancerInfo({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  factory FreelancerInfo.fromJson(Map<String, dynamic> json) {
    return FreelancerInfo(
      id: json['id'].toString(),
      name: json['name'] ?? 'Unknown Freelancer',
      avatarUrl: json['avatarUrl'] ?? json['avatar'],
    );
  }
}

enum SortOption { newest, oldest, priceHighToLow, priceLowToHigh, rating }