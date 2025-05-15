import 'package:flutter/material.dart';
import 'cart/cart_view.dart';
import 'products/products_view.dart';
import 'package:provider/provider.dart';
import '../view_models/products_view_model.dart';
import 'products/widgets/product_card.dart';
import 'home/home_view.dart';

class MainNavigationPage extends StatefulWidget {
  static final GlobalKey<_MainNavigationPageState> globalKey = GlobalKey<_MainNavigationPageState>();
  MainNavigationPage({Key? key}) : super(key: globalKey);

  static void setTab(int index) {
    globalKey.currentState?._setTab(index);
  }

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  void _setTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final List<Widget> _pages = [
    const AccountPage(),
    const CartView(),
    const CategoriesPage(),
    const HomeView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'حسابي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'السلة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'التصنيفات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'المنتجات',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

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
                            builder: (context) => const ProductsView(),
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
                              child: ProductCard(product: products[index]),
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
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'التصنيفات',
        style: TextStyle(fontSize: 24, fontFamily: 'Cairo'),
      ),
    );
  }
}

class AccountPage extends StatelessWidget {
  const AccountPage({Key? key}) : super(key: key);

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