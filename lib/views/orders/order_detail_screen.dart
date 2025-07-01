import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/order_view_model.dart';
import '../../widgets/modern_loader.dart';
import '../../models/order.dart';
import '../../view_models/cart_view_model.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _didFetch = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didFetch) {
      _didFetch = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<OrderViewModel>().loadOrderById(widget.orderId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderViewModel = context.watch<OrderViewModel>();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('تفاصيل الطلب #${widget.orderId}', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: orderViewModel.isLoadingOrderDetail
            ? const Center(child: ModernLoader())
            : orderViewModel.orderDetailError != null
                ? Center(child: Text(orderViewModel.orderDetailError!, style: const TextStyle(fontFamily: 'Cairo', color: Colors.red)))
                : orderViewModel.selectedOrder == null
                    ? const Center(child: Text('لم يتم العثور على الطلب', style: TextStyle(fontFamily: 'Cairo')))
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('الحالة:', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                                Text(orderViewModel.selectedOrder!.orderStatus ?? '', style: TextStyle(fontFamily: 'Cairo', color: Colors.blue)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('المبلغ الكلي:', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                                Text('${(orderViewModel.selectedOrder!.totalAmount ?? 0).toStringAsFixed(0)} ل.س', style: TextStyle(fontFamily: 'Cairo', color: Colors.green)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text('عنوان التوصيل: ${orderViewModel.selectedOrder!.addressId ?? ''}', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Text('العناصر:', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 8),
                            Expanded(
                              child: ListView.builder(
                                itemCount: orderViewModel.selectedOrder!.items.length,
                                itemBuilder: (context, index) {
                                  final item = orderViewModel.selectedOrder!.items[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 6),
                                    child: ListTile(
                                      leading: item.imageUrl != null && item.imageUrl!.isNotEmpty
                                          ? Image.network(
                                              context.read<CartViewModel>().apiClient.getMediaUrl(item.imageUrl!),
                                              width: 50,
                                              height: 50,
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
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
      ),
    );
  }
} 