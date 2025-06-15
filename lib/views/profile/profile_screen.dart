import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/user_view_model.dart';
import '../auth/register_screen.dart';
import '../favorites/favorites_screen.dart';
import '../contact/contact_screen.dart';
import '../address/addresses_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
      ),
      body: Directionality(
          textDirection: TextDirection.rtl,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      const SizedBox(height: 16),
                      _ProfileOption(
              icon: Icons.login,
              label: 'تسجيل الدخول',
              onTap: () {
                Navigator.of(context).pushNamed('/login');
              },
            ),
            _ProfileOption(
              icon: Icons.app_registration,
              label: 'إنشاء حساب',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => RegisterScreen()),
                );
              },
            ),
            const Divider(height: 32),
            _ProfileOption(
              icon: Icons.location_on,
              label: 'عناويني',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddressesScreen()),
                );
              },
            ),
            _ProfileOption(
              icon: Icons.favorite,
              label: 'المفضلة',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                );
              },
            ),
            _ProfileOption(
              icon: Icons.card_giftcard,
              label: 'الجوائز و قسائم التخفيض',
              onTap: () {},
            ),
            const Divider(height: 32),
            _ProfileOption(
              icon: Icons.info,
              label: 'لمحة عن تطبيقنا',
                        onTap: () {},
            ),
            _ProfileOption(
              icon: Icons.privacy_tip,
              label: 'سياسة الخصوصية',
              onTap: () {},
                      ),
            _ProfileOption(
              icon: Icons.phone,
              label: 'اتصل بنا',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ContactScreen()),
                );
              },
                ),
              ],
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
          style: TextStyle(
            fontFamily: 'Cairo',
            color: color ?? Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }
} 