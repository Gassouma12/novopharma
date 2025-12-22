import 'package:flutter/foundation.dart';
import 'package:novopharma/controllers/auth_provider.dart';
import 'package:novopharma/models/goal.dart';
import 'package:novopharma/services/goal_service.dart';

class GoalProvider extends ChangeNotifier {
  final GoalService _goalService = GoalService();
  AuthProvider _authProvider;

  List<Goal> _goals = [];
  bool _isLoading = false;
  String? _error;

  GoalProvider(this._authProvider) {
    if (_authProvider.userProfile != null) {
      fetchGoals();
    }
  }

  void update(AuthProvider authProvider) {
    if (authProvider.userProfile?.uid != _authProvider.userProfile?.uid) {
      _authProvider = authProvider;
      if (_authProvider.userProfile != null) {
        fetchGoals();
      } else {
        _goals = [];
        notifyListeners();
      }
    }
  }

  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchGoals() async {
    if (_isLoading) return; // Prevent duplicate calls

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _goals = await _goalService.getUserGoals();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
