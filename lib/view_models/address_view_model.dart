import 'package:e_commerce/repositories/address_repository.dart';
import 'package:e_commerce/core/api/api_client.dart';
import 'package:e_commerce/core/api/api_response.dart';
import 'package:flutter/material.dart';
import '../models/address.dart';

class AddressViewModel extends ChangeNotifier {
  final AddressRepository _repository;
  final ApiClient _apiClient;
  List<Address> _addresses = []; // Displayed addresses
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  
  // Pagination state
  int _currentPage = 1;
  int _pageSize = 5;
  bool _hasMoreData = true;
  int _totalCount = 0;
  int _totalPages = 0;

  AddressViewModel(this._repository, this._apiClient);

  List<Address> get addresses => _addresses;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  bool get hasMoreData => _hasMoreData;
  int get totalAddresses => _totalCount;
  int get totalPages => _totalPages;

  // Load addresses with pagination (first page)
  Future<String?> loadAddresses() async {
    return await _loadAddressesPage(1, reset: true);
  }

  // Load more addresses (next page)
  Future<String?> loadMoreAddresses() async {
    if (!_hasMoreData || _isLoadingMore) return null;
    return await _loadAddressesPage(_currentPage + 1, reset: false);
  }

  // Internal method to load a specific page
  Future<String?> _loadAddressesPage(int pageNumber, {required bool reset}) async {
    try {
      if (reset) {
        _isLoading = true;
        _currentPage = 1;
        _hasMoreData = true;
        _addresses.clear(); // Clear displayed addresses
      } else {
        _isLoadingMore = true;
      }
      _error = null;
      notifyListeners();
      
      final response = await _repository.fetchAddresses(
        pageNumber: pageNumber,
        pageSize: _pageSize,
      );
      
      final newAddresses = response.data ?? [];
      
      // Extract pagination metadata from response
      final metadata = response.metadata;
      if (metadata != null) {
        _currentPage = metadata['pageNumber'] ?? pageNumber;
        _pageSize = metadata['pageSize'] ?? _pageSize;
        _totalPages = metadata['totalPages'] ?? 0;
        _totalCount = metadata['totalCount'] ?? 0;
        _hasMoreData = metadata['hasNextPage'] ?? false;
      }
      
      if (reset) {
        _addresses = newAddresses;
      } else {
        _addresses.addAll(newAddresses);
      }
      
      notifyListeners();
      return response.message;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return _error;
    } finally {
      if (reset) {
        _isLoading = false;
      } else {
        _isLoadingMore = false;
      }
      notifyListeners();
    }
  }

  // Refresh addresses (reset to first page)
  Future<String?> refreshAddresses() async {
    return await loadAddresses();
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

  // Fetch a single address by ID
  Future<Address?> fetchAddressById(String addressId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await _repository.fetchAddress(addressId);
      return response.data;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 