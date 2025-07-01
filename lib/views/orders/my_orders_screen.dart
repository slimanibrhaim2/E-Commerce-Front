import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/user_view_model.dart';
import '../../view_models/order_view_model.dart';
import '../../widgets/modern_loader.dart';
import '../../models/order.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  bool _didFetch = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userViewModel = context.watch<UserViewModel>();
    final isLoggedIn = userViewModel.isLoggedIn;
    final orderViewModel = context.read<OrderViewModel>();
    if (!_didFetch && isLoggedIn) {
      _didFetch = true;
      orderViewModel.loadMyOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = context.watch<UserViewModel>();
    final isLoggedIn = userViewModel.isLoggedIn;
    final orderViewModel = context.watch<OrderViewModel>();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('طلباتي', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: isLoggedIn
            ? orderViewModel.isLoadingOrders
                ? const Center(child: ModernLoader())
                : orderViewModel.ordersError != null
                    ? Center(child: Text(orderViewModel.ordersError!, style: const TextStyle(fontFamily: 'Cairo', color: Colors.red)))
                    : orderViewModel.myOrders.isEmpty
                        ? const Center(child: Text('لا يوجد طلبات بعد', style: TextStyle(fontFamily: 'Cairo')))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: orderViewModel.myOrders.length,
                            itemBuilder: (context, index) {
                              final order = orderViewModel.myOrders[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('#${order.id}', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 18)),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('الحالة: ${order.orderStatus ?? ''}', style: const TextStyle(fontFamily: 'Cairo')),
                                          Text('المبلغ الكلي: ${(order.totalAmount ?? 0).toStringAsFixed(0)} ل.س', style: const TextStyle(fontFamily: 'Cairo', color: Colors.green)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text('تاريخ الإنشاء: ${order.createdAt != null ? order.createdAt!.toLocal().toString().split(".")[0] : ''}', style: const TextStyle(fontFamily: 'Cairo')),
                                      const SizedBox(height: 4),
                                      Text('عنوان التوصيل: ${order.addressId ?? ''}', style: const TextStyle(fontFamily: 'Cairo')),
                                      const Divider(height: 20),
                                      Text('العناصر:', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      ...order.items.map((item) => ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: item.imageUrl != null && item.imageUrl!.isNotEmpty
                                                ? Image.network(
                                                    // You may want to use your media URL helper here
                                                    'https://your-api-base-url${item.imageUrl}',
                                                    width: 40,
                                                    height: 40,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
                                                  )
                                                : const Icon(Icons.image_not_supported),
                                            title: Text(item.name ?? '', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                                            subtitle: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('السعر: ${(item.price ?? 0).toStringAsFixed(0)} ل.س', style: const TextStyle(fontFamily: 'Cairo')),
                                                Text('الكمية: ${item.quantity}', style: const TextStyle(fontFamily: 'Cairo')),
                                              ],
                                            ),
                                            trailing: Text('المجموع: ${(item.totalPrice ?? 0).toStringAsFixed(0)} ل.س', style: const TextStyle(fontFamily: 'Cairo', color: Colors.green)),
                                          )),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.lock_outline, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('يرجى تسجيل الدخول لعرض طلباتك', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, color: Colors.grey)),
                  ],
                ),
              ),
      ),
    );
  }
} 