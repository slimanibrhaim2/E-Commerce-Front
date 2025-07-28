import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/follow_view_model.dart';
import '../view_models/user_view_model.dart';
import '../views/auth/login_screen.dart';
import 'modern_snackbar.dart';

class FollowButton extends StatefulWidget {
  final String userId;
  final bool? initialIsFollowing;
  final double? width;
  final double? height;

  const FollowButton({
    super.key,
    required this.userId,
    this.initialIsFollowing,
    this.width,
    this.height,
  });

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(
                  Icons.login,
                  color: Colors.blue,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'تسجيل الدخول مطلوب',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: const Text(
              'يجب عليك تسجيل الدخول أولاً لمتابعة المستخدمين',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'إلغاء',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.grey,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'تسجيل الدخول',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<FollowViewModel, UserViewModel>(
      builder: (context, followViewModel, userViewModel, child) {
        // Don't show follow button for own profile
        final currentUserId = userViewModel.user?.id;
        if (currentUserId == widget.userId) {
          return const SizedBox.shrink();
        }

        // Initialize following state if provided
        if (widget.initialIsFollowing != null && followViewModel.isFollowing(widget.userId) != widget.initialIsFollowing) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            followViewModel.setFollowingState(widget.userId, widget.initialIsFollowing!);
          });
        }

        final isFollowing = followViewModel.isFollowing(widget.userId);
        final isLoading = followViewModel.isLoading(widget.userId);

        return SizedBox(
          width: widget.width ?? double.infinity,
          height: widget.height ?? 48,
          child: ElevatedButton(
            onPressed: isLoading 
                ? null 
                : () async {
                    // Check if user is logged in
                    if (currentUserId == null) {
                      _showLoginRequiredDialog(context);
                      return;
                    }

                    final success = await followViewModel.toggleFollow(widget.userId);
                    if (context.mounted) {
                      if (success) {
                        final message = isFollowing 
                            ? 'تم إلغاء المتابعة بنجاح'
                            : 'تم المتابعة بنجاح';
                        ModernSnackbar.show(
                          context: context,
                          message: message,
                          type: SnackBarType.success,
                        );
                      } else {
                        ModernSnackbar.show(
                          context: context,
                          message: followViewModel.error ?? 'حدث خطأ',
                          type: SnackBarType.error,
                        );
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: currentUserId == null 
                  ? Colors.blue.shade400  // Different color for login prompt
                  : (isFollowing ? Colors.red.shade400 : Colors.grey),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              shadowColor: (currentUserId == null 
                  ? Colors.blue.shade400 
                  : (isFollowing ? Colors.red.shade400 : Colors.grey)).withOpacity(0.3),
            ),
            child: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      // Determine text based on available width
                      final isWideEnough = constraints.maxWidth > 140;
                      final loginText = isWideEnough 
                          ? 'تسجيل الدخول للمتابعة'
                          : 'دخول للمتابعة';
                      
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            currentUserId == null 
                                ? Icons.login
                                : (isFollowing ? Icons.person_remove : Icons.person_add),
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              currentUserId == null 
                                  ? loginText
                                  : (isFollowing ? 'إلغاء المتابعة' : 'متابعة'),
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
} 