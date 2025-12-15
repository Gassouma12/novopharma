import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:novopharma/models/user_model.dart';

class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getLeaderboard(String period) async {
    try {
      // 1. Determine the start date for the query
      DateTime startDate;
      final now = DateTime.now();
      switch (period) {
        case 'daily':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'weekly':
          startDate = now.subtract(Duration(days: now.weekday - 1));
          startDate = DateTime(startDate.year, startDate.month, startDate.day);
          break;
        case 'monthly':
          startDate = DateTime(now.year, now.month, 1);
          break;
        case 'yearly':
          startDate = DateTime(now.year, 1, 1);
          break;
        default:
          // Default to weekly
          startDate = now.subtract(Duration(days: now.weekday - 1));
          startDate = DateTime(startDate.year, startDate.month, startDate.day);
      }

      // 2. Query sales collection
      final salesSnapshot = await _firestore
          .collection('sales')
          .where(
            'saleDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .get();

      if (salesSnapshot.docs.isEmpty) {
        return [];
      }

      // 3. Aggregate points for each user
      final Map<String, int> userPoints = {};
      for (var saleDoc in salesSnapshot.docs) {
        final data = saleDoc.data();
        final userId = data['userId'] as String?;
        final pointsValue = data['pointsEarned'];
        // Handle both int and double types from Firestore
        final points = pointsValue is num ? pointsValue.toInt() : null;
        if (userId != null && points != null) {
          userPoints.update(
            userId,
            (value) => value + points,
            ifAbsent: () => points,
          );
        }
      }

      if (userPoints.isEmpty) {
        return [];
      }

      // 4. Sort users by points and get top users' IDs
      final sortedUsers = userPoints.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Let's limit to fetching top 100 to avoid huge queries
      final topUserIds = sortedUsers.take(100).map((e) => e.key).toList();

      if (topUserIds.isEmpty) {
        return [];
      }

      // 5. Fetch user details for the top users
      final usersSnapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: topUserIds)
          .get();

      final Map<String, UserModel> userProfiles = {
        for (var doc in usersSnapshot.docs)
          doc.id: UserModel.fromFirestore(doc),
      };

      // 6. Combine user data with points and rank
      final List<Map<String, dynamic>> leaderboard = [];
      int rank = 1;
      for (var userEntry in sortedUsers) {
        final userId = userEntry.key;
        final points = userEntry.value;
        final userProfile = userProfiles[userId];

        if (userProfile != null) {
          leaderboard.add({
            'rank': rank,
            'name': userProfile.name,
            'avatarUrl': userProfile.avatarUrl,
            'points': points,
            'userId': userId,
          });
          rank++;
        }
      }

      return leaderboard;
    } catch (e) {
      print('Error fetching leaderboard: $e');
      return [];
    }
  }
}
