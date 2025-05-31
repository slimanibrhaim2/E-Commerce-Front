import 'package:flutter/material.dart';
import '../models/user.dart';
// Accept both real and fake repositories
// ignore: prefer_typing_uninitialized_variables
var _repository;

class UserViewModel extends ChangeNotifier {
  // Accept both real and fake repositories
  final dynamic _repository;
  User? _user;
  bool _isLoading = false;
  String? _error;

  UserViewModel(this._repository);

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserProfile() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      _user = await _repository.fetchUserProfile();
    } catch (e) {
      _error = 'حدث خطأ أثناء تحميل بيانات المستخدم';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserProfile(User user) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      _user = await _repository.updateUserProfile(user);
    } catch (e) {
      _error = 'حدث خطأ أثناء تحديث بيانات المستخدم';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 