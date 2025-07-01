import 'package:flutter/material.dart';
import '../repositories/order_repository.dart';
import '../models/order.dart';
import '../core/api/api_response.dart';

class OrderViewModel extends ChangeNotifier {
  final OrderRepository repository;
  Order? order;
  bool isLoading = false;
  String? error;
  List<Order> myOrders = [];
  bool isLoadingOrders = false;
  String? ordersError;

  OrderViewModel(this.repository);

  Future<String?> checkout(String addressId) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final response = await repository.checkout(addressId);
      order = response.data;
      error = null;
      notifyListeners();
      return response.message;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return error;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyOrders() async {
    isLoadingOrders = true;
    ordersError = null;
    notifyListeners();
    try {
      final response = await repository.getMyOrders();
      myOrders = response.data ?? [];
      ordersError = null;
    } catch (e) {
      ordersError = e.toString();
    }
    isLoadingOrders = false;
    notifyListeners();
  }
} 