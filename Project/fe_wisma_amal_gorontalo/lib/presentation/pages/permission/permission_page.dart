import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/domain/entity/permission_entity.dart';
import 'package:frontend/domain/entity/table/tabel_colum.dart';
import 'package:frontend/main.dart';
import 'package:frontend/presentation/bloc/permission/permission_bloc.dart';
import 'package:frontend/presentation/bloc/permission/permission_event.dart';
import 'package:frontend/presentation/bloc/permission/permission_state.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';
import 'package:frontend/presentation/widget/core/card/basic_card.dart';
import 'package:frontend/presentation/widget/core/dialog/app_dialog.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';
import 'package:frontend/presentation/widget/core/table/table.dart';
import 'package:frontend/presentation/widget/core/textform/textform.dart';

@RoutePage()
class PermissionPage extends StatelessWidget {
  const PermissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: serviceLocator<PermissionBloc>()..add(GetPermissionsEvent()),
      child: const PermissionView(),
    );
  }
}

class PermissionView extends StatelessWidget {
  const PermissionView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool canView = context.can('view-permission');

    if (!canView) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 100, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Access Denied',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text('You do not have permission to view this page.'),
            ],
          ),
        ),
      );
    }

    final bool canCreate = context.can('create-permission');
    final bool canUpdate = context.can('update-permission');
    final bool canDelete = context.can('delete-permission');

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Permission Management',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                // BasicButton(
                //   onPressed: canCreate
                //       ? () => _showPermissionForm(context)
                //       : null,
                //   label: 'Add Permission',
                //   leadIcon: Icon(
                //     Icons.add,
                //     color: canCreate ? Colors.white : Colors.grey,
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 24),
            BlocConsumer<PermissionBloc, PermissionState>(
              listener: (context, state) {
                if (state.status.isSuccess && state.successMessage != null) {
                  AppSnackbar.showSuccess(state.successMessage!);
                }
              },
              builder: (context, state) {
                if (state.status.isInProgress) {
                  return const Center(child: CircularProgressIndicator());
                }

                return TableCard(
                  title: 'System Permission List',
                  columns: const [
                    TableColumn(label: 'Permission Name', flex: 2),
                    TableColumn(label: 'Target', flex: 1),
                    TableColumn(label: 'Description', flex: 3),
                  ],
                  rows: state.permissions.map((p) {
                    return [p.name, p.target ?? '-', p.description ?? '-'];
                  }).toList(),
                  // Note: Since TableCard currently only accepts List<String>,
                  // we need a small modification or to wrap the action buttons.
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPermissionForm(
    BuildContext context, {
    PermissionEntity? permission,
  }) {
    final nameController = TextEditingController(text: permission?.name);
    final targetController = TextEditingController(text: permission?.target);
    final descController = TextEditingController(text: permission?.description);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(permission == null ? 'Add Permission' : 'Edit Permission'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextForm(
              title: 'Permission Name',
              hintText: 'e.g. manage-users',
              controller: nameController,
            ),
            const SizedBox(height: 16),
            CustomTextForm(
              title: 'Target',
              hintText: 'admin / user',
              controller: targetController,
            ),
            const SizedBox(height: 16),
            CustomTextForm(
              title: 'Description',
              hintText: 'Explanation of the permission function',
              controller: descController,
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          BasicButton(
            onPressed: () {
              final entity = PermissionEntity(
                id: permission?.id ?? 0,
                name: nameController.text,
                target: targetController.text,
                description: descController.text,
              );
              if (permission == null) {
                context.read<PermissionBloc>().add(AddPermissionEvent(entity));
              } else {
                context.read<PermissionBloc>().add(
                  UpdatePermissionEvent(entity),
                );
              }
              Navigator.pop(dialogContext);
            },
            label: 'Save',
          ),
        ],
      ),
    );
  }
}
