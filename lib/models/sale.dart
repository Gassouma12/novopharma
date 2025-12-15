import 'package:cloud_firestore/cloud_firestore.dart';

class Sale {
  final String id;
  final String userId;
  final String pharmacyId;
  final String productId;
  final String productNameSnapshot;
  final int quantity;
  final double pointsEarned;
  final DateTime saleDate;
  final double totalPrice;
  final String? productBrandSnapshot;
  final String? productCategorySnapshot;

  Sale({
    required this.id,
    required this.userId,
    required this.pharmacyId,
    required this.productId,
    required this.productNameSnapshot,
    required this.quantity,
    required this.pointsEarned,
    required this.saleDate,
    required this.totalPrice,
    this.productBrandSnapshot,
    this.productCategorySnapshot,
  });

  factory Sale.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Sale(
      id: doc.id,
      userId: data['userId'] ?? '',
      pharmacyId: data['pharmacyId'] ?? '',
      productId: data['productId'] ?? '',
      productNameSnapshot: data['productNameSnapshot'] ?? '',
      quantity: data['quantity'] ?? 0,
      pointsEarned: (data['pointsEarned'] as num?)?.toDouble() ?? 0.0,
      saleDate: (data['saleDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalPrice: (data['totalPrice'] as num?)?.toDouble() ?? 0.0,
      productBrandSnapshot: data['productBrandSnapshot'],
      productCategorySnapshot: data['productCategorySnapshot'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'pharmacyId': pharmacyId,
      'productId': productId,
      'productNameSnapshot': productNameSnapshot,
      'quantity': quantity,
      'pointsEarned': pointsEarned,
      'saleDate': Timestamp.fromDate(saleDate),
      'totalPrice': totalPrice,
      'productBrandSnapshot': productBrandSnapshot,
      'productCategorySnapshot': productCategorySnapshot,
    };
  }
}
