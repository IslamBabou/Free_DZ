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
      id: json['id']?.toString() ?? '',
      name: (json['full_name'] != null && json['full_name'].toString().isNotEmpty)
          ? json['full_name']
          : 'Unknown',
      title: (json['professional_title'] != null && json['professional_title'].toString().isNotEmpty)
          ? json['professional_title']
          : 'Freelancer',
      imageUrl: json['avatar_url'] ?? 'https://i.pravatar.cc/150?img=1',
      rating: (json['rating'] != null ? (json['rating'] as num).toDouble() : 0.0),
      reviewCount: json['total_reviews'] ?? 0,
      hourlyRate: json['hourlyRate']?.toString() ?? '0',
      skills: json['skills'] != null ? List<String>.from(json['skills']) : [],
    );
  }
}

class Service {
  final String id;
  final String title;
  final String description;
  final String category;
  final String price;
  final String status;
  final String userId;

  Service({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.status,
    required this.userId,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Service',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      price: json['price']?.toString() ?? '0',
      status: json['status']?.toString() ?? 'pending',
      userId: json['user']?['id']?.toString() ?? '',
    );
  }
}
