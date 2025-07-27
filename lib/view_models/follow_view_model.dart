import 'package:flutter/material.dart';
import '../repositories/follow_repository.dart';
import '../models/follower.dart';
import '../models/following.dart';
import '../core/api/api_response.dart';

class FollowViewModel extends ChangeNotifier {
  final FollowRepository _repository;
  
  // Track loading states for specific users
  final Map<String, bool> _followingStates = {};
  final Map<String, bool> _loadingStates = {};
  String? _error;

  // Followers and Following data
  List<Follower> _followers = [];
  List<Following> _following = [];
  bool _isLoadingFollowers = false;
  bool _isLoadingFollowing = false;
  bool _isLoadingMoreFollowers = false;
  bool _isLoadingMoreFollowing = false;
  
  // Pagination for followers
  int _followersCurrentPage = 1;
  int _followersPageSize = 10;
  bool _hasMoreFollowers = true;
  int _followersTotalCount = 0;
  int _followersTotalPages = 0;
  
  // Pagination for following
  int _followingCurrentPage = 1;
  int _followingPageSize = 10;
  bool _hasMoreFollowing = true;
  int _followingTotalCount = 0;
  int _followingTotalPages = 0;

  FollowViewModel(this._repository);

  String? get error => _error;
  
  bool isFollowing(String userId) {
    return _followingStates[userId] ?? false;
  }
  
  bool isLoading(String userId) {
    return _loadingStates[userId] ?? false;
  }

  // Getters for followers and following
  List<Follower> get followers => _followers;
  List<Following> get following => _following;
  bool get isLoadingFollowers => _isLoadingFollowers;
  bool get isLoadingFollowing => _isLoadingFollowing;
  bool get isLoadingMoreFollowers => _isLoadingMoreFollowers;
  bool get isLoadingMoreFollowing => _isLoadingMoreFollowing;
  bool get hasMoreFollowers => _hasMoreFollowers;
  bool get hasMoreFollowing => _hasMoreFollowing;
  int get followersTotalCount => _followersTotalCount;
  int get followingTotalCount => _followingTotalCount;

  void setFollowingState(String userId, bool isFollowing) {
    _followingStates[userId] = isFollowing;
    notifyListeners();
  }

