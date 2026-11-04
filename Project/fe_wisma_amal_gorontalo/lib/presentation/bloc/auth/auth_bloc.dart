import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:frontend/core/constant/storage_constant.dart';
import 'package:frontend/core/services/network/exception.dart';
import 'package:frontend/core/services/storage/shared_prefrence.dart';
import 'package:frontend/data/model/auth/auth_request_model.dart';
import 'package:frontend/domain/usecase/auth/check_session_usecase.dart';
import 'package:frontend/domain/usecase/auth/get_permissions_usecase.dart';
import 'package:frontend/domain/usecase/auth/is_logged_in_usecase.dart';
import 'package:frontend/domain/usecase/auth/login_usecase.dart';
import 'package:frontend/domain/usecase/auth/logout_usecase.dart';
import 'package:frontend/domain/usecase/auth/register_usecase.dart';
import 'package:frontend/domain/usecase/usecase.dart';
import 'package:frontend/domain/repository/auth_repository.dart';
import 'package:frontend/domain/entity/permission_entity.dart';
import 'package:frontend/domain/entity/user_entity.dart';
import 'package:frontend/presentation/bloc/auth/auth_event.dart';
import 'package:frontend/presentation/bloc/auth/auth_state.dart';
import 'package:frontend/presentation/bloc/setting/feature_toggle/feature_toggle_bloc.dart';
import 'package:frontend/presentation/bloc/setting/feature_toggle/feature_toggle_event.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';

