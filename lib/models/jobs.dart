// ==========================================
// MODELS
// ==========================================

class Job {
  final String id;
  final String title;
  final String clientName;
  final int budget; // ✅ INT, not String
  final String category;
  final String description;
  final DateTime postedDate;
  final int proposalsCount;

  Job({
    required this.id,
    required this.title,
    required this.clientName,
    required this.budget,
    required this.category,
    required this.description,
    required this.postedDate,
    required this.proposalsCount,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'].toString(),
        title: json['title'] ?? '',
        clientName: json['client_name'] ?? '',
        budget: (double.parse(json['budget'])).toInt(),
        category: json['category_badge'] ?? 'General',
        description: json['description'] ?? '',
        postedDate: DateTime.parse(json['posted_at'] ?? DateTime.now().toIso8601String()),
        proposalsCount: json['proposals_count'] ?? 0,
    );
  }
}

// ==========================================
// CLIENT JOB MODEL
// ==========================================
// Extends the base Job model with client-specific fields

enum JobStatus {
  open,
  closed,
  draft;

  static JobStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'open':
        return JobStatus.open;
      case 'closed':
        return JobStatus.closed;
      case 'draft':
        return JobStatus.draft;
      default:
        return JobStatus.draft;
    }
  }

  String get displayName {
    switch (this) {
      case JobStatus.open:
        return 'Open';
      case JobStatus.closed:
        return 'Closed';
      case JobStatus.draft:
        return 'Draft';
    }
  }
}

class ClientJob {
  final String id;
  final String title;
  final String description;
  final int budget;
  final String category;
  final String location;
  final DateTime postedDate;
  final int proposalsCount;
  
  // Client-specific fields
  final JobStatus status;

  ClientJob({
    required this.id,
    required this.title,
    required this.description,
    required this.budget,
    required this.category,
    required this.location,
    required this.postedDate,
    required this.proposalsCount,
    required this.status,
  });

  factory ClientJob.fromJson(Map<String, dynamic> json) {
    return ClientJob(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      budget: json['budget'] ?? 0,
      category: json['category'] ?? 'General',
      location: json['location'] ?? 'Remote',
      postedDate: DateTime.parse(json['postedDate'] ?? DateTime.now().toIso8601String()),
      proposalsCount: json['proposalsCount'] ?? 0,
      status: JobStatus.fromString(json['status'] as String? ?? 'draft'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'budget': budget,
      'category': category,
      'location': location,
      'postedDate': postedDate.toIso8601String(),
      'proposalsCount': proposalsCount,
      'status': status.name,
    };
  }

  ClientJob copyWith({
    String? id,
    String? title,
    String? description,
    int? budget,
    String? category,
    String? location,
    DateTime? postedDate,
    int? proposalsCount,
    JobStatus? status,
  }) {
    return ClientJob(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      budget: budget ?? this.budget,
        category: category ?? this.category,
      location: location ?? this.location,
      postedDate: postedDate ?? this.postedDate,
      proposalsCount: proposalsCount ?? this.proposalsCount,
      status: status ?? this.status,
    );
  }
}