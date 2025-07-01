import 'package:flutter/material.dart';
import '../repositories/review_repository.dart';
import '../models/review.dart';
import '../core/api/api_response.dart';

class ReviewViewModel extends ChangeNotifier {
  final ReviewRepository repository;
  bool isLoading = false;
  String? error;
  Review? createdReview;

  ReviewViewModel(this.repository);

  Future<String?> submitReview(Review review) async {
    isLoading = true;
    error = null;
    notifyListeners();
    
    try {
      print('ReviewViewModel: Starting review submission for order: ${review.orderId}');
      final response = await repository.createReview(review);
      print('ReviewViewModel: Review response - success: ${response.success}, message: ${response.message}, data: ${response.data}');
      
      // Check if the response indicates a business error
      if (response.success == false) {
        error = response.message ?? 'حدث خطأ أثناء إرسال التقييم';
        createdReview = null;
        print('ReviewViewModel: Business error detected - $error');
        notifyListeners();
        return error;
      }
      
      createdReview = response.data;
      error = null;
      print('ReviewViewModel: Review submitted successfully - ID: ${createdReview?.id}');
      notifyListeners();
      return response.message;
    } catch (e) {
      error = e.toString();
      print('ReviewViewModel: Exception during review submission - $error');
      notifyListeners();
      return error;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    error = null;
    notifyListeners();
  }

  void reset() {
    isLoading = false;
    error = null;
    createdReview = null;
    notifyListeners();
  }
} 