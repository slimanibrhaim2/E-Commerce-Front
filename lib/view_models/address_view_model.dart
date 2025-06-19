import 'package:e_commerce/repositories/address_repository.dart';
import 'package:e_commerce/core/api/api_client.dart';
import 'package:flutter/material.dart';
import '../models/address.dart';

class AddressViewModel extends ChangeNotifier {
  final AddressRepository _repository;
  final ApiClient _apiClient;
  List<Address> _addresses = [];
  bool _isLoading = false;
  String? _error;

  AddressViewModel(this._repository, this._apiClient);

  List<Address> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<String?> loadAddresses() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await _repository.fetchAddresses();
      _addresses = response.data ?? [];
      notifyListeners();
      return response.message;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return _error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> createAddress(Address address) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await _repository.createAddress(address);
      if (response.data != null) {
        await loadAddresses(); // Refresh the entire list after creating
      }
      return response.message;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> updateAddress(String addressId, Address address) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await _repository.updateAddress(addressId, address);
      if (response.data != null) {
        await loadAddresses(); // Refresh the entire list after updating
      }
      return response.message;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> deleteAddress(String addressId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await _repository.deleteAddress(addressId);
      await loadAddresses(); // Always refresh the list after deletion
      return response.message;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 