import 'package:cloud_firestore/cloud_firestore.dart';

// Nested model for acquisition rules
class AcquisitionRules {
  final String metric; // 'points', 'revenue', or 'quantity'
  final double targetValue;
  final Scope scope;
  final Timeframe timeframe;

  AcquisitionRules({
    required this.metric,
    required this.targetValue,
    required this.scope,
    required this.timeframe,
  });

  factory AcquisitionRules.fromMap(Map<String, dynamic> map) {
    return AcquisitionRules(
      metric: map['metric'] ?? 'points',
      targetValue: (map['targetValue'] as num?)?.toDouble() ?? 0.0,
      scope: Scope.fromMap(map['scope'] as Map<String, dynamic>? ?? {}),
      timeframe: Timeframe.fromMap(
        map['timeframe'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class Scope {
  final List<String> brands;
  final List<String> categories;
  final List<String> productIds;

  Scope({
    required this.brands,
    required this.categories,
    required this.productIds,
  });

  factory Scope.fromMap(Map<String, dynamic> map) {
    return Scope(
      brands: List<String>.from(map['brands'] ?? []),
      categories: List<String>.from(map['categories'] ?? []),
      productIds: List<String>.from(map['productIds'] ?? []),
    );
  }
}

class Timeframe {
  final DateTime startDate;
  final DateTime endDate;

  Timeframe({required this.startDate, required this.endDate});

  factory Timeframe.fromMap(Map<String, dynamic> map) {
    return Timeframe(
      startDate: _parseDate(map['startDate']) ?? DateTime.now(),
      endDate:
          _parseDate(map['endDate']) ?? DateTime.now().add(Duration(days: 30)),
    );
  }

  static DateTime? _parseDate(dynamic date) {
    if (date is Timestamp) {
      return date.toDate();
    }
    if (date is String) {
      return DateTime.tryParse(date);
    }
    return null;
  }
}

class Badge {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final bool isActive;
  final int maxWinners;
  final int winnerCount;
  final AcquisitionRules acquisitionRules;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? points; // Points awarded when badge is earned

  // Old structure fields (for backward compatibility)
  final String? progressMetric;
  final Map<String, dynamic>? criteria;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.isActive,
    required this.maxWinners,
    required this.winnerCount,
    required this.acquisitionRules,
    required this.createdAt,
    required this.updatedAt,
    this.points,
    // Old (optional for backward compatibility)
    this.progressMetric,
    this.criteria,
  });

  bool get isAvailable => winnerCount < maxWinners;

  bool get isExpired =>
      DateTime.now().isAfter(acquisitionRules.timeframe.endDate);

  bool get isNotStarted =>
      DateTime.now().isBefore(acquisitionRules.timeframe.startDate);

  bool get isActiveNow =>
      isActive && !isExpired && !isNotStarted && isAvailable;

  factory Badge.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Badge(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      isActive: data['isActive'] ?? false,
      maxWinners: data['maxWinners'] ?? 0,
      winnerCount: data['winnerCount'] ?? 0,
      acquisitionRules: AcquisitionRules.fromMap(
        data['acquisitionRules'] as Map<String, dynamic>? ?? {},
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      points: data['points'] as int?,
      // Old structure fields
      progressMetric: data['progressMetric'],
      criteria: data['criteria'] as Map<String, dynamic>?,
    );
  }
}
