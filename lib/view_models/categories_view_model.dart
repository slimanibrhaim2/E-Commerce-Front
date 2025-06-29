import 'package:flutter/material.dart';
import '../models/category.dart';
import '../repositories/category_repository.dart';
import '../core/api/api_client.dart';

class CategoriesViewModel extends ChangeNotifier {
  final CategoryRepository _repository;
  final ApiClient _apiClient;
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  CategoriesViewModel(this._repository, this._apiClient);

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ApiClient get apiClient => _apiClient;

  Future<String?> loadCategories() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _repository.getCategories();
      _categories = response.data ?? [];
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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
