import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:novopharma/models/user_model.dart';
import 'package:novopharma/services/auth_service.dart';
import 'package:novopharma/services/storage_service.dart';
import 'package:novopharma/services/user_service.dart';
import 'package:novopharma/services/notification_service.dart';

enum AppAuthState {
  unknown,
  unauthenticated,
  authenticatedPending,
  authenticatedActive,
  authenticatedDisabled,
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();

  User? _firebaseUser;
  UserModel? _userProfile;
  AppAuthState _appAuthState = AppAuthState.unknown;
  StreamSubscription<UserModel?>? _userProfileSubscription;
  bool _fcmTokenSaved = false; // Prevent duplicate FCM saves

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  // Getters
  User? get firebaseUser => _firebaseUser;
  UserModel? get userProfile => _userProfile;
  AppAuthState get appAuthState => _appAuthState;

  @override
  void dispose() {
    _userProfileSubscription?.cancel();
    super.dispose();
  }

  Future<void> _onAuthStateChanged(User? user) async {
    await _userProfileSubscription?.cancel();

    if (user == null) {
      _firebaseUser = null;
      _userProfile = null;
      _appAuthState = AppAuthState.unauthenticated;
      _fcmTokenSaved = false; // Reset on logout
    } else {
      _firebaseUser = user;
      _appAuthState = AppAuthState.unknown;
      _userProfileSubscription = _userService
          .getUserProfile(user.uid)
          .listen(
            (userProfile) {
              _userProfile = userProfile;
              if (_userProfile == null) {
                _appAuthState = AppAuthState.authenticatedDisabled;
              } else {
                switch (_userProfile!.status) {
                  case UserStatus.active:
                    _appAuthState = AppAuthState.authenticatedActive;
                    // Save FCM token when user becomes active (only once)
                    if (!_fcmTokenSaved) {
                      _fcmTokenSaved = true;
                      _saveFCMToken(user.uid);
                    }
                    break;
                  case UserStatus.pending:
                    _appAuthState = AppAuthState.authenticatedPending;
                    break;
                  case UserStatus.disabled:
                    _appAuthState = AppAuthState.authenticatedDisabled;
                    break;
                  default:
                    _appAuthState = AppAuthState.unauthenticated;
                }
              }
              notifyListeners();
            },
            onError: (error) {
              _appAuthState = AppAuthState.unauthenticated;
              notifyListeners();
            },
          );
    }
    notifyListeners();
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await _authService.signInWithEmailAndPassword(email, password);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message; // Return error message
    }
  }

  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    required DateTime dateOfBirth,
    required String pharmacyId,
    required String pharmacyName,
    required String phone,
    required String avatarUrl,
    required String position,
  }) async {
    try {
      UserCredential userCredential = await _authService
          .createUserWithEmailAndPassword(email, password);
      User newUser = userCredential.user!;

      await _userService.createUserProfile(
        user: newUser,
        name: name,
        dateOfBirth: dateOfBirth,
        pharmacyId: pharmacyId,
        pharmacyName: pharmacyName,
        phone: phone,
        avatarUrl: avatarUrl,
        position: position,
      );
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message; // Return error message
    } catch (e) {
      return 'An unexpected error occurred.';
    }
  }

  Future<String?> updateUserProfile(Map<String, dynamic> data) async {
    if (_firebaseUser == null) return 'No user logged in.';
    try {
      await _userService.updateUserProfile(_firebaseUser!.uid, data);
      return null; // Success
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateAvatar(File imageFile) async {
    if (_firebaseUser == null) return 'No user logged in.';
    try {
      final downloadUrl = await _storageService.uploadProfilePicture(
        _firebaseUser!.uid,
        imageFile,
      );

      if (downloadUrl == null) {
        return 'Failed to upload image.';
      }

      await updateUserProfile({'avatarUrl': downloadUrl});
      return null; // Success
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<String?> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    if (_firebaseUser == null) return 'No user logged in.';
    try {
      await _authService.changePassword(
        email: _firebaseUser!.email!,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An unexpected error occurred.';
    }
  }

  // Save FCM token to user document
  Future<void> _saveFCMToken(String userId) async {
    try {
      await _notificationService.saveFCMToken(userId);
    } catch (e) {
      // Silently handle FCM token save errors
    }
  }
}
