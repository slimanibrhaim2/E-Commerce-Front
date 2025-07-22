import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/favorites_view_model.dart';
import '../../view_models/user_view_model.dart';
import '../../widgets/modern_loader.dart';
import '../../widgets/modern_snackbar.dart';
import '../../models/favorite.dart';
import '../../models/product.dart';
import '../products/product_detail/product_detail_screen.dart';
import '../../view_models/product_details_view_model.dart';
import '../../view_models/products_view_model.dart';
import '../../view_models/cart_view_model.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showLoadMore = false;

  @override
  void initState() {
    super.initState();
    
    // Add scroll listener
    _scrollController.addListener(_onScroll);
    
    // Load favorites when screen opens (both online and offline)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userViewModel = context.read<UserViewModel>();
      final favoritesViewModel = context.read<FavoritesViewModel>();
      if (userViewModel.isLoggedIn) {
        favoritesViewModel.loadFavorites();
      } else {
        // Load offline favorites if user is not logged in
        favoritesViewModel.loadOfflineFavorites();
      }
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
          title: const Text(
            'المفضلة',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Selector2<FavoritesViewModel, UserViewModel, Map<String, dynamic>>(
          selector: (context, favoritesViewModel, userViewModel) {
            return {
              'isLoggedIn': userViewModel.isLoggedIn,
              'isLoading': favoritesViewModel.isLoading,
              'error': favoritesViewModel.error,
              'favoritesCount': favoritesViewModel.favoritesCount,
              'offlineFavoritesCount': favoritesViewModel.offlineFavorites.length,
            };
          },
          builder: (context, data, child) {
            final isLoggedIn = data['isLoggedIn'] as bool;
            final isLoading = data['isLoading'] as bool;
            final error = data['error'] as String?;
            final favoritesCount = data['favoritesCount'] as int;
            final offlineFavoritesCount = data['offlineFavoritesCount'] as int;
            
            // Show offline indicator if user is not logged in but has offline items
            final hasOfflineItems = offlineFavoritesCount > 0 && !isLoggedIn;
            
            if (!isLoggedIn && favoritesCount == 0) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'لا توجد منتجات في المفضلة',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                        fontSize: 16,
                        color: Colors.grey,
                            ),
                          ),
                    const SizedBox(height: 8),
                    const Text(
                      'أضف منتجات إلى المفضلة للبدء',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
            }

            if (isLoading) {
              return const Center(child: ModernLoader());
            }

            if (error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      error,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<FavoritesViewModel>().loadFavorites(),
                      child: const Text(
                        'إعادة المحاولة',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (favoritesCount == 0) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'لا توجد منتجات في المفضلة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Offline indicator banner
                if (hasOfflineItems)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.cloud_off,
                          color: Colors.orange.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'المنتجات محفوظة محلياً - سجل الدخول لمزامنتها',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = (constraints.maxWidth / 200).floor();
                final columns = crossAxisCount < 2 ? 2 : crossAxisCount;
                final aspectRatio = 0.75;
                final crossAxisSpacing = 16.0;
                final mainAxisSpacing = 16.0;
                final padding = 16.0;

                return RefreshIndicator(
                  onRefresh: () => context.read<FavoritesViewModel>().refreshFavorites(),
                  child: Column(
                    children: [
                      Expanded(
                        child: Selector<FavoritesViewModel, List<Favorite>>(
                          selector: (context, favoritesViewModel) => favoritesViewModel.favorites,
                          builder: (context, favorites, child) {
                            // Combine online favorites and offline favorites
                            final allFavorites = <Widget>[];
                            
                            // Add online favorites
                            for (final favorite in favorites) {
                              allFavorites.add(FavoriteCard(favorite: favorite));
                            }
                            
                            // Offline favorites are now loaded as proper Favorite objects with product data
                            // No need to build separate offline cards
                            
                            return GridView.builder(
                              controller: _scrollController,
                              padding: EdgeInsets.all(padding),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                childAspectRatio: aspectRatio,
                                crossAxisSpacing: crossAxisSpacing,
                                mainAxisSpacing: mainAxisSpacing,
                              ),
                              itemCount: allFavorites.length,
                              itemBuilder: (context, index) {
                                return allFavorites[index];
                              },
                            );
                          },
                        ),
                      ),
                      // Show "Load More" button only when user reaches bottom and has more data
                      if (_showLoadMore && context.read<FavoritesViewModel>().hasMoreData)
                        Container(
                          margin: const EdgeInsets.all(16),
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: context.read<FavoritesViewModel>().isLoadingMore ? null : () async {
                              await context.read<FavoritesViewModel>().loadMoreFavorites();
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
                            child: context.read<FavoritesViewModel>().isLoadingMore
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
              ],
            );
          },
        ),
      ),
    );
  }


}

