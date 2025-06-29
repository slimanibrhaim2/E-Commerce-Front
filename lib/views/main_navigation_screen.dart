import 'package:e_commerce/views/products/product_list/product_list_screen.dart';
import 'package:e_commerce/views/products/product_list/widgets/product_card.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../view_models/products_view_model.dart';
import 'cart/cart_screen.dart';
import 'home/home_screen.dart';
import 'categories/categories_screen.dart';
import 'profile/profile_screen.dart';
import 'products/add_product/add_product_screen.dart';
import '../view_models/user_view_model.dart';
import '../widgets/modern_snackbar.dart';
import '../view_models/cart_view_model.dart';


class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  const MainNavigationScreen({super.key, this.initialIndex = 4});

  static void setTab(int index) {
    _MainNavigationScreenState.currentIndex = index;
  }

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  static int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  void _setTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text(
              'إضافة جديد',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                color: Colors.pink, // Modern purple
                fontSize: 22,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(thickness: 1, color: Color(0xFFEEEFF1)),
                const SizedBox(height: 12),
                ListTile(
                  leading: Container(
                    decoration: BoxDecoration(
                      color: Colors.pink.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.shopping_bag, color: Colors.pink),
                  ),
                  title: const Text(
                    'إضافة منتج',
                    style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.right,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    final userViewModel = context.read<UserViewModel>();
                    
                    if (userViewModel.isLoggedIn) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddProductScreen(),
                        ),
                      );
                    } else {
                      ModernSnackbar.show(
                        context: context,
                        message: 'الرجاء تسجيل الدخول أولاً للمتابعة',
                        type: SnackBarType.error,
                      );
                      Navigator.of(context).pushNamed('/login');
                    }
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: Container(
                    decoration: BoxDecoration(
                      color: Colors.pink.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.miscellaneous_services, color: Colors.pink),
                  ),
                  title: const Text(
                    'إضافة خدمة',
                    style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.right,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to add service screen
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  final List<Widget> _pages = [
    const ProfileScreen(),    // 0
    const CartScreen(),       // 1
    SizedBox.shrink(),        // 2 (placeholder for add ad)
    const CategoriesScreen(), // 3
    const HomeScreen(),       // 4
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 2) {
            // If 'إضافة إعلان' tab is tapped
            _showAddDialog(context);
          } else {
            setState(() {
              currentIndex = index;
            });
            
            // Refresh cart when cart tab is selected
            if (index == 1) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final cartViewModel = context.read<CartViewModel>();
                cartViewModel.loadCart();
              });
            }
          }
        },
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'حسابي',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                Consumer2<UserViewModel, CartViewModel>(
                  builder: (context, user, cart, child) {
                    if (user.isLoggedIn && cart.totalItems > 0) {
                      return Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${cart.totalItems}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
            label: 'السلة',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'إضافة إعلان',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'التصنيفات',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductsViewModel>(
      builder: (context, viewModel, child) {
        final products = viewModel.products;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProductListScreen(),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_back_ios),
                          const Text(
                            'عرض الكل',
                            style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                        
                        ]
                      ),
                    ),
                    const Text(
                      'منتجات مقترحة',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 260,
                  child: products.isEmpty
                      ? const Center(child: Text('لا توجد منتجات متاحة'))
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          itemCount: products.length > 8 ? 8 : products.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            return SizedBox(
                              width: 180,
                              child: ProductCard(
                                product: products[index],
                                apiClient: viewModel.apiClient,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoriesScreen();
  }
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'حسابي',
        style: TextStyle(fontSize: 24, fontFamily: 'Cairo'),
      ),
    );
  }
} 