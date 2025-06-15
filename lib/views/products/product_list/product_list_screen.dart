import 'package:e_commerce/views/products/product_list/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/products_view_model.dart';
import '../../cart/cart_screen.dart';
import '../../favorites/favorites_screen.dart';
import '../../../models/category.dart';

class ProductListScreen extends StatefulWidget {
  final Category? category;

  const ProductListScreen({
    super.key,
    this.category,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  @override
  void initState() {
    super.initState();
    // Load products when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsViewModel>().loadProducts(
            category: widget.category?.name,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.category?.name ?? 'المنتجات',
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
                        builder: (context) => const FavoritesScreen(),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CartScreen(),
                      ),
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
                      onPressed: () => viewModel.loadProducts(
                        category: widget.category?.name,
                      ),
                      child: const Text(
                        'إعادة المحاولة',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (viewModel.products.isEmpty) {
              return Center(
                child: Text(
                  widget.category != null
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
                  onRefresh: () => viewModel.loadProducts(
                    category: widget.category?.name,
                  ),
                  child: GridView.builder(
                    padding: EdgeInsets.all(padding),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      childAspectRatio: aspectRatio,
                      crossAxisSpacing: crossAxisSpacing,
                      mainAxisSpacing: mainAxisSpacing,
                    ),
                    itemCount: viewModel.products.length,
                    itemBuilder: (context, index) {
                      return ProductCard(product: viewModel.products[index]);
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
