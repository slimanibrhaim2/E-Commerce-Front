import 'package:e_commerce/repositories/address_repository.dart';
import 'package:e_commerce/core/api/api_client.dart';
import 'package:e_commerce/core/api/api_response.dart';
import 'package:flutter/material.dart';
import '../models/address.dart';

class AddressViewModel extends ChangeNotifier {
  final AddressRepository _repository;
  final ApiClient _apiClient;
  List<Address> _allAddresses = []; // Store all addresses from API
  List<Address> _addresses = []; // Displayed addresses (paginated)
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  
  // Pagination state
  int _currentPage = 1;
  int _pageSize = 5; // Changed from 10 to 5 for testing
  bool _hasMoreData = true;

  AddressViewModel(this._repository, this._apiClient);

  List<Address> get addresses => _addresses;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  bool get hasMoreData => _hasMoreData;
  int get totalAddresses => _allAddresses.length;

  // Load addresses with pagination (first page)
  Future<String?> loadAddresses() async {
    print('🚀 AddressViewModel.loadAddresses() called');
    return await _loadAddressesPage(1, reset: true);
  }

  // Load more addresses (next page)
  Future<String?> loadMoreAddresses() async {
    print('🚀 AddressViewModel.loadMoreAddresses() called');
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
        _allAddresses.clear(); // Clear all addresses when resetting
        _addresses.clear(); // Also clear displayed addresses
      } else {
        _isLoadingMore = true;
      }
      _error = null;
      notifyListeners();
      
      print('🔄 Loading addresses page $pageNumber (reset: $reset)');
      print('🔄 Current state - allAddresses: ${_allAddresses.length}, displayedAddresses: ${_addresses.length}');
      
      // If this is the first page, fetch all addresses from API
      ApiResponse<List<Address>>? response;
      if (reset || _allAddresses.isEmpty) {
        print('🚀 About to call repository.fetchAddresses with pageNumber=$pageNumber, pageSize=$_pageSize');
        response = await _repository.fetchAddresses(
          pageNumber: pageNumber,
          pageSize: _pageSize,
        );
        print('🚀 Repository call completed');
        
        final newAddresses = response.data ?? [];
        print('📦 Received ${newAddresses.length} addresses from API');
        print('📦 Address names: ${newAddresses.map((a) => a.name).toList()}');
        
        if (reset) {
          _allAddresses = newAddresses;
        } else {
          // If backend doesn't support pagination, we might get all addresses again
          // In that case, we'll use client-side pagination
          if (_allAddresses.isEmpty) {
            _allAddresses = newAddresses;
          }
        }
      }
      
      // Apply client-side pagination
      final startIndex = (pageNumber - 1) * _pageSize;
      final endIndex = startIndex + _pageSize;
      
      print('📊 Client-side pagination: startIndex=$startIndex, endIndex=$endIndex, totalAddresses=${_allAddresses.length}');
      print('📊 Page size: $_pageSize, Current page: $pageNumber');
      
      if (reset) {
        _addresses = _allAddresses.take(_pageSize).toList();
        print('📊 Reset: Taking first $_pageSize addresses from ${_allAddresses.length} total');
      } else {
        final newPageAddresses = _allAddresses.skip(startIndex).take(_pageSize).toList();
        _addresses.addAll(newPageAddresses);
        print('📊 Load more: Adding ${newPageAddresses.length} addresses from index $startIndex');
      }
      
      // Check if we have more data
      _hasMoreData = endIndex < _allAddresses.length;
      _currentPage = pageNumber;
      
      print('📊 Final state:');
      print('   - Current page: $_currentPage');
      print('   - Has more data: $_hasMoreData');
      print('   - Total addresses: ${_allAddresses.length}');
      print('   - Displayed addresses: ${_addresses.length}');
      print('   - End index: $endIndex');
      print('   - Should show load more: ${endIndex < _allAddresses.length}');
      
      notifyListeners();
      return response?.message;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      print('❌ Error loading addresses: $_error');
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