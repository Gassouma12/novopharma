import 'package:cloud_firestore/cloud_firestore.dart';

enum RedemptionStatus { pending, approved, rejected }

class PluxeeRedemptionRequest {
  final String id;
  final String userId;
  final String userNameSnapshot;
  final String userEmailSnapshot;
  final double pointsToRedeem;
  final double pluxeeCreditsEquivalent;
  final RedemptionStatus status;
  final DateTime requestedAt;
  final DateTime? processedAt;
  final String? processedBy;
  final String? rejectionReason;

  PluxeeRedemptionRequest({
    required this.id,
    required this.userId,
    required this.userNameSnapshot,
    required this.userEmailSnapshot,
    required this.pointsToRedeem,
    required this.pluxeeCreditsEquivalent,
    required this.status,
    required this.requestedAt,
    this.processedAt,
    this.processedBy,
    this.rejectionReason,
  });

  factory PluxeeRedemptionRequest.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PluxeeRedemptionRequest(
      id: doc.id,
      userId: data['userId'] ?? '',
      userNameSnapshot: data['userNameSnapshot'] ?? '',
      userEmailSnapshot: data['userEmailSnapshot'] ?? '',
      pointsToRedeem: (data['pointsToRedeem'] as num?)?.toDouble() ?? 0.0,
      pluxeeCreditsEquivalent:
          (data['pluxeeCreditsEquivalent'] as num?)?.toDouble() ?? 0.0,
      status: _statusFromString(data['status']),
      requestedAt: _parseDate(data['requestedAt']) ?? DateTime.now(),
      processedAt: _parseDate(data['processedAt']),
      processedBy: data['processedBy'],
      rejectionReason: data['rejectionReason'],
    );
  }

  static RedemptionStatus _statusFromString(String? status) {
    switch (status) {
      case 'approved':
        return RedemptionStatus.approved;
      case 'rejected':
        return RedemptionStatus.rejected;
      case 'pending':
      default:
        return RedemptionStatus.pending;
    }
  }

  String get statusString {
    switch (status) {
      case RedemptionStatus.approved:
        return 'approved';
      case RedemptionStatus.rejected:
        return 'rejected';
      case RedemptionStatus.pending:
        return 'pending';
    }
  }

  bool get isPending => status == RedemptionStatus.pending;
  bool get isApproved => status == RedemptionStatus.approved;
  bool get isRejected => status == RedemptionStatus.rejected;
}

DateTime? _parseDate(dynamic dateValue) {
  if (dateValue is Timestamp) {
    return dateValue.toDate();
  } else if (dateValue is String) {
    return DateTime.tryParse(dateValue);
  }
  return null;
}
