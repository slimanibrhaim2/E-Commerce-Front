import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/product.dart';
import '../../../../view_models/cart_view_model.dart';
import '../../../../view_models/product_details_view_model.dart';
import '../../../../view_models/products_view_model.dart';
import '../../../../widgets/modern_loader.dart';
import '../../../../widgets/modern_snackbar.dart';
import '../../product_detail/product_detail_screen.dart';
import '../../../../view_models/user_view_model.dart';
import '../../../../view_models/favorites_view_model.dart';


class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({
    super.key,
    required this.product,
  });

  String _formatPrice(double price) {
    String priceString = price.toStringAsFixed(0);
    if (priceString.length > 7) {
      priceString = '${priceString.substring(0, 7)}...';
    }
    return '$priceString ل.س';
  }

  Widget _buildStockInfo(BuildContext context) {
    final textStyle = const TextStyle(fontSize: 10, fontFamily: 'Cairo', fontWeight: FontWeight.bold);
    
    if (!product.isAvailable || product.stockQuantity <= 0) {
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

    final String stockText = product.stockQuantity > 20 
      ? 'متوفر +20' 
      : 'متوفر ${product.stockQuantity}';

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
        final imageHeight = cardWidth * 0.7; // Reduced to 70% for better proportions

        final crossAxisCount = (constraints.maxWidth / 200).floor();
        final columns = crossAxisCount < 2 ? 2 : crossAxisCount;

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
                    ),
                    child: ProductDetailScreen(productId: product.id!),
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
                            child: product.media.isNotEmpty
                                ? ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: Image.network(
                                product.media.first.url,
                                height: imageHeight,
                                width: double.infinity,
                                fit: BoxFit.cover,
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
                                    product.name,
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
                                _buildStockInfo(context),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              product.description,
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
                                    final result = await context.read<CartViewModel>().addItemToCart(product.id!, 1, context);
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
                                  _formatPrice(product.price),
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
                // Favorite Button
                Positioned(
                  top: 8,
                  left: 8,
                  child: Consumer<FavoritesViewModel>(
                    builder: (context, favoritesViewModel, child) {
                      final isFavorite = favoritesViewModel.isFavorite(product.id!);
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            Map<String, dynamic> result;
                            if (isFavorite) {
                              result = await favoritesViewModel.removeFromFavorites(product.id!, context);
                            } else {
                              result = await favoritesViewModel.addToFavorites(product.id!, context);
                            }
                            
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
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? const Color(0xFFE84393) : Colors.grey,
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