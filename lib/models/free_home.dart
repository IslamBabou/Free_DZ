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
  bool isFavorite;
  final int? deliveryTime;        // total days
  final DateTime? submittedAt;    // start date

  Job({
    required this.id,
    required this.title,
    required this.clientName,
    required this.budget,
    required this.description,
    required this.location,
    required this.postedAt,
    required this.categoryBadge,
    required this.isFavorite, 
    this.deliveryTime,
    this.submittedAt,
  });



  static int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  if (value is double) return value.toInt();
  return null;
}
  /// ⏳ Remaining days
  int get remainingDays {
    if (deliveryTime == null || submittedAt == null) return 0;

    final now = DateTime.now();
    final passedDays = now.difference(submittedAt!).inDays;

    final remaining = deliveryTime! - passedDays;
    return remaining > 0 ? remaining : 0;
  }



  factory Job.fromJson(Map<String, dynamic> json) {
  final List proposalsList = json['proposals'] ?? [];
  final Map<String, dynamic>? proposal =
      proposalsList.isNotEmpty ? Map<String, dynamic>.from(proposalsList.first) : null;

  return Job(
    id: json['id'].toString(),
    title: json['title'] ?? '',
    clientName: json['client_name'] ?? 'Anonymous',
    budget: Job._parseInt(json['budget']) ?? 0,
    description: json['description'] ?? '',
    location: json['location'] ?? 'Remote',
    postedAt: DateTime.parse(json['posted_at']),
    categoryBadge: json['category_badge'] ?? 'General',
    isFavorite: json['is_favorited'] ?? false,

    // ✅ FIX HERE
    deliveryTime: Job._parseInt(proposal?['delivery_time']),
    submittedAt: proposal?['submitted_at'] != null
        ? DateTime.parse(proposal!['submitted_at'])
        : null,
  );
}

  
}