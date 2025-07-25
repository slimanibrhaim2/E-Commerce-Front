import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/order_view_model.dart';
import '../../view_models/cart_view_model.dart';
import '../../view_models/address_view_model.dart';
import '../../view_models/payment_view_model.dart';
import '../../models/address.dart';
import '../../widgets/modern_loader.dart';
import '../../widgets/modern_snackbar.dart';
import '../../widgets/order_status_flow.dart';
import '../reviews/review_form_screen.dart';
import '../address/view_address_on_map_screen.dart';
import '../cart/widgets/payment_method_selection_sheet.dart';

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
  Address? _deliveryAddress;
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    // Load order details when the view is created
    Future.microtask(() => 
      context.read<OrderViewModel>().loadOrderById(widget.orderId)
    );
  }

  Future<void> _loadDeliveryAddress(String addressId) async {
    if (_deliveryAddress != null) return; // Already loaded
    
    setState(() {
      _isLoadingAddress = true;
    });

    try {
      final addressViewModel = context.read<AddressViewModel>();
      final address = await addressViewModel.fetchAddressById(addressId);
      
      if (mounted) {
        setState(() {
          _deliveryAddress = address;
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingAddress = false;
        });
      }
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
                            // Order Status Flow
                            OrderStatusFlow(
                              currentStatus: orderViewModel.selectedOrder!.orderStatus ?? 'قيد الانتظار',
                              isCancelled: orderViewModel.selectedOrder!.orderStatus == 'ملغي',
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('المبلغ الكلي:', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                                Text('${(orderViewModel.selectedOrder!.totalAmount ?? 0).toStringAsFixed(0)} ل.س', style: TextStyle(fontFamily: 'Cairo', color: Colors.green)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Load address details if we have an address ID
                            if (orderViewModel.selectedOrder!.addressId != null && orderViewModel.selectedOrder!.addressId!.isNotEmpty)
                              FutureBuilder<void>(
                                future: _loadDeliveryAddress(orderViewModel.selectedOrder!.addressId!),
                                builder: (context, snapshot) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text('عنوان التوصيل: ', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                                          if (_isLoadingAddress)
                                            const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          else if (_deliveryAddress != null)
                                            Expanded(
                                              child: GestureDetector(
                                                                                                 onTap: () {
                                                   if (_deliveryAddress!.latitude != null && _deliveryAddress!.longitude != null) {
                                                     Navigator.of(context).push(
                                                       MaterialPageRoute(
                                                         builder: (context) => ViewAddressOnMapScreen(
                                                           latitude: _deliveryAddress!.latitude!,
                                                           longitude: _deliveryAddress!.longitude!,
                                                           name: _deliveryAddress!.name,
                                                         ),
                                                       ),
                                                     );
                                                   }
                                                 },
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue.shade50,
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: Colors.blue.shade200),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.location_on,
                                                        color: Colors.blue.shade600,
                                                        size: 20,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                          _deliveryAddress!.name ?? 'عنوان التوصيل',
                                                          style: TextStyle(
                                                            fontFamily: 'Cairo',
                                                            color: Colors.blue.shade700,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                      Icon(
                                                        Icons.map,
                                                        color: Colors.blue.shade600,
                                                        size: 16,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          else
                                            Text(
                                              'خطأ في تحميل العنوان',
                                              style: TextStyle(
                                                fontFamily: 'Cairo',
                                                color: Colors.red.shade600,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                        ],
                                      ),
                                      if (_deliveryAddress != null) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          'اضغط على العنوان لرؤيته على الخريطة',
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ],
                                  );
                                },
                              )
                            else
                              Text('عنوان التوصيل: غير محدد', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.grey)),
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
                            // Show payment and cancel buttons for pending orders
                            if (orderViewModel.selectedOrder!.orderStatus == 'قيد الانتظار') ...[
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.orange.shade200),
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      'الطلب في انتظار الدفع',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'يمكنك إتمام الدفع أو إلغاء الطلب',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 14,
                                        color: Colors.orange,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
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
                                              if (selectedMethod != null && context.mounted) {
                                                // Process payment
                                                final message = await paymentViewModel.processPayment(
                                                  orderId: widget.orderId,
                                                  amount: orderViewModel.selectedOrder!.totalAmount ?? 0,
                                                  paymentMethodId: selectedMethod.id!,
                                                  paymentDetails: null,
                                                );
                                                if (context.mounted) {
                                                  ModernSnackbar.show(
                                                    context: context,
                                                    message: message ?? 'تم معالجة الدفع بنجاح',
                                                    type: SnackBarType.success,
                                                  );
                                                  // Reload order details to update status
                                                  await orderViewModel.loadOrderById(widget.orderId);
                                                  // Also refresh the orders list when going back
                                                  await orderViewModel.loadMyOrders();
                                                }
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              backgroundColor: Colors.green,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text(
                                              'إتمام الدفع',
                                              style: TextStyle(
                                                fontFamily: 'Cairo',
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              // Show confirmation dialog
                                              final confirmed = await showDialog<bool>(
                                                context: context,
                                                builder: (context) => Directionality(
                                                  textDirection: TextDirection.rtl,
                                                  child: AlertDialog(
                                                    title: const Text(
                                                      'تأكيد الإلغاء',
                                                      style: TextStyle(
                                                        fontFamily: 'Cairo',
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    content: const Text(
                                                      'هل أنت متأكد من إلغاء هذا الطلب؟',
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
                                                          backgroundColor: Colors.red,
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
                                                final message = await orderViewModel.cancelOrder(widget.orderId);
                                                if (context.mounted) {
                                                  ModernSnackbar.show(
                                                    context: context,
                                                    message: message ?? 'تم إلغاء الطلب بنجاح',
                                                    type: SnackBarType.success,
                                                  );
                                                  // Reload order details to update status
                                                  await orderViewModel.loadOrderById(widget.orderId);
                                                  // Also refresh the orders list when going back
                                                  await orderViewModel.loadMyOrders();
                                                }
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              backgroundColor: Colors.red,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text(
                                              'إلغاء الطلب',
                                              style: TextStyle(
                                                fontFamily: 'Cairo',
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
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