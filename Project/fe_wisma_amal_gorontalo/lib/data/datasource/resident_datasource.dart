import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:frontend/core/services/network/dio_client.dart';
import 'package:frontend/domain/entity/resident/resident_entity.dart';
import 'package:frontend/domain/entity/resident/resident_detail_entity.dart';
import 'package:frontend/domain/entity/resident/resident_profile_entity.dart';
import 'package:frontend/data/model/resident/resident_detail_model.dart';
import 'package:frontend/data/model/resident/resident_profile_model.dart';

class ResidentDatasource {
  final DioClient dioClient;

  ResidentDatasource({required this.dioClient});

  /// Fetches the list of all residents for the Admin page (with pagination and filters)
  Future<ResidentResponse> getAdminResidents({
    int page = 1,
    int perPage = 10,
    String? search,
    String? status,
    String? payment,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'per_page': perPage,
      };

      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (status != null) queryParams['status'] = status;
      if (payment != null) queryParams['payment'] = payment;

      final response = await dioClient.get(
        '/v1/room-schedules',
        queryParams: queryParams,
      );

      return ResidentResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches the specific details of a single resident
  Future<ResidentDetailEntity> getAdminResidentDetail(String id) async {
    try {
      // Adjust this URL if the detail endpoint differs on the backend
      final response = await dioClient.get('/v1/room-schedules/$id');
      return ResidentDetailModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches the profile data of the currently signed-in resident
  Future<ResidentProfileEntity> getProfile() async {
    try {
      // Retrieved from the backend Auth Module endpoint you already have
      final response = await dioClient.get('/resident/profile');
      return ResidentProfileModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  /// Completes the resident's personal data profile (including ID card photo upload)
  Future<ResidentProfileEntity> completeProfile({
    required String idCardNumber,
    required String phoneNumber,
    required String gender,
    String? job,
    required String addressKtp,
    String? emergencyContactName,
    String? emergencyContactPhone,
    PlatformFile? ktpPhoto,
  }) async {
    try {
      // Using FormData because there may be file uploads (Multipart/form-data)
      FormData formData = FormData.fromMap({
        'id_card_number': idCardNumber,
        'phone_number': phoneNumber,
        'gender': gender,
        'address_ktp': addressKtp,
        if (job != null) 'job': job,
        if (emergencyContactName != null)
          'emergency_contact_name': emergencyContactName,
        if (emergencyContactPhone != null)
          'emergency_contact_phone': emergencyContactPhone,
      });

      // Attaches the ID card file if the user selects one
      if (ktpPhoto != null) {
        if (ktpPhoto.bytes != null) {
          formData.files.add(
            MapEntry(
              'ktp_photo',
              MultipartFile.fromBytes(ktpPhoto.bytes!, filename: ktpPhoto.name),
            ),
          );
        } else if (ktpPhoto.path != null) {
          formData.files.add(
            MapEntry(
              'ktp_photo',
              await MultipartFile.fromFile(
                ktpPhoto.path!,
                filename: ktpPhoto.name,
              ),
            ),
          );
        }
      }

      final response = await dioClient.post(
        '/resident/profile',
        data: formData,
      );
      return ResidentProfileModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }
}
