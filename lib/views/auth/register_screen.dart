import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../../view_models/user_view_model.dart';
import '../../view_models/cart_view_model.dart';
import '../../view_models/favorites_view_model.dart';
import '../../models/user.dart';
import '../../widgets/modern_snackbar.dart';
import '../../core/api/api_exception.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../main_navigation_screen.dart';
import 'package:e_commerce/views/auth/widgets/otp_dialog.dart';
import 'package:e_commerce/widgets/modern_loader.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>(); // Key to manage the form state and validate input fields
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _pickedImage;
  String? _base64Image;   // To store the image as a base64 string
  bool _isLoading = false;
  final _storage = const FlutterSecureStorage();

  @override
  void dispose() {  // Clean up controllers when the screen is destroyed to free memory
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _syncOfflineData() async {
    try {
      // Sync offline favorites
      await context.read<FavoritesViewModel>().syncOfflineFavorites();
      
      // Sync offline cart
      await context.read<CartViewModel>().syncOfflineCart();
      
      // Clear offline data from view models
      context.read<FavoritesViewModel>().clearOfflineDataAfterLogin();
      context.read<CartViewModel>().clearOfflineDataAfterLogin();
      
      // Reload online data after sync
      await context.read<FavoritesViewModel>().loadFavorites();
      await context.read<CartViewModel>().loadCart();
      
                  // Offline data synced successfully
    } catch (e) {
              // Error syncing offline data
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _base64Image = base64Encode(bytes);
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final user = User(
      firstName: _firstNameController.text.trim(),
      middleName: _middleNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      profilePhoto: _base64Image,
      description: _descriptionController.text.trim(),
    );
    try {
      final userViewModel = context.read<UserViewModel>();
      final message = await userViewModel.registerUser(user);
      // Always show backend message (success or error)
      ModernSnackbar.show(
        context: context,
        message: message ?? '',
        type: userViewModel.step == RegistrationStep.awaitingOtp
            ? SnackBarType.success
            : SnackBarType.error,
      );
      // Only show OTP dialog if registration is successful
      if (userViewModel.step == RegistrationStep.awaitingOtp) {
        _showOtpDialog(userViewModel);
      }
    } catch (e) {
      String errorMsg = e is ApiException ? e.message : e.toString();
      ModernSnackbar.show(
        context: context,
        message: errorMsg,
        type: SnackBarType.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showOtpDialog(UserViewModel userViewModel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String? localError = userViewModel.error;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return OtpDialog(
              isLoading: userViewModel.isLoading,
              errorMessage: localError,
              onSubmit: (otp) async {
                final message = await userViewModel.verifyOtp(otp);
                if (userViewModel.error == null && userViewModel.jwt != null) {
                  Navigator.of(context).pop();
                  ModernSnackbar.show(
                    context: context,
                    message: message ?? '',
                    type: SnackBarType.success,
                  );
                  // JWT Token received successfully
                  await _storage.write(key: 'auth_token', value: userViewModel.jwt!);
                  // Fetch user profile after registration
                  await userViewModel.loadUserProfile();
                  // Load cart after successful registration
                  await context.read<CartViewModel>().loadCart();
                  
                  // Sync offline data
                  await _syncOfflineData();
                  
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                    (route) => false,
                  );
                } else {
                  setStateDialog(() {
                    localError = userViewModel.error ?? message ?? '';
                  });
                }
              },
              onCancel: () => Navigator.of(context).pop(),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('إنشاء حساب جديد')),
        body: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 6,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey, // Connect this form to the _formKey to validate ti later.
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: _pickedImage != null ? FileImage(_pickedImage!) : null,
                            child: _pickedImage == null
                                ? Icon(Icons.person, size: 48, color: Colors.grey[400])
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.blue,
                                child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'الاسم الأول',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _middleNameController,
                        decoration: const InputDecoration(
                          labelText: 'اسم الأب',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'الكنية',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'رقم الهاتف',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'البريد الإلكتروني',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'الوصف',
                          prefixIcon: Icon(Icons.info_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: ModernLoader(),
                                )
                              : const Text('إنشاء حساب', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}