import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AppUser? _user;
  String? _token;
  bool _loading = false;

  AuthProvider(this._authService);

  AppUser? get user => _user;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _loading;

  Future<void> init() async {
    _loading = true;
    notifyListeners();

    final result = await _authService.getCurrentUser();

    if (result != null) {
      final (token, user) = result;
      _token = token;
      _user = user;
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _loading = true;
    notifyListeners();
    try {
      final (token, user) = await _authService.login(email, password);
      _token = token;
      _user = user;
    } catch (e) {
      _loading = false;
      notifyListeners();
      rethrow;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> register(String email, String password) async {
    _loading = true;
    notifyListeners();
    final (token, user) = await _authService.register(email, password);
    _token = token;
    _user = user;
    _loading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _token = null;
    _user = null;
    notifyListeners();
  }
}
