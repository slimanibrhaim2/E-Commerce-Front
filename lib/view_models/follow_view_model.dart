import 'package:flutter/material.dart';
import '../repositories/follow_repository.dart';

class FollowViewModel extends ChangeNotifier {
  final FollowRepository _repository;
  
  // Track loading states for specific users
  final Map<String, bool> _followingStates = {};
  final Map<String, bool> _loadingStates = {};
  String? _error;

  FollowViewModel(this._repository);

  String? get error => _error;
  
  bool isFollowing(String userId) {
    return _followingStates[userId] ?? false;
  }
  
  bool isLoading(String userId) {
    return _loadingStates[userId] ?? false;
  }

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
} 