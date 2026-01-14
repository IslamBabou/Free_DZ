class Job {
  final int id;
  final String title;
  final String description;
  final String budget;       // 🔥 STRING
  final String status;
  final String clientName;
  final String location;
  final DateTime postedAt;
  final String category;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.budget,
    required this.status,
    required this.clientName,
    required this.location,
    required this.postedAt,
    required this.category,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      budget: json['budget'].toString(), // ✅ safe
      status: json['status'] ?? '',
      clientName: json['client_name'] ?? '',
      location: json['location'] ?? '',
      category: json['category_badge'] ?? '',
      postedAt: DateTime.tryParse(json['posted_at'] ?? '') ?? DateTime.now(),
    );
  }
}
