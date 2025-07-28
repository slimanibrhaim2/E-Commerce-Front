import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/app_colors.dart';
import '../../view_models/cart_view_model.dart';
import '../../view_models/user_view_model.dart';
import '../../widgets/modern_loader.dart';
import '../../widgets/modern_snackbar.dart';
import '../../models/cart_item.dart';
import '../../view_models/order_view_model.dart';
import '../../view_models/address_view_model.dart';
import '../../models/address.dart';
import 'widgets/cart_item_widget.dart';
import 'widgets/address_selection_sheet.dart';
import 'widgets/order_summary_screen.dart';
import '../auth/login_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showLoadMore = false;

  @override
  void initState() {
    super.initState();
    
    // Add scroll listener
    _scrollController.addListener(_onScroll);
    
    // Load cart when screen opens if user is logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userViewModel = context.read<UserViewModel>();
      final cartViewModel = context.read<CartViewModel>();
      if (userViewModel.isLoggedIn) {
        cartViewModel.loadCart();
      } else {
        // Load offline cart if user is not logged in
        cartViewModel.loadOfflineCart();
      }
    });
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

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(
                  Icons.login,
                  color: Colors.blue,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'تسجيل الدخول مطلوب',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: const Text(
              'يجب عليك تسجيل الدخول أولاً لإتمام الطلب',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'إلغاء',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.grey,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'تسجيل الدخول',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildOfflineCartItemWidget(CartItem offlineItem, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Product Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child: offlineItem.imageUrl != null && offlineItem.imageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            context.read<CartViewModel>().apiClient.getMediaUrl(offlineItem.imageUrl!),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[200],
                                ),
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                  size: 30,
                                ),
                              );
                            },
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[200],
                          ),
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 30,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offlineItem.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(offlineItem.price ?? 0).toStringAsFixed(0)} ل.س',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Quantity Controls for offline items
                      Row(
                        children: [
                          SizedBox(
                            width: 28,
                            height: 28,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.remove, size: 18),
                              onPressed: () async {
                                if (offlineItem.quantity > 1) {
                                  await context.read<CartViewModel>().updateOfflineCartItemQuantity(
                                    offlineItem.itemId,
                                    offlineItem.quantity - 1,
                                    context,
                                  );
                                } else {
                                  await context.read<CartViewModel>().removeOfflineCartItem(
                                    offlineItem.itemId,
                                    context,
                                  );
                                }
                              },
                            ),
                          ),
                          Container(
                            width: 32,
                            alignment: Alignment.center,
                            child: Text(
                              '${offlineItem.quantity}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 28,
                            height: 28,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: () async {
                                await context.read<CartViewModel>().updateOfflineCartItemQuantity(
                                  offlineItem.itemId,
                                  offlineItem.quantity + 1,
                                  context,
                                );
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () async {
                              await context.read<CartViewModel>().removeOfflineCartItem(
                                offlineItem.itemId,
                                context,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Offline indicator
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Text(
                'محلي',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10,
                  color: Colors.orange.shade700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'السلة',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Selector2<CartViewModel, UserViewModel, Map<String, dynamic>>(
          selector: (context, cartViewModel, userViewModel) {
            return {
              'cartItems': cartViewModel.cartItems,
              'offlineCartItemsWithDetails': cartViewModel.offlineCartItemsWithDetails,
              'offlineCartItems': cartViewModel.offlineCartItems,
              'isLoggedIn': userViewModel.isLoggedIn,
              'isLoading': cartViewModel.isLoading,
              'error': cartViewModel.error,
              'cartItemsCount': cartViewModel.cartItems.length,
              'offlineCartItemsCount': cartViewModel.offlineCartItems.length,
              'totalItems': cartViewModel.totalItems,
              'totalPrice': cartViewModel.totalPrice,
            };
          },
          builder: (context, data, child) {
            final cartItems = data['cartItems'] as List<CartItem>;
            final offlineCartItemsWithDetails = data['offlineCartItemsWithDetails'] as List<CartItem>;
            final offlineCartItems = data['offlineCartItems'] as List<Map<String, dynamic>>;
            final isLoggedIn = data['isLoggedIn'] as bool;
            final isLoading = data['isLoading'] as bool;
            final error = data['error'] as String?;
            final cartItemsCount = data['cartItemsCount'] as int;
            final offlineCartItemsCount = data['offlineCartItemsCount'] as int;
            final totalItems = data['totalItems'] as int;
            final totalPrice = data['totalPrice'] as double;

            // Show offline indicator if user is not logged in but has offline items
            final hasOfflineItems = offlineCartItemsCount > 0 && !isLoggedIn;
            
            if (!isLoggedIn && totalItems == 0) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'السلة فارغة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'أضف منتجات إلى السلة للبدء',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (isLoading) {
              return const Center(child: ModernLoader());
            }

            if (error != null && isLoggedIn) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      error,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<CartViewModel>().loadCart(),
                      child: const Text(
                        'إعادة المحاولة',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (totalItems == 0) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'السلة فارغة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Show loader if offline cart is not empty but details are not loaded yet
            if (!isLoggedIn && offlineCartItems.isNotEmpty && offlineCartItemsWithDetails.isEmpty) {
              return const Center(child: ModernLoader());
            }

            // Combine online and unique offline items
            final onlineIds = cartItems.map((item) => item.itemId).toSet();
            final uniqueOfflineItems = offlineCartItemsWithDetails
                .where((item) => !onlineIds.contains(item.itemId))
                .toList();
            final allItems = [...cartItems, ...uniqueOfflineItems];

            return Column(
              children: [
                // Offline indicator banner
                if (hasOfflineItems)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.cloud_off,
                          color: Colors.orange.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'المنتجات محفوظة محلياً - سجل الدخول لمزامنتها',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () {
                      final userViewModel = context.read<UserViewModel>();
                      final cartViewModel = context.read<CartViewModel>();
                      if (userViewModel.isLoggedIn) {
                        return cartViewModel.refreshCart();
                      } else {
                        return cartViewModel.loadOfflineCart();
                      }
                    },
                    child: Column(
                      children: [
                        Expanded(
                    child: Selector2<CartViewModel, UserViewModel, Map<String, dynamic>>(
                      selector: (context, cartViewModel, userViewModel) {
                        return {
                          'cartItems': cartViewModel.cartItems,
                          'offlineCartItemsWithDetails': cartViewModel.offlineCartItemsWithDetails,
                          'isLoggedIn': userViewModel.isLoggedIn,
                        };
                      },
                      builder: (context, data, child) {
                        final cartItems = data['cartItems'] as List<CartItem>;
                        final offlineCartItemsWithDetails = data['offlineCartItemsWithDetails'] as List<CartItem>;
                        final isLoggedIn = data['isLoggedIn'] as bool;
                        
                        // Combine online and unique offline items
                        final onlineIds = cartItems.map((item) => item.itemId).toSet();
                        final uniqueOfflineItems = offlineCartItemsWithDetails
                            .where((item) => !onlineIds.contains(item.itemId))
                            .toList();
                        final allItems = [...cartItems, ...uniqueOfflineItems];
                        
                        return ListView.builder(
                                controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: allItems.length,
                          itemBuilder: (context, index) {
                            final item = allItems[index];
                            if (item is CartItem && onlineIds.contains(item.itemId)) {
                              // Online item
                              return CartItemWidget(
                                item: item,
                                index: index,
                              );
                            } else {
                              // Offline item
                              return _buildOfflineCartItemWidget(item, index);
                            }
                          },
                        );
                      },
                          ),
                        ),
                        // Show "Load More" button only when user reaches bottom and has more data
                        if (_showLoadMore && context.read<CartViewModel>().hasMoreData)
                          Container(
                            margin: const EdgeInsets.all(16),
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: context.read<CartViewModel>().isLoadingMore ? null : () async {
                                await context.read<CartViewModel>().loadMoreCartItems();
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
                              child: context.read<CartViewModel>().isLoadingMore
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
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'عدد المنتجات:',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '$totalItems منتج',
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'المجموع الكلي:',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '${totalPrice.toStringAsFixed(0)} ل.س',
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: totalItems > 0 ? () async {
                              // Show address selection modal
                              final addressViewModel = context.read<AddressViewModel>();
                              final userViewModel = context.read<UserViewModel>();
                              if (!userViewModel.isLoggedIn) {
                                _showLoginRequiredDialog(context);
                                return;
                              }
                              await addressViewModel.loadAddresses();
                              Address? selectedAddress = await showModalBottomSheet<Address?>(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                ),
                                builder: (context) {
                                  return AddressSelectionSheet();
                                },
                              );
                              print('Selected address: ${selectedAddress?.toJson()}');
                              if (selectedAddress == null) return;
                              
                              // Call checkout
                              final orderViewModel = context.read<OrderViewModel>();
                              print('Calling checkout with address ID: ${selectedAddress.id}');
                              final message = await orderViewModel.checkout(selectedAddress.id!);
                              print('Checkout message: $message');
                              print('OrderViewModel error: ${orderViewModel.error}');
                              print('OrderViewModel order: ${orderViewModel.order}');
                              
                              if (orderViewModel.error != null) {
                                ModernSnackbar.show(
                                  context: context,
                                  message: orderViewModel.error!,
                                  type: SnackBarType.error,
                                );
                                return;
                              }
                              if (orderViewModel.order != null && context.mounted) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => OrderSummaryScreen(order: orderViewModel.order!),
                                  ),
                                );
                              }
                            } : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: totalItems > 0 ? Colors.blue : Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              totalItems > 0 ? 'إتمام الطلب' : 'السلة فارغة',
                              style: const TextStyle(
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
              ],
            );
          },
        ),
      ),
    );
  }
}



 