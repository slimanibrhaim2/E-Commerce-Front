import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/follow_view_model.dart';
import '../../view_models/user_view_model.dart';
import '../../widgets/modern_loader.dart';
import '../../widgets/modern_snackbar.dart';
import '../user_info/seller_profile_screen.dart';

class FollowingScreen extends StatefulWidget {
  const FollowingScreen({super.key});

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> with RouteAware {
  late ScrollController _scrollController;
  bool _showLoadMore = false;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FollowViewModel>().loadFollowing();
      _hasInitialized = true;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh following when returning to this screen (but not on first load)
    if (_hasInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<FollowViewModel>().refreshFollowing();
        }
      });
    }
  }



  void _scrollListener() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final threshold = maxScroll * 0.8; // Show button when 80% scrolled

      setState(() {
        _showLoadMore = currentScroll > threshold;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'متابعاتي',
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
        body: Consumer<FollowViewModel>(
          builder: (context, followViewModel, child) {
            if (followViewModel.isLoadingFollowing && followViewModel.following.isEmpty) {
              return const Center(child: ModernLoader());
            }

            if (followViewModel.error != null && followViewModel.following.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => followViewModel.refreshFollowing(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              followViewModel.error!,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => followViewModel.refreshFollowing(),
                              child: const Text(
                                'إعادة المحاولة',
                                style: TextStyle(fontFamily: 'Cairo'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (followViewModel.following.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => followViewModel.refreshFollowing(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_add_disabled_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'لا تتابع أي شخص حتى الآن',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => followViewModel.refreshFollowing(),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: followViewModel.following.length,
                      itemBuilder: (context, index) {
                                                 final following = followViewModel.following[index];
                         return Card(
                           margin: const EdgeInsets.only(bottom: 8),
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(12),
                           ),
                           child: ListTile(
                             contentPadding: const EdgeInsets.all(12),
                             leading: CircleAvatar(
                               radius: 25,
                               backgroundImage: (following.followingProfileUrl != null && following.followingProfileUrl!.isNotEmpty)
                                   ? NetworkImage(context.read<UserViewModel>().apiClient.getUserFileUrl(following.followingProfileUrl!))
                                   : null,
                               child: (following.followingProfileUrl == null || following.followingProfileUrl!.isEmpty)
                                   ? const Icon(Icons.person, size: 25)
                                   : null,
                             ),
                             title: Text(
                               following.followingName ?? 'مستخدم',
                               style: const TextStyle(
                                 fontFamily: 'Cairo',
                                 fontWeight: FontWeight.bold,
                                 fontSize: 16,
                               ),
                             ),
                             subtitle: following.createdAt != null
                                 ? Text(
                                     'تاريخ المتابعة: ${_formatDate(following.createdAt!)}',
                                     style: const TextStyle(
                                       fontFamily: 'Cairo',
                                       fontSize: 14,
                                       color: Colors.grey,
                                     ),
                                   )
                                 : null,
                             trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                             onTap: () {
                               if (following.followingId != null) {
                                 Navigator.of(context).push(
                                   MaterialPageRoute(
                                     builder: (_) => SellerProfileScreen(
                                       sellerId: following.followingId!,
                                       sellerName: following.followingName ?? 'مستخدم',
                                     ),
                                   ),
                                 );
                               }
                             },
                           ),
                         );
                      },
                    ),
                  ),
                  if (_showLoadMore && followViewModel.hasMoreFollowing)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton(
                        onPressed: followViewModel.isLoadingMoreFollowing
                            ? null
                            : () => followViewModel.loadMoreFollowing(),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: followViewModel.isLoadingMoreFollowing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'تحميل المزيد',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
} 