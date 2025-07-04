import 'package:e_commerce/repositories/user_repository.dart';
import 'package:e_commerce/core/api/api_client.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import 'dart:io';
import '../core/api/api_response.dart';
import '../core/services/local_storage_service.dart';


enum RegistrationStep { none, registering, awaitingOtp, verifyingOtp, done }
enum LoginStep { none, loggingIn, awaitingOtp, verifyingOtp, done }

class UserViewModel extends ChangeNotifier {
  final UserRepository _repository;
  final ApiClient _apiClient;
  User? _user;
  bool _isLoading = false;
  String? _error;
  RegistrationStep _step = RegistrationStep.none;
  LoginStep _loginStep = LoginStep.none;
  String? _phoneNumber;
  String? _jwt;
  bool _wasLoggedIn = false; // Track if user was previously logged in

  UserViewModel(this._repository, this._apiClient);

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  RegistrationStep get step => _step;
  String? get phoneNumber => _phoneNumber;
  String? get jwt => _jwt;
  LoginStep get loginStep => _loginStep;
  bool get isLoggedIn => _jwt != null;
  bool get wasLoggedIn => _wasLoggedIn;
  ApiClient get apiClient => _apiClient;

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
      return _error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ApiResponse<User>> updateUserProfile(User user, {File? profileImage}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      final response = await _repository.updateCurrentUserProfile(user, profileImage: profileImage);
      
      // Update the user data with the response from backend
      if (response.data != null) {
      _user = response.data;
        print('Updated user data: ${_user?.toJson()}');
      }
      
      return response;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      final response = await _repository.uploadProfileImage(imageFile);
      if (response.data != null && _user != null) {
        // Update the user's profile photo URL
        _user = _user!.copyWith(profilePhoto: response.data);
      }
      return response.message ?? 'تم رفع الصورة بنجاح';
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> deleteUser() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      final response = await _repository.deleteCurrentUserProfile();
      return response.message;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> registerUser(User user) async {
    try {
      _isLoading = true;
      _error = null;
      _step = RegistrationStep.registering;
      notifyListeners();
      final response = await _repository.registerUser(user);
      if (response.success == true) {
        _phoneNumber = user.phoneNumber;
        _step = RegistrationStep.awaitingOtp;
      } else {
        _error = response.message;
        _step = RegistrationStep.none;
      }
      return response.message;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _step = RegistrationStep.none;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> verifyOtp(String otp) async {
    try {
      _isLoading = true;
      _error = null;
      _step = RegistrationStep.verifyingOtp;
      notifyListeners();
      final response = await _repository.verifyOtp(_phoneNumber!, otp);
      if (response.success == true && response.data != null) {
        _jwt = response.data;
        _apiClient.setToken(_jwt);
        _wasLoggedIn = true; // Mark as logged in
        _step = RegistrationStep.done;
        
        // Sync offline data after successful registration
        _syncOfflineData();
      } else {
        _error = response.message;
        _step = RegistrationStep.awaitingOtp;
      }
      return response.message;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _step = RegistrationStep.awaitingOtp;
      return _error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> login(String phoneNumber) async {
    try {
      _isLoading = true;
      _error = null;
      _loginStep = LoginStep.loggingIn;
      notifyListeners();
      final response = await _repository.login(phoneNumber);
      if (response.success == true) {
        _phoneNumber = phoneNumber;
        _loginStep = LoginStep.awaitingOtp;
      } else {
        _error = response.message;
        _loginStep = LoginStep.none;
      }
      return response.message;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _loginStep = LoginStep.none;
      return _error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> verifyLoginOtp(String otp) async {
    try {
      _isLoading = true;
      _error = null;
      _loginStep = LoginStep.verifyingOtp;
      notifyListeners();
      final response = await _repository.verifyLoginOtp(_phoneNumber!, otp);
      if (response.data != null) {
        _jwt = response.data;
        _apiClient.setToken(_jwt);
        _wasLoggedIn = true; // Mark as logged in
        _loginStep = LoginStep.done;
        
        // Sync offline data after successful login
        _syncOfflineData();
      } else {
        _error = response.message;
        _loginStep = LoginStep.awaitingOtp;
      }
      return response.message;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _loginStep = LoginStep.awaitingOtp;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final wasLoggedIn = _wasLoggedIn; // Store before clearing
    _jwt = null;
    _user = null;
    _phoneNumber = null;
    _error = null;
    _step = RegistrationStep.none;
    _loginStep = LoginStep.none;
    _wasLoggedIn = false;
    _apiClient.clearToken();
    
    // Clear offline data on logout only if user was previously logged in
    if (wasLoggedIn) {
      await _clearOfflineData();
    }
    
    notifyListeners();
  }

  // Sync offline favorites and cart data to backend
  void _syncOfflineData() {
    // This will be called by the UI layer to sync data
    // We can't directly access other view models here due to dependency issues
    print('User logged in - offline data should be synced');
  }

  // Clear offline data on logout
  Future<void> _clearOfflineData() async {
    try {
      final localStorage = await LocalStorageService.getInstance();
      await localStorage.clearAllOfflineData();
      print('All offline data cleared on logout');
    } catch (e) {
      print('Error clearing offline data: $e');
    }
  }

  void setJwt(String? token) {
    _jwt = token;
    _repository.setToken(token);
    notifyListeners();
  }

  // Load JWT from storage and set it
  Future<void> loadJwt() async {
    // ... existing code ...
  }

  // Refresh user profile from backend
  Future<void> refreshUserProfile() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      final response = await _repository.fetchUserProfile();
      _user = response.data;
      print('Refreshed user data: ${_user?.toJson()}');
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      print('Error refreshing profile: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to fetch user information by ID (for seller info)
  Future<User?> fetchUserById(String userId) async {
    try {
      final response = await _repository.getUserById(userId);
      if (response.success && response.data != null) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('Error fetching user by ID: $e');
      return null;
    }
  }
} 