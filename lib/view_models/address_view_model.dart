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
      
      print('Creating address: ${address.toJson()}');
      final response = await _repository.createAddress(address);
      print('Address creation response: ${response.data?.toJson()}');
      
      if (response.data != null) {
        // Add to local list immediately for better UX
        _addresses.add(response.data!);
        notifyListeners(); // Notify immediately for instant UI update
        print('Address added to local list. Total addresses: ${_addresses.length}');
        // Then refresh from server to ensure consistency
        await loadAddresses();
      }
      return response.message;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      print('Error creating address: $_error');
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
        // Update the local list immediately for better UX
        final index = _addresses.indexWhere((addr) => addr.id == addressId);
        if (index != -1) {
          _addresses[index] = address;
          notifyListeners(); // Notify immediately for instant UI update
        }
        // Then refresh from server to ensure consistency
        await loadAddresses();
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
      // Remove from local list immediately for better UX
      _addresses.removeWhere((addr) => addr.id == addressId);
      notifyListeners(); // Notify immediately for instant UI update
      // Then refresh from server to ensure consistency
      await loadAddresses();
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