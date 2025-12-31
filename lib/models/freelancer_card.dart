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
}