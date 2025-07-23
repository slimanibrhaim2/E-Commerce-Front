import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../view_models/user_view_model.dart';
import '../../widgets/modern_loader.dart';
import '../../widgets/star_rating_widget.dart';
import 'seller_products_screen.dart';

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
                              _buildInfoRow(
                                icon: Icons.phone,
                                label: 'رقم الهاتف',
                                value: _seller!.phoneNumber!,
                              ),
                              const SizedBox(height: 16),
                            ],
                            // Email
                            if (_seller!.email != null) ...[
                              _buildInfoRow(
                                icon: Icons.email,
                                label: 'البريد الإلكتروني',
                                value: _seller!.email!,
                              ),
                              const SizedBox(height: 16),
                            ],
                            // Description
                            if (_seller!.description != null && _seller!.description!.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              const Text(
                                'نبذة عن البائع',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Text(
                                  _seller!.description!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Cairo',
                                    height: 1.6,
                                  ),
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
                                icon: const Icon(Icons.shopping_bag, size: 24),
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
                          ],
                        ),
                      ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.blue,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 