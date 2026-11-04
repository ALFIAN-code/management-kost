import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/constant/endpoint_constant.dart';
import 'package:frontend/core/services/network/dio_client.dart';
import 'package:frontend/core/services/storage/shared_prefrence.dart';
import 'package:frontend/data/model/auth/auth_request_model.dart';
import 'package:frontend/data/model/auth/auth_response_model.dart';
import 'package:frontend/data/model/base_response_model.dart';

class AuthDatasource {
  AuthDatasource({required this.dioClient});

  final DioClient dioClient;

  Future<BaseResponseModel<AuthResponseModel>> register(
    AuthRequestModel request,
  ) async {
    try {
      final response = await dioClient.post(
        EndpointConstant.registerEndpoint,
        data: request.toJson(),
      );
      return BaseResponseModel<AuthResponseModel>.fromJson(
        response.data,
        (json) => AuthResponseModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<BaseResponseModel<AuthResponseModel>> login(
    AuthRequestModel request,
  ) async {
    try {
      final response = await dioClient.post(
        EndpointConstant.loginEndpoint,
        data: request.toJson(),
      );
      final baseResponse = BaseResponseModel<AuthResponseModel>.fromJson(
        response.data,
        (json) => AuthResponseModel.fromJson(json),
      );
      return baseResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkSession() async {
    try {
      final response = await dioClient.get(
        EndpointConstant.checkSessionEndpoint,
      );
      var data = BaseResponseModel.fromJson(response.data, (json) {});
      if (response.statusCode == 200) {
        return data.status;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<BaseResponseModel<Map<String, dynamic>>> getPermissions() async {
    try {
      final response = await dioClient.get(EndpointConstant.permissionEndpoint);
      final baseResponse = BaseResponseModel<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => Map<String, dynamic>.from(json as Map),
      );
      return baseResponse;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<bool> logout() async {
    try {
      var response = await dioClient.post(EndpointConstant.logoutEndpoint);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<BaseResponseModel<dynamic>> forgotPassword(String email) async {
    try {
      final response = await dioClient.post(
        EndpointConstant.forgotPasswordEndpoint,
        data: {'email': email},
      );
      return BaseResponseModel.fromJson(response.data, (json) => json);
    } catch (e) {
      rethrow;
    }
  }

  Future<BaseResponseModel<dynamic>> verifyOtp(String email, String otp) async {
    try {
      final response = await dioClient.post(
        EndpointConstant.verifyOtpEndpoint,
        data: {'email': email, 'otp': otp},
      );
      return BaseResponseModel.fromJson(response.data, (json) => json);
    } catch (e) {
      rethrow;
    }
  }

  Future<BaseResponseModel<dynamic>> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await dioClient.post(
        EndpointConstant.resetPasswordEndpoint,
        data: {
          'email': email,
          'otp': otp,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
      return BaseResponseModel.fromJson(response.data, (json) => json);
    } catch (e) {
      rethrow;
    }
  }

  Future<BaseResponseModel<AuthResponseModel>> loginWithGoogle(
    String idToken,
  ) async {
    try {
      final response = await dioClient.post(
        EndpointConstant.googleLoginEndpoint,
        data: {'id_token': idToken},
      );
      return BaseResponseModel<AuthResponseModel>.fromJson(
        response.data,
        (json) => AuthResponseModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<BaseResponseModel<dynamic>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await dioClient.post(
        EndpointConstant.verifyEmailOtpEndpoint,
        data: {'email': email, 'otp': otp},
      );
      return BaseResponseModel.fromJson(response.data, (json) => json);
    } catch (e) {
      rethrow;
    }
  }

  Future<BaseResponseModel<dynamic>> resendEmailOtp({
    required String email,
  }) async {
    try {
      final response = await dioClient.post(
        EndpointConstant.resendEmailOtpEndpoint,
        data: {'email': email},
      );
      return BaseResponseModel.fromJson(response.data, (json) => json);
    } catch (e) {
      rethrow;
    }
  }
}
