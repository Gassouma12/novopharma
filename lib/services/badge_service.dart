import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:novopharma/models/badge.dart';
import 'package:novopharma/models/user_badge.dart';

class BadgeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'badges';

  /// Fetch all active badges that are currently available
  Future<List<Badge>> getActiveBadges() async {
    try {
      final now = Timestamp.now();

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get();

      final badges = querySnapshot.docs
          .map((doc) => Badge.fromFirestore(doc))
          .where(
            (badge) =>
                badge.isActiveNow && // Check timeframe and availability
                badge.winnerCount < badge.maxWinners,
          )
          .toList();

      log('[BadgeService] Found ${badges.length} active and available badges');
      return badges;
    } catch (e) {
      log('[BadgeService] Error fetching active badges: $e');
      return [];
    }
  }

  /// Fetch user's earned badges
  Future<List<UserBadge>> getUserBadges(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('userBadges')
          .orderBy('awardedAt', descending: true)
          .get();

      final userBadges = querySnapshot.docs
          .map((doc) => UserBadge.fromFirestore(doc))
          .toList();

      log('[BadgeService] User $userId has ${userBadges.length} badges');
      return userBadges;
    } catch (e) {
      log('[BadgeService] Error fetching user badges: $e');
      return [];
    }
  }

  /// Check if user already has a specific badge
  Future<bool> userHasBadge(String userId, String badgeId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('userBadges')
          .doc(badgeId)
          .get();

      return doc.exists;
    } catch (e) {
      log('[BadgeService] Error checking if user has badge: $e');
      return false;
    }
  }

  /// Get user's progress for a specific badge
  Future<DocumentSnapshot?> getUserBadgeProgress(
    String userId,
    String badgeId,
  ) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('userBadgeProgress')
          .doc(badgeId)
          .get();

      return doc;
    } catch (e) {
      log('[BadgeService] Error fetching badge progress: $e');
      return null;
    }
  }

  /// Stream all badges (for UI display)
  Stream<List<Badge>> streamAllBadges() {
    try {
      return _firestore.collection(_collection).orderBy('name').snapshots().map(
        (querySnapshot) {
          return querySnapshot.docs
              .map((doc) => Badge.fromFirestore(doc))
              .toList();
        },
      );
    } catch (e) {
      log('[BadgeService] Error streaming all badges: $e');
      return Stream.value([]);
    }
  }
}
