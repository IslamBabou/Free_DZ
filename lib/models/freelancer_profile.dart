// ==========================================
// FREELANCER MODEL
// ==========================================
class Freelancer {
  final String id;
  final String? fullName;
  final String? professionalTitle;
  final String? location;
  final String? bio;
  final double? hourlyRate;
  final int? yearsOfExperience;
  final String? responseTime;
  final List<String>? languages;
  final List<String>? skills;
  final List<String>? services;
  final List<String>? portfolio;
  final List<String>? reviews;
  final Map<String, int>? ratingDistribution;
  final double rating;
  final String? avatarUrl;

  Freelancer({
    required this.id,
    this.fullName,
    this.professionalTitle,
    this.location,
    this.bio,
    this.hourlyRate,
    this.yearsOfExperience,
    this.responseTime,
    this.languages,
    this.skills,
    this.services,
    this.portfolio,
    this.reviews,
    this.ratingDistribution,
    required this.rating,
    this.avatarUrl,
  });

  factory Freelancer.fromJson(Map<String, dynamic> json) {
    return Freelancer(
      id: json['id'].toString(),
      fullName: json['full_name'] as String?,
      professionalTitle: json['professional_title'] as String?,
      location: json['location'] as String?,
      bio: json['bio'] as String?,
      hourlyRate: (json['hourlyRate'] != null)
          ? (json['hourlyRate'] as num).toDouble()
          : null,
      yearsOfExperience: json['years_of_experience'] as int?,
      responseTime: json['response_time'] as String?,
      languages: (json['languages'] != null)
          ? List<String>.from(json['languages'])
          : null,
      skills: (json['skills'] != null)
          ? List<String>.from(json['skills'])
          : null,
      services: (json['services'] != null)
          ? List<String>.from(json['services'])
          : null,
      portfolio: (json['portfolio'] != null)
          ? List<String>.from(json['portfolio'])
          : null,
      reviews: (json['reviews'] != null)
          ? List<String>.from(json['reviews'])
          : null,
      ratingDistribution: (json['rating_distribution'] != null)
          ? Map<String, int>.from(json['rating_distribution'])
          : null,
      rating: (json['rating'] != null) ? (json['rating'] as num).toDouble() : 0.0,
      avatarUrl: json['avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'professional_title': professionalTitle,
      'location': location,
      'bio': bio,
      'hourlyRate': hourlyRate,
      'years_of_experience': yearsOfExperience,
      'response_time': responseTime,
      'languages': languages,
      'skills': skills,
      'services': services,
      'portfolio': portfolio,
      'reviews': reviews,
      'rating_distribution': ratingDistribution,
      'avatar': avatarUrl,
    };
  }

  double get averageRating {
  if (ratingDistribution == null || ratingDistribution!.isEmpty) return 0.0;
  int totalStars = 0;
  int totalVotes = 0;
  ratingDistribution!.forEach((star, count) {
    totalStars += int.parse(star) * count;
    totalVotes += count;
  });
  return totalVotes > 0 ? totalStars / totalVotes : 0.0;
}
}
