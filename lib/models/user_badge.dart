import 'package:cloud_firestore/cloud_firestore.dart';

class UserBadge {
  final String id;
  final String userId;
  final String badgeId;
  final String badgeName;
  final String badgeDescription;
  final String badgeImageUrl;
  final String context;
  final DateTime awardedAt;

  UserBadge({
    required this.id,
    required this.userId,
    required this.badgeId,
    required this.badgeName,
    required this.badgeDescription,
    required this.badgeImageUrl,
    required this.context,
    required this.awardedAt,
  });

  factory UserBadge.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserBadge(
      id: doc.id,
      userId: data['userId'] ?? '',
      badgeId: data['badgeId'] ?? '',
      badgeName: data['badgeName'] ?? '',
      badgeDescription: data['badgeDescription'] ?? '',
      badgeImageUrl: data['badgeImageUrl'] ?? '',
      context: data['context'] ?? '',
      awardedAt: (data['awardedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Factory for subcollection where document ID is the badge ID
  /// and uses 'imageUrl' field instead of 'badgeImageUrl'
  factory UserBadge.fromSubcollection(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserBadge(
      id: doc.id,
      userId: data['userId'] ?? '',
      badgeId: doc.id, // Document ID IS the badge ID
      badgeName: data['badgeName'] ?? '',
      badgeDescription: data['badgeDescription'] ?? '',
      badgeImageUrl:
          data['imageUrl'] ??
          data['badgeImageUrl'] ??
          '', // Handle both field names
      context: data['context'] ?? '',
      awardedAt: (data['awardedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
