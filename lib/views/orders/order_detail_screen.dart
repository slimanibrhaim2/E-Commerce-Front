import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/order_view_model.dart';
import '../../view_models/cart_view_model.dart';
import '../../widgets/modern_loader.dart';
import '../../widgets/modern_snackbar.dart';
import '../reviews/review_form_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load order details when the view is created
    Future.microtask(() => 
      context.read<OrderViewModel>().loadOrderById(widget.orderId)
    );
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
                            // Show delivery confirmation button only if order status is "تم الدفع"
                            if (orderViewModel.selectedOrder!.orderStatus == 'تم الدفع') ...[
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.blue.shade200),
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      'هل تم توصيل طلبك؟',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'اضغط على الزر أدناه فقط إذا تم توصيل طلبك بالفعل',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 14,
                                        color: Colors.blue,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          // Show confirmation dialog
                                          final confirmed = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => Directionality(
                                              textDirection: TextDirection.rtl,
                                              child: AlertDialog(
                                                title: const Text(
                                                  'تأكيد التوصيل',
                                                  style: TextStyle(
                                                    fontFamily: 'Cairo',
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                content: const Text(
                                                  'هل أنت متأكد أن طلبك تم توصيله؟',
                                                  style: TextStyle(fontFamily: 'Cairo'),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context, false),
                                                    child: const Text(
                                                      'إلغاء',
                                                      style: TextStyle(fontFamily: 'Cairo'),
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () => Navigator.pop(context, true),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.green,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      'تأكيد',
                                                      style: TextStyle(
                                                        fontFamily: 'Cairo',
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );

                                          if (confirmed == true && context.mounted) {
                                            final message = await orderViewModel.markOrderDelivered(widget.orderId);
                                            if (context.mounted) {
                                              ModernSnackbar.show(
                                                context: context,
                                                message: message ?? 'تم تأكيد التوصيل بنجاح',
                                                type: SnackBarType.success,
                                              );
                                              // Reload order details to update status
                                              await orderViewModel.loadOrderById(widget.orderId);
                                              // Also refresh the orders list when going back
                                              await orderViewModel.loadMyOrders();
                                              
                                              // Show review form after successful delivery confirmation
                                              if (context.mounted) {
                                                await Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) => ReviewFormScreen(
                                                      orderId: widget.orderId,
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          backgroundColor: Colors.green,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text(
                                          'تم التوصيل',
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
      ),
    );
  }
} 