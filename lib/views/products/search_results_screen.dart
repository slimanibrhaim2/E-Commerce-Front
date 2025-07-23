import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/products_view_model.dart';
import '../../widgets/modern_loader.dart';
import '../../widgets/modern_snackbar.dart';
import '../products/product_detail/product_detail_screen.dart';
import '../products/product_list/widgets/product_card.dart';

class SearchResultsScreen extends StatefulWidget {
  final String searchQuery;

  const SearchResultsScreen({
    super.key,
    required this.searchQuery,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showLoadMore = false;

  @override
  void initState() {
    super.initState();
    
    // Add scroll listener
    _scrollController.addListener(_onScroll);
    
    // Perform search when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsViewModel>().searchProducts(widget.searchQuery);
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
            'نتائج البحث: ${widget.searchQuery}',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Consumer<ProductsViewModel>(
          builder: (context, productsViewModel, child) {
            if (productsViewModel.isLoading) {
              return const Center(child: ModernLoader());
            }

            if (productsViewModel.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                      onPressed: () => productsViewModel.searchProducts(widget.searchQuery),
                      child: const Text(
                        'إعادة المحاولة',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (productsViewModel.products.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد نتائج للبحث عن "${widget.searchQuery}"',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'جرب البحث بكلمات مختلفة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Search results header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    border: Border(
                      bottom: BorderSide(color: Colors.blue.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: Colors.blue.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'تم العثور على ${productsViewModel.products.length} منتج',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Products list
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => productsViewModel.searchProducts(widget.searchQuery),
                    child: Column(
                      children: [
                        Expanded(
                    child: GridView.builder(
                            controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: productsViewModel.products.length,
                      itemBuilder: (context, index) {
                        final product = productsViewModel.products[index];
                        return ProductCard(
                          product: product,
                          apiClient: productsViewModel.apiClient,
                        );
                      },
                          ),
                        ),
                        // Show "Load More" button only when user reaches bottom and has more data
                        if (_showLoadMore && productsViewModel.hasMoreData)
                          Container(
                            margin: const EdgeInsets.all(16),
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: productsViewModel.isLoadingMore ? null : () async {
                                await productsViewModel.loadMoreSearchResults();
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
                              child: productsViewModel.isLoadingMore
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
              ],
            );
          },
        ),
      ),
    );
  }
} 