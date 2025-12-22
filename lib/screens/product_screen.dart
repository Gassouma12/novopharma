import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:novopharma/controllers/sales_history_provider.dart';
import 'package:provider/provider.dart';
import 'package:novopharma/controllers/auth_provider.dart';
import 'package:novopharma/models/goal.dart';
import 'package:novopharma/models/pharmacy.dart';
import 'package:novopharma/models/product.dart';
import 'package:novopharma/models/sale.dart';
import 'package:novopharma/models/user_model.dart';
import 'package:novopharma/services/goal_service.dart';
import 'package:novopharma/services/pharmacy_service.dart';
import 'package:novopharma/services/product_service.dart';
import 'package:novopharma/services/user_service.dart';
import 'package:novopharma/generated/l10n/app_localizations.dart';
import 'package:novopharma/services/sale_service.dart';

// Helper class to hold all the data fetched for the screen
class _ProductScreenData {
  final Product? product;
  final List<Product> recommendedProducts;
  final List<Goal> allGoals;
  final UserModel? user;
  final Pharmacy? pharmacy;

  _ProductScreenData({
    this.product,
    this.recommendedProducts = const [],
    this.allGoals = const [],
    this.user,
    this.pharmacy,
  });
}

class ProductScreen extends StatefulWidget {
  final String? sku;
  final Sale? sale;
  const ProductScreen({super.key, this.sku, this.sale});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ProductService _productService = ProductService();
  final GoalService _goalService = GoalService();
  final UserService _userService = UserService();
  final PharmacyService _pharmacyService = PharmacyService();
  final SaleService _saleService = SaleService();

  late Future<_ProductScreenData> _dataFuture;
  final ValueNotifier<int> _quantityNotifier = ValueNotifier(1);

  @override
  void initState() {
    super.initState();
    if (widget.sale != null) {
      _quantityNotifier.value = widget.sale!.quantity;
    }
    _dataFuture = _loadData();
  }

  @override
  void dispose() {
    _quantityNotifier.dispose();
    super.dispose();
  }

  Future<_ProductScreenData> _loadData() async {
    final product = widget.sale != null
        ? await _productService.getProductById(widget.sale!.productId)
        : await _productService.getProductBySku(widget.sku!);
    if (product == null) return _ProductScreenData(product: null);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.firebaseUser?.uid;
    if (userId == null) return _ProductScreenData(product: product);

    final [recommendedProducts, allGoals, user] = await Future.wait([
      product.recommendedWith.isNotEmpty
          ? _productService.getProductsByIds(product.recommendedWith)
          : Future.value(<Product>[]),
      _goalService.getUserGoals(),
      _userService.getUser(userId),
    ]);

    Pharmacy? pharmacy;
    final userModel = user as UserModel?;
    if (userModel != null && userModel.pharmacyId.isNotEmpty) {
      final pharmacies = await _pharmacyService.getPharmaciesByIds([
        userModel.pharmacyId,
      ]);
      if (pharmacies.isNotEmpty) {
        pharmacy = pharmacies.first;
      }
    }

    return _ProductScreenData(
      product: product,
      recommendedProducts: recommendedProducts as List<Product>,
      allGoals: allGoals as List<Goal>,
      user: userModel,
      pharmacy: pharmacy,
    );
  }

  void _submitSale(Product product, UserModel user) {
    final int quantity = _quantityNotifier.value;
    final double totalPrice = product.price * quantity;

    if (widget.sale != null) {
      // Update existing sale
      final updatedSale = Sale(
        id: widget.sale!.id,
        userId: user.uid,
        pharmacyId: user.pharmacyId,
        productId: product.id,
        productNameSnapshot: product.name,
        quantity: quantity,
        pointsEarned: product.points * quantity,
        saleDate: widget.sale!.saleDate, // Keep original sale date
        totalPrice: totalPrice,
      );
      Provider.of<SalesHistoryProvider>(
        context,
        listen: false,
      ).updateSale(widget.sale!, updatedSale);
    } else {
      // Create new sale
      final newSale = Sale(
        id: '', // Firestore will generate ID
        userId: user.uid,
        pharmacyId: user.pharmacyId,
        productId: product.id,
        productNameSnapshot: product.name,
        quantity: quantity,
        pointsEarned: product.points * quantity,
        saleDate: DateTime.now(),
        totalPrice: totalPrice,
      );
      _saleService.createSale(newSale);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scannedProduct),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF102132),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF6F8FB),
      body: FutureBuilder<_ProductScreenData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          final product = data.product;
          final user = data.user;
          final pharmacy = data.pharmacy;

          if (product == null) return Center(child: Text('Product not found.'));
          if (user == null || pharmacy == null) {
            return Center(child: Text('Could not load user profile.'));
          }

          // Check if product is disabled
          if (product.isDisabled) {
            return _buildDisabledProductView(l10n, product);
          }

          final relatedGoals = _goalService.findMatchingGoals(
            product,
            data.allGoals,
          );

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image and Basic Info
                      _buildProductHeader(product),
                      const SizedBox(height: 24),

                      // Sale Details Card (Quantity & Price)
                      _buildModernSaleCard(l10n, product),
                      const SizedBox(height: 24),

                      // Description
                      if (product.description.isNotEmpty) ...[
                        _buildModernSection(
                          l10n.description,
                          Icons.article_outlined,
                          product.description,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Usage Tips (Conseil d'utilisation)
                      if (product.protocol.isNotEmpty) ...[
                        _buildModernSection(
                          l10n.usageTips,
                          Icons.lightbulb_outline,
                          product.protocol,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Protocol (Recommendé avec)
                      if (data.recommendedProducts.isNotEmpty) ...[
                        _buildModernSectionTitle(
                          l10n.protocol,
                          Icons.local_hospital_outlined,
                        ),
                        const SizedBox(height: 12),
                        _buildRecommendedProductsList(data.recommendedProducts),
                        const SizedBox(height: 16),
                      ],

                      // Composition
                      if (product.composition.isNotEmpty) ...[
                        _buildModernSection(
                          l10n.composition,
                          Icons.science_outlined,
                          product.composition,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Related Goals (Objectifs associés)
                      if (relatedGoals.isNotEmpty) ...[
                        _buildModernSectionTitle(
                          l10n.relatedGoals,
                          Icons.flag_outlined,
                        ),
                        const SizedBox(height: 12),
                        ...relatedGoals.map(
                          (goal) => _buildModernGoalCard(
                            goal,
                            product,
                            user,
                            pharmacy,
                          ),
                        ),
                      ],

                      const SizedBox(height: 100), // Space for bottom bar
                    ],
                  ),
                ),
              ),
              _buildModernActionBar(l10n, product, user),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProductHeader(Product product) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F9BD1), Color(0xFF1887B8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F9BD1).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          if (product.imageUrl.isNotEmpty)
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.image_not_supported_outlined,
                    size: 80,
                    color: Color(0xFFE0E0E0),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        product.marque,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSaleCard(AppLocalizations l10n, Product product) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Quantity Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1F9BD1), Color(0xFF1887B8)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.quantity,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF102132),
                    ),
                  ),
                ],
              ),
              ValueListenableBuilder<int>(
                valueListenable: _quantityNotifier,
                builder: (context, quantity, child) {
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F8FB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.remove_circle,
                            color: quantity > 1
                                ? const Color(0xFF1F9BD1)
                                : Colors.grey,
                          ),
                          onPressed: () {
                            if (quantity > 1) _quantityNotifier.value--;
                          },
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$quantity',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF102132),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle,
                            color: Color(0xFF1F9BD1),
                          ),
                          onPressed: () {
                            _quantityNotifier.value++;
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 16),
          // Points Display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.stars_rounded,
                      color: Color(0xFFF59E0B),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Points',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF102132),
                    ),
                  ),
                ],
              ),
              ValueListenableBuilder<int>(
                valueListenable: _quantityNotifier,
                builder: (context, quantity, child) {
                  final pointsEarned = product.points * quantity;
                  // Format to remove trailing .0 for whole numbers
                  final pointsText = pointsEarned % 1 == 0
                      ? pointsEarned.toInt().toString()
                      : pointsEarned.toString();
                  return Text(
                    pointsText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF59E0B),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernSectionTitle(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F9BD1), Color(0xFF1887B8)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F9BD1).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSection(String title, IconData icon, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1F9BD1), Color(0xFF1887B8)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1F9BD1).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF4A5568),
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedProductsList(List<Product> products) {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductScreen(sku: product.sku),
                ),
              );
            },
            child: Container(
              width: 180,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Container(
                      height: 140,
                      width: double.infinity,
                      color: const Color(0xFFF6F8FB),
                      child: CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.image_not_supported_outlined,
                          size: 40,
                          color: Color(0xFFE0E0E0),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF102132),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.marque,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernGoalCard(
    Goal goal,
    Product product,
    UserModel user,
    Pharmacy pharmacy,
  ) {
    return FutureBuilder<bool>(
      future: _goalService.isUserEligibleForGoal(goal, product, user, pharmacy),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        final isEligible = snapshot.data ?? false;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isEligible
                  ? [const Color(0xFF10B981), const Color(0xFF059669)]
                  : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color:
                    (isEligible
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444))
                        .withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isEligible ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEligible ? "Eligible" : "Not eligible",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernActionBar(
    AppLocalizations l10n,
    Product product,
    UserModel user,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ValueListenableBuilder<int>(
                valueListenable: _quantityNotifier,
                builder: (context, quantity, child) {
                  // Keep totalPrice calculation for internal use but don't show it
                  final totalPrice = product.price * quantity;
                  // Display only the unit price (fixed, not multiplied)
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.recommendedPrice,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${product.price.toStringAsFixed(2)} TND',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF102132),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _submitSale(product, user),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      widget.sale != null ? l10n.updateSale : l10n.confirmSale,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisabledProductView(AppLocalizations l10n, Product product) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Product Image
            if (product.imageUrl.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.grey.withOpacity(0.5),
                      BlendMode.saturation,
                    ),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Container(
                        height: 200,
                        width: 200,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, size: 80),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 32),

            // Disabled Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.block, color: Colors.red.shade700, size: 64),
            ),
            const SizedBox(height: 24),

            // Product Name
            Text(
              product.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF102132),
              ),
            ),
            const SizedBox(height: 8),

            // Product Brand
            Text(
              product.marque,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Color(0xFF4A5568)),
            ),
            const SizedBox(height: 32),

            // Warning Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.shade200, width: 2),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.red.shade700,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.productNotAvailable,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.productNotAvailableMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red.shade700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Back Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F9BD1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  l10n.goBack,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
