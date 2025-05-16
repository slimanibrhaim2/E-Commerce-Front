import 'package:e_commerce/views/home/widgets/search_and_favorite_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/products_view_model.dart';
import '../products/product_list/product_list_screen.dart';
import '../products/product_list/widgets/product_card.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

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
                favoriteCount: 0, // You can connect this to your favorites state
                onSearch: (query) {
                  // Implement search functionality
                  print('Searching for: $query');
                },
                onFavoriteTap: () {
                  // Implement favorite tap functionality
                  print('Favorite tapped');
                },
              ),
              // Products Section
              Expanded(
                child: Consumer<ProductsViewModel>(
                  builder: (context, viewModel, child) {
                    final products = viewModel.products;
                    return Padding(
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
                                      builder: (context) => const ProductsView(),
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
                          SizedBox(
                            height: 260,
                            child: products.isEmpty
                                ? const Center(child: Text('لا توجد منتجات متاحة'))
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
                          ),
                        ],
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