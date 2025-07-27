import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/products_view_model.dart';
import '../../widgets/modern_loader.dart';
import 'product_list/widgets/product_card.dart';

class FilterResultsScreen extends StatefulWidget {
  final String? categoryId;
  final double? minPrice;
  final double? maxPrice;

  const FilterResultsScreen({
    super.key,
    this.categoryId,
    this.minPrice,
    this.maxPrice,
  });

  @override
  State<FilterResultsScreen> createState() => _FilterResultsScreenState();
}

class _FilterResultsScreenState extends State<FilterResultsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showLoadMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Load filtered products when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsViewModel>().filterProducts(
        categoryId: widget.categoryId,
        minPrice: widget.minPrice,
        maxPrice: widget.maxPrice,
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
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      if (!_showLoadMore) {
        setState(() {
          _showLoadMore = true;
        });
      }
    } else {
      if (_showLoadMore) {
        setState(() {
          _showLoadMore = false;
        });
      }
    }
  }

  String _buildFilterSummary() {
    List<String> filters = [];
    
    if (widget.categoryId != null) {
      filters.add('تصنيف محدد');
    }
    
    if (widget.minPrice != null && widget.maxPrice != null) {
      filters.add('${widget.minPrice!.toStringAsFixed(0)} - ${widget.maxPrice!.toStringAsFixed(0)} ل.س');
    } else if (widget.minPrice != null) {
      filters.add('من ${widget.minPrice!.toStringAsFixed(0)} ل.س');
    } else if (widget.maxPrice != null) {
      filters.add('حتى ${widget.maxPrice!.toStringAsFixed(0)} ل.س');
    }
    
    return filters.isEmpty ? 'جميع المنتجات' : filters.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'نتائج البحث',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          centerTitle: true,
        ),
        body: Consumer<ProductsViewModel>(
          builder: (context, productsViewModel, child) {
            final products = productsViewModel.filteredProducts;
            final isLoading = productsViewModel.isLoadingFilteredProducts;
            final error = productsViewModel.error;

            if (isLoading && products.isEmpty) {
              return const Center(child: ModernLoader());
            }

            if (error != null && products.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'حدث خطأ أثناء تحميل المنتجات',
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Cairo',
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        productsViewModel.filterProducts(
                          categoryId: widget.categoryId,
                          minPrice: widget.minPrice,
                          maxPrice: widget.maxPrice,
                        );
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

            if (products.isEmpty && !isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.search_off,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'لا توجد منتجات تطابق الفلتر المحدد',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _buildFilterSummary(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Cairo',
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Go back to filter screen
                      },
                      child: const Text(
                        'تعديل الفلتر',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Filter summary header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey.shade100,
                  child: Column(
                    children: [
                      Text(
                        'تم العثور على ${productsViewModel.filteredTotalCount} منتج',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _buildFilterSummary(),
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Products grid
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await productsViewModel.filterProducts(
                        categoryId: widget.categoryId,
                        minPrice: widget.minPrice,
                        maxPrice: widget.maxPrice,
                      );
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
                          apiClient: productsViewModel.apiClient,
                        );
                      },
                    ),
                  ),
                ),

                // Load More Button
                if (_showLoadMore && productsViewModel.hasMoreFilteredData)
                  Container(
                    margin: const EdgeInsets.all(16),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: productsViewModel.isLoadingMoreFilteredProducts 
                          ? null 
                          : () async {
                              await productsViewModel.loadMoreFilteredProducts();
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
                      child: productsViewModel.isLoadingMoreFilteredProducts
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.keyboard_arrow_down),
                                SizedBox(width: 8),
                                Text(
                                  'تحميل المزيد',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
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