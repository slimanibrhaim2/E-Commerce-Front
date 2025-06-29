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
  @override
  void initState() {
    super.initState();
    // Load favorites when screen opens if user is logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userViewModel = context.read<UserViewModel>();
      if (userViewModel.isLoggedIn) {
        context.read<FavoritesViewModel>().loadFavorites();
      }
    });
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
              'favoritesCount': favoritesViewModel.favorites.length,
            };
          },
          builder: (context, data, child) {
            final isLoggedIn = data['isLoggedIn'] as bool;
            final isLoading = data['isLoading'] as bool;
            final error = data['error'] as String?;
            final favoritesCount = data['favoritesCount'] as int;
            
            // Check if user is logged in
            if (!isLoggedIn) {
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
                      'يجب تسجيل الدخول لعرض المفضلة',
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

            return LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = (constraints.maxWidth / 200).floor();
                final columns = crossAxisCount < 2 ? 2 : crossAxisCount;
                final aspectRatio = 0.75;
                final crossAxisSpacing = 16.0;
                final mainAxisSpacing = 16.0;
                final padding = 16.0;

                return RefreshIndicator(
                  onRefresh: () => context.read<FavoritesViewModel>().loadFavorites(),
                  child: Selector<FavoritesViewModel, List<Favorite>>(
                    selector: (context, favoritesViewModel) => favoritesViewModel.favorites,
                    builder: (context, favorites, child) {
                      return GridView.builder(
                        padding: EdgeInsets.all(padding),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          childAspectRatio: aspectRatio,
                          crossAxisSpacing: crossAxisSpacing,
                          mainAxisSpacing: mainAxisSpacing,
                        ),
                        itemCount: favorites.length,
                        itemBuilder: (context, index) {
                          final favorite = favorites[index];
                          return FavoriteCard(favorite: favorite);
                        },
                      );
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
                                    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
                                    if (!userViewModel.isLoggedIn) {
                                      ModernSnackbar.show(
                                        context: context,
                                        message: 'يجب تسجيل الدخول لإضافة منتجات إلى السلة',
                                        type: SnackBarType.error,
                                      );
                                      return;
                                    }
                                    final result = await context.read<CartViewModel>().addItemToCart(favorite.itemId, 1, context); // Use itemId here
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
                // Remove from Favorites Button
                Positioned(
                  top: 8,
                  left: 8,
                  child: Consumer<FavoritesViewModel>(
                    builder: (context, favoritesViewModel, child) {
                      return Material(
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