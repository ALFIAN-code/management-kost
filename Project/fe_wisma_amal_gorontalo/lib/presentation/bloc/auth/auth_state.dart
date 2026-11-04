import 'package:equatable/equatable.dart';
import 'package:frontend/data/model/auth/user_model.dart';
import 'package:frontend/domain/entity/user_entity.dart';
import 'package:formz/formz.dart';

class AuthState extends Equatable {
  final bool isLoggedIn;
  final UserEntity? userInfo;
  final bool obscureText;
  final FormzSubmissionStatus status;
  final String? errorMessage;
  final String? successMessage;
  final bool forgotPasswordSent;
  final bool otpVerified;
  final bool passwordResetSuccess;
  final bool emailVerified;
  final bool emailVerificationSent;

  const AuthState({
    this.isLoggedIn = false,
    this.userInfo,
    this.obscureText = true,
    this.status = FormzSubmissionStatus.initial,
    this.errorMessage,
    this.successMessage,
    this.forgotPasswordSent = false,
    this.otpVerified = false,
    this.passwordResetSuccess = false,
    this.emailVerified = false,
    this.emailVerificationSent = false,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    UserEntity? userInfo,
    bool? obscureText,
    FormzSubmissionStatus? status,
    String? errorMessage,
    String? successMessage,
    bool? forgotPasswordSent,
    bool? otpVerified,
    bool? passwordResetSuccess,
    bool? emailVerified,
    bool? emailVerificationSent,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userInfo: userInfo ?? this.userInfo,
      obscureText: obscureText ?? this.obscureText,
      status: status ?? this.status,
      errorMessage: errorMessage,
      successMessage: successMessage,
      forgotPasswordSent: forgotPasswordSent ?? this.forgotPasswordSent,
      otpVerified: otpVerified ?? this.otpVerified,
      passwordResetSuccess: passwordResetSuccess ?? this.passwordResetSuccess,
      emailVerified: emailVerified ?? this.emailVerified,
      emailVerificationSent:
          emailVerificationSent ?? this.emailVerificationSent,
    );
  }

  @override
  List<Object?> get props => [
    isLoggedIn,
    userInfo,
    obscureText,
    status,
    errorMessage,
    successMessage,
    forgotPasswordSent,
    otpVerified,
    passwordResetSuccess,
    emailVerified,
    emailVerificationSent,
  ];
}
