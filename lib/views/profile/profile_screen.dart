import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../view_models/user_view_model.dart';
import '../../models/user.dart';
import '../auth/register_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _pickedImage;
  bool _didLoad = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
      // Here you can call your ViewModel to update the profile photo if needed
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<UserViewModel>().loadUserProfile();
      });
      _didLoad = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, viewModel, child) {
        final user = viewModel.user;
        String displayName = 'اسم المستخدم';
        if (user != null && (user.firstName!.isNotEmpty || user.lastName!.isNotEmpty)) {
          displayName = '${user.firstName} ${user.middleName ?? ''} ${user.lastName}'.trim();
        }
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: const Color(0xFFF5F6FA),
            body: Column(
              children: [
                // Header Card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4A90E2), Color(0xFF50E3C2)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  padding: const EdgeInsets.only(top: 60, bottom: 24, right: 24, left: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: Colors.white,
                            backgroundImage: _pickedImage != null
                                ? FileImage(_pickedImage!)
                                : (user?.profilePhoto != null && user!.profilePhoto!.isNotEmpty
                                    ? NetworkImage(user.profilePhoto!) as ImageProvider
                                    : null),
                            child: (user?.profilePhoto == null || user!.profilePhoto!.isEmpty) && _pickedImage == null
                                ? Icon(Icons.person, size: 48, color: Colors.grey[400])
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.blue,
                                child: Icon(Icons.camera_alt, color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.phoneNumber ?? '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to edit profile or show info
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color(0xFF4A90E2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          'معلومات الحساب',
                          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Options List
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _ProfileOption(icon: Icons.receipt_long, label: 'طلباتي', onTap: () {}),
                      _ProfileOption(icon: Icons.location_on, label: 'عناويني', onTap: () {}),
                      _ProfileOption(icon: Icons.favorite, label: 'المفضلة', onTap: () {}),
                      _ProfileOption(icon: Icons.card_giftcard, label: 'الجوائز و قسائم التخفيض', onTap: () {}),
                      const Divider(height: 32),
                      _ProfileOption(icon: Icons.info, label: 'لمحة عن تطبيقنا', onTap: () {}),
                      _ProfileOption(icon: Icons.privacy_tip, label: 'سياسة الخصوصية', onTap: () {}),
                      _ProfileOption(icon: Icons.phone, label: 'اتصل بنا', onTap: () {}),
                      const SizedBox(height: 16),
                      _ProfileOption(
                        icon: Icons.login,
                        label: 'تسجيل الدخول',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Login pressed')),
                          );
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
                      _ProfileOption(
                        icon: Icons.logout,
                        label: 'تسجيل الخروج',
                        onTap: () {},
                        color: Colors.red,
                      ),
                    ],
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