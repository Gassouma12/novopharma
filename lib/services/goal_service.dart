import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:novopharma/models/goal.dart';
import 'package:novopharma/models/pharmacy.dart';
import 'package:novopharma/models/product.dart';
import 'package:novopharma/models/user_goal_progress.dart';
import 'package:novopharma/models/user_model.dart';
import 'package:novopharma/services/pharmacy_service.dart';
import 'package:novopharma/services/user_service.dart';

class GoalService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();
  final PharmacyService _pharmacyService = PharmacyService();

  Future<List<Goal>> getUserGoals() async {
    final user = _auth.currentUser;
    if (user == null) {
      log('Error: No authenticated user found.');
      return [];
    }

    try {
      // Step 1: Get User and Pharmacy context
      final userProfile = await _userService.getUser(user.uid);
      if (userProfile == null || userProfile.pharmacyId.isEmpty) {
        log('User profile or pharmacyId not found.');
        return [];
      }

      final pharmacy = await _pharmacyService.getPharmacy(
        userProfile.pharmacyId,
      );
      if (pharmacy == null) {
        log(
          'Pharmacy details not found for pharmacyId: ${userProfile.pharmacyId}',
        );
        return [];
      }

      // Step 2: Construct and execute parallel queries
      final now = Timestamp.now();
      log('Fetching goals with endDate >= $now');

      final baseQuery = _db
          .collection('goals')
          .where('isActive', isEqualTo: true)
          .where('endDate', isGreaterThanOrEqualTo: now);

      final queries = <Future<QuerySnapshot<Map<String, dynamic>>>>[
        // Goals with no pharmacy restrictions (global goals)
        baseQuery.where('criteria.pharmacyIds', isEqualTo: []).get(),
        // Goals targeting the user's specific zone
        baseQuery.where('criteria.zones', arrayContains: pharmacy.zone).get(),
        // Goals targeting the user's specific client category
        baseQuery
            .where(
              'criteria.clientCategories',
              arrayContains: pharmacy.clientCategory,
            )
            .get(),
        // Goals targeting the user's specific pharmacy ID
        baseQuery
            .where(
              'criteria.pharmacyIds',
              arrayContains: userProfile.pharmacyId,
            )
            .get(),
      ];

      final querySnapshots = await Future.wait(queries);

      // Log the results of each query
      log('Query 1 (Global) returned ${querySnapshots[0].docs.length} goals.');
      log(
        'Query 2 (Zone: ${pharmacy.zone}) returned ${querySnapshots[1].docs.length} goals.',
      );
      log(
        'Query 3 (Client Category: ${pharmacy.clientCategory}) returned ${querySnapshots[2].docs.length} goals.',
      );
      log(
        'Query 4 (Pharmacy ID: ${userProfile.pharmacyId}) returned ${querySnapshots[3].docs.length} goals.',
      );

      // Step 3: Merge and de-duplicate results
      final Map<String, Goal> relevantGoals = {};
      for (final snapshot in querySnapshots) {
        for (final doc in snapshot.docs) {
          relevantGoals[doc.id] = Goal.fromFirestore(doc);
        }
      }

      log('Total unique goals after merging: ${relevantGoals.length}');

      final goalList = relevantGoals.values.toList();
      if (goalList.isEmpty) {
        log('No relevant goals found for this user after merge.');
        return [];
      }

      // Step 4: Fetch user progress for the filtered goals
      log('[GoalService] Fetching user progress for ${goalList.length} goals');
      final progressSnapshot = await _db
          .collection('users')
          .doc(user.uid)
          .collection('userGoalProgress')
          .get();

      log(
        '[GoalService] Found ${progressSnapshot.docs.length} progress documents',
      );
      final Map<String, UserGoalProgress> userProgress = {
        for (var doc in progressSnapshot.docs)
          doc.id: UserGoalProgress.fromMap(doc.id, doc.data()),
      };

      // Log progress details
      for (var entry in userProgress.entries) {
        log(
          '[GoalService] Progress for goal ${entry.key}: value=${entry.value.progressValue}, status=${entry.value.status}',
        );
      }

      // Step 5: Combine goals with their progress
      final List<Goal> goalsWithProgress = goalList.map((goal) {
        final progress = userProgress[goal.id];
        if (progress != null) {
          log(
            '[GoalService] ✅ Goal "${goal.title}" has progress: ${progress.progressValue}/${goal.targetValue}',
          );
        } else {
          log('[GoalService] ⚠️ Goal "${goal.title}" has NO progress data');
        }
        return goal.copyWith(userProgress: progress);
      }).toList();

      return goalsWithProgress;
    } catch (e, s) {
      log('Error fetching user goals with filtering', error: e, stackTrace: s);
      return [];
    }
  }

  List<Goal> findMatchingGoals(Product product, List<Goal> allGoals) {
    return allGoals.where((goal) {
      final criteria = goal.criteria;
      final matchesProduct = criteria.products.contains(product.id);
      final matchesBrand = criteria.brands.contains(product.marque);
      final matchesCategory = criteria.categories.contains(product.category);
      bool productOk = criteria.products.isNotEmpty ? matchesProduct : false;
      bool brandOk = criteria.brands.isNotEmpty ? matchesBrand : false;
      bool categoryOk = criteria.categories.isNotEmpty
          ? matchesCategory
          : false;
      return productOk || brandOk || categoryOk;
    }).toList();
  }

  Future<bool> isUserEligibleForGoal(
    Goal goal,
    Product product,
    UserModel user,
    Pharmacy pharmacy,
  ) async {
    final criteria = goal.criteria;

    if (criteria.categories.isNotEmpty &&
        !criteria.categories.contains(product.category)) {
      return false;
    }
    if (criteria.brands.isNotEmpty &&
        !criteria.brands.contains(product.marque)) {
      return false;
    }
    if (criteria.products.isNotEmpty &&
        !criteria.products.contains(product.id)) {
      return false;
    }
    if (criteria.pharmacyIds.isNotEmpty &&
        !criteria.pharmacyIds.contains(user.pharmacyId)) {
      return false;
    }
    if (criteria.zones.isNotEmpty && !criteria.zones.contains(pharmacy.zone)) {
      return false;
    }
    if (criteria.clientCategories.isNotEmpty &&
        !criteria.clientCategories.contains(pharmacy.clientCategory)) {
      return false;
    }
    return true;
  }
}