  Future<bool> followUser(String userId) async {
    try {
      _loadingStates[userId] = true;
      _error = null;
      notifyListeners();

      print('Following user: $userId');
      final response = await _repository.followUser(userId);
      
             if (response.success) {
         _followingStates[userId] = true;
         // Refresh following list to show the new follow
         _refreshFollowingInBackground();
         notifyListeners();
         return true;
      } else {
        _error = response.message ?? 'فشل في المتابعة';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _loadingStates[userId] = false;
      notifyListeners();
    }
  }

  Future<bool> unfollowUser(String userId) async {
    try {
      _loadingStates[userId] = true;
      _error = null;
      notifyListeners();

      print('Unfollowing user: $userId');
      // For unfollow, we use the userId as followingId since we get it from seller info
      final response = await _repository.unfollowUser(userId);
      
             if (response.success) {
         _followingStates[userId] = false;
         // Refresh following list to remove the unfollowed user
         _refreshFollowingInBackground();
         notifyListeners();
         return true;
      } else {
        _error = response.message ?? 'فشل في إلغاء المتابعة';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _loadingStates[userId] = false;
      notifyListeners();
    }
  }

  Future<bool> toggleFollow(String userId) async {
    final currentlyFollowing = isFollowing(userId);
    
    if (currentlyFollowing) {
      return await unfollowUser(userId);
    } else {
      return await followUser(userId);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Load followers
  Future<void> loadFollowers() async {
    if (_isLoadingFollowers) return;

    _isLoadingFollowers = true;
    _followersCurrentPage = 1;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getMyFollowers(
        pageNumber: _followersCurrentPage,
        pageSize: _followersPageSize,
      );

      if (response.success && response.data != null) {
        _followers = response.data!;
        _updateFollowersPagination(response.metadata);
      } else {
        _error = response.message ?? 'فشل في جلب المتابعين';
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingFollowers = false;
      notifyListeners();
    }
  }

  // Load more followers
  Future<void> loadMoreFollowers() async {
    if (_isLoadingMoreFollowers || !_hasMoreFollowers) return;

    _isLoadingMoreFollowers = true;
    notifyListeners();

    try {
      final response = await _repository.getMyFollowers(
        pageNumber: _followersCurrentPage + 1,
        pageSize: _followersPageSize,
      );

      if (response.success && response.data != null) {
        _followers.addAll(response.data!);
        _followersCurrentPage++;
        _updateFollowersPagination(response.metadata);
      } else {
        _error = response.message ?? 'فشل في جلب المتابعين';
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingMoreFollowers = false;
      notifyListeners();
    }
  }

  // Load following
  Future<void> loadFollowing() async {
    if (_isLoadingFollowing) return;

    _isLoadingFollowing = true;
    _followingCurrentPage = 1;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getMyFollowing(
        pageNumber: _followingCurrentPage,
        pageSize: _followingPageSize,
      );

      if (response.success && response.data != null) {
        _following = response.data!;
        _updateFollowingPagination(response.metadata);
      } else {
        _error = response.message ?? 'فشل في جلب المتابعين';
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingFollowing = false;
      notifyListeners();
    }
  }

  // Load more following
  Future<void> loadMoreFollowing() async {
    if (_isLoadingMoreFollowing || !_hasMoreFollowing) return;

    _isLoadingMoreFollowing = true;
    notifyListeners();

    try {
      final response = await _repository.getMyFollowing(
        pageNumber: _followingCurrentPage + 1,
        pageSize: _followingPageSize,
      );

      if (response.success && response.data != null) {
        _following.addAll(response.data!);
        _followingCurrentPage++;
        _updateFollowingPagination(response.metadata);
      } else {
        _error = response.message ?? 'فشل في جلب المتابعين';
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingMoreFollowing = false;
      notifyListeners();
    }
  }

  // Refresh followers
  Future<void> refreshFollowers() async {
    _followersCurrentPage = 1;
    _hasMoreFollowers = true;
    await loadFollowers();
  }

  // Refresh following
  Future<void> refreshFollowing() async {
    _followingCurrentPage = 1;
    _hasMoreFollowing = true;
    await loadFollowing();
  }

  void _updateFollowersPagination(Map<String, dynamic>? metadata) {
    if (metadata != null) {
      _followersTotalCount = metadata['totalCount'] ?? 0;
      _followersTotalPages = metadata['totalPages'] ?? 0;
      _hasMoreFollowers = metadata['hasNextPage'] ?? false;
    }
  }

  void _updateFollowingPagination(Map<String, dynamic>? metadata) {
    if (metadata != null) {
      _followingTotalCount = metadata['totalCount'] ?? 0;
      _followingTotalPages = metadata['totalPages'] ?? 0;
      _hasMoreFollowing = metadata['hasNextPage'] ?? false;
    }
  }

  // Background refresh methods (don't show loading indicators)
  void _refreshFollowingInBackground() {
    _repository.getMyFollowing(pageNumber: 1, pageSize: _followingPageSize).then((response) {
      if (response.success && response.data != null) {
        _following = response.data!;
        _followingCurrentPage = 1;
        _updateFollowingPagination(response.metadata);
        notifyListeners();
      }
    }).catchError((e) {
      // Silently handle error for background refresh
      print('Background refresh following error: $e');
    });
  }

  void _refreshFollowersInBackground() {
    _repository.getMyFollowers(pageNumber: 1, pageSize: _followersPageSize).then((response) {
      if (response.success && response.data != null) {
        _followers = response.data!;
        _followersCurrentPage = 1;
        _updateFollowersPagination(response.metadata);
        notifyListeners();
      }
    }).catchError((e) {
      // Silently handle error for background refresh
      print('Background refresh followers error: $e');
    });
  }
} 