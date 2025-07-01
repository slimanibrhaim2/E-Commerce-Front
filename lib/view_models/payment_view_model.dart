import 'package:flutter/material.dart';
import '../repositories/payment_repository.dart';
import '../models/payment_method.dart';

class PaymentViewModel extends ChangeNotifier {
  final PaymentRepository repository;
  List<PaymentMethod> paymentMethods = [];
  bool isLoading = false;
  String? error;

  PaymentViewModel(this.repository);

  Future<void> loadPaymentMethods() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final response = await repository.getPaymentMethods();
      paymentMethods = response.data ?? [];
      error = null;
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<String?> processPayment({
    required String orderId,
    required double amount,
    required String paymentMethodId,
    String? paymentDetails,
  }) async {
    try {
      final response = await repository.processPayment(
        orderId: orderId,
        amount: amount,
        paymentMethodId: paymentMethodId,
        paymentDetails: paymentDetails,
      );
      return response.message;
    } catch (e) {
      return e.toString();
    }
  }
} 