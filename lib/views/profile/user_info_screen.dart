import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/user_view_model.dart';
import '../../models/user.dart';
import '../../widgets/modern_snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserInfoScreen extends StatelessWidget {
  const UserInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userViewModel = context.watch<UserViewModel>();
    final user = userViewModel.user;
    print('User in UI: ${user?.toJson()}');
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'معلومات الحساب',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'المعلومات الشخصية',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 16),
              // Profile Photo Display
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: user?.profilePhoto != null && user!.profilePhoto!.isNotEmpty
                          ? NetworkImage(user.profilePhoto!)
                          : null,
                      child: user?.profilePhoto == null || user!.profilePhoto!.isEmpty
                          ? const Icon(Icons.person, size: 50, color: Colors.grey)
                          : null,
                    ),
                    if (user?.profilePhoto != null && user!.profilePhoto!.isNotEmpty)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _InfoCard(
                title: 'الاسم الأول',
                value: user?.firstName ?? 'غير متوفر',
                icon: Icons.person,
              ),
              _InfoCard(
                title: 'اسم الأب',
                value: user?.middleName ?? 'غير متوفر',
                icon: Icons.person_outline,
              ),
              _InfoCard(
                title: 'الكنية',
                value: user?.lastName ?? 'غير متوفر',
                icon: Icons.person_outline,
              ),
              _InfoCard(
                title: 'رقم الهاتف',
                value: user?.phoneNumber ?? 'غير متوفر',
                icon: Icons.phone,
              ),
              _InfoCard(
                title: 'البريد الإلكتروني',
                value: user?.email ?? 'غير متوفر',
                icon: Icons.email,
              ),
              _InfoCard(
                title: 'الوصف الشخصي',
                value: user?.description ?? 'غير متوفر',
                icon: Icons.description,
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text(
                        'تعديل',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => _showEditDialog(context, userViewModel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.delete),
                      label: const Text(
                        'حذف الحساب',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => _showDeleteDialog(context, userViewModel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, UserViewModel userViewModel) {
    final user = userViewModel.user;
    final firstNameController = TextEditingController(text: user?.firstName ?? '');
    final middleNameController = TextEditingController(text: user?.middleName ?? '');
    final lastNameController = TextEditingController(text: user?.lastName ?? '');
    final phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final descriptionController = TextEditingController(text: user?.description ?? '');
    String? profilePhotoUrl = user?.profilePhoto;
    bool phoneChanged = false;
    File? selectedImageFile;

    showDialog(
      context: context,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppBar(
                      title: const Text('تعديل المعلومات الشخصية'),
                      automaticallyImplyLeading: false,
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                          top: 16.0,
                          left: 16.0,
                          right: 16.0,
                          bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Profile Photo Section
                            Center(
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 60,
                                        backgroundImage: selectedImageFile != null
                                            ? FileImage(selectedImageFile!)
                                            : (profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty
                                                ? NetworkImage(profilePhotoUrl!) as ImageProvider
                                                : null),
                                        child: (selectedImageFile == null && 
                                                (profilePhotoUrl == null || profilePhotoUrl!.isEmpty))
                                            ? const Icon(Icons.person, size: 60, color: Colors.grey)
                                            : null,
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).primaryColor,
                                            shape: BoxShape.circle,
                                          ),
                                          child: IconButton(
                                            icon: const Icon(Icons.camera_alt, color: Colors.white),
                                            onPressed: () async {
                                              final ImagePicker picker = ImagePicker();
                                              final XFile? image = await picker.pickImage(
                                                source: ImageSource.gallery,
                                                maxWidth: 512,
                                                maxHeight: 512,
                                                imageQuality: 80,
                                              );
                                              if (image != null) {
                                                selectedImageFile = File(image.path);
                                                // Force rebuild of dialog
                                                (context as Element).markNeedsBuild();
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: () async {
                                      final ImagePicker picker = ImagePicker();
                                      final XFile? image = await picker.pickImage(
                                        source: ImageSource.gallery,
                                        maxWidth: 512,
                                        maxHeight: 512,
                                        imageQuality: 80,
                                      );
                                      if (image != null) {
                                        selectedImageFile = File(image.path);
                                        // Force rebuild of dialog
                                        (context as Element).markNeedsBuild();
                                      }
                                    },
                                    child: const Text(
                                      'تغيير الصورة الشخصية',
                                      style: TextStyle(fontFamily: 'Cairo'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            TextField(
                              controller: firstNameController,
                              decoration: InputDecoration(
                                labelText: 'الاسم الأول',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle: const TextStyle(fontFamily: 'Cairo'),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: middleNameController,
                              decoration: InputDecoration(
                                labelText: 'اسم الأب',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle: const TextStyle(fontFamily: 'Cairo'),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: lastNameController,
                              decoration: InputDecoration(
                                labelText: 'الكنية',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle: const TextStyle(fontFamily: 'Cairo'),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: phoneController,
                              decoration: InputDecoration(
                                labelText: 'رقم الهاتف',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle: const TextStyle(fontFamily: 'Cairo'),
                                helperText: 'تغيير رقم الهاتف سيتطلب إعادة تسجيل الدخول',
                                helperStyle: const TextStyle(fontFamily: 'Cairo'),
                              ),
                              onChanged: (value) {
                                phoneChanged = value != user?.phoneNumber;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: emailController,
                              decoration: InputDecoration(
                                labelText: 'البريد الإلكتروني',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle: const TextStyle(fontFamily: 'Cairo'),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: descriptionController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: 'الوصف الشخصي',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelStyle: const TextStyle(fontFamily: 'Cairo'),
                                hintText: 'اكتب وصفاً مختصراً عن نفسك...',
                                hintStyle: const TextStyle(fontFamily: 'Cairo'),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () async {
                                  try {
                                    // First upload image if selected
                                    String? finalProfilePhotoUrl = profilePhotoUrl;
                                    if (selectedImageFile != null) {
                                      final imageUploadMessage = await userViewModel.uploadProfileImage(selectedImageFile!);
                                      if (userViewModel.error != null) {
                                        ModernSnackbar.show(
                                          context: context,
                                          message: userViewModel.error!,
                                          type: SnackBarType.error,
                                        );
                                        return;
                                      }
                                      // Show image upload success message if provided
                                      if (imageUploadMessage != null && imageUploadMessage.isNotEmpty) {
                                        ModernSnackbar.show(
                                          context: context,
                                          message: imageUploadMessage,
                                          type: SnackBarType.success,
                                        );
                                      }
                                      // Get the uploaded image URL from the updated user
                                      finalProfilePhotoUrl = userViewModel.user?.profilePhoto;
                                    }

                                    final updatedUser = User(
                                      firstName: firstNameController.text.trim(),
                                      middleName: middleNameController.text.trim(),
                                      lastName: lastNameController.text.trim(),
                                      phoneNumber: phoneController.text.trim(),
                                      email: emailController.text.trim(),
                                      profilePhoto: finalProfilePhotoUrl,
                                      description: descriptionController.text.trim(),
                                    );

                                    final message = await userViewModel.updateUserProfile(updatedUser);
                                    if (!context.mounted) return;
                                    Navigator.pop(context);

                                    if (phoneChanged) {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => Directionality(
                                          textDirection: TextDirection.rtl,
                                          child: AlertDialog(
                                            title: const Text(
                                              'تنبيه',
                                              style: TextStyle(
                                                fontFamily: 'Cairo',
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            content: const Text(
                                              'سيتم تسجيل خروجك الآن لتأكيد رقم هاتفك الجديد',
                                              style: TextStyle(fontFamily: 'Cairo'),
                                            ),
                                            actions: [
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Theme.of(context).primaryColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                                onPressed: () async {
                                                  await userViewModel.logout();
                                                  if (!context.mounted) return;
                                                  // Navigate to login screen with phone number pre-filled
                                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                                    '/login',
                                                    (route) => false,
                                                    arguments: phoneController.text.trim(),
                                                  );
                                                },
                                                child: const Text(
                                                  'موافق',
                                                  style: TextStyle(
                                                    fontFamily: 'Cairo',
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    } else {
                                      // Show the actual backend message
                                      ModernSnackbar.show(
                                        context: context,
                                        message: message ?? 'تم تحديث المعلومات بنجاح',
                                        type: SnackBarType.success,
                                      );
                                    }
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    ModernSnackbar.show(
                                      context: context,
                                      message: e.toString().replaceAll('Exception: ', ''),
                                      type: SnackBarType.error,
                                    );
                                  }
                                },
                                child: const Text(
                                  'حفظ التغييرات',
                                  style: TextStyle(fontFamily: 'Cairo'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, UserViewModel userViewModel) {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text(
              'حذف الحساب',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'هل أنت متأكد أنك تريد حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء.',
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  final message = await userViewModel.deleteUser();
                  Navigator.pop(context);
                  ModernSnackbar.show(
                    context: context,
                    message: message ?? 'تم حذف الحساب بنجاح',
                    type: SnackBarType.success,
                  );
                  // Optionally, log out and navigate to login screen
                  await userViewModel.logout();
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                },
                child: const Text(
                  'حذف',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.blueGrey),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 