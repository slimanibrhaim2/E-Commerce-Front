import 'package:e_commerce/views/products/product_list/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/cart_view_model.dart';
import '../../../view_models/favorites_view_model.dart';
import '../../../view_models/products_view_model.dart';
import '../../cart/cart_screen.dart';
import '../../favorites/favorites_screen.dart';
import '../../../models/category.dart';

class ProductsView extends StatelessWidget {
  final Category? category;

  const ProductsView({
    Key? key,
    this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
      appBar: AppBar(
        title: Text(
          category?.name ?? 'المنتجات',
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider(
                          create: (context) => FavoritesViewModel(
                            context.read<ProductsViewModel>().repository,
                          ),
                          child: const FavoritesView(),
                        ),
                      ),
                    );
                  },
                ),
                Consumer<CartViewModel>(
                  builder: (context, cart, child) {
                    return Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shopping_cart),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChangeNotifierProvider.value(
                                  value: cart,
                                  child: const CartView(),
                                ),
                              ),
                            );
                          },
                        ),
                        if (cart.itemCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE84393),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${cart.itemCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
          ),
        ],
      ),
      body: Consumer<ProductsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    viewModel.error!,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadProducts(),
                    child: const Text(
                      'إعادة المحاولة',
                      style: TextStyle(fontFamily: 'Cairo'),
                    ),
                  ),
                ],
              ),
            );
          }

          final products = category != null
              ? viewModel.products.where((p) => 
                  p.category.trim().toLowerCase() == category!.name.trim().toLowerCase()
                ).toList()
              : viewModel.products;

          if (products.isEmpty) {
            return Center(
              child: Text(
                category != null
                    ? 'لا توجد منتجات في هذا التصنيف'
                    : 'لا توجد منتجات متاحة',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                ),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = (constraints.maxWidth / 200).floor();
              final columns = crossAxisCount < 2 ? 2 : crossAxisCount;
              final aspectRatio = 0.75;
              final crossAxisSpacing = 16.0;
              final mainAxisSpacing = 16.0;
              final padding = 16.0;

              return RefreshIndicator(
                onRefresh: () => viewModel.loadProducts(),
                child: GridView.builder(
                  padding: EdgeInsets.all(padding),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    childAspectRatio: aspectRatio,
                    crossAxisSpacing: crossAxisSpacing,
                    mainAxisSpacing: mainAxisSpacing,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: products[index]);
                  },
                ),
              );
            },
          );
        },
        ),
      ),
    );
  }
} 