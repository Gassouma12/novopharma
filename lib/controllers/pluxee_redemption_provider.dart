import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:novopharma/controllers/auth_provider.dart';
import 'package:novopharma/models/pluxee_redemption_request.dart';
import 'package:novopharma/services/pluxee_redemption_service.dart';

class PluxeeRedemptionProvider with ChangeNotifier {
  final PluxeeRedemptionService _service = PluxeeRedemptionService();
  AuthProvider _authProvider;

  List<PluxeeRedemptionRequest> _requests = [];
  bool _isLoading = false;
  double _conversionRate = 100.0;
  StreamSubscription<List<PluxeeRedemptionRequest>>? _requestsSubscription;
  StreamSubscription<double>? _conversionRateSubscription;

  PluxeeRedemptionProvider(this._authProvider) {
    _subscribeToConversionRate();
    if (_authProvider.userProfile != null) {
      _subscribeToRequests();
    }
  }

  // Getters
  List<PluxeeRedemptionRequest> get requests => _requests;
  bool get isLoading => _isLoading;
  double get conversionRate => _conversionRate;

  List<PluxeeRedemptionRequest> get pendingRequests =>
      _requests.where((r) => r.isPending).toList();

  List<PluxeeRedemptionRequest> get processedRequests =>
      _requests.where((r) => !r.isPending).toList();

  double get totalPendingPoints =>
      pendingRequests.fold(0.0, (sum, request) => sum + request.pointsToRedeem);

  void update(AuthProvider authProvider) {
    if (authProvider.userProfile?.uid != _authProvider.userProfile?.uid) {
      _authProvider = authProvider;
      _subscribeToRequests();
    }
  }

  void _subscribeToConversionRate() {
    _conversionRateSubscription = _service.conversionRateStream().listen(
      (rate) {
        _conversionRate = rate;
        notifyListeners();
      },
      onError: (error) {
        // Handle error silently
      },
    );
  }

  void _subscribeToRequests() {
    _isLoading = true;
    notifyListeners();

    _requestsSubscription?.cancel();

    if (_authProvider.userProfile == null) {
      _requests = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    final userId = _authProvider.userProfile!.uid;

    _requestsSubscription = _service
        .getUserRedemptionRequests(userId)
        .listen(
          (requests) {
            _requests = requests;
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  Future<String?> createRedemptionRequest(double pointsToRedeem) async {
    if (_authProvider.userProfile == null) {
      return 'User not logged in';
    }

    final user = _authProvider.userProfile!;
    return await _service.createRedemptionRequest(
      userId: user.uid,
      userName: user.name,
      userEmail: user.email,
      pointsToRedeem: pointsToRedeem,
    );
  }

  Future<String?> cancelRequest(String requestId) async {
    if (_authProvider.userProfile == null) {
      return 'User not logged in';
    }

    return await _service.cancelRedemptionRequest(
      requestId: requestId,
      userId: _authProvider.userProfile!.uid,
    );
  }

  double calculatePluxeeCredits(double points) {
    return points / _conversionRate;
  }

  @override
  void dispose() {
    _requestsSubscription?.cancel();
    _conversionRateSubscription?.cancel();
    super.dispose();
  }
}
