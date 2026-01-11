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
        budget: (json['budget'] != null) ? double.parse(json['budget'].toString()).toInt() : 0,
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

enum JobStatus {
  open,
  closed,
  draft;

  // Convert backend string to enum
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

  // Friendly display
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

  // JSON -> ClientJob
  factory ClientJob.fromJson(Map<String, dynamic> json) {
  // Safe budget parsing
  int budgetValue;
  final budgetRaw = json['budget'];
  if (budgetRaw is String) {
    budgetValue = double.parse(budgetRaw).toInt();
  } else if (budgetRaw is num) {
    budgetValue = budgetRaw.toInt();
  } else {
    budgetValue = 0;
  }

  return ClientJob(
    id: json['id'].toString(),
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    budget: budgetValue,
    category: json['category_badge'] ?? 'General',
    location: json['location'] ?? 'Remote',
    postedDate: DateTime.parse(json['posted_at'] ?? DateTime.now().toIso8601String()),
    proposalsCount: json['proposals_count'] ?? 0,
    status: JobStatus.fromString(json['status'] ?? 'draft'),
  );
}



  // ClientJob -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'budget': budget,
      'category_badge': category,
      'location': location,
      'posted_at': postedDate.toIso8601String(),
      'proposals_count': proposalsCount,
      'status': status.name,
    };
  }

  // Copy method (optional, useful for updates)
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
