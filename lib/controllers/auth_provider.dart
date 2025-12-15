import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:novopharma/models/user_model.dart';
import 'package:novopharma/services/auth_service.dart';
import 'package:novopharma/services/storage_service.dart';
import 'package:novopharma/services/user_service.dart';

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

  User? _firebaseUser;
  UserModel? _userProfile;
  AppAuthState _appAuthState = AppAuthState.unknown;
  StreamSubscription<UserModel?>? _userProfileSubscription;

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
    print('[AuthProvider] Auth state changed: user=${user?.uid}');
    await _userProfileSubscription?.cancel();

    if (user == null) {
      print('[AuthProvider] No user, setting unauthenticated');
      _firebaseUser = null;
      _userProfile = null;
      _appAuthState = AppAuthState.unauthenticated;
    } else {
      print(
        '[AuthProvider] User authenticated: ${user.uid}, fetching profile...',
      );
      _firebaseUser = user;
      _appAuthState = AppAuthState.unknown;
      _userProfileSubscription = _userService
          .getUserProfile(user.uid)
          .listen(
            (userProfile) {
              print(
                '[AuthProvider] User profile received: ${userProfile?.name}, status=${userProfile?.status}',
              );
              _userProfile = userProfile;
              if (_userProfile == null) {
                print(
                  '[AuthProvider] Profile is null, setting authenticatedDisabled',
                );
                _appAuthState = AppAuthState.authenticatedDisabled;
              } else {
                switch (_userProfile!.status) {
                  case UserStatus.active:
                    print(
                      '[AuthProvider] User is active, setting authenticatedActive',
                    );
                    _appAuthState = AppAuthState.authenticatedActive;
                    break;
                  case UserStatus.pending:
                    print(
                      '[AuthProvider] User is pending, setting authenticatedPending',
                    );
                    _appAuthState = AppAuthState.authenticatedPending;
                    break;
                  case UserStatus.disabled:
                    print(
                      '[AuthProvider] User is disabled, setting authenticatedDisabled',
                    );
                    _appAuthState = AppAuthState.authenticatedDisabled;
                    break;
                  default:
                    print(
                      '[AuthProvider] Unknown status, setting unauthenticated',
                    );
                    _appAuthState = AppAuthState.unauthenticated;
                }
              }
              notifyListeners();
            },
            onError: (error) {
              print('[AuthProvider] Error fetching user profile: $error');
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
}
