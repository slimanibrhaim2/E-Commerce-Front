import 'package:e_commerce/views/home/widgets/search_and_favorite_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/products_view_model.dart';
import '../products/product_list/product_list_screen.dart';
import '../products/product_list/widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load products when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsViewModel>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Search and Favorite Bar
              SearchAndFavoriteBar(
                favoriteCount: 0,
                onSearch: (query) {
                  print('Searching for: $query');
                },
                onFavoriteTap: () {
                  print('Favorite tapped');
                },
              ),
              // Products Section
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Suggested Products Section
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'منتجات مقترحة',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
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
                                      const Text(
                                        'عرض الكل',
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.arrow_forward_ios),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Consumer<ProductsViewModel>(
                              builder: (context, viewModel, child) {
                                if (viewModel.isLoading) {
                                  return const SizedBox(
                                    height: 260,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                if (viewModel.error != null) {
                                  return SizedBox(
                                    height: 260,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'حدث خطأ: ${viewModel.error}',
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontFamily: 'Cairo',
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          ElevatedButton(
                                            onPressed: () {
                                              viewModel.loadProducts();
                                            },
                                            child: const Text(
                                              'إعادة المحاولة',
                                              style: TextStyle(fontFamily: 'Cairo'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                final products = viewModel.products;
                                return SizedBox(
                                  height: 260,
                                  child: products.isEmpty
                                      ? const Center(
                                          child: Text(
                                            'لا توجد منتجات متاحة',
                                            style: TextStyle(fontFamily: 'Cairo'),
                                          ),
                                        )
                                      : ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: products.length > 8 ? 8 : products.length,
                                          separatorBuilder: (context, index) => const SizedBox(width: 12),
                                          itemBuilder: (context, index) {
                                            return SizedBox(
                                              width: 180,
                                              child: ProductCard(product: products[index]),
                                            );
                                          },
                                        ),
                                );
                              },
                            ),
                          ],
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
    );
  }
}