import 'package:e_commerce/views/products/product_list/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/products_view_model.dart';
import '../../cart/cart_screen.dart';
import '../../favorites/favorites_screen.dart';
import '../../../models/category.dart';
import '../../../widgets/modern_loader.dart';

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
  final ScrollController _scrollController = ScrollController();
  bool _showLoadMore = false;

  @override
  void initState() {
    super.initState();
    
    // Add scroll listener
    _scrollController.addListener(_onScroll);
    
    // Load products when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsViewModel>().loadProducts(
            category: widget.category?.id,
          );
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
            if (viewModel.isLoading && viewModel.products.isEmpty) {
              return const Center(
                child: ModernLoader(),
              );
            }

            if (viewModel.error != null && viewModel.products.isEmpty) {
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
                        category: widget.category?.id,
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

            final crossAxisCount = (MediaQuery.of(context).size.width / 200).floor();
            final columns = crossAxisCount < 2 ? 2 : crossAxisCount;
            final aspectRatio = 0.75;
            final crossAxisSpacing = 16.0;
            final mainAxisSpacing = 16.0;
            final padding = 16.0;

            return RefreshIndicator(
              onRefresh: () => viewModel.refreshProducts(),
              child: Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(padding),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        childAspectRatio: aspectRatio,
                        crossAxisSpacing: crossAxisSpacing,
                        mainAxisSpacing: mainAxisSpacing,
                      ),
                      itemCount: viewModel.products.length,
                      itemBuilder: (context, index) {
                        return ProductCard(
                          product: viewModel.products[index],
                          apiClient: viewModel.apiClient,
                        );
                      },
                    ),
                  ),
                  // Show "Load More" button only when user reaches bottom and has more data
                  if (_showLoadMore && viewModel.hasMoreData)
                    Container(
                      margin: const EdgeInsets.all(16),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: viewModel.isLoadingMore ? null : () async {
                          await viewModel.loadMoreProducts();
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
                        child: viewModel.isLoadingMore
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
            );
          },
        ),
      ),
    );
  }
}
