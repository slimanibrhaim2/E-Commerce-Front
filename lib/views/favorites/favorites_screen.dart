import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/favorites_view_model.dart';
import '../../widgets/modern_loader.dart';
import '../products/product_list/widgets/product_card.dart';
import '../../widgets/modern_snackbar.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // Favorites are already loaded in main.dart, no need to load again
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
          actions: [
            Consumer<FavoritesViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.favoriteProducts.isEmpty) return const SizedBox.shrink();
                
                return IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text(
                          'إزالة جميع المفضلة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: const Text(
                          'هل أنت متأكد من إزالة جميع المنتجات من المفضلة؟',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'إلغاء',
                              style: TextStyle(fontFamily: 'Cairo'),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              final result = await viewModel.removeAllFavorites(context);
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
                            child: const Text(
                              'إزالة',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: Consumer<FavoritesViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: ModernLoader());
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
                      onPressed: () => viewModel.loadFavorites(),
                      child: const Text(
                        'إعادة المحاولة',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (viewModel.favoriteProducts.isEmpty) {
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
                  onRefresh: () => viewModel.loadFavorites(),
                  child: GridView.builder(
                    padding: EdgeInsets.all(padding),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      childAspectRatio: aspectRatio,
                      crossAxisSpacing: crossAxisSpacing,
                      mainAxisSpacing: mainAxisSpacing,
                    ),
                    itemCount: viewModel.favoriteProducts.length,
                    itemBuilder: (context, index) {
                      return ProductCard(product: viewModel.favoriteProducts[index]);
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