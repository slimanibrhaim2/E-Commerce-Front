import 'package:flutter/foundation.dart';
import '../core/api/api_client.dart';
import '../models/review.dart';
import '../repositories/review_repository.dart';

class MyReviewsViewModel extends ChangeNotifier {
  final ReviewRepository _reviewRepository;

  MyReviewsViewModel({required ApiClient apiClient})
      : _reviewRepository = ReviewRepository(apiClient: apiClient);

  // State variables
  List<Review> _reviews = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  
  // Pagination variables
  int _currentPage = 1;
  int _pageSize = 10;
  int _totalCount = 0;
  int _totalPages = 0;
  bool _hasMoreData = false;

  // Getters
  List<Review> get reviews => _reviews;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalCount => _totalCount;
  int get totalPages => _totalPages;
  bool get hasMoreData => _hasMoreData;
  bool get showLoadMore => _hasMoreData && !_isLoadingMore;

  // Load initial reviews
  Future<void> loadMyReviews({bool reset = true}) async {
    if (reset) {
      _currentPage = 1;
      _reviews.clear();
    }

    _isLoading = reset;
    _error = null;
    notifyListeners();

    try {
      final response = await _reviewRepository.getMyReviews(
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

      if (response.data != null) {
        if (reset) {
          _reviews = response.data!;
        } else {
          _reviews.addAll(response.data!);
        }

        // Update pagination info from metadata
        if (response.metadata != null) {
          _totalCount = response.metadata!['totalCount'] ?? 0;
          _totalPages = response.metadata!['totalPages'] ?? 0;
          _hasMoreData = response.metadata!['hasNextPage'] ?? false;
        }
      } else {
        _error = response.message ?? 'حدث خطأ في جلب المراجعات';
      }
    } catch (e) {
      _error = 'حدث خطأ في جلب المراجعات';
      if (kDebugMode) {
        print('Error loading reviews: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load more reviews (pagination)
  Future<void> loadMoreReviews() async {
    if (_isLoadingMore || !_hasMoreData) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      _currentPage++;
      final response = await _reviewRepository.getMyReviews(
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

      if (response.data != null && response.data!.isNotEmpty) {
        _reviews.addAll(response.data!);
        
        // Update pagination info
        if (response.metadata != null) {
          _totalCount = response.metadata!['totalCount'] ?? 0;
          _totalPages = response.metadata!['totalPages'] ?? 0;
          _hasMoreData = response.metadata!['hasNextPage'] ?? false;
        }
      } else {
        _hasMoreData = false;
      }
    } catch (e) {
      _currentPage--; // Revert page increment on error
      if (kDebugMode) {
        print('Error loading more reviews: $e');
      }
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Refresh reviews
  Future<void> refreshReviews() async {
    await loadMyReviews(reset: true);
  }

  // Clear data
  void clearData() {
    _reviews.clear();
    _currentPage = 1;
    _totalCount = 0;
    _totalPages = 0;
    _hasMoreData = false;
    _error = null;
    notifyListeners();
  }
} 