import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:frontend/core/services/network/exception.dart';
import 'package:frontend/domain/usecase/permission/create_permission_usecase.dart';
import 'package:frontend/domain/usecase/permission/delete_permission_usecase.dart';
import 'package:frontend/domain/usecase/permission/get_permission_list_usecase.dart';
import 'package:frontend/domain/usecase/permission/update_permission_usecase.dart';
import 'package:frontend/domain/usecase/usecase.dart';
import 'package:frontend/presentation/bloc/permission/permission_event.dart';
import 'package:frontend/presentation/bloc/permission/permission_state.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';

class PermissionBloc extends Bloc<PermissionEvent, PermissionState> {
  final GetPermissionListUseCase getPermissionsUseCase;
  final CreatePermissionUseCase createPermissionUseCase;
  final UpdatePermissionUseCase updatePermissionUseCase;
  final DeletePermissionUseCase deletePermissionUseCase;

  PermissionBloc({
    required this.getPermissionsUseCase,
    required this.createPermissionUseCase,
    required this.updatePermissionUseCase,
    required this.deletePermissionUseCase,
  }) : super(const PermissionState()) {
    on<GetPermissionsEvent>(_onGetPermissions);
    on<AddPermissionEvent>(_onAddPermission);
    on<UpdatePermissionEvent>(_onUpdatePermission);
    on<DeletePermissionEvent>(_onDeletePermission);
  }

  Future<void> _onGetPermissions(
    GetPermissionsEvent event,
    Emitter<PermissionState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      final result = await getPermissionsUseCase(NoParams());
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.success,
          permissions: result,
        ),
      );
    } on AppException catch (e) {
      AppSnackbar.showError('Failed to load permissions: ${e.message}');
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onAddPermission(
    AddPermissionEvent event,
    Emitter<PermissionState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await createPermissionUseCase(event.permission);
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.success,
          successMessage: "Permission added successfully",
        ),
      );
      add(GetPermissionsEvent()); // Refresh data after add
    } on AppException catch (e) {
      AppSnackbar.showError('Failed to add permission: ${e.message}');
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdatePermission(
    UpdatePermissionEvent event,
    Emitter<PermissionState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await updatePermissionUseCase(event.permission);
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.success,
          successMessage: "Permission updated successfully",
        ),
      );
      add(GetPermissionsEvent()); // Refresh data after update
    } on AppException catch (e) {
      AppSnackbar.showError('Failed to update permission: ${e.message}');
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeletePermission(
    DeletePermissionEvent event,
    Emitter<PermissionState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      final success = await deletePermissionUseCase(event.id);
      if (success) {
        emit(
          state.copyWith(
            status: FormzSubmissionStatus.success,
            successMessage: "Permission deleted successfully",
          ),
        );
        add(GetPermissionsEvent()); // Refresh data after delete
      }
    } on AppException catch (e) {
      AppSnackbar.showError('Failed to delete permission: ${e.message}');
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
