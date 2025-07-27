import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/follow_view_model.dart';
import '../view_models/user_view_model.dart';
import 'modern_snackbar.dart';

class FollowButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Consumer2<FollowViewModel, UserViewModel>(
      builder: (context, followViewModel, userViewModel, child) {
        // Don't show follow button for own profile
        final currentUserId = userViewModel.user?.id;
        if (currentUserId == userId) {
          return const SizedBox.shrink();
        }

        // Initialize following state if provided
        if (initialIsFollowing != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            followViewModel.setFollowingState(userId, initialIsFollowing!);
          });
        }

        final isFollowing = followViewModel.isFollowing(userId);
        final isLoading = followViewModel.isLoading(userId);

        return SizedBox(
          width: width ?? double.infinity,
          height: height ?? 48,
          child: ElevatedButton(
            onPressed: isLoading 
                ? null 
                : () async {
                    final success = await followViewModel.toggleFollow(userId);
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
              backgroundColor: isFollowing ? Colors.red.shade400 : Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              shadowColor: (isFollowing ? Colors.red.shade400 : Colors.grey).withOpacity(0.3),
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
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isFollowing ? Icons.person_remove : Icons.person_add,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isFollowing ? 'إلغاء المتابعة' : 'متابعة',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
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