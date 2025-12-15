import 'dart:async';
import 'package:flutter/material.dart' hide Badge;
import 'package:novopharma/models/badge.dart';
import 'package:novopharma/models/user_badge.dart';
import 'package:novopharma/services/badge_service.dart';
import 'package:novopharma/services/user_badge_service.dart';
import 'package:novopharma/services/sale_service.dart';
import 'package:novopharma/controllers/auth_provider.dart';
import 'package:collection/collection.dart';

// A wrapper class to hold merged badge data
class BadgeDisplayInfo {
  final Badge badge;
  final UserBadge? userBadge; // Null if not awarded
  final double progress; // 0.0 to 1.0

  BadgeDisplayInfo({required this.badge, this.userBadge, this.progress = 0.0});

  bool get isAwarded => userBadge != null;
}

class BadgeProvider with ChangeNotifier {
  final BadgeService _badgeService = BadgeService();
  final UserBadgeService _userBadgeService = UserBadgeService();
  final SaleService _saleService = SaleService();
  AuthProvider _authProvider;

  List<BadgeDisplayInfo> _badges = [];
  bool _isLoading = true;
  StreamSubscription? _badgesSubscription;
  StreamSubscription? _userBadgesSubscription;

  BadgeProvider(this._authProvider) {
    if (_authProvider.userProfile != null) {
      _listenToBadges();
    }
  }

  void update(AuthProvider authProvider) {
    // Check if the user has changed (e.g., logged in or out)
    if (authProvider.userProfile?.uid != _authProvider.userProfile?.uid) {
      _authProvider = authProvider;
      _cancelSubscriptions(); // Cancel old subscriptions
      if (_authProvider.userProfile != null) {
        _listenToBadges();
      } else {
        // User logged out, clear the badges
        _badges = [];
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  List<BadgeDisplayInfo> get badges => _badges;
  bool get isLoading => _isLoading;

  void _listenToBadges() {
    if (_authProvider.userProfile == null) return;

    _isLoading = true;
    notifyListeners();

    final userId = _authProvider.userProfile!.uid;

    // Combine streams of all badges and user-specific badges
    _badgesSubscription = _badgeService.streamAllBadges().listen((allBadges) {
      // When all badges update, re-fetch user badges and recalculate everything
      _userBadgesSubscription?.cancel();
      _userBadgesSubscription = _userBadgeService
          .streamUserBadges(userId)
          .listen((userBadges) async {
            await _processBadgeData(allBadges, userBadges, userId);
          });
    });
  }

  Future<void> _processBadgeData(
    List<Badge> allBadges,
    List<UserBadge> userBadges,
    String userId,
  ) async {
    final List<BadgeDisplayInfo> badgeInfos = [];
    for (final badge in allBadges) {
      final userBadge = userBadges.firstWhereOrNull(
        (ub) => ub.badgeId == badge.id,
      );

      double progress = 0.0;
      if (userBadge != null) {
        progress = 1.0;
      } else {
        progress = await _calculateProgress(badge, userId);
      }

      badgeInfos.add(
        BadgeDisplayInfo(
          badge: badge,
          userBadge: userBadge,
          progress: progress,
        ),
      );
    }
    _badges = badgeInfos;
    _isLoading = false;
    notifyListeners();
  }

  Future<double> _calculateProgress(Badge badge, String userId) async {
    // Handle old structure
    if (badge.progressMetric != null) {
      switch (badge.progressMetric) {
        case 'sales_booster':
          return await _calculateSalesBoosterProgress(userId);
        default:
          return 0.0;
      }
    }

    // Handle new structure - fetch from userBadgeProgress subcollection
    if (badge.acquisitionRules != null) {
      final rules = badge.acquisitionRules!;

      try {
        // Fetch progress from Firestore subcollection
        final progressDoc = await _badgeService.getUserBadgeProgress(
          userId,
          badge.id,
        );

        if (progressDoc != null && progressDoc.exists) {
          final data = progressDoc.data() as Map<String, dynamic>?;
          final progressValue =
              (data?['progressValue'] as num?)?.toDouble() ?? 0.0;

          if (rules.targetValue == 0) return 1.0;
          final progress = progressValue / rules.targetValue;
          return progress.clamp(0.0, 1.0);
        }

        return 0.0; // No progress yet
      } catch (e) {
        print('[BadgeProvider] Error fetching badge progress: $e');
        return 0.0;
      }
    }

    return 0.0;
  }

  Future<double> _calculateSalesBoosterProgress(String userId) async {
    try {
      final now = DateTime.now();
      final prevMonth = DateTime(now.year, now.month - 1, 1);
      final thisMonthStart = DateTime(now.year, now.month, 1);

      final prevMonthSales = await _saleService.getSalesHistory(
        userId,
        startDate: prevMonth,
        endDate: thisMonthStart.subtract(const Duration(days: 1)),
      );

      final thisMonthSales = await _saleService.getSalesHistory(
        userId,
        startDate: thisMonthStart,
        endDate: now,
      );

      final double prevMonthTotal = prevMonthSales.fold(
        0,
        (sum, sale) => sum + (sale.totalPrice ?? 0.0),
      );
      final double thisMonthTotal = thisMonthSales.fold(
        0,
        (sum, sale) => sum + (sale.totalPrice ?? 0.0),
      );

      if (prevMonthTotal == 0) return thisMonthTotal > 0 ? 1.0 : 0.0;

      final target = prevMonthTotal * 1.2; // 20% increase target
      if (target == 0) return 1.0;

      final progress = thisMonthTotal / target;
      return progress.clamp(0.0, 1.0); // Clamp between 0 and 1
    } catch (e) {
      print('Error calculating sales booster progress: $e');
      return 0.0;
    }
  }

  void _cancelSubscriptions() {
    _badgesSubscription?.cancel();
    _userBadgesSubscription?.cancel();
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }
}
