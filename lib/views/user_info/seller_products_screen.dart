import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/products_view_model.dart';
import '../../widgets/modern_loader.dart';
import '../products/product_list/widgets/product_card.dart';

class SellerProductsScreen extends StatefulWidget {
  final String sellerId;
  final String sellerName;

  const SellerProductsScreen({
    super.key,
    required this.sellerId,
    required this.sellerName,
  });

  @override
  State<SellerProductsScreen> createState() => _SellerProductsScreenState();
}

class _SellerProductsScreenState extends State<SellerProductsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showLoadMore = false;

  @override
  void initState() {
    super.initState();
    
    // Add scroll listener
    _scrollController.addListener(_onScroll);
    
    // Load seller products when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsViewModel>().loadSellerProducts(widget.sellerId);
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
            'منتجات ${widget.sellerName}',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Consumer<ProductsViewModel>(
          builder: (context, productsViewModel, child) {
            final products = productsViewModel.sellerProducts;
            
            if (productsViewModel.isLoadingSellerProducts && products.isEmpty) {
              return const Center(child: ModernLoader());
            }

            if (productsViewModel.error != null && products.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      productsViewModel.error!,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        productsViewModel.loadSellerProducts(widget.sellerId);
                      },
                      child: const Text(
                        'إعادة المحاولة',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (products.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'لا توجد منتجات لهذا البائع',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'البائع لم ينشر أي منتجات بعد',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Products count
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[50],
                  child: Text(
                    '${products.length} منتج',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                // Products grid
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await productsViewModel.loadSellerProducts(widget.sellerId);
                    },
                    child: GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return ProductCard(
                          product: products[index],
                          apiClient: context.read<ProductsViewModel>().apiClient,
                        );
                      },
                    ),
                  ),
                ),
                
                // Load More Button
                if (_showLoadMore && productsViewModel.hasMoreSellerProducts)
                  Container(
                    margin: const EdgeInsets.all(16),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: productsViewModel.isLoadingMoreSellerProducts ? null : () async {
                        await productsViewModel.loadMoreSellerProducts(widget.sellerId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: productsViewModel.isLoadingMoreSellerProducts
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'تحميل المزيد',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
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