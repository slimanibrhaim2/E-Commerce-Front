import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/user_view_model.dart';
import '../../view_models/order_view_model.dart';
import '../../widgets/modern_loader.dart';
import '../../models/order.dart';
import 'order_detail_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  bool _didFetch = false;
  final ScrollController _scrollController = ScrollController();
  bool _showLoadMore = false;

  @override
  void initState() {
    super.initState();
    
    // Add scroll listener
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // Show load more button when user is 200 pixels from bottom
      if (!_showLoadMore) {
        setState(() {
          _showLoadMore = true;
        });
      }
    } else {
      // Hide load more button when user scrolls up
      if (_showLoadMore) {
        setState(() {
          _showLoadMore = false;
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userViewModel = context.watch<UserViewModel>();
    final isLoggedIn = userViewModel.isLoggedIn;
    final orderViewModel = context.read<OrderViewModel>();
    if (!_didFetch && isLoggedIn) {
      _didFetch = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        orderViewModel.loadMyOrders();
      });
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
            ? orderViewModel.isLoadingOrders && orderViewModel.myOrders.isEmpty
                ? const Center(child: ModernLoader())
                : orderViewModel.ordersError != null && orderViewModel.myOrders.isEmpty
                    ? Center(child: Text(orderViewModel.ordersError!, style: const TextStyle(fontFamily: 'Cairo', color: Colors.red)))
                    : orderViewModel.myOrders.isEmpty
                        ? const Center(child: Text('لا يوجد طلبات بعد', style: TextStyle(fontFamily: 'Cairo')))
                        : RefreshIndicator(
                            onRefresh: () => orderViewModel.refreshOrders(),
                            child: Column(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    padding: const EdgeInsets.all(16),
                                    itemCount: orderViewModel.myOrders.length,
                                    itemBuilder: (context, index) {
                                      final order = orderViewModel.myOrders[index];
                                      return Card(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        child: ListTile(
                                          title: Text('#${order.id}', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('الحالة: ${order.orderStatus ?? ''}', style: const TextStyle(fontFamily: 'Cairo')),
                                              Text('تاريخ الإنشاء: ${order.createdAt != null ? order.createdAt!.toLocal().toString().split(".")[0] : ''}', style: const TextStyle(fontFamily: 'Cairo')),
                                              Text('المبلغ الكلي: ${(order.totalAmount ?? 0).toStringAsFixed(0)} ل.س', style: const TextStyle(fontFamily: 'Cairo', color: Colors.green)),
                                            ],
                                          ),
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) => OrderDetailScreen(orderId: order.id!),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                // Show "Load More" button only when user reaches bottom and has more data
                                if (_showLoadMore && orderViewModel.hasMoreData)
                                  Container(
                                    margin: const EdgeInsets.all(16),
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: orderViewModel.isLoadingMore ? null : () async {
                                        await orderViewModel.loadMoreOrders();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF7C3AED),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        elevation: 4,
                                        shadowColor: const Color(0xFF7C3AED).withOpacity(0.3),
                                      ),
                                      child: orderViewModel.isLoadingMore
                                          ? const SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.keyboard_arrow_down,
                                                  size: 24,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(width: 8),
                                                const Text(
                                                  'تحميل المزيد',
                                                  style: TextStyle(
                                                    fontFamily: 'Cairo',
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                              ],
                            ),
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