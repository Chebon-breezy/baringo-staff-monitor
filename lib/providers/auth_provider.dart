// File: lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:staff_performance_mapping/models/user_model.dart';
import 'package:staff_performance_mapping/services/auth_service.dart';
import 'package:staff_performance_mapping/services/database_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  User? get currentUser => _authService.getCurrentUser();

  Stream<User?> authStateChanges() => _authService.user;

  Future<bool> signUp(UserModel user, String password) async {
    try {
      final result = await _authService.signUp(user, password);
      return result != null;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      final result = await _authService.signIn(email, password);
      return result != null;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<bool> isAdmin() async {
    if (currentUser == null) return false;
    final user = await _databaseService.getUserById(currentUser!.uid);
    return user?.isAdmin ?? false;
  }

  Future<UserModel?> getCurrentUser() async {
    if (currentUser == null) return null;
    return await _databaseService.getUserById(currentUser!.uid);
  }

  Future<void> updateUserProfile(UserModel user) async {
    await _databaseService.updateUserProfile(user);
    notifyListeners();
  }
}
