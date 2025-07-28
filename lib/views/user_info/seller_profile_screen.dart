import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/user.dart';
import '../../view_models/user_view_model.dart';
import '../../widgets/modern_loader.dart';
import '../../widgets/star_rating_widget.dart';
import '../../widgets/follow_button.dart';
import 'seller_products_screen.dart';
import '../reviews/provider_reviews_screen.dart';

class SellerProfileScreen extends StatefulWidget {
  final String sellerId;
  final String sellerName;

  const SellerProfileScreen({
    super.key,
    required this.sellerId,
    required this.sellerName,
  });

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  User? _seller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSellerInfo();
  }

  Future<void> _loadSellerInfo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userViewModel = context.read<UserViewModel>();
      final seller = await userViewModel.fetchUserById(widget.sellerId);
      
      if (mounted) {
        setState(() {
          _seller = seller;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _launchContact(String url, String errorMessage) async {
    try {
      if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
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
            'معلومات البائع',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(child: ModernLoader())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _error!,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadSellerInfo,
                          child: const Text(
                            'إعادة المحاولة',
                            style: TextStyle(fontFamily: 'Cairo'),
                          ),
                        ),
                      ],
                    ),
                  )
                : _seller == null
                    ? const Center(
                        child: Text(
                          'لم يتم العثور على معلومات البائع',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16,
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profile Header
                            Center(
                              child: Column(
                                children: [
                                  // Profile Photo
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.grey[200],
                                    backgroundImage: _seller!.profilePhoto != null && _seller!.profilePhoto!.isNotEmpty
                                        ? NetworkImage(context.read<UserViewModel>().apiClient.getUserFileUrl(_seller!.profilePhoto!))
                                        : null,
                                    child: _seller!.profilePhoto == null || _seller!.profilePhoto!.isEmpty
                                        ? const Icon(
                                            Icons.person,
                                            size: 50,
                                            color: Colors.grey,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                  // Name
                                  Text(
                                    _seller!.fullName,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Cairo',
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  // Star Rating
                                  if (_seller!.rating != null) ...[
                                    const SizedBox(height: 8),
                                    StarRatingWidget(
                                      rating: _seller!.rating!,
                                      numOfReviews: _seller!.numOfReviews,
                                      starSize: 20,
                                      fontSize: 16,
                                      alignment: MainAxisAlignment.center,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Follow Button
                            FollowButton(
                              userId: widget.sellerId,
                              initialIsFollowing: _seller!.isFollowing,
                              height: 50,
                            ),
                            const SizedBox(height: 32),
                            // Contact Information
                            const Text(
                              'معلومات التواصل',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Phone Number
                            if (_seller!.phoneNumber != null) ...[
                              _buildContactOption(
                                icon: Icons.phone,
                                title: 'اتصال مباشر',
                                subtitle: _seller!.phoneNumber!,
                                onTap: () => _launchContact(
                                  'tel:${_seller!.phoneNumber!.replaceAll('\u200E', '')}',
                                  'لا يمكن فتح تطبيق الهاتف',
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildContactOption(
                                icon: FontAwesomeIcons.whatsapp,
                                title: 'واتساب',
                                subtitle: 'تواصل عبر الواتساب',
                                onTap: () => _launchContact(
                                  'https://wa.me/${_seller!.phoneNumber!.replaceAll(RegExp(r'[^\d+]'), '')}',
                                  'لا يمكن فتح تطبيق واتساب',
                                ),
                                iconColor: const Color(0xFF25D366),
                              ),
                              const SizedBox(height: 16),
                            ],
                            // Email
                            if (_seller!.email != null) ...[
                              _buildContactOption(
                                icon: Icons.email,
                                title: 'البريد الإلكتروني',
                                subtitle: _seller!.email!,
                                onTap: () => _launchContact(
                                  'mailto:${_seller!.email!}',
                                  'لا يمكن فتح تطبيق البريد',
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                                        // Description - Full Width Modern Design
            if (_seller!.description != null && _seller!.description!.isNotEmpty) ...[
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C3AED).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: Color(0xFF7C3AED),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'نبذة عن البائع',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                            color: Color(0xFF2D3436),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _seller!.description!,
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
            ],
                            // Show Products Button
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SellerProductsScreen(
                                        sellerId: widget.sellerId,
                                        sellerName: _seller?.fullName ?? widget.sellerName,
                                      ),
                                    ),
                                  );
                                },
                                                                 style: ElevatedButton.styleFrom(
                                   backgroundColor: const Color(0xFF7C3AED),
                                   foregroundColor: Colors.white,
                                   padding: const EdgeInsets.symmetric(vertical: 16),
                                   shape: RoundedRectangleBorder(
                                     borderRadius: BorderRadius.circular(12),
                                   ),
                                   elevation: 2,
                                 ),
                                                                 icon: const Icon(Icons.shopping_bag, color: Colors.white, size: 24),
                                label: const Text(
                                  'عرض منتجات البائع',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            
                            // Customer Reviews Button
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProviderReviewsScreen(
                                        providerId: widget.sellerId,
                                        providerName: _seller?.fullName ?? widget.sellerName,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                icon: const Icon(Icons.rate_review, color: Colors.white, size: 24),
                                label: const Text(
                                  'مراجعات الزبائن لهذا البائع',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor ?? Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'Cairo',
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
        ),
        onTap: onTap,
      ),
    );
  }
} 