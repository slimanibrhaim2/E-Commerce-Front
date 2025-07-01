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
  Order? selectedOrder;
  bool isLoadingOrderDetail = false;
  String? orderDetailError;

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

  Future<void> loadOrderById(String orderId) async {
    isLoadingOrderDetail = true;
    orderDetailError = null;
    notifyListeners();
    try {
      final response = await repository.getOrderById(orderId);
      selectedOrder = response.data;
      orderDetailError = null;
    } catch (e) {
      orderDetailError = e.toString();
    }
    isLoadingOrderDetail = false;
    notifyListeners();
  }

  Future<String?> cancelOrder(String orderId) async {
    try {
      final response = await repository.cancelOrder(orderId);
      return response.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> markOrderDelivered(String orderId) async {
    try {
      final response = await repository.markOrderDelivered(orderId);
      return response.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Refresh the current order (used in order summary screen)
  Future<void> refreshCurrentOrder(String orderId) async {
    try {
      final response = await repository.getOrderById(orderId);
      order = response.data;
      notifyListeners();
    } catch (e) {
      // Handle error silently or log it
      print('Error refreshing current order: $e');
    }
  }
} 