import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:novopharma/models/campaign.dart';
import 'package:novopharma/models/goal.dart';
import 'package:novopharma/models/product.dart';
import 'package:novopharma/models/sale.dart';
import 'package:novopharma/services/product_service.dart';
import 'package:novopharma/services/campaign_service.dart';
import 'package:novopharma/services/goal_service.dart';
import 'package:novopharma/services/sale_service.dart';

class ScanProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
  final CampaignService _campaignService = CampaignService();
  final GoalService _goalService = GoalService();
  final SaleService _saleService = SaleService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Product? _scannedProduct;
  Product? get scannedProduct => _scannedProduct;

  List<Campaign> _matchingCampaigns = [];
  List<Campaign> get matchingCampaigns => _matchingCampaigns;

  List<Goal> _matchingGoals = [];
  List<Goal> get matchingGoals => _matchingGoals;

  List<Product> _recommendedProducts = [];
  List<Product> get recommendedProducts => _recommendedProducts;

  int _quantity = 1;
  int get quantity => _quantity;

  bool get isStockAvailable =>
      _scannedProduct != null && _scannedProduct!.stock > 0;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void incrementQuantity() {
    if (_scannedProduct != null && _quantity < _scannedProduct!.stock) {
      _quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity() {
    if (_quantity > 1) {
      _quantity--;
      notifyListeners();
    }
  }

  Future<void> fetchProductAndRelatedData(String sku) async {
    _isLoading = true;
    _quantity = 1; // Reset quantity on new scan
    _errorMessage = null;
    _scannedProduct = null;
    _matchingCampaigns = [];
    _matchingGoals = [];
    _recommendedProducts = [];
    notifyListeners();

    try {
      _scannedProduct = await _productService.getProductBySku(sku);

      if (_scannedProduct != null) {
        final recommendedIds = _scannedProduct!.recommendedWith;

        // Fetch campaigns, goals, and recommended products in parallel
        final campaignsFuture = _campaignService.findMatchingCampaigns(
          _scannedProduct!,
        );
        final goalsFuture = _goalService.getUserGoals().then(
          (allGoals) =>
              _goalService.findMatchingGoals(_scannedProduct!, allGoals),
        );
        final recommendedProductsFuture = (recommendedIds.isNotEmpty)
            ? _productService.getProductsByIds(recommendedIds)
            : Future.value(<Product>[]);

        final results = await Future.wait([
          campaignsFuture,
          goalsFuture,
          recommendedProductsFuture,
        ]);

        _matchingCampaigns = results[0] as List<Campaign>;
        _matchingGoals = results[1] as List<Goal>;
        _recommendedProducts = results[2] as List<Product>;
      } else {
        _errorMessage = 'Product not found';
      }
    } catch (e) {
      _errorMessage = 'An error occurred while fetching product data.';
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> confirmSale({
    required String userId,
    required String pharmacyId,
  }) async {
    if (_scannedProduct == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Calculate total points and total price based on quantity
      final double totalPoints = _scannedProduct!.points * _quantity;
      final double totalPrice = _scannedProduct!.price * _quantity;

      final newSale = Sale(
        id: '', // Firestore will generate this
        userId: userId,
        pharmacyId: pharmacyId,
        productId: _scannedProduct!.id,
        productNameSnapshot: _scannedProduct!.name,
        quantity: _quantity,
        pointsEarned: totalPoints,
        saleDate: DateTime.now(),
        totalPrice: totalPrice,
      );

      await _saleService.createSale(newSale);

      // Clear the state after a successful sale
      _scannedProduct = null;
      _matchingCampaigns = [];
      _matchingGoals = [];
      _recommendedProducts = [];
      _quantity = 1;

      return true;
    } catch (e) {
      _errorMessage = 'Failed to confirm sale. Please try again.';
      print(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
