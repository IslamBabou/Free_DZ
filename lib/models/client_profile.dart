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
      email: json['email']??"",
      fullName: json['full_name'] ?? json['name'] ?? '',
      phoneNumber: json['phone_number'] ?? json['phone']??'',
      location: json['location']??'',
      avatarUrl: json['avatar_url'] ?? json['avatar']?? '',
      isVerified: json['is_verified'] ?? false,
      role: json['role'] ?? 'client',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
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