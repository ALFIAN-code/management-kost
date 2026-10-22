import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

// --- Core Widget Imports ---
import 'package:frontend/presentation/widget/core/card/basic_card.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/presentation/bloc/profile/profile_bloc.dart';
import 'package:frontend/presentation/bloc/resident/complete_profile/complete_profile_bloc.dart';
import 'package:frontend/presentation/bloc/resident/complete_profile/complete_profile_event.dart';
import 'package:frontend/presentation/bloc/resident/complete_profile/complete_profile_state.dart';
import 'package:frontend/presentation/bloc/my_reservation/my_reservation_bloc.dart';
import 'package:frontend/presentation/bloc/my_reservation/my_reservation_event.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';

@RoutePage()
class ProfileUserPage extends StatelessWidget {
  const ProfileUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => serviceLocator<ProfileBloc>()..add(FetchProfile()),
          ),
          BlocProvider(
            create: (context) => serviceLocator<CompleteProfileBloc>()..add(LoadProfileEvent()),
          ),
          BlocProvider(
            create: (context) => serviceLocator<MyReservationBloc>()..add(GetMyReservationsEvent()),
          ),
        ],
        child: Builder(
          builder: (context) {
            final profileState = context.watch<ProfileBloc>().state;
            final completeProfileState = context.watch<CompleteProfileBloc>().state;
            final myReservationState = context.watch<MyReservationBloc>().state;

            final isLoading = profileState is ProfileLoading ||
                completeProfileState is CompleteProfileLoading ||
                myReservationState.status == FormzSubmissionStatus.inProgress;

            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Extract User data
            String name = '-';
            String email = '-';
            String phone = '-';
            String? role;
            if (profileState is ProfileLoaded) {
              name = profileState.user.name;
              email = profileState.user.email;
              phone = profileState.user.phoneNumber ?? '-';
              role = profileState.user.role;
            }

            final roleLower = (role ?? '').toLowerCase();
            final isAdmin = roleLower.contains('admin');
            final isTenant = roleLower.contains('resident') ||
                roleLower.contains('member') ||
                roleLower.contains('tenant') ||
                roleLower.contains('penyewa');

            // Extract Resident Profile data
            String gender = '-';
            String job = '-';
            String ktpPhotoUrl = '';
            if (completeProfileState is CompleteProfileLoaded) {
              final p = completeProfileState.profile;
              gender = p.gender == 'male' ? 'Male' : (p.gender == 'female' ? 'Female' : p.gender);
              job = p.job ?? '-';
              ktpPhotoUrl = p.ktpPhotoUrl ?? '';
              if (phone == '-') phone = p.phoneNumber; // fallback
            }

            // Extract Lease data
            String roomNumber = '-';
            String rentalType = '-';
            String endDate = '-';
            String startDate = '-';
            String paymentStatus = '-';
            String residentStatus = 'Active'; // Default for logged in users
            if (myReservationState.status == FormzSubmissionStatus.success &&
                myReservationState.reservations.isNotEmpty) {
              // Get the most recent active lease
              final res = myReservationState.reservations.first;
              roomNumber = res.roomTitle;
              if (res.roomNumber.isNotEmpty) {
                roomNumber += ' - ${res.roomNumber}';
              }
              rentalType = res.rentalType;
              endDate = res.endDate;
              startDate = res.startDate;
              paymentStatus = res.paymentStatus == 'paid' ? 'Paid' : (res.paymentStatus == 'unpaid' ? 'Unpaid' : res.paymentStatus);
              residentStatus = res.status == 'active' ? 'Active' : res.status;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 22, 28, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- PAGE TITLE ---
                  Text(
                    'Resident Profile',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontSize: 32, // Adjusted proportionally
                          fontWeight: FontWeight.w700,
                          height: 1,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 16),

                    if (isTenant && !isAdmin && completeProfileState is! CompleteProfileLoaded)
                      BasicCard(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'The profile data is incomplete. Complete it to continue as a resident.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          BasicButton(
                            type: ButtonType.secondary,
                            onPressed: () async {
                              await context.router.push(
                                const CompleteProfileRoute(),
                              );
                              if (context.mounted) {
                                context.read<ProfileBloc>().add(FetchProfile());
                                context.read<CompleteProfileBloc>().add(
                                      LoadProfileEvent(),
                                    );
                              }
                            },
                            label: 'Complete',
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),

                  // --- HEADER PROFILE ---
                  Row(
                    children: [
                      // Circular avatar (enlarged proportionally per the mockup)
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2.5,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: ktpPhotoUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: Image.network(
                                  ktpPhotoUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.person_outline,
                                    size: 48,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.person_outline,
                                size: 48,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                      ),
                      const SizedBox(width: 20),
                      // Name and Room
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF141414),
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            roomNumber,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 15,
                                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7) ?? Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // --- CARD 1: PERSONAL INFORMATION ---
                  _InfoSectionCard(
                    title: 'Personal Information',
                    showEditButton: isTenant && !isAdmin,
                    onEditTap: () async {
                      await context.router.push(const CompleteProfileRoute());
                      if (context.mounted) {
                        context.read<ProfileBloc>().add(FetchProfile());
                        context.read<CompleteProfileBloc>().add(LoadProfileEvent());
                      }
                    },
                    child: Wrap(
                      spacing: 24,    // Jarak horizontal antar kolom
                      runSpacing: 24, // Jarak vertikal antar baris
                      children: [
                        _InfoItem(label: 'Full Name', value: name),
                        _InfoItem(label: 'Phone Number', value: phone),
                        _InfoItem(label: 'Email Address', value: email),
                        _InfoItem(label: 'Gender', value: gender),
                        _InfoItem(label: 'Room Number', value: roomNumber),
                        _InfoItem(label: 'Status', value: job),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- CARD 2: LEASE CONTRACT INFORMATION ---
                  _InfoSectionCard(
                    title: 'Lease Contract Information',
                    child: Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      children: [
                        _InfoItem(label: 'Room Type', value: rentalType),
                        _InfoItem(label: 'Contract End Date', value: endDate),
                        _InfoItem(label: 'Lease Price', value: '-'), // API doesn't return price in rentals/my
                        _InfoItem(label: 'Resident Status', value: residentStatus),
                        _InfoItem(label: 'Lease Start Date', value: startDate),
                        _InfoItem(label: 'Payment Status', value: paymentStatus),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PRIVATE WIDGETS (Helpers specific to card layout and text)
// -----------------------------------------------------------------------------

class _InfoSectionCard extends StatelessWidget {
  const _InfoSectionCard({
    required this.title,
    required this.child,
    this.showEditButton = false,
    this.onEditTap,
  });

  final String title;
  final Widget child;
  final bool showEditButton;
  final VoidCallback? onEditTap;

  @override
  Widget build(BuildContext context) {
    return BasicCard(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(32), // Padding widened per the mockup
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              const Spacer(),
              if (showEditButton)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(99),
                    onTap: onEditTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).dividerColor),
                        borderRadius: BorderRadius.circular(99),
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Edit',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.edit_outlined,
                            size: 14,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 28),
          child, // The Wrap content is loaded here
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    // Fixed width so the layout stays neatly aligned on the left like the mockup
    return SizedBox(
      width: 320, 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6) ?? Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}