import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/order.dart';
import '../../../view_models/cart_view_model.dart';
import '../../../view_models/order_view_model.dart';
import '../../../view_models/payment_view_model.dart';
import '../../../widgets/modern_snackbar.dart';
import 'payment_method_selection_sheet.dart';

class OrderSummaryScreen extends StatelessWidget {
  final Order order;
  const OrderSummaryScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ملخص الطلب', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('الحالة:', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                  Text(order.orderStatus ?? '', style: TextStyle(fontFamily: 'Cairo', color: Colors.blue)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('المبلغ الكلي:', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                  Text('${(order.totalAmount ?? 0).toStringAsFixed(0)} ل.س', style: TextStyle(fontFamily: 'Cairo', color: Colors.green)),
                ],
              ),
              const SizedBox(height: 12),
              Text('العناصر:', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: order.items.length,
                  itemBuilder: (context, index) {
                    final item = order.items[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: Image.network(
                          context.read<CartViewModel>().apiClient.getMediaUrl(item.imageUrl ?? ''),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
                        ),
                        title: Text(
                          item.name ?? '',
                          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                        ),
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
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final paymentViewModel = context.read<PaymentViewModel>();
                    await paymentViewModel.loadPaymentMethods();
                    final selectedMethod = await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (context) {
                        return const PaymentMethodSelectionSheet();
                      },
                    );
                    if (selectedMethod != null) {
                      // Process payment
                      final message = await paymentViewModel.processPayment(
                        orderId: order.id!,
                        amount: order.totalAmount ?? 0,
                        paymentMethodId: selectedMethod.id!,
                        paymentDetails: null,
                      );
                      if (context.mounted) {
                        ModernSnackbar.show(
                          context: context,
                          message: message ?? 'تم معالجة الدفع بنجاح',
                          type: SnackBarType.success,
                        );
                        // Clear cart after successful payment
                        context.read<CartViewModel>().clearCart();
                        Navigator.of(context).pop(); // Close order summary
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
                    'اختيار طريقة الدفع',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Show delivery confirmation button only if order status is "تم الدفع"
              if (order.orderStatus == 'تم الدفع') ...[
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
                              final orderViewModel = context.read<OrderViewModel>();
                              final message = await orderViewModel.markOrderDelivered(order.id!);
                              if (context.mounted) {
                                ModernSnackbar.show(
                                  context: context,
                                  message: message ?? 'تم تأكيد التوصيل بنجاح',
                                  type: SnackBarType.success,
                                );
                                // Refresh the order to update its status
                                await orderViewModel.refreshCurrentOrder(order.id!);
                                if (context.mounted) {
                                  Navigator.of(context).pop(); // Close order summary
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
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final orderViewModel = context.read<OrderViewModel>();
                    final message = await orderViewModel.cancelOrder(order.id!);
                    if (context.mounted) {
                      ModernSnackbar.show(
                        context: context,
                        message: message ?? 'تم إلغاء الطلب بنجاح',
                        type: SnackBarType.success,
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'إلغاء الطلب',
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
      ),
    );
  }
} 