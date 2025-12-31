// ==========================================
// MODELS
// ==========================================

class ClientProfile {
  final String id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String? location;
  final String? avatarUrl;
  final bool isVerified;
  final String role;
  final DateTime createdAt;

  ClientProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.location,
    this.avatarUrl,
    required this.isVerified,
    required this.role,
    required this.createdAt,
  });

  factory ClientProfile.fromJson(Map<String, dynamic> json) {
    return ClientProfile(
      id: json['id'].toString(),
      email: json['email'],
      fullName: json['fullName'] ?? json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? json['phone'],
      location: json['location'],
      avatarUrl: json['avatarUrl'] ?? json['avatar'],
      isVerified: json['isVerified'] ?? false,
      role: json['role'] ?? 'CLIENT',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'location': location,
    };
  }
}