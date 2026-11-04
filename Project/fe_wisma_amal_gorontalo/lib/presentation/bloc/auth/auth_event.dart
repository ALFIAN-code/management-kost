import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class InitLoginStatusEvent extends AuthEvent {
  const InitLoginStatusEvent();
}

class GetPermissionsEvent extends AuthEvent {
  const GetPermissionsEvent();
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterEvent extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final String passwordConfirm;

  const RegisterEvent({
    required this.username,
    required this.email,
    required this.password,
    required this.passwordConfirm,
  });

  @override
  List<Object?> get props => [username, email, password, passwordConfirm];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

class GetUserInfoEvent extends AuthEvent {
  const GetUserInfoEvent();
}

class ToggleObscureTextEvent extends AuthEvent {
  const ToggleObscureTextEvent();
}

class ResetStateEvent extends AuthEvent {
  const ResetStateEvent();
}

class CheckSessionEvent extends AuthEvent {
  const CheckSessionEvent();
}

class SessionExpiredEvent extends AuthEvent {
  const SessionExpiredEvent();
}

class GoogleLoginEvent extends AuthEvent {
  final String idToken;
  const GoogleLoginEvent({required this.idToken});

  @override
  List<Object?> get props => [idToken];
}

class ForgotPasswordEvent extends AuthEvent {
  final String email;
  const ForgotPasswordEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

class VerifyOtpEvent extends AuthEvent {
  final String email;
  final String otp;
  const VerifyOtpEvent({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}

class ResetPasswordEvent extends AuthEvent {
  final String email;
  final String otp;
  final String password;
  final String passwordConfirm;
  const ResetPasswordEvent({
    required this.email,
    required this.otp,
    required this.password,
    required this.passwordConfirm,
  });

  @override
  List<Object?> get props => [email, otp, password, passwordConfirm];
}

class VerifyEmailOtpEvent extends AuthEvent {
  final String email;
  final String otp;
  const VerifyEmailOtpEvent({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}

class ResendEmailOtpEvent extends AuthEvent {
  final String email;
  const ResendEmailOtpEvent({required this.email});

  @override
  List<Object?> get props => [email];
}
