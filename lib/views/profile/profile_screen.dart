import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/user_view_model.dart';
import '../../view_models/cart_view_model.dart';
import '../../view_models/favorites_view_model.dart';
import '../auth/register_screen.dart';
import '../favorites/favorites_screen.dart';
import '../contact/contact_screen.dart';
import '../address/addresses_screen.dart';
import 'user_info_screen.dart';
import 'about_us_screen.dart';
import 'privacy_policy_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../widgets/modern_snackbar.dart';
import '../../widgets/star_rating_widget.dart';
import '../reviews/my_reviews_screen.dart';
import '../orders/my_orders_screen.dart';
import '../profile/my_products_screen.dart';
import 'followers_screen.dart';
import 'following_screen.dart';
import '../../view_models/follow_view_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _didFetch = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userViewModel = context.watch<UserViewModel>();
    final isLoggedIn = userViewModel.jwt != null;
    if (!_didFetch && isLoggedIn && userViewModel.user == null) {
      _didFetch = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final message = await userViewModel.loadUserProfile();
        if (userViewModel.error != null && mounted) {
          ModernSnackbar.show(
            context: context,
            message: userViewModel.error!,
            type: SnackBarType.error,
          );
        }
        
        // Load followers and following counts for display
        if (mounted && isLoggedIn) {
          context.read<FollowViewModel>().loadFollowers();
          context.read<FollowViewModel>().loadFollowing();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = context.watch<UserViewModel>();
    final isLoggedIn = userViewModel.jwt != null;
    final storage = const FlutterSecureStorage();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
      appBar: AppBar(
          title: const Text(
            'الملف الشخصي',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
        ),
          centerTitle: true,
      ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 16),
            _UserInfoHeader(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const UserInfoScreen()),
                );
              },
            ),
            const Divider(height: 32),
            if (isLoggedIn) ...[
              _FollowStatsWidget(),
              const Divider(height: 32),
            ],
            if (!isLoggedIn) ...[
              _SectionHeader(title: 'الحساب', color: Colors.blue.shade600),
              _ProfileOption(
                icon: Icons.login,
                label: 'تسجيل الدخول',
                color: Colors.purple.shade600,
                onTap: () {
                  Navigator.of(context).pushNamed('/login');
                },
              ),
              _ProfileOption(
                icon: Icons.app_registration,
                label: 'إنشاء حساب',
                color: Colors.purple.shade600,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
              ),
            ],
            _SectionHeader(title: 'خدماتي', color: Colors.blue.shade600),
            _ProfileOption(
              icon: Icons.location_on,
              label: 'عناويني',
              color: Colors.purple.shade600,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddressesScreen()),
                );
              },
            ),
            _ProfileOption(
              icon: Icons.list_alt,
              label: 'طلباتي',
              color: Colors.purple.shade600,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
                );
              },
            ),
            if (isLoggedIn)
              _ProfileOption(
                icon: Icons.shopping_bag,
                label: 'منتجاتي',
                color: Colors.purple.shade600,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MyProductsScreen()),
                );
              },
            ),
            if (isLoggedIn)
              _ProfileOption(
                icon: Icons.rate_review,
                label: 'مراجعاتي',
                color: Colors.purple.shade600,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MyReviewsScreen()),
                  );
                },
              ),
            _ProfileOption(
              icon: Icons.favorite,
              label: 'المفضلة',
              color: Colors.purple.shade600,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                );
              },
            ),
            _ProfileOption(
              icon: Icons.card_giftcard,
              label: 'الجوائز و قسائم التخفيض',
              color: Colors.purple.shade600,
              onTap: () {},
            ),
            _SectionHeader(title: 'الدعم و المعلومات', color: Colors.blue.shade600),
            _ProfileOption(
              icon: Icons.info,
              label: 'لمحة عن تطبيقنا',
              color: Colors.purple.shade600,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AboutUsScreen()),
                );
              },
            ),
            _ProfileOption(
              icon: Icons.privacy_tip,
              label: 'سياسة الخصوصية',
              color: Colors.purple.shade600,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                );
              },
            ),
            _ProfileOption(
              icon: Icons.phone,
              label: 'اتصل بنا',
              color: Colors.purple.shade600,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ContactScreen()),
                );
              },
            ),
            if (isLoggedIn)
              _ProfileOption(
                icon: Icons.logout,
                label: 'تسجيل الخروج',
                color: Colors.red,
                onTap: () async {
                  // Clear JWT and user info
                  await Provider.of<UserViewModel>(context, listen: false).logout();
                  // Clear cart after logout
                  context.read<CartViewModel>().clearCart();
                  // Clear offline data
                  await context.read<FavoritesViewModel>().clearOfflineFavorites();
                  await context.read<CartViewModel>().clearOfflineCart();
                  // Clear all local storage
                  await storage.deleteAll();
                  ModernSnackbar.show(
                    context: context,
                    message: 'تم تسجيل الخروج بنجاح',
                    type: SnackBarType.success,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _UserInfoHeader extends StatelessWidget {
  final VoidCallback onTap;

  const _UserInfoHeader({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserViewModel>().user;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: (user != null && user.profilePhoto != null && user.profilePhoto!.isNotEmpty)
                    ? NetworkImage(context.read<UserViewModel>().apiClient.getUserFileUrl(user.profilePhoto!))
                    : null,
                child: (user == null || user.profilePhoto == null || user.profilePhoto!.isEmpty)
                    ? const Icon(Icons.person, size: 30)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      [
                        user?.firstName,
                        user?.middleName,
                        user?.lastName,
                      ].where((name) => name != null && name.isNotEmpty).join(' ').isNotEmpty
                          ? [
                              user?.firstName,
                              user?.middleName,
                              user?.lastName,
                            ].where((name) => name != null && name.isNotEmpty).join(' ')
                          : 'اسم المستخدم',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.phoneNumber ?? '',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    if (user?.rating != null) ...[
                      const SizedBox(height: 4),
                      StarRatingWidget(
                        rating: user!.rating!,
                        numOfReviews: user.numOfReviews,
                        starSize: 16,
                        fontSize: 12,
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ProfileOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: color ?? Colors.blueGrey),
        title: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cairo',
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 8, left: 16, right: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: color.withOpacity(0.3),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 1,
              color: color.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowStatsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FollowViewModel>(
      builder: (context, followViewModel, child) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _FollowStatItem(
                  icon: Icons.people,
                  label: 'المتابعون',
                  count: followViewModel.followersTotalCount,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const FollowersScreen()),
                    );
                  },
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.grey.shade300,
                ),
                _FollowStatItem(
                  icon: Icons.person_add,
                  label: 'متابعاتي',
                  count: followViewModel.followingTotalCount,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const FollowingScreen()),
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

class _FollowStatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final VoidCallback onTap;

  const _FollowStatItem({
    required this.icon,
    required this.label,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.shade50,
                border: Border.all(color: Colors.blue.shade200, width: 2),
              ),
              child: Icon(
                icon,
                color: Colors.blue.shade600,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 