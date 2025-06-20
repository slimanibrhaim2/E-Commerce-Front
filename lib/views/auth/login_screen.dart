import 'package:e_commerce/views/auth/widgets/otp_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/user_view_model.dart';
import '../../widgets/modern_snackbar.dart';
import '../main_navigation_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../widgets/modern_loader.dart';

class LoginScreen extends StatefulWidget {
  final String? initialPhoneNumber;
  
  const LoginScreen({
    super.key,
    this.initialPhoneNumber,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneController;
  bool _isLoading = false;
  String? _errorMessage;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.initialPhoneNumber ?? '');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final userViewModel = context.read<UserViewModel>();
      final message = await userViewModel.login(_phoneController.text);
      
      if (!mounted) return;
      
      // First show the backend message
      ModernSnackbar.show(
        context: context,
        message: message ?? '',
        type: userViewModel.loginStep == LoginStep.awaitingOtp
            ? SnackBarType.success
            : SnackBarType.error,
      );

      setState(() {
        _isLoading = false;
      });

      // Only show OTP dialog if login was successful
      if (userViewModel.loginStep == LoginStep.awaitingOtp) {
        _showOtpDialog(userViewModel);
      } else {
        // If login failed, show error in the form
        setState(() {
          _errorMessage = message;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _showOtpDialog(UserViewModel userViewModel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String? localError = userViewModel.error;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (context, setStateDialog) {
              return OtpDialog(
                isLoading: userViewModel.isLoading,
                errorMessage: localError,
                onSubmit: (otp) async {
                  try {
                    final message = await userViewModel.verifyLoginOtp(otp);
                    if (!mounted) return;
                    
                    if (userViewModel.error == null && userViewModel.jwt != null) {
                      // Save token
                      await _storage.write(key: 'auth_token', value: userViewModel.jwt!);
                      // Fetch user profile
                      await userViewModel.loadUserProfile();
                      if (!mounted) return;
                      
                      // Show success message
                      ModernSnackbar.show(
                        context: context,
                        message: message ?? 'تم تسجيل الدخول بنجاح',
                        type: SnackBarType.success,
                      );
                      
                      // Navigate to home screen
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                        (route) => false,
                      );
                    } else {
                      setStateDialog(() {
                        localError = userViewModel.error ?? message ?? '';
                      });
                    }
                  } catch (e) {
                    setStateDialog(() {
                      localError = e.toString();
                    });
                  }
                },
                onCancel: () => Navigator.of(context).pop(),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'تسجيل الدخول',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'رقم الهاتف',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelStyle: const TextStyle(fontFamily: 'Cairo'),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال رقم الهاتف';
                      }
                      return null;
                    },
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontFamily: 'Cairo',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isLoading ? null : _sendOtp,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: ModernLoader(),
                            )
                          : const Text(
                              'إرسال الرمز',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 