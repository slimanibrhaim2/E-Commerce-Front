import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/product.dart';
import '../../../../view_models/cart_view_model.dart';
import '../../../../view_models/product_details_view_model.dart';
import '../../../../view_models/products_view_model.dart';
import '../../../../widgets/modern_loader.dart';
import '../../../../widgets/modern_snackbar.dart';
import '../../product_detail/product_detail_screen.dart';


class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({
    super.key,
    required this.product,
  });

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
                    child: ProductDetailScreen(productId: int.parse(product.id!)),
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
                            Text(
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
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'متوفر',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                      fontFamily: 'Cairo',
                                    ),
                                    textAlign: TextAlign.right,
                                    textDirection: TextDirection.rtl,
                                  ),
                                ),
                                Text(
                                  '${product.price} ل.س',
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
                  child: Consumer<ProductsViewModel>(
                    builder: (context, viewModel, child) {
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            final message = await viewModel.toggleFavorite(int.parse(product.id!), context);
                            if (message != null && context.mounted) {
                              ModernSnackbar.show(
                                context: context,
                                message: message,
                                type: viewModel.error != null ? SnackBarType.error : SnackBarType.success,
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
                              product.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: product.isFavorite ? const Color(0xFFE84393) : Colors.grey,
                              size: 18,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        final message = await context.read<CartViewModel>().addToCart(int.parse(product.id!), 1, context);
                        if (message != null && context.mounted) {
                          ModernSnackbar.show(
                            context: context,
                            message: message,
                            type: context.read<CartViewModel>().error != null ? SnackBarType.error : SnackBarType.success,
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
                          Icons.shopping_cart,
                          color: Colors.black,
                          size: 18,
                        ),
                      ),
                    ),
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