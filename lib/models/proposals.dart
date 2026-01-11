// ==========================================
// PROPOSAL MODELS
// ==========================================

enum ProposalStatus {
  pending,
  accepted,
  rejected,
  withdrawn;

  String get displayName {
    switch (this) {
      case ProposalStatus.pending:
        return 'Pending';
      case ProposalStatus.accepted:
        return 'Accepted';
      case ProposalStatus.rejected:
        return 'Rejected';
      case ProposalStatus.withdrawn:
        return 'Withdrawn';
    }
  }

  bool get isPending => this == ProposalStatus.pending;
  bool get isAccepted => this == ProposalStatus.accepted;
  bool get isRejected => this == ProposalStatus.rejected;
  bool get isWithdrawn => this == ProposalStatus.withdrawn;
}

class Proposal {
  final String id;
  final String jobId;
  final String freelancerId;
  final String freelancerName;
  final String? freelancerAvatar;
  final double? freelancerRating;
  final int completedJobs;
  final int bidAmount;
  final int deliveryTime;
  final String coverLetter;
  final ProposalStatus status;
  final DateTime submittedAt;
  final DateTime? respondedAt;

  Proposal({
    required this.id,
    required this.jobId,
    required this.freelancerId,
    required this.freelancerName,
    this.freelancerAvatar,
    this.freelancerRating,
    this.completedJobs = 0,
    required this.bidAmount,
    required this.deliveryTime,
    required this.coverLetter,
    required this.status,
    required this.submittedAt,
    this.respondedAt,
  });

  factory Proposal.fromJson(Map<String, dynamic> json) {
    final freelancerData = json['freelancer'] ?? {};
    
    return Proposal(
      id: json['id'].toString(),
      jobId: json['job_id']?.toString() ?? json['jobId']?.toString() ?? '',
      freelancerId: json['freelancer_id']?.toString() ?? 
                   json['freelancerId']?.toString() ?? 
                   freelancerData['id']?.toString() ?? '',
      freelancerName: freelancerData['name'] ?? 
                     freelancerData['full_name'] ?? 
                     json['freelancer_name'] ?? 
                     'Unknown',
      freelancerAvatar: freelancerData['avatar_url'] ?? 
                       freelancerData['avatarUrl'] ?? 
                       freelancerData['avatar'],
      freelancerRating: (freelancerData['rating'] ?? 
                        freelancerData['average_rating'])?.toDouble(),
      completedJobs: freelancerData['completed_jobs'] ?? 
                    freelancerData['completedJobs'] ?? 
                    0,
      bidAmount: json['bid_amount'] ?? json['bidAmount'] ?? 0,
      deliveryTime: json['delivery_time'] ?? json['deliveryTime'] ?? 0,
      coverLetter: json['cover_letter'] ?? json['coverLetter'] ?? '',
      status: _parseStatus(json['status']),
      submittedAt: DateTime.parse(
        json['submitted_at'] ?? 
        json['submittedAt'] ?? 
        json['created_at'] ?? 
        DateTime.now().toIso8601String()
      ),
      respondedAt: json['responded_at'] != null || json['respondedAt'] != null
          ? DateTime.parse(json['responded_at'] ?? json['respondedAt'])
          : null,
    );
  }

  static ProposalStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'accepted':
        return ProposalStatus.accepted;
      case 'rejected':
        return ProposalStatus.rejected;
      case 'withdrawn':
        return ProposalStatus.withdrawn;
      default:
        return ProposalStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_id': jobId,
      'freelancer_id': freelancerId,
      'bid_amount': bidAmount,
      'delivery_time': deliveryTime,
      'cover_letter': coverLetter,
      'status': status.name,
      'submitted_at': submittedAt.toIso8601String(),
      if (respondedAt != null) 'responded_at': respondedAt!.toIso8601String(),
    };
  }

  Proposal copyWith({
    String? id,
    String? jobId,
    String? freelancerId,
    String? freelancerName,
    String? freelancerAvatar,
    double? freelancerRating,
    int? completedJobs,
    int? bidAmount,
    int? deliveryTime,
    String? coverLetter,
    ProposalStatus? status,
    DateTime? submittedAt,
    DateTime? respondedAt,
  }) {
    return Proposal(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      freelancerId: freelancerId ?? this.freelancerId,
      freelancerName: freelancerName ?? this.freelancerName,
      freelancerAvatar: freelancerAvatar ?? this.freelancerAvatar,
      freelancerRating: freelancerRating ?? this.freelancerRating,
      completedJobs: completedJobs ?? this.completedJobs,
      bidAmount: bidAmount ?? this.bidAmount,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      coverLetter: coverLetter ?? this.coverLetter,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Proposal && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Proposal(id: $id, freelancer: $freelancerName, bid: $bidAmount DA, status: ${status.name})';
  }
}

// Helper class for proposal submission
class ProposalSubmission {
  final int bidAmount;
  final int deliveryTime;
  final String coverLetter;

  ProposalSubmission({
    required this.bidAmount,
    required this.deliveryTime,
    required this.coverLetter,
  });

  Map<String, dynamic> toJson() {
    return {
      'bid_amount': bidAmount,
      'delivery_time': deliveryTime,
      'cover_letter': coverLetter,
    };
  }

  bool get isValid {
    return bidAmount > 0 && 
           deliveryTime > 0 && 
           coverLetter.trim().length >= 20;
  }
}