class AuthStateNotifier extends ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  set isLoggedIn(bool value) {
    if (_isLoggedIn != value) {
      _isLoggedIn = value;
      notifyListeners();
    }
  }
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CheckSessionUseCase checkSessionUseCase;
  final GetPermissionsUseCase getPermissionsUseCase;
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final IsLoggedInUseCase isLoggedInUseCase;
  final SharedPrefsStorage storage;
  final AuthStateNotifier loginStatusNotifier = AuthStateNotifier();
  Timer? _sessionTimer;

  AuthBloc({
    required this.checkSessionUseCase,
    required this.getPermissionsUseCase,
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.isLoggedInUseCase,
    required this.storage,
  }) : super(const AuthState()) {
    on<InitLoginStatusEvent>(_onInitLoginStatus);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<GetUserInfoEvent>(_onGetUserInfo);
    on<GetPermissionsEvent>(_onGetPermissions);
    on<ToggleObscureTextEvent>(_onToggleObscureText);
    on<SessionExpiredEvent>(_onSessionExpired);
    on<GoogleLoginEvent>(_onGoogleLogin);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<ResetPasswordEvent>(_onResetPassword);
    on<VerifyEmailOtpEvent>(_onVerifyEmailOtp);
    on<ResendEmailOtpEvent>(_onResendEmailOtp);
    on<ResetStateEvent>((event, emit) {
      emit(const AuthState());
    });
    add(const InitLoginStatusEvent());
    on<CheckSessionEvent>((event, emit) async {
      _sessionTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
        _checkSession();
      });
    });
  }

  Future<void> _onGetPermissions(
    GetPermissionsEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await getPermissionsUseCase(NoParams());

      final currentUser = state.userInfo;
      if (currentUser == null) return;

      final newPermissions = Permissions(
        storage.getPermissions()?.toSet() ?? {},
      );
      final newRoles =
          storage.getList(StorageConstant.roleActive) ?? currentUser.roles;

      final permissionsChanged = !_setsEqual(
        currentUser.permissions?.raw ?? {},
        newPermissions.raw,
      );
      final rolesChanged = !_setsEqual(
        currentUser.roles.toSet(),
        newRoles.toSet(),
      );

      if (permissionsChanged || rolesChanged) {
        final updatedUser = currentUser.copyWith(
          permissions: newPermissions,
          roles: newRoles,
        );
        emit(state.copyWith(userInfo: updatedUser));
      }
    } on AppException catch (e) {
      debugPrint('Error fetching permissions: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error fetching permissions: $e');
    }
  }

  bool _setsEqual(Set<String> a, Set<String> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }

  Future<void> _checkSession() async {
    try {
      final isValid = await checkSessionUseCase(NoParams());
      if (!isValid) {
        add(const LogoutEvent());
        AppSnackbar.showError(
          'Your session has expired. Please sign in again.',
        );
      } else {
        // Refresh permissions every time the session is checked (every 5 minutes)
        add(const GetPermissionsEvent());
      }
    } on AppException catch (e) {
      print('Error checking session: ${e.message}');
    } catch (e) {
      print('Unexpected error checking session: $e');
    }
  }

  void _onInitLoginStatus(
    InitLoginStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    print('Initializing login status...');
    final status = await isLoggedInUseCase(NoParams());

    // The permission endpoint can be accessed with or without a token,
    // so it is safe to always refresh at the start.
    try {
      await getPermissionsUseCase(NoParams());
    } catch (e) {
      debugPrint('Failed to refresh permissions on init: $e');
    }

    loginStatusNotifier.isLoggedIn = status;
    print('Login status initialized: $status');

    if (status) {
      final email = storage.get(StorageConstant.email);
      final username = storage.get(StorageConstant.userName);
      final userId = storage.getInt(StorageConstant.userId);
      final role = storage.getList(StorageConstant.roleActive);
      final permissions = Permissions(storage.getPermissions()?.toSet() ?? {});

      final userInfo = UserEntity(
        email: email ?? '',
        name: username ?? '',
        id: userId ?? 0,
        roles: role ?? [],
        permissions: permissions,
      );
      serviceLocator<FeatureToggleBloc>().add(FetchFeatureToggles());
      emit(state.copyWith(isLoggedIn: status, userInfo: userInfo));
    } else {
      final permissions = Permissions(storage.getPermissions()?.toSet() ?? {});
      final guestUser = UserEntity(
        id: null,
        name: 'Guest',
        email: '',
        roles: const [],
        permissions: permissions,
      );
      emit(state.copyWith(isLoggedIn: status, userInfo: guestUser));
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(
      state.copyWith(
        status: FormzSubmissionStatus.inProgress,
        errorMessage: null,
      ),
    );

    try {
      final result = await loginUseCase(
        AuthRequestModel(email: event.email, password: event.password),
      );

      final isLoggedIn = await isLoggedInUseCase(NoParams());

      if (isLoggedIn) {
        add(const GetUserInfoEvent());
        serviceLocator<FeatureToggleBloc>().add(FetchFeatureToggles());
        emit(
          state.copyWith(
            isLoggedIn: true,
            userInfo: result,
            status: FormzSubmissionStatus.success,
            successMessage: 'Login successful!',
          ),
        );
      }
      AppSnackbar.showSuccess('Login successful!');
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.message,
        ),
      );
      AppSnackbar.showError('Login failed: ${e.message}');
    } catch (e) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
      AppSnackbar.showError('Login failed: ${e.toString()}');
    }
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(
      state.copyWith(
        status: FormzSubmissionStatus.inProgress,
        errorMessage: null,
      ),
    );

    try {
      final result = await registerUseCase(
        AuthRequestModel(
          email: event.email,
          password: event.password,
          username: event.username,
          passwordConfirmation: event.passwordConfirm,
        ),
      );

      final isLoggedIn = await isLoggedInUseCase(NoParams());

      if (isLoggedIn) {
        add(const GetUserInfoEvent());
        serviceLocator<FeatureToggleBloc>().add(FetchFeatureToggles());
        emit(
          state.copyWith(
            isLoggedIn: true,
            userInfo: result,
            status: FormzSubmissionStatus.success,
            successMessage: 'Register successful!',
          ),
        );
      }
      AppSnackbar.showSuccess('Register successful!');
    } on AppException catch (e) {
      AppSnackbar.showError('Register failed: ${e.message}');
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      AppSnackbar.showError('Register failed: ${e.toString()}');
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    try {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
      await logoutUseCase(NoParams());
      emit(
        const AuthState(
          status: FormzSubmissionStatus.initial,
          isLoggedIn: false,
        ),
      );
    } on AppException catch (e) {
      AppSnackbar.showError('Logout failed: ${e.message}');
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.message,
          isLoggedIn: false,
        ),
      );
    } catch (e) {
      AppSnackbar.showError('Logout failed: ${e.toString()}');
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.toString(),
          isLoggedIn: false,
        ),
      );
    }
  }

  Future<void> _onSessionExpired(
    SessionExpiredEvent event,
    Emitter<AuthState> emit,
  ) async {
    print('Handling Session Expired Event...');
    try {
      // 1. Clear local storage & token directly to be sure
      await storage.clear();
      // insecure but since secureStorage is internal to repository, we use repository via logoutUseCase or similar
      // Actually, better to use the repository functionality if possible
      // but logoutUseCase might call the API.
      // Let's just reset the state and let the session initialization handle it.

      // Emit guest state
      emit(
        const AuthState(
          status: FormzSubmissionStatus.initial,
          isLoggedIn: false,
        ),
      );

      loginStatusNotifier.isLoggedIn = false;

      // Update permissions as guest
      await getPermissionsUseCase(NoParams());

      AppSnackbar.showError('Your session has expired. Please sign in again.');
    } catch (e) {
      print('Error during session expiration handling: $e');
    }
  }

  void _onGetUserInfo(GetUserInfoEvent event, Emitter<AuthState> emit) {
    try {
      final email = storage.get(StorageConstant.email);
      final username = storage.get(StorageConstant.userName);
      final userId = storage.getInt(StorageConstant.userId);
      final role = storage.getList(StorageConstant.roleActive);
      final permissions = Permissions(storage.getPermissions()?.toSet() ?? {});

      final userInfo = UserEntity(
        email: email ?? '',
        name: username ?? '',
        id: userId ?? 0,
        roles: role ?? [],
        permissions: permissions,
      );

      emit(state.copyWith(userInfo: userInfo));
    } on AppException catch (e) {
      AppSnackbar.showError('Failed to get user information: ${e.message}');
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.message,
          isLoggedIn: false,
        ),
      );
    } catch (e) {
      AppSnackbar.showError('Failed to get user information: ${e.toString()}');
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.toString(),
          isLoggedIn: false,
        ),
      );
    }
  }

  void _onToggleObscureText(
    ToggleObscureTextEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(obscureText: !state.obscureText));
  }

  Future<void> _onGoogleLogin(
    GoogleLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: FormzSubmissionStatus.inProgress,
        errorMessage: null,
      ),
    );
    try {
      final authRepo = serviceLocator.get<AuthRepository>();
      final user = await authRepo.loginWithGoogle(event.idToken);
      final isLoggedIn = await isLoggedInUseCase(NoParams());
      if (isLoggedIn) {
        add(const GetUserInfoEvent());
        serviceLocator<FeatureToggleBloc>().add(FetchFeatureToggles());
        emit(
          state.copyWith(
            isLoggedIn: true,
            userInfo: user,
            status: FormzSubmissionStatus.success,
            successMessage: 'Berhasil masuk dengan Google!',
          ),
        );
      }
      AppSnackbar.showSuccess('Berhasil masuk dengan Google!');
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.message,
        ),
      );
      AppSnackbar.showError(e.message);
    } catch (e) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
      AppSnackbar.showError(e.toString());
    }
  }

  Future<void> _onForgotPassword(
    ForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: FormzSubmissionStatus.inProgress,
        errorMessage: null,
        forgotPasswordSent: false,
      ),
    );
    try {
      final authRepo = serviceLocator.get<AuthRepository>();
      await authRepo.forgotPassword(event.email);
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.success,
          forgotPasswordSent: true,
          successMessage: 'Kode OTP telah dikirimkan ke email Anda.',
        ),
      );
      AppSnackbar.showSuccess('Kode OTP telah dikirimkan ke email Anda.');
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.message,
        ),
      );
      AppSnackbar.showError(e.message);
    } catch (e) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
      AppSnackbar.showError(e.toString());
    }
  }

  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: FormzSubmissionStatus.inProgress,
        errorMessage: null,
        otpVerified: false,
      ),
    );
    try {
      final authRepo = serviceLocator.get<AuthRepository>();
      await authRepo.verifyOtp(event.email, event.otp);
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.success,
          otpVerified: true,
          successMessage: 'Kode OTP terverifikasi.',
        ),
      );
      AppSnackbar.showSuccess('Kode OTP berhasil diverifikasi.');
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.message,
        ),
      );
      AppSnackbar.showError(e.message);
    } catch (e) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
      AppSnackbar.showError(e.toString());
    }
  }

  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: FormzSubmissionStatus.inProgress,
        errorMessage: null,
        passwordResetSuccess: false,
      ),
    );
    try {
      final authRepo = serviceLocator.get<AuthRepository>();
      await authRepo.resetPassword(
        email: event.email,
        otp: event.otp,
        password: event.password,
        passwordConfirmation: event.passwordConfirm,
      );
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.success,
          passwordResetSuccess: true,
          successMessage:
              'Kata sandi berhasil direset! Silakan login dengan kata sandi baru.',
        ),
      );
      AppSnackbar.showSuccess('Kata sandi berhasil direset! Silakan login.');
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.message,
        ),
      );
      AppSnackbar.showError(e.message);
    } catch (e) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
      AppSnackbar.showError(e.toString());
    }
  }

  Future<void> _onVerifyEmailOtp(
    VerifyEmailOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: FormzSubmissionStatus.inProgress,
        errorMessage: null,
        emailVerified: false,
      ),
    );
    try {
      final authRepo = serviceLocator.get<AuthRepository>();
      await authRepo.verifyEmailOtp(email: event.email, otp: event.otp);
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.success,
          emailVerified: true,
          successMessage: 'Alamat email berhasil diverifikasi!',
        ),
      );
      AppSnackbar.showSuccess('Alamat email berhasil diverifikasi!');
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.message,
        ),
      );
      AppSnackbar.showError(e.message);
    } catch (e) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
      AppSnackbar.showError(e.toString());
    }
  }

  Future<void> _onResendEmailOtp(
    ResendEmailOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: FormzSubmissionStatus.inProgress,
        errorMessage: null,
        emailVerificationSent: false,
      ),
    );
    try {
      final authRepo = serviceLocator.get<AuthRepository>();
      await authRepo.resendEmailOtp(event.email);
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.success,
          emailVerificationSent: true,
          successMessage:
              'Kode verifikasi baru telah dikirimkan ke email Anda.',
        ),
      );
      AppSnackbar.showSuccess(
        'Kode verifikasi baru telah dikirimkan ke email Anda.',
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.message,
        ),
      );
      AppSnackbar.showError(e.message);
    } catch (e) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
      AppSnackbar.showError(e.toString());
    }
  }

  @override
  Future<void> close() {
    _sessionTimer?.cancel();
    loginStatusNotifier.dispose();
    return super.close();
  }
}
