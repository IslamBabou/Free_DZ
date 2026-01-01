// ==========================================
// MODELS
// ==========================================

class Job {
  final String id;
  final String title;
  final String clientName;
  final int budget;
  final String description;
  final String location;
  final DateTime postedAt;
  final String categoryBadge;

  Job({
    required this.id,
    required this.title,
    required this.clientName,
    required this.budget,
    required this.description,
    required this.location,
    required this.postedAt,
    required this.categoryBadge,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      clientName: json['clientName'] ?? 'Anonymous',
      budget: json['budget'] ?? 0,
      description: json['description'] ?? '',
      location: json['location'] ?? 'Remote',
      postedAt: DateTime.parse(json['postedAt'] ?? DateTime.now().toIso8601String()),
      categoryBadge: json['categoryBadge'] ?? json['category'] ?? 'General',
    );
  }
}