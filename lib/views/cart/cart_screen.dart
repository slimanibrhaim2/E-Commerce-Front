import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    // Load cart when screen opens if user is logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userViewModel = context.read<UserViewModel>();
      if (userViewModel.isLoggedIn) {
        context.read<CartViewModel>().loadCart();
      }
    });
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
              'isLoggedIn': userViewModel.isLoggedIn,
              'isLoading': cartViewModel.isLoading,
              'error': cartViewModel.error,
              'cartItemsCount': cartViewModel.cartItems.length,
              'totalItems': cartViewModel.totalItems,
              'totalPrice': cartViewModel.totalPrice,
            };
          },
          builder: (context, data, child) {
            final isLoggedIn = data['isLoggedIn'] as bool;
            final isLoading = data['isLoading'] as bool;
            final error = data['error'] as String?;
            final cartItemsCount = data['cartItemsCount'] as int;
            final totalItems = data['totalItems'] as int;
            final totalPrice = data['totalPrice'] as double;

            // Check if user is logged in
            if (!isLoggedIn) {
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
                      'يجب تسجيل الدخول لعرض السلة',
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

            if (isLoading) {
              return const Center(child: ModernLoader());
            }

            if (error != null) {
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

            if (cartItemsCount == 0) {
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

            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => context.read<CartViewModel>().loadCart(),
                    child: Selector<CartViewModel, List<CartItem>>(
                      selector: (context, cartViewModel) => cartViewModel.cartItems,
                      builder: (context, cartItems, child) {
                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            final item = cartItems[index];
                            return Selector<CartViewModel, CartItem?>(
                              selector: (context, cartViewModel) {
                                try {
                                  return cartViewModel.cartItems[index];
                                } catch (e) {
                                  return null;
                                }
                              },
                              builder: (context, item, child) {
                                if (item == null) return const SizedBox.shrink();
                                return CartItemWidget(
                                  item: item,
                                  index: index,
                                );
                              },
                            );
                          },
                        );
                      },
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
                            onPressed: cartItemsCount > 0 ? () async {
                              // Show address selection modal
                              final addressViewModel = context.read<AddressViewModel>();
                              final userViewModel = context.read<UserViewModel>();
                              if (!userViewModel.isLoggedIn) {
                                ModernSnackbar.show(
                                  context: context,
                                  message: 'يجب تسجيل الدخول لإتمام الطلب',
                                  type: SnackBarType.error,
                                );
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
                              backgroundColor: cartItemsCount > 0 ? Colors.blue : Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              cartItemsCount > 0 ? 'إتمام الطلب' : 'السلة فارغة',
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



 