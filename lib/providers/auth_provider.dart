import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _userModel;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  bool get isAuthenticated => FirebaseAuth.instance.currentUser != null;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    if (isAuthenticated) {
      await refreshUserModel();
      // Force logout if user is no longer approved or doesn't exist in DB
      if (_userModel == null || _userModel!.status != 'approved') {
        await logout();
      }
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> refreshUserModel() async {
    _userModel = await _authService.getCurrentUserModel();
    notifyListeners();
  }

  Future<void> submitSignupRequest({
    required String name,
    required String email,
    required String role,
    required String password,
    String? paperTitle,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.submitSignupRequest(
        name: name,
        email: email,
        role: role,
        password: password,
        paperTitle: paperTitle,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.login(email, password);
      await refreshUserModel();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _userModel = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