class FavoriteCard extends StatelessWidget {
  final Favorite favorite;

  const FavoriteCard({
    super.key,
    required this.favorite,
  });

  String _formatPrice(double price) {
    String priceString = price.toStringAsFixed(0);
    if (priceString.length > 7) {
      priceString = '${priceString.substring(0, 7)}...';
    }
    return '$priceString ل.س';
  }

  Widget _buildStockInfo(BuildContext context, Favorite favorite) {
    final textStyle = const TextStyle(fontSize: 10, fontFamily: 'Cairo', fontWeight: FontWeight.bold);
    
    // Use the quantity from the favorite, not from the product
    final quantity = favorite.quantity;
    
    if (quantity <= 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'نفذت الكمية',
          style: textStyle.copyWith(color: Colors.red),
        ),
      );
    }

    final String stockText = quantity > 20 
      ? 'متوفر +20' 
      : 'متوفر $quantity';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        stockText,
        style: textStyle.copyWith(color: Colors.green),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final imageHeight = cardWidth * 0.7;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider(
                    create: (context) => ProductDetailsViewModel(
                      context.read<ProductsViewModel>().repository,
                      context.read<ProductsViewModel>().apiClient,
                    ),
                    child: ProductDetailScreen(productId: favorite.itemId), // Use itemId here
                  ),
                ),
              );
            },
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Stack(
                        children: [
                          Container(
                            height: imageHeight,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            child: favorite.baseItem.media.isNotEmpty
                                ? ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: Image.network(
                                context.read<FavoritesViewModel>().apiClient.getMediaUrl(favorite.baseItem.media.first.url),
                                height: imageHeight,
                                width: double.infinity,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: imageHeight,
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                      size: 40,
                                    ),
                                  );
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    height: imageHeight,
                                    color: Colors.grey[200],
                                    child: const ModernLoader(),
                                  );
                                },
                              ),
                            )
                                : Container(
                              height: imageHeight,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                                size: 40,
                              ),
                            ),
                          ),
                          // Gradient overlay
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.4),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Product Details
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    favorite.baseItem.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Cairo',
                                      color: Color(0xFF2D3436),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.right,
                                    textDirection: TextDirection.rtl,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildStockInfo(context, favorite),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              favorite.baseItem.description,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[700],
                                fontFamily: 'Cairo',
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    final result = await context.read<CartViewModel>().addItemToCart(favorite.itemId, 1, context);
                                    final message = result['message'] as String?;
                                    final success = result['success'] as bool? ?? false;
                                    final isOffline = result['offline'] as bool? ?? false;
                                    
                                    if (message != null && context.mounted) {
                                      ModernSnackbar.show(
                                        context: context,
                                        message: message,
                                        type: success ? SnackBarType.success : SnackBarType.error,
                                      );
                                    }
                                  },
                                  child: const Icon(
                                    Icons.add_shopping_cart,
                                    color: Colors.grey,
                                    size: 22,
                                  ),
                                ),
                                Text(
                                  _formatPrice(favorite.baseItem.price),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontFamily: 'Cairo',
                                  ),
                                  textAlign: TextAlign.right,
                                  textDirection: TextDirection.rtl,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Remove from Favorites Button and Offline Indicator
                Consumer<FavoritesViewModel>(
                  builder: (context, favoritesViewModel, child) {
                    return Stack(
                      children: [
                // Remove from Favorites Button
                Positioned(
                  top: 8,
                  left: 8,
                          child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            final result = await favoritesViewModel.removeFromFavorites(favorite.itemId, context);
                            
                            final message = result['message'] as String?;
                            final success = result['success'] as bool? ?? false;
                            
                            if (message != null && context.mounted) {
                              ModernSnackbar.show(
                                context: context,
                                message: message,
                                type: success ? SnackBarType.success : SnackBarType.error,
                              );
                            }
                          },
                          customBorder: const CircleBorder(),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.favorite,
                              color: Color(0xFFE84393),
                              size: 18,
                            ),
                          ),
                        ),
                          ),
                        ),
                        // Offline indicator for offline favorites
                        if (favoritesViewModel.offlineFavorites.contains(favorite.itemId))
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.orange.shade200),
                              ),
                              child: Text(
                                'محلي',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 10,
                                  color: Colors.orange.shade700,
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
          ),
        );
      },
    );
  }
} 