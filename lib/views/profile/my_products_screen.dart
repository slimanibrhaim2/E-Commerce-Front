import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/products_view_model.dart';
import '../../view_models/user_view_model.dart';
import '../../view_models/product_details_view_model.dart';
import '../../widgets/modern_loader.dart';
import '../../widgets/modern_snackbar.dart';
import '../products/product_detail/product_detail_screen.dart';
import '../products/add_product/add_product_screen.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  @override
  void initState() {
    super.initState();
    // Load user products when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userViewModel = context.read<UserViewModel>();
      if (userViewModel.isLoggedIn) {
        context.read<ProductsViewModel>().loadMyProducts();
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
            'منتجاتي',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddProductScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: Consumer2<ProductsViewModel, UserViewModel>(
          builder: (context, productsViewModel, userViewModel, child) {
            // Check if user is logged in
            if (!userViewModel.isLoggedIn) {
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
                      'يجب تسجيل الدخول لعرض منتجاتك',
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
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => productsViewModel.loadMyProducts(),
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
                      Icons.shopping_bag_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'لا توجد منتجات لك',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'ابدأ بإضافة منتج جديد',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AddProductScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text(
                        'إضافة منتج',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => productsViewModel.loadMyProducts(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: productsViewModel.products.length,
                itemBuilder: (context, index) {
                  final product = productsViewModel.products[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () async {
                        try {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(
                                productId: product.id!.toString(),
                              ),
                            ),
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ModernSnackbar.show(
                              context: context,
                              message: 'حدث خطأ أثناء الانتقال إلى تفاصيل المنتج: ${e.toString()}',
                              type: SnackBarType.error,
                            );
                          }
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Image
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                color: Colors.grey[200],
                              ),
                              child: product.media.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                      child: Image.network(
                                        productsViewModel.apiClient.getMediaUrl(product.media.first.url),
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
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
                                            color: Colors.grey[200],
                                            child: const ModernLoader(),
                                          );
                                        },
                                      ),
                                    )
                                  : const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                      size: 40,
                                    ),
                            ),
                          ),
                          // Product Details
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Cairo',
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  product.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontFamily: 'Cairo',
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${product.price.toStringAsFixed(0)} ل.س',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: product.isAvailable
                                            ? Colors.green.shade50
                                            : Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: product.isAvailable
                                              ? Colors.green.shade200
                                              : Colors.red.shade200,
                                        ),
                                      ),
                                      child: Text(
                                        product.isAvailable ? 'متوفر' : 'غير متوفر',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: product.isAvailable
                                              ? Colors.green.shade700
                                              : Colors.red.shade700,
                                          fontFamily: 'Cairo',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          print('Navigating to product details with ID: ${product.id}');
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => ChangeNotifierProvider(
                                                create: (context) => ProductDetailsViewModel(
                                                  context.read<ProductsViewModel>().repository,
                                                  context.read<ProductsViewModel>().apiClient,
                                                ),
                                                child: ProductDetailScreen(productId: product.id!),
                                              ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.visibility, size: 16),
                                        label: const Text(
                                          'عرض',
                                          style: TextStyle(fontFamily: 'Cairo'),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () async {
                                          // TODO: Implement edit functionality
                                          ModernSnackbar.show(
                                            context: context,
                                            message: 'سيتم إضافة ميزة التعديل قريباً',
                                            type: SnackBarType.info,
                                          );
                                        },
                                        icon: const Icon(Icons.edit, size: 16),
                                        label: const Text(
                                          'تعديل',
                                          style: TextStyle(fontFamily: 'Cairo'),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () async {
                                          final confirmed = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => Directionality(
                                              textDirection: TextDirection.rtl,
                                              child: AlertDialog(
                                                title: const Text(
                                                  'تأكيد الحذف',
                                                  style: TextStyle(fontFamily: 'Cairo'),
                                                ),
                                                content: Text(
                                                  'هل أنت متأكد من حذف المنتج "${product.name}"؟',
                                                  style: const TextStyle(fontFamily: 'Cairo'),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context, false),
                                                    child: const Text(
                                                      'إلغاء',
                                                      style: TextStyle(fontFamily: 'Cairo'),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context, true),
                                                    child: const Text(
                                                      'حذف',
                                                      style: TextStyle(
                                                        fontFamily: 'Cairo',
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );

                                          if (confirmed == true && context.mounted) {
                                            try {
                                              print('Deleting product with ID: ${product.id}');
                                              final message = await productsViewModel.deleteProduct(product.id!);
                                              if (context.mounted) {
                                                ModernSnackbar.show(
                                                  context: context,
                                                  message: message ?? 'تم حذف المنتج بنجاح',
                                                  type: message?.contains('نجح') == true || message?.contains('تم') == true
                                                      ? SnackBarType.success
                                                      : SnackBarType.error,
                                                );
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ModernSnackbar.show(
                                                  context: context,
                                                  message: 'حدث خطأ أثناء حذف المنتج: ${e.toString()}',
                                                  type: SnackBarType.error,
                                                );
                                              }
                                            }
                                          }
                                        },
                                        icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                                        label: const Text(
                                          'حذف',
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            color: Colors.red,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          side: const BorderSide(color: Colors.red),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
} 