import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/utils/image_utils.dart';
import 'package:frontend/presentation/bloc/resident/complete_profile/complete_profile_bloc.dart';
import 'package:frontend/presentation/bloc/resident/complete_profile/complete_profile_event.dart';
import 'package:frontend/presentation/bloc/resident/complete_profile/complete_profile_state.dart';
import 'package:frontend/presentation/widget/core/card/basic_card.dart';
import 'package:frontend/presentation/widget/core/textform/textform.dart';
import 'package:frontend/presentation/widget/core/textform/dropdown_field.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:frontend/presentation/bloc/auth/auth_event.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';

@RoutePage()
class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nikController = TextEditingController();
  final _phoneController = TextEditingController();
  final _jobController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  String _gender = 'male';
  PlatformFile? _ktpPhoto;
  String? _existingKtpPhotoUrl;

  Future<void> _pickImage() async {
    final results = await ImageUtils.pickImagesWeb();
    if (results.isNotEmpty) {
      setState(() {
        _ktpPhoto = results.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) =>
          serviceLocator<CompleteProfileBloc>()..add(LoadProfileEvent()),
      child: BlocListener<CompleteProfileBloc, CompleteProfileState>(
        listener: (context, state) {
          if (state is CompleteProfileLoaded) {
            _nikController.text = state.profile.idCardNumber;
            _phoneController.text = state.profile.phoneNumber;
            _jobController.text = state.profile.job ?? '';
            _addressController.text = state.profile.addressKtp;
            _emergencyNameController.text =
                state.profile.emergencyContactName ?? '';
            _emergencyPhoneController.text =
                state.profile.emergencyContactPhone ?? '';
            setState(() {
              _gender = state.profile.gender;
              _existingKtpPhotoUrl = state.profile.ktpPhotoUrl;
            });
          }
          if (state is CompleteProfileSuccess) {
            AppSnackbar.showSuccess('Profile successfully saved.');
            // Refresh Auth state to update permissions/roles
            context.read<AuthBloc>().add(const InitLoginStatusEvent());
            context.router.pop();
          } else if (state is CompleteProfileFailure) {
            AppSnackbar.showError('Failed: ${state.message}');
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Complete Resident Profile'),
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: theme.colorScheme.onSurface,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile Information',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please complete your personal information to continue the room booking process.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),

                  BasicCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(theme, 'Personal Information'),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextForm(
                                controller: _nikController,
                                title: 'NIK (ID Number)',
                                isRequired: true,
                                hintText: 'Enter the 16-digit NIK',
                                validator: (v) =>
                                    v!.isEmpty ? 'Is required' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomTextForm(
                                controller: _phoneController,
                                title: 'Phone Number',
                                isRequired: true,
                                hintText: 'Example: 08123456789',
                                validator: (v) =>
                                    v!.isEmpty ? 'Is required' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CustomDropdownField<String>(
                                title: 'Gender',
                                isRequired: true,
                                hint: 'Select gender',
                                value: _gender,
                                items: const ['male', 'female']
                                    .map((e) => DropdownMenuItem(value: e, child: Text(e == 'male' ? 'Male' : 'Female')))
                                    .toList(),
                                onChanged: (v) => setState(() => _gender = v!),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomTextForm(
                                controller: _jobController,
                                title: 'Occupation',
                                hintText: 'Example: Student, Employee',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CustomTextForm(
                          controller: _addressController,
                          title: 'ID Card Address',
                          isRequired: true,
                          hintText: 'Enter the full address as stated on your ID card',
                          maxLines: 3,
                          validator: (v) => v!.isEmpty ? 'Is required' : null,
                        ),

                        const SizedBox(height: 32),
                        _buildSectionTitle(theme, 'Emergency Contact'),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextForm(
                                controller: _emergencyNameController,
                                title: 'Emergency Contact Name',
                                hintText: 'Parent or guardian name',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomTextForm(
                                controller: _emergencyPhoneController,
                                title: 'Emergency Phone Number',
                                hintText: 'Example: 08123456789',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),
                        _buildSectionTitle(theme, 'ID Card Photo'),
                        const SizedBox(height: 16),
                        _buildImagePicker(theme),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  BlocBuilder<CompleteProfileBloc, CompleteProfileState>(
                    builder: (context, state) {
                      return BasicButton(
                        label: 'SAVE PROFILE',
                        isLoading: state is CompleteProfileLoading,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<CompleteProfileBloc>().add(
                              SubmitProfileEvent(
                                idCardNumber: _nikController.text,
                                phoneNumber: _phoneController.text,
                                gender: _gender,
                                job: _jobController.text,
                                addressKtp: _addressController.text,
                                emergencyContactName:
                                    _emergencyNameController.text,
                                emergencyContactPhone:
                                    _emergencyPhoneController.text,
                                ktpPhoto: _ktpPhoto,
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 64),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Container(width: 40, height: 2, color: theme.colorScheme.primary),
      ],
    );
  }

  Widget _buildImagePicker(ThemeData theme) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        ),
        child: _ktpPhoto != null && _ktpPhoto!.bytes != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(_ktpPhoto!.bytes!, fit: BoxFit.cover),
              )
            : (_existingKtpPhotoUrl != null && _existingKtpPhotoUrl!.isNotEmpty)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _existingKtpPhotoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text('Upload ID Card Photo', style: theme.textTheme.titleSmall),
                      Text(
                        'JPG/PNG format, max 2MB',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
      ),
    );
  }
}
