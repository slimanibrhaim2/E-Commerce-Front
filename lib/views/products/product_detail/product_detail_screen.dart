import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_colors.dart';

import '../../../view_models/product_details_view_model.dart';
import '../../../widgets/modern_loader.dart';
import '../../../view_models/cart_view_model.dart';
import '../../../widgets/modern_snackbar.dart';
import '../../../view_models/user_view_model.dart';
import '../../../view_models/favorites_view_model.dart';
import '../../user_info/seller_profile_screen.dart';
import '../../../models/user.dart';
import '../../../widgets/follow_button.dart';
import '../../../widgets/star_rating_widget.dart';
import '../../../view_models/follow_view_model.dart';


class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  bool _isDescriptionExpanded = false;
  User? _seller;
  bool _isLoadingSeller = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Load product details when the view is created
    Future.microtask(() => 
      context.read<ProductDetailsViewModel>().loadProduct(widget.productId)
    );
  }

  Future<void> _loadSellerInfo(String sellerId) async {
    if (_isLoadingSeller) return;
    
    setState(() {
      _isLoadingSeller = true;
    });

    try {
      final userViewModel = context.read<UserViewModel>();
      final seller = await userViewModel.fetchUserById(sellerId);
      
      if (mounted) {
        setState(() {
          _seller = seller;
          _isLoadingSeller = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSeller = false;
        });
      }
    }
  }

    Widget _buildSellerInfoSection(dynamic product) {
    // Load seller info when we have the product
    if (product.userId != null && _seller == null && !_isLoadingSeller) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadSellerInfo(product.userId!);
      });
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.store,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'صاحب الإعلان',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          if (_isLoadingSeller)
            const Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text(
                  'جاري تحميل معلومات البائع...',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.grey,
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                // Seller Profile Row
                Row(
                  children: [
                    // Large Profile Image
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _seller?.profilePhoto != null && _seller!.profilePhoto!.isNotEmpty
                          ? NetworkImage(context.read<UserViewModel>().apiClient.getUserFileUrl(_seller!.profilePhoto!))
                          : null,
                      child: _seller?.profilePhoto == null || _seller!.profilePhoto!.isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 36,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    // Seller Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _seller?.fullName ?? 'البائع',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                              color: Color(0xFF2D3436),
                            ),
                          ),
                          const SizedBox(height: 4),
                                                     // Star Rating using our StarRatingWidget
                           if (_seller?.rating != null) ...[
                             StarRatingWidget(
                               rating: _seller!.rating!,
                               numOfReviews: _seller!.numOfReviews,
                               starSize: 16,
                               fontSize: 12,
                               alignment: MainAxisAlignment.start,
                             ),
                           ] else ...[
                             Text(
                               'عضو',
                               style: TextStyle(
                                 fontSize: 12,
                                 color: Colors.grey[600],
                                 fontFamily: 'Cairo',
                               ),
                             ),
                           ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Action Buttons Row
                Row(
                  children: [
                                         // Follow Button
                     Expanded(
                       child: Consumer<UserViewModel>(
                         builder: (context, userViewModel, child) {
                           if (userViewModel.user?.id == product.userId) {
                             return const SizedBox.shrink(); // Hide for own products
                           }
                           return FollowButton(
                             key: ValueKey('follow_${product.userId}_${_seller?.isFollowing}'),
                             userId: product.userId!,
                             initialIsFollowing: _seller?.isFollowing,
                             height: 50,
                           );
                         },
                       ),
                     ),
                    const SizedBox(width: 12),
                                         // Profile Button
                     Expanded(
                       child: SizedBox(
                         height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (product.userId != null) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => SellerProfileScreen(
                                    sellerId: product.userId!,
                                    sellerName: _seller?.fullName ?? 'البائع',
                                  ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.person, size: 18, color: Colors.white),
                          label: const Text(
                            'الملف الشخصي',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'تفاصيل المنتج',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Consumer<ProductDetailsViewModel>(
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
                      onPressed: () => viewModel.loadProduct(widget.productId),
                      child: const Text(
                        'إعادة المحاولة',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                    ),
                  ],
                ),
              );
            }

            final product = viewModel.product;
            if (product == null) {
              return const Center(
                child: Text(
                  'المنتج غير موجود',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Images Gallery
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: product.media.isNotEmpty
                            ? PageView.builder(
                                controller: _pageController,
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentImageIndex = index;
                                  });
                                },
                                itemCount: product.media.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () => _showImageGallery(context, product, index, viewModel.apiClient),
                                    child: Image.network(
                                      viewModel.apiClient.getMediaUrl(product.media[index].url),
                                      fit: BoxFit.contain,
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
                                  );
                                },
                              )
                            : Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                              ),
                      ),
                      // Image Indicators
                      if (product.media.length > 1)
                        Positioned(
                          bottom: 20,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              product.media.length,
                              (index) => Container(
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                width: _currentImageIndex == index ? 12 : 8,
                                height: _currentImageIndex == index ? 12 : 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentImageIndex == index
                                      ? Colors.black
                                      : Colors.black.withOpacity(0.4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.8),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      // Favorite Button
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Consumer<FavoritesViewModel>(
                          builder: (context, favoritesViewModel, child) {
                            final isFavorite = favoritesViewModel.isFavorite(product.id!);
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  final favoritesViewModel = context.read<FavoritesViewModel>();
                                  final result = await favoritesViewModel.toggleFavorite(product.id!.toString(), context);
                                  final message = result['message'] as String?;
                                  final success = result['success'] as bool? ?? false;
                                  final isOffline = result['offline'] as bool? ?? false;
                                  
                                  if (message != null && message.isNotEmpty && context.mounted) {
                                    ModernSnackbar.show(
                                      context: context,
                                      message: message,
                                      type: success ? SnackBarType.success : SnackBarType.error,
                                    );
                                  }
                                },
                                customBorder: const CircleBorder(),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFavorite
                                        ? const Color(0xFFE84393)
                                        : Colors.grey,
                                    size: 24,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  // Product Details
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                            color: Color(0xFF2D3436),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Modern Price Section - Single line
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.priceGradientStart,
                                AppColors.priceGradientEnd,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.priceGradientStart.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                'السعر: ',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white.withOpacity(0.9),
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${product.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'ل.س',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Modern Stock Status - Centered with icon
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: product.isAvailable 
                                  ? AppColors.success.withOpacity(0.1) 
                                  : AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: product.isAvailable 
                                    ? AppColors.success.withOpacity(0.3) 
                                    : AppColors.error.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: product.isAvailable ? AppColors.success : AppColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    product.isAvailable ? Icons.check : Icons.close,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  product.isAvailable ? 'متوفر الآن' : 'غير متوفر',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: product.isAvailable ? AppColors.success : AppColors.error,
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Modern Description Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.description,
                                          color: AppColors.primary,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'وصف المنتج',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Cairo',
                                          color: Color(0xFF2D3436),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (product.description.length > 100)
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _isDescriptionExpanded = !_isDescriptionExpanded;
                                          });
                                        },
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              _isDescriptionExpanded ? 'عرض أقل' : 'عرض المزيد',
                                              style: TextStyle(
                                                color: AppColors.primary,
                                                fontFamily: 'Cairo',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Icon(
                                              _isDescriptionExpanded 
                                                  ? Icons.keyboard_arrow_up 
                                                  : Icons.keyboard_arrow_down,
                                              color: AppColors.primary,
                                              size: 16,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _isDescriptionExpanded
                                    ? product.description
                                    : product.description.length > 100
                                        ? '${product.description.substring(0, 100)}...'
                                        : product.description,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[700],
                                  fontFamily: 'Cairo',
                                  height: 1.7,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (product.serialNumber != null && product.serialNumber!.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          const Text(
                            'الرقم التسلسلي',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                              color: Color(0xFF2D3436),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.qr_code,
                                  color: const Color(0xFF2D3436),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    product.serialNumber!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF2D3436),
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        // Modern Features Section
                        if (product.features.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.featured_play_list,
                                        color: AppColors.primary,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'المميزات',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Cairo',
                                        color: Color(0xFF2D3436),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                
                                // Features Table
                                Column(
                                  children: product.features.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final feature = entry.value;
                                    final isLast = index == product.features.length - 1;
                                    
                                    return Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                          decoration: BoxDecoration(
                                            color: index % 2 == 0 
                                                ? Colors.grey[50] 
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Feature Name (Left)
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  feature.name,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Cairo',
                                                    color: Color(0xFF2D3436),
                                                  ),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                              
                                              // Separator
                                              Container(
                                                margin: const EdgeInsets.symmetric(horizontal: 16),
                                                width: 1,
                                                height: 24,
                                                color: Colors.grey[300],
                                              ),
                                              
                                              // Feature Value (Right)
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  feature.value,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.grey[700],
                                                    fontFamily: 'Cairo',
                                                    height: 1.4,
                                                  ),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (!isLast) const SizedBox(height: 8),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
                              final result = await cartViewModel.addItemToCart(product.id!.toString(), 1, context);
                              final message = result['message'] as String?;
                              final success = result['success'] as bool? ?? false;
                              final isOffline = result['offline'] as bool? ?? false;
                              
                              if (message != null && message.isNotEmpty && context.mounted) {
                                ModernSnackbar.show(
                                  context: context,
                                  message: message,
                                  type: success ? SnackBarType.success : SnackBarType.error,
                                );
                              }
                            },
                            icon: const Icon(Icons.shopping_cart),
                            label: const Text(
                              'إضافة إلى السلة',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        
                        // Seller Info Section - At the very bottom after Add to Cart
                        const SizedBox(height: 32),
                        _buildSellerInfoSection(product),
                      ],
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

  void _showImageGallery(BuildContext context, dynamic product, int initialIndex, apiClient) {
    try {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: PageView.builder(
            controller: PageController(initialPage: initialIndex),
            itemCount: product.media.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                child: Center(
                  child: Image.network(
                      apiClient.getMediaUrl(product.media[index].url),
                    fit: BoxFit.contain,
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
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
    } catch (e) {
      if (context.mounted) {
        ModernSnackbar.show(
          context: context,
          message: 'حدث خطأ أثناء عرض معرض الصور: ${e.toString()}',
          type: SnackBarType.error,
        );
      }
    }
  }
} 