import 'package:frontend/domain/entity/user_entity.dart';

abstract class AuthRepository {
  Future<bool> checkSession();
  Future<void> getPermissions();
  Future<UserEntity> register(dynamic request);
  Future<UserEntity> login(dynamic request);
  Future<bool> logout();
  Future<bool> isLoggedIn();
  Future<void> forgotPassword(String email);
  Future<void> verifyOtp(String email, String otp);
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  });
  Future<UserEntity> loginWithGoogle(String idToken);
  Future<void> verifyEmailOtp({required String email, required String otp});
  Future<void> resendEmailOtp(String email);
}
