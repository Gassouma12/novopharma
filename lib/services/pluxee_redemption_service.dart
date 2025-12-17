import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:novopharma/models/pluxee_redemption_request.dart';

class PluxeeRedemptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get the conversion rate from appSettings
  Future<double> getConversionRate() async {
    try {
      final doc = await _firestore
          .collection('appsettings')
          .doc('T3z8r3NEYoWh8CUFx87G')
          .get();

      if (doc.exists) {
        final data = doc.data();
        final rate = data?['pointsToPluxeeRate'];

        if (rate != null) {
          return rate.toDouble();
        } else {
          return 100.0;
        }
      } else {
        return 100.0;
      }
    } catch (e) {
      return 100.0;
    }
  }

  /// Stream the conversion rate from appSettings in real-time
  Stream<double> conversionRateStream() {
    return _firestore
        .collection('appsettings')
        .doc('T3z8r3NEYoWh8CUFx87G')
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            final data = doc.data();
            final rate = data?['pointsToPluxeeRate'];

            if (rate != null) {
              return rate.toDouble();
            } else {
              return 100.0;
            }
          } else {
            return 100.0;
          }
        });
  }

  /// Create a new redemption request
  Future<String?> createRedemptionRequest({
    required String userId,
    required String userName,
    required String userEmail,
    required double pointsToRedeem,
  }) async {
    try {
      // Get conversion rate
      final conversionRate = await getConversionRate();
      final pluxeeCredits = pointsToRedeem / conversionRate;

      // Reference to user document
      final userRef = _firestore.collection('users').doc(userId);
      final requestRef = _firestore
          .collection('pluxeeRedemptionRequests')
          .doc();

      // Use transaction to ensure data consistency
      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          throw Exception('User not found');
        }

        final userData = userDoc.data()!;
        final currentPointsValue = userData['points'];
        final currentPoints = currentPointsValue is num
            ? currentPointsValue.toDouble()
            : 0.0;
        final pendingPointsValue = userData['pendingPluxeePoints'];
        final pendingPoints = pendingPointsValue is num
            ? pendingPointsValue.toDouble()
            : 0.0;
        final availablePoints = currentPoints - pendingPoints;

        if (availablePoints < pointsToRedeem) {
          throw Exception('Insufficient available points');
        }

        // Create the redemption request
        transaction.set(requestRef, {
          'userId': userId,
          'userNameSnapshot': userName,
          'userEmailSnapshot': userEmail,
          'pointsToRedeem': pointsToRedeem,
          'pluxeeCreditsEquivalent': pluxeeCredits,
          'status': 'pending',
          'requestedAt': FieldValue.serverTimestamp(),
          'processedAt': null,
          'processedBy': null,
          'rejectionReason': null,
        });

        // Lock the points by adding to pendingPluxeePoints
        transaction.update(userRef, {
          'pendingPluxeePoints': FieldValue.increment(pointsToRedeem),
        });
      });

      return null; // Success
    } catch (e) {
      print('Error creating redemption request: $e');
      return e.toString();
    }
  }

  /// Get real-time stream of user's redemption requests
  Stream<List<PluxeeRedemptionRequest>> getUserRedemptionRequests(
    String userId,
  ) {
    try {
      print('📱 [PluxeeService] Setting up stream for userId: $userId');
      return _firestore
          .collection('pluxeeRedemptionRequests')
          .where('userId', isEqualTo: userId)
          .orderBy('requestedAt', descending: true)
          .snapshots()
          .map((querySnapshot) {
            print(
              '📱 [PluxeeService] Received ${querySnapshot.docs.length} documents from Firestore',
            );
            final requests = querySnapshot.docs.map((doc) {
              print(
                '📱 [PluxeeService] Document ID: ${doc.id}, Data: ${doc.data()}',
              );
              return PluxeeRedemptionRequest.fromFirestore(doc);
            }).toList();
            print(
              '📱 [PluxeeService] Parsed ${requests.length} redemption requests',
            );
            return requests;
          });
    } catch (e) {
      print('❌ [PluxeeService] Error getting user redemption requests: $e');
      return Stream.value([]);
    }
  }

  /// Cancel a pending request (optional feature)
  Future<String?> cancelRedemptionRequest({
    required String requestId,
    required String userId,
  }) async {
    try {
      final requestRef = _firestore
          .collection('pluxeeRedemptionRequests')
          .doc(requestId);
      final userRef = _firestore.collection('users').doc(userId);

      await _firestore.runTransaction((transaction) async {
        final requestDoc = await transaction.get(requestRef);

        if (!requestDoc.exists) {
          throw Exception('Request not found');
        }

        final requestData = requestDoc.data()!;
        final status = requestData['status'] as String;

        if (status != 'pending') {
          throw Exception('Can only cancel pending requests');
        }

        final pointsToRedeemValue = requestData['pointsToRedeem'];
        final pointsToRedeem = pointsToRedeemValue is num
            ? pointsToRedeemValue.toDouble()
            : 0.0;

        // Delete the request
        transaction.delete(requestRef);

        // Return the locked points
        transaction.update(userRef, {
          'pendingPluxeePoints': FieldValue.increment(-pointsToRedeem),
        });
      });

      return null; // Success
    } catch (e) {
      print('Error cancelling redemption request: $e');
      return e.toString();
    }
  }
}
