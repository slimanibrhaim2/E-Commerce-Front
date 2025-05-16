import 'package:flutter/foundation.dart' as foundation;
import '../models/category.dart';
import '../repositories/category_repository.dart';

class CategoriesViewModel extends foundation.ChangeNotifier {
  final CategoryRepository _repository;
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  CategoriesViewModel(this._repository);

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _categories = await _repository.getAll();
    } catch (e) {
      _error = 'حدث خطأ أثناء تحميل التصنيفات';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 