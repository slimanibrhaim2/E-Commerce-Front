import 'package:e_commerce/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/api_response.dart';
// Accept both real and fake repositories
// ignore: prefer_typing_uninitialized_variables
var _repository;

class UserViewModel extends ChangeNotifier {
  final UserRepository _repository;
  User? _user;
  bool _isLoading = false;
  String? _error;

  UserViewModel(this._repository);

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<String?> loadUserProfile() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      final response = await _repository.fetchUserProfile();
      _user = response.data;
      return response.message;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> updateUserProfile(User user) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      final response = await _repository.updateUserProfile(user);
      _user = response.data;
      return response.message;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> createUser(User user) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      final response = await _repository.createUser(user);
      return response.message;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 