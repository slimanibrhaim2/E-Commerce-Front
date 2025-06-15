import 'package:e_commerce/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/api_response.dart';
// Accept both real and fake repositories
// ignore: prefer_typing_uninitialized_variables
var _repository;

enum RegistrationStep { none, registering, awaitingOtp, verifyingOtp, done }
enum LoginStep { none, loggingIn, awaitingOtp, verifyingOtp, done }

class UserViewModel extends ChangeNotifier {
  final UserRepository _repository;
  User? _user;
  bool _isLoading = false;
  String? _error;
  RegistrationStep _step = RegistrationStep.none;
  LoginStep _loginStep = LoginStep.none;
  String? _phoneNumber;
  String? _jwt;

  UserViewModel(this._repository);

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  RegistrationStep get step => _step;
  String? get phoneNumber => _phoneNumber;
  String? get jwt => _jwt;
  LoginStep get loginStep => _loginStep;

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
        _step = RegistrationStep.done;
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
        _loginStep = LoginStep.done;
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
} 