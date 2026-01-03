// ==========================================
// SERVICE MODEL
// ==========================================

enum ServiceStatus {
  active,
  inactive,
  pending;

  static ServiceStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return ServiceStatus.active;
      case 'inactive':
        return ServiceStatus.inactive;
      case 'pending':
        return ServiceStatus.pending;
      default:
        return ServiceStatus.inactive;
    }
  }

  String get displayName {
    switch (this) {
      case ServiceStatus.active:
        return 'Active';
      case ServiceStatus.inactive:
        return 'Inactive';
      case ServiceStatus.pending:
        return 'Pending';
    }
  }
}

class Service {
  final String id;
  final String title;
  final String description;
  final String category;
  final String price;
  final ServiceStatus status;
  final DateTime createdAt;

  Service({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.status,
    required this.createdAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'].toString(),
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      price: json['price'] as String,
      status: ServiceStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Service copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? price,
    ServiceStatus? status,
    DateTime? createdAt,
  }) {
    return Service(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}