import 'package:e_commerce/views/auth/widgets/otp_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/user_view_model.dart';
import '../../widgets/modern_snackbar.dart';
import '../main_navigation_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  final _storage = const FlutterSecureStorage();

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
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return OtpDialog(
              isLoading: userViewModel.isLoading,
              errorMessage: localError,
              onSubmit: (otp) async {
                final message = await userViewModel.verifyLoginOtp(otp);
                if (userViewModel.error == null && userViewModel.jwt != null) {
                  Navigator.of(context).pop();
                  ModernSnackbar.show(
                    context: context,
                    message: message ?? '',
                    type: SnackBarType.success,
                  );
                  await _storage.write(key: 'auth_token', value: userViewModel.jwt!);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل الدخول'),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'رقم الهاتف',
                      border: OutlineInputBorder(),
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
                        style: TextStyle(color: Colors.red.shade700),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendOtp,
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('إرسال رمز التحقق'),
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