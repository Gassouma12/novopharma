import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:novopharma/models/user_model.dart';

class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cache with timestamp - expires after 2 minutes
  static final Map<String, _LeaderboardCache> _cache = {};
  static const Duration _cacheDuration = Duration(minutes: 2);

  Future<List<Map<String, dynamic>>> getLeaderboard(String period) async {
    print('🏆 [LEADERBOARD] ===== Starting Leaderboard Calculation =====');

    // Check cache first
    if (_cache.containsKey(period)) {
      final cached = _cache[period]!;
      final age = DateTime.now().difference(cached.timestamp);
      if (age < _cacheDuration) {
        print('💾 [LEADERBOARD] Using cached data (age: ${age.inSeconds}s)');
        print('🏆 [LEADERBOARD] ===== Complete from cache in 0ms =====');
        return cached.data;
      } else {
        print(
          '⏰ [LEADERBOARD] Cache expired (age: ${age.inSeconds}s), refreshing...',
        );
      }
    }

    final startTime = DateTime.now();

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

      print('📅 [LEADERBOARD] Period: $period, Start date: $startDate');
      final timestampStart = Timestamp.fromDate(startDate);

      // 2. Query all point sources for the period
      print('🔄 [LEADERBOARD] Querying sales...');
      final salesQueryStart = DateTime.now();
      final salesSnapshot = await _firestore
          .collection('sales')
          .where('saleDate', isGreaterThanOrEqualTo: timestampStart)
          .get();
      final salesQueryDuration = DateTime.now().difference(salesQueryStart);
      print(
        '✅ [LEADERBOARD] Sales query: ${salesSnapshot.docs.length} docs in ${salesQueryDuration.inMilliseconds}ms',
      );

      // 3. Aggregate points from sales first and collect user IDs
      final Map<String, int> userPoints = {};
      final Set<String> allUserIds = {};

      for (var saleDoc in salesSnapshot.docs) {
        final data = saleDoc.data();
        final userId = data['userId'] as String?;
        final pointsValue = data['pointsEarned'];
        final points = pointsValue is num ? pointsValue.toInt() : 0;
        if (userId != null && points > 0) {
          userPoints.update(
            userId,
            (value) => value + points,
            ifAbsent: () => points,
          );
          allUserIds.add(userId);
        }
      }

      print(
        '💰 [LEADERBOARD] Sales aggregated: ${allUserIds.length} users with sales points',
      );

      // 4. Get ONLY users who have sales (not ALL users!)
      print(
        '🔄 [LEADERBOARD] Querying user subcollections for ${allUserIds.length} active users...',
      );
      final subcollectionStart = DateTime.now();

      int totalQuizQueries = 0;
      int totalGoalQueries = 0;
      int totalBadgeQueries = 0;

      // Process in batches to avoid too many concurrent requests
      final userIdsList = allUserIds.toList();
      for (int i = 0; i < userIdsList.length; i += 10) {
        final batch = userIdsList.skip(i).take(10).toList();

        // Query subcollections in parallel for this batch
        final batchResults = await Future.wait(
          batch.map((userId) async {
            final results = await Future.wait([
              // Quiz points
              _firestore
                  .collection('users')
                  .doc(userId)
                  .collection('quizAttempts')
                  .where('timestamp', isGreaterThanOrEqualTo: timestampStart)
                  .get(),
              // Goal points
              _firestore
                  .collection('users')
                  .doc(userId)
                  .collection('userGoalProgress')
                  .where('completedAt', isGreaterThanOrEqualTo: timestampStart)
                  .get(),
              // Badge awards
              _firestore
                  .collection('users')
                  .doc(userId)
                  .collection('userBadges')
                  .where('awardedAt', isGreaterThanOrEqualTo: timestampStart)
                  .get(),
            ]);

            return {
              'userId': userId,
              'quizSnapshot': results[0],
              'goalSnapshot': results[1],
              'badgeSnapshot': results[2],
            };
          }),
        );

        // Process batch results
        for (var userResult in batchResults) {
          final userId = userResult['userId'] as String;

          // Quiz points
          int quizPoints = 0;
          final quizSnapshot = userResult['quizSnapshot'] as QuerySnapshot;
          totalQuizQueries++;
          for (var quizDoc in quizSnapshot.docs) {
            final pointsValue = quizDoc.data() as Map<String, dynamic>;
            quizPoints += (pointsValue['pointsEarned'] is num
                ? (pointsValue['pointsEarned'] as num).toInt()
                : 0);
          }

          // Goal points
          int goalPoints = 0;
          final goalSnapshot = userResult['goalSnapshot'] as QuerySnapshot;
          totalGoalQueries++;
          for (var goalDoc in goalSnapshot.docs) {
            final pointsValue = goalDoc.data() as Map<String, dynamic>;
            goalPoints += (pointsValue['pointsAwarded'] is num
                ? (pointsValue['pointsAwarded'] as num).toInt()
                : 0);
          }

          // Badge points - collect badge IDs
          final badgeSnapshot = userResult['badgeSnapshot'] as QuerySnapshot;
          totalBadgeQueries++;
          int badgePoints = 0;

          if (badgeSnapshot.docs.isNotEmpty) {
            final badgeIds = badgeSnapshot.docs
                .map(
                  (doc) =>
                      (doc.data() as Map<String, dynamic>)['badgeId']
                          as String?,
                )
                .where((id) => id != null)
                .cast<String>()
                .toSet()
                .toList();

            // Batch fetch badge details
            if (badgeIds.isNotEmpty) {
              for (int j = 0; j < badgeIds.length; j += 10) {
                final badgeBatch = badgeIds.skip(j).take(10).toList();
                try {
                  final badgeDetailsQuery = await _firestore
                      .collection('badges')
                      .where(FieldPath.documentId, whereIn: badgeBatch)
                      .get();

                  final badgePointsMap = <String, int>{};
                  for (var badgeDoc in badgeDetailsQuery.docs) {
                    final pointsValue = badgeDoc.data()['points'];
                    if (pointsValue != null && pointsValue is num) {
                      badgePointsMap[badgeDoc.id] = pointsValue.toInt();
                    }
                  }

                  for (var badgeDoc in badgeSnapshot.docs) {
                    final badgeId =
                        (badgeDoc.data() as Map<String, dynamic>)['badgeId']
                            as String?;
                    if (badgeId != null &&
                        badgePointsMap.containsKey(badgeId)) {
                      badgePoints += badgePointsMap[badgeId]!;
                    }
                  }
                } catch (e) {
                  // Skip if badge details can't be fetched
                }
              }
            }
          }

          final totalNonSalesPoints = quizPoints + goalPoints + badgePoints;
          if (totalNonSalesPoints > 0) {
            userPoints.update(
              userId,
              (value) => value + totalNonSalesPoints,
              ifAbsent: () => totalNonSalesPoints,
            );
          }
        }
      }

      final subcollectionDuration = DateTime.now().difference(
        subcollectionStart,
      );
      print(
        '✅ [LEADERBOARD] Subcollections processed in ${subcollectionDuration.inMilliseconds}ms',
      );
      print(
        '   └─ Quiz queries: $totalQuizQueries, Goal queries: $totalGoalQueries, Badge queries: $totalBadgeQueries',
      );

      if (userPoints.isEmpty) {
        print('⚠️ [LEADERBOARD] No points found');
        return [];
      }

      // 6. Sort users by points
      final sortedUsers = userPoints.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Limit to top 100
      final topUserIds = sortedUsers.take(100).map((e) => e.key).toList();

      if (topUserIds.isEmpty) {
        print('⚠️ [LEADERBOARD] No top users found');
        return [];
      }

      print(
        '🔄 [LEADERBOARD] Fetching details for top ${topUserIds.length} users...',
      );
      final userDetailsStart = DateTime.now();

      // 7. Batch fetch user details in chunks of 10
      final Map<String, Map<String, dynamic>> userDetailsMap = {};

      for (int i = 0; i < topUserIds.length; i += 10) {
        final batch = topUserIds.skip(i).take(10).toList();
        final userDetailsSnapshot = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        for (var userDoc in userDetailsSnapshot.docs) {
          final userId = userDoc.id;
          final userData = userDoc.data();
          userDetailsMap[userId] = {
            'name': userData['name'] as String? ?? 'Unknown',
            'avatarUrl': userData['avatarUrl'] as String? ?? '',
          };
        }
      }

      final userDetailsDuration = DateTime.now().difference(userDetailsStart);
      print(
        '✅ [LEADERBOARD] User details fetched in ${userDetailsDuration.inMilliseconds}ms',
      );

      // Build final leaderboard with ranks (already sorted by points)
      final List<Map<String, dynamic>> leaderboard = [];
      int rank = 1;
      for (var userEntry in sortedUsers.take(100)) {
        final userId = userEntry.key;
        final points = userEntry.value;
        final userDetails = userDetailsMap[userId];

        if (userDetails != null) {
          leaderboard.add({
            'rank': rank,
            'userId': userId,
            'name': userDetails['name'],
            'avatarUrl': userDetails['avatarUrl'],
            'points': points,
          });
          rank++;
        }
      }

      final totalDuration = DateTime.now().difference(startTime);
      print(
        '🏆 [LEADERBOARD] ===== Complete in ${totalDuration.inMilliseconds}ms (${(totalDuration.inMilliseconds / 1000).toStringAsFixed(1)}s) =====',
      );
      print('   └─ Top ${leaderboard.length} users ranked');

      // Cache the result
      _cache[period] = _LeaderboardCache(
        data: leaderboard,
        timestamp: DateTime.now(),
      );
      print('💾 [LEADERBOARD] Data cached for $period period');

      return leaderboard;
    } catch (e) {
      print('❌ [LEADERBOARD] Error: $e');
      return [];
    }
  }

  // Clear cache manually if needed (e.g., after making a sale)
  static void clearCache([String? period]) {
    if (period != null) {
      _cache.remove(period);
      print('🗑️ [LEADERBOARD] Cache cleared for $period');
    } else {
      _cache.clear();
      print('🗑️ [LEADERBOARD] All cache cleared');
    }
  }
}

// Cache container class
class _LeaderboardCache {
  final List<Map<String, dynamic>> data;
  final DateTime timestamp;

  _LeaderboardCache({required this.data, required this.timestamp});
}
