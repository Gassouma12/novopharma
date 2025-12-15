import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:novopharma/models/sale.dart';

class SaleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'sales';

  Future<void> createSale(Sale sale) async {
    final userRef = _firestore.collection('users').doc(sale.userId);
    final saleRef = _firestore.collection(_collection).doc();

    final saleData = sale.toFirestore();
    log('[SaleService] Attempting to create sale with data: $saleData');
    log('[SaleService] Sale will be created at: sales/${saleRef.id}');
    log(
      '[SaleService] Product ID: ${sale.productId}, Quantity: ${sale.quantity}, Points: ${sale.pointsEarned}',
    );

    await _firestore
        .runTransaction((transaction) async {
          // 1. Create the new sale document
          transaction.set(saleRef, saleData);

          // 2. Atomically update the user's points
          transaction.update(userRef, {
            'points': FieldValue.increment(sale.pointsEarned),
          });
        })
        .catchError((error) {
          log('[SaleService] Error in createSale transaction: $error');
          // Rethrow the error to be caught by the provider
          throw error;
        });

    log('[SaleService] ✅ Sale created successfully at: sales/${saleRef.id}');
    log('[SaleService] Waiting for Cloud Function to process goal progress...');
  }

  Future<void> updateSale(Sale oldSale, Sale newSale) async {
    final userRef = _firestore.collection('users').doc(newSale.userId);
    final saleRef = _firestore.collection(_collection).doc(newSale.id);

    log('Attempting to update sale ${newSale.id}');

    await _firestore
        .runTransaction((transaction) async {
          transaction.update(saleRef, newSale.toFirestore());

          final pointsDifference = newSale.pointsEarned - oldSale.pointsEarned;
          transaction.update(userRef, {
            'points': FieldValue.increment(pointsDifference),
          });
        })
        .catchError((error) {
          log('Error in updateSale transaction: $error');
          throw error;
        });
  }

  Future<void> deleteSale(Sale sale) async {
    final userRef = _firestore.collection('users').doc(sale.userId);
    final saleRef = _firestore.collection(_collection).doc(sale.id);

    log('Attempting to delete sale ${sale.id}');

    await _firestore
        .runTransaction((transaction) async {
          transaction.delete(saleRef);
          transaction.update(userRef, {
            'points': FieldValue.increment(-sale.pointsEarned),
          });
        })
        .catchError((error) {
          log('Error in deleteSale transaction: $error');
          throw error;
        });
  }

  Future<List<Sale>> getSalesHistory(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('saleDate', descending: true);

      if (startDate != null) {
        query = query.where(
          'saleDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }
      if (endDate != null) {
        // To include the whole end day, we set the time to the end of the day.
        final endOfDay = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          23,
          59,
          59,
        );
        query = query.where(
          'saleDate',
          isLessThanOrEqualTo: Timestamp.fromDate(endOfDay),
        );
      }

      final querySnapshot = await query.get();
      final List<Sale> sales = querySnapshot.docs
          .map((doc) => Sale.fromFirestore(doc))
          .toList();
      return sales;
    } catch (e) {
      print('Error fetching sales history: $e');
      return [];
    }
  }
}
