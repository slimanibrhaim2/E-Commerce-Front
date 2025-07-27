import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/follow_view_model.dart';
import '../../view_models/user_view_model.dart';
import '../../widgets/modern_loader.dart';
import '../../widgets/modern_snackbar.dart';
import '../user_info/seller_profile_screen.dart';

class FollowersScreen extends StatefulWidget {
  const FollowersScreen({super.key});

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> with RouteAware {
  late ScrollController _scrollController;
  bool _showLoadMore = false;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FollowViewModel>().loadFollowers();
      _hasInitialized = true;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh followers when returning to this screen (but not on first load)
    if (_hasInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<FollowViewModel>().refreshFollowers();
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
            'المتابعون',
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
            if (followViewModel.isLoadingFollowers && followViewModel.followers.isEmpty) {
              return const Center(child: ModernLoader());
            }

            if (followViewModel.error != null && followViewModel.followers.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => followViewModel.refreshFollowers(),
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
                              onPressed: () => followViewModel.refreshFollowers(),
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

            if (followViewModel.followers.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => followViewModel.refreshFollowers(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'لا يوجد متابعون حتى الآن',
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
              onRefresh: () => followViewModel.refreshFollowers(),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: followViewModel.followers.length,
                      itemBuilder: (context, index) {
                                                 final follower = followViewModel.followers[index];
                         return Card(
                           margin: const EdgeInsets.only(bottom: 8),
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(12),
                           ),
                           child: ListTile(
                             contentPadding: const EdgeInsets.all(12),
                             leading: CircleAvatar(
                               radius: 25,
                               backgroundImage: (follower.followerProfileUrl != null && follower.followerProfileUrl!.isNotEmpty)
                                   ? NetworkImage(context.read<UserViewModel>().apiClient.getUserFileUrl(follower.followerProfileUrl!))
                                   : null,
                               child: (follower.followerProfileUrl == null || follower.followerProfileUrl!.isEmpty)
                                   ? const Icon(Icons.person, size: 25)
                                   : null,
                             ),
                             title: Text(
                               follower.followerName ?? 'مستخدم',
                               style: const TextStyle(
                                 fontFamily: 'Cairo',
                                 fontWeight: FontWeight.bold,
                                 fontSize: 16,
                               ),
                             ),
                             subtitle: follower.createdAt != null
                                 ? Text(
                                     'تاريخ المتابعة: ${_formatDate(follower.createdAt!)}',
                                     style: const TextStyle(
                                       fontFamily: 'Cairo',
                                       fontSize: 14,
                                       color: Colors.grey,
                                     ),
                                   )
                                 : null,
                             trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                             onTap: () {
                               if (follower.followerId != null) {
                                 Navigator.of(context).push(
                                   MaterialPageRoute(
                                     builder: (_) => SellerProfileScreen(
                                       sellerId: follower.followerId!,
                                       sellerName: follower.followerName ?? 'مستخدم',
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
                  if (_showLoadMore && followViewModel.hasMoreFollowers)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton(
                        onPressed: followViewModel.isLoadingMoreFollowers
                            ? null
                            : () => followViewModel.loadMoreFollowers(),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: followViewModel.isLoadingMoreFollowers
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