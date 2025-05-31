import '../models/user.dart';

class FakeUserRepository {
  Future<User> fetchUserProfile() async {
    await Future.delayed(Duration(seconds: 1));
    return User(
      id: '1',
      firstName: 'أحمد',
      middleName: 'محمد',
      lastName: 'خالد',
      phoneNumber: '0999999999',
      email: 'ahmad@example.com',
      profilePhoto: null,
      description: 'مستخدم تجريبي',
    );
  }

  Future<User> updateUserProfile(User user) async {
    await Future.delayed(Duration(seconds: 1));
    return user;
  }
} 