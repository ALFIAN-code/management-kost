import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:formz/formz.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/presentation/bloc/reservation_detail_form/reservation_detail_form_bloc.dart';
import 'package:frontend/presentation/widget/core/appbar/app_topbar.dart';
import 'package:frontend/presentation/widget/core/card/app_section_card.dart';
import 'package:frontend/presentation/widget/core/card/selection_card.dart';
import 'package:frontend/presentation/widget/core/textform/textform.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';
import 'package:frontend/presentation/widget/core/wrapper/hover_wrapper.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';

import 'package:frontend/domain/entity/room_entity.dart';
import 'package:frontend/domain/entity/setting/midtrans_method_entity.dart';
import 'package:frontend/domain/usecase/finance/get_available_payment_methods_usecase.dart';
import 'package:frontend/domain/usecase/resident/get_resident_profile_usecase.dart';
import 'package:frontend/domain/usecase/setting/get_public_settings_usecase.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';

@RoutePage()
class ReservationDetailFormPage extends StatelessWidget {
  final RoomEntity room;
  const ReservationDetailFormPage({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ReservationDetailFormBloc(
            getSettingsUseCase: serviceLocator.get<GetPublicSettingsUseCase>(),
            createReservationUseCase: serviceLocator.get(),
            getProfileUseCase: serviceLocator.get<GetResidentProfileUseCase>(),
            getAvailablePaymentMethodsUseCase: serviceLocator
                .get<GetAvailablePaymentMethodsUseCase>(),
          )..add(
            InitReservationEvent(
              room,
              isLoggedIn: context.read<AuthBloc>().state.isLoggedIn,
              userId: context.read<AuthBloc>().state.userInfo?.id,
              userName: context.read<AuthBloc>().state.userInfo?.name,
            ),
          ),
      child: const ReservationDetailFormView(),
    );
  }
}

class ReservationDetailFormView extends StatefulWidget {
  const ReservationDetailFormView({super.key});

  @override
  State<ReservationDetailFormView> createState() =>
      _ReservationDetailFormViewState();
}

class _ReservationDetailFormViewState extends State<ReservationDetailFormView> {
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(
    BuildContext context,
    TextEditingController controller,
    Function(DateTime) onDateSelected,
  ) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      initialDate: now,
    );

    if (date != null) {
      final formatted = '${date.day}/${date.month}/${date.year}';
      controller.text = formatted;
      onDateSelected(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReservationDetailFormBloc, ReservationDetailFormState>(
      listener: (context, state) {
        if (state.startDate != null) {
          final date = state.startDate!;
          _startDateController.text = '${date.day}/${date.month}/${date.year}';
        }
        if (state.endDate != null) {
          final date = state.endDate!;
          _endDateController.text = '${date.day}/${date.month}/${date.year}';
        }

        if (state.readyToConfirm) {
          context.read<ReservationDetailFormBloc>().add(
            const ResetConfirmFlagEvent(),
          );
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) _showConfirmReservationDialog(context);
          });
        }

        if (state.status == FormzSubmissionStatus.success) {
          AppSnackbar.showSuccess(
            'Booking created successfully. Please complete the payment.',
          );
          if (state.paymentMethod == 'tunai') {
            context.router.replace(
              PaymentUploadRoute(reservation: state.createdReservation!),
            );
          } else {
            context.router.replace(
              MidtransPaymentRoute(
                reservation: state.createdReservation!.copyWith(
                  selectedPaymentMethod: state.selectedMidtransMethod,
                ),
              ),
            );
          }
        } else if (state.status == FormzSubmissionStatus.failure) {
          final error = state.errorMessage ?? 'Failed to create the booking';
          AppSnackbar.showError(error);

          if (error.toLowerCase().contains('profil') ||
              error.toLowerCase().contains('biodata')) {
            context.router.push(const CompleteProfileRoute());
          }
        }
      },
      builder: (context, state) {
        final room = state.room;
        final isDark = AppTheme.isDark(context);

        // ── Design system tokens ─────────────────────────────────────────────
        final textPrimary =
            isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;
        final textSecondary =
            isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;
        final primaryColor =
            isDark ? AppColorsDark.primary : AppColorsLight.primary;
        final borderColor =
            isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight;

        final statusWaiting =
            isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting;
        final statusWaitingBg = isDark
            ? AppColorsDark.statusWaitingBg
            : AppColorsLight.statusWaitingBg;
        final statusWaitingBorder = isDark
            ? AppColorsDark.statusWaitingBorder
            : AppColorsLight.statusWaitingBorder;

        if (room == null) {
          return Scaffold(
            backgroundColor: isDark
                ? AppColorsDark.background
                : AppColorsLight.background,
            body: Column(
              children: [
                AppTopBar(
                  title: 'Reservation Details',
                  breadcrumb: 'Reservations / Details',
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.router.pop(),
                    tooltip: 'Back',
                  ),
                ),
                Expanded(child: _buildSkeleton(isDark)),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: isDark
              ? AppColorsDark.background
              : AppColorsLight.background,
          body: Column(
            children: [
              AppTopBar(
                title: 'Reservation Details',
                breadcrumb: 'Reservations / Details',
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.router.pop(),
                  tooltip: 'Back',
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxxl),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// LEFT ─────────────────────────────────────────────────
                      Expanded(
                        flex: 3,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              /// SELECTED ROOM
                              AppSectionCard(
                                title: 'Selected room',
                                icon: Icons.bed_outlined,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(AppSpacing.lg),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColorsDark.primaryLight
                                        : AppColorsLight.primaryLight,
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusLg,
                                    ),
                                    border: Border.all(
                                      color: isDark
                                          ? AppColorsDark.primary.withValues(
                                              alpha: 0.4,
                                            )
                                          : AppColorsLight.primary.withValues(
                                              alpha: 0.3,
                                            ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        room.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        'No. ${room.number} • ${room.facilities.join(', ')}',
                                        style: TextStyle(color: textSecondary),
                                      ),
                                      const SizedBox(height: AppSpacing.sm),
                                      Text(
                                        'Monthly: ${room.priceFormatted} | Yearly: Rp ${NumberFormat.decimalPattern('id').format((room.price * 12).toInt()).replaceAll(',', '.')}',
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: AppSpacing.xxl),

                              /// LEASE TYPE
                              AppSectionCard(
                                title: 'Select Lease Type',
                                icon: Icons.date_range_outlined,
                                child: Wrap(
                                  spacing: AppSpacing.lg,
                                  runSpacing: AppSpacing.lg,
                                  children: [
                                    SelectionCard.vertical(
                                      title: 'Monthly Lease',
                                      subtitle: 'More affordable for short stays',
                                      valueLabel:
                                          '${room.priceFormatted} / month',
                                      selected: state.rentType == 'Bulanan',
                                      onTap: () => context
                                          .read<ReservationDetailFormBloc>()
                                          .add(
                                            const RentTypeChanged('Bulanan'),
                                          ),
                                      minWidth: 260,
                                      maxWidth: 358,
                                    ),
                                    SelectionCard.vertical(
                                      title: 'Yearly Lease',
                                      subtitle:
                                          'More affordable for long stays',
                                      valueLabel:
                                          'Rp ${NumberFormat.decimalPattern('id').format((room.price * 12).toInt()).replaceAll(',', '.')} / year',
                                      selected: state.rentType == 'Tahunan',
                                      onTap: () => context
                                          .read<ReservationDetailFormBloc>()
                                          .add(
                                            const RentTypeChanged('Tahunan'),
                                          ),
                                      minWidth: 260,
                                      maxWidth: 358,
                                    ),
                                    // Daily logic (preserved)
                                    if (state.isDailyRentalEnabled &&
                                        room.priceDaily > 0)
                                      const SizedBox.shrink(),
                                  ],
                                ),
                              ),

                              const SizedBox(height: AppSpacing.xxl),

                              /// LEASE DETAILS
                              AppSectionCard(
                                title: 'Lease Details',
                                icon: Icons.calendar_month_outlined,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => _pickDate(
                                              context,
                                              _startDateController,
                                              (date) {
                                                context
                                                    .read<
                                                      ReservationDetailFormBloc
                                                    >()
                                                    .add(
                                                      StartDateChanged(date),
                                                    );
                                              },
                                            ),
                                            child: AbsorbPointer(
                                              child: CustomTextForm(
                                                title: 'Start Date',
                                                hintText: 'Select a date',
                                                controller:
                                                    _startDateController,
                                                isRequired: true,
                                                suffixIcon: const Icon(
                                                  Icons.calendar_today,
                                                  size: 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.md),
                                        if (state.rentType == 'Bulanan' ||
                                            state.rentType == 'Tahunan')
                                          Expanded(
                                            child: CustomTextForm(
                                              title: state.rentType == 'Bulanan'
                                                  ? 'Number of Months'
                                                  : 'Number of Years',
                                              hintText:
                                                  state.rentType == 'Bulanan'
                                                  ? 'How many months?'
                                                  : 'How many years?',
                                              keyboardType:
                                                  TextInputType.number,
                                              initialValue:
                                                  state.durationMonths
                                                      .toString(),
                                              onChanged: (val) {
                                                final value =
                                                    int.tryParse(val) ?? 1;
                                                context
                                                    .read<
                                                      ReservationDetailFormBloc
                                                    >()
                                                    .add(
                                                      DurationMonthsChanged(
                                                        value,
                                                      ),
                                                    );
                                              },
                                              isRequired: true,
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (state.rentType == 'Bulanan' ||
                                        state.rentType == 'Tahunan') ...[
                                      const SizedBox(height: AppSpacing.lg),
                                      CustomTextForm(
                                        title: 'Estimated End Date',
                                        hintText: '-',
                                        controller: _endDateController,
                                        enabled: false,
                                        isRequired: false,
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              const SizedBox(height: AppSpacing.xxl),

                              /// PAYMENT SCHEME — only shown if start_date > H+7
                              if (state.isDpAvailable) ...[
                                AppSectionCard(
                                  title: 'Payment Scheme',
                                  icon: Icons.account_balance_outlined,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'The start date is more than 7 days away. You can choose to pay the down payment (50% upfront) now and settle the remainder before the check-in date.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: textSecondary,
                                          height: 1.5,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.lg),
                                      Wrap(
                                        spacing: AppSpacing.lg,
                                        runSpacing: AppSpacing.lg,
                                        children: [
                                          SelectionCard.vertical(
                                            title: 'Full Payment',
                                            subtitle:
                                                'Pay all costs now',
                                            valueLabel:
                                                'Rp ${NumberFormat.decimalPattern('id').format(state.totalPrice).replaceAll(',', '.')}',
                                            selected:
                                                state.paymentScheme == 'full',
                                            onTap: () => context
                                                .read<
                                                  ReservationDetailFormBloc
                                                >()
                                                .add(
                                                  const PaymentSchemeChanged(
                                                    'full',
                                                  ),
                                                ),
                                            minWidth: 220,
                                            maxWidth: 320,
                                          ),
                                          SelectionCard.vertical(
                                            title: 'Down Payment (DP)',
                                            subtitle:
                                                'Pay 50% now, settle the rest before check-in',
                                            valueLabel:
                                                'Rp ${NumberFormat.decimalPattern('id').format(state.dpAmount.toInt()).replaceAll(',', '.')}',
                                            selected:
                                                state.paymentScheme == 'dp',
                                            accentColor: statusWaiting,
                                            onTap: () => context
                                                .read<
                                                  ReservationDetailFormBloc
                                                >()
                                                .add(
                                                  const PaymentSchemeChanged(
                                                    'dp',
                                                  ),
                                                ),
                                            minWidth: 220,
                                            maxWidth: 320,
                                          ),
                                        ],
                                      ),
                                      if (state.paymentScheme == 'dp') ...[
                                        const SizedBox(height: AppSpacing.md),
                                        // ── DP banner (design system tokens) ──
                                        Container(
                                          padding: const EdgeInsets.all(
                                            AppSpacing.md,
                                          ),
                                          decoration: BoxDecoration(
                                            color: statusWaitingBg,
                                            borderRadius: BorderRadius.circular(
                                              AppSpacing.radiusMd,
                                            ),
                                            border: Border.all(
                                              color: statusWaitingBorder,
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                size: 18,
                                                color: statusWaiting,
                                              ),
                                              const SizedBox(
                                                width: AppSpacing.sm,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  'The down payment must be paid within 15 minutes after booking. The remaining payment must be settled before the check-in date.',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: statusWaiting,
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xxl),
                              ],

                              /// PAYMENT METHOD
                              AppSectionCard(
                                title: 'Payment Method',
                                icon: Icons.payment_outlined,
                                child: Column(
                                  children: [
                                    Wrap(
                                      spacing: AppSpacing.lg,
                                      runSpacing: AppSpacing.lg,
                                      children: [
                                        if (state.isMidtransEnabled)
                                          SelectionCard.horizontal(
                                            title: 'Online Payment',
                                            subtitle: _midtransSubtitle(
                                              state.midtransPaymentMethods,
                                            ),
                                            icon: Icons.account_balance_wallet,
                                            selected:
                                                state.paymentMethod == 'online',
                                            onTap: () => context
                                                .read<
                                                  ReservationDetailFormBloc
                                                >()
                                                .add(
                                                  const PaymentMethodChanged(
                                                    'online',
                                                  ),
                                                ),
                                            minWidth: 260,
                                            maxWidth: 358,
                                          ),
                                        SelectionCard.horizontal(
                                          title: 'Manual Payment',
                                          subtitle:
                                              'Transfer or cash with proof',
                                          icon: Icons.payments,
                                          selected:
                                              state.paymentMethod == 'tunai',
                                          onTap: () => context
                                              .read<ReservationDetailFormBloc>()
                                              .add(
                                                const PaymentMethodChanged(
                                                  'tunai',
                                                ),
                                              ),
                                          minWidth: 260,
                                          maxWidth: 358,
                                        ),
                                      ],
                                    ),

                                    if (state.paymentMethod == 'online') ...[
                                      const SizedBox(height: AppSpacing.xxl),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Select Payment Method',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: textPrimary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'The method you select will open on the Midtrans payment page.',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: textSecondary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.md),

                                      // ── All methods in maintenance ──────────
                                      if (state.midtransPaymentMethods
                                              .isNotEmpty &&
                                          state.midtransPaymentMethods.every(
                                            (m) => !m.available,
                                          )) ...[
                                        Container(
                                          padding: const EdgeInsets.all(
                                            AppSpacing.lg,
                                          ),
                                          decoration: BoxDecoration(
                                            color: statusWaitingBg,
                                            borderRadius: BorderRadius.circular(
                                              AppSpacing.radiusMd,
                                            ),
                                            border: Border.all(
                                              color: statusWaitingBorder,
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.build_outlined,
                                                color: statusWaiting,
                                                size: 20,
                                              ),
                                              const SizedBox(
                                                width: AppSpacing.md,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'All online payment methods are under maintenance',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13,
                                                        color: statusWaiting,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: AppSpacing.xs,
                                                    ),
                                                    Text(
                                                      'No method is currently available. Please use Manual Payment or try again later.',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: statusWaiting,
                                                        height: 1.4,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: AppSpacing.sm,
                                                    ),
                                                    GestureDetector(
                                                      onTap: () => context
                                                          .read<
                                                            ReservationDetailFormBloc
                                                          >()
                                                          .add(
                                                            const PaymentMethodChanged(
                                                              'tunai',
                                                            ),
                                                          ),
                                                      child: Text(
                                                        'Switch to Manual Payment →',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: statusWaiting,
                                                          decoration: TextDecoration
                                                              .underline,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: AppSpacing.md),
                                      ],

                                      // ── No method available ──────────────────
                                      if (state
                                          .midtransPaymentMethods.isEmpty) ...[
                                        Container(
                                          padding: const EdgeInsets.all(
                                            AppSpacing.lg,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? AppColorsDark.surface
                                                : AppColorsLight.surface,
                                            borderRadius: BorderRadius.circular(
                                              AppSpacing.radiusMd,
                                            ),
                                            border: Border.all(
                                              color: borderColor,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                color: textSecondary,
                                                size: 18,
                                              ),
                                              const SizedBox(
                                                width: AppSpacing.md,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  'No online payment method is active. Contact the caretaker or use Manual Payment.',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: textSecondary,
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ] else
                                        GridView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                mainAxisSpacing:
                                                    AppSpacing.sm,
                                                crossAxisSpacing: AppSpacing.sm,
                                                mainAxisExtent: 72,
                                              ),
                                          itemCount: state
                                              .midtransPaymentMethods.length,
                                          itemBuilder: (context, index) {
                                            final method = state
                                                .midtransPaymentMethods[index];
                                            final isSelected =
                                                state.selectedMidtransMethod ==
                                                method.code;
                                            return _midtransMethodCard(
                                              method: method,
                                              selected: isSelected,
                                              onTap: method.available
                                                  ? () => context
                                                        .read<
                                                          ReservationDetailFormBloc
                                                        >()
                                                        .add(
                                                          SelectedMidtransMethodChanged(
                                                            isSelected
                                                                ? null
                                                                : method.code,
                                                          ),
                                                        )
                                                  : () {},
                                            );
                                          },
                                        ),
                                    ] else if (state.paymentMethod ==
                                        'tunai') ...[
                                      const SizedBox(height: AppSpacing.lg),
                                      // ── Manual payment banner ────────────
                                      Container(
                                        padding: const EdgeInsets.all(
                                          AppSpacing.lg,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusWaitingBg,
                                          borderRadius: BorderRadius.circular(
                                            AppSpacing.radiusMd,
                                          ),
                                          border: Border.all(
                                            color: statusWaitingBorder,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              color: statusWaiting,
                                              size: 20,
                                            ),
                                            const SizedBox(
                                              width: AppSpacing.md,
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Manual Payment',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13,
                                                      color: statusWaiting,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: AppSpacing.xs,
                                                  ),
                                                  Text(
                                                    'Make a bank transfer or pay in cash, then upload the payment proof in the next step.',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: statusWaiting,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          )
                              .animate()
                              .fadeIn(duration: 300.ms)
                              .slideY(
                                begin: 0.05,
                                end: 0,
                                duration: 300.ms,
                              ),
                        ),
                      ),

                      const SizedBox(width: AppSpacing.xxl),

                      /// RIGHT ────────────────────────────────────────────────
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            // ── Cost Summary ─────────────────────────────
                            AppSectionCard(
                              title: 'Cost Summary',
                              icon: Icons.receipt_long_outlined,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Room name + duration row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        room.title,
                                        style:
                                            TextStyle(color: textSecondary),
                                      ),
                                      Text(
                                        '${state.duration} '
                                        '${state.rentType == 'Bulanan' ? 'Month' : state.rentType == 'Tahunan' ? 'Year' : 'Day'}',
                                        style:
                                            TextStyle(color: textSecondary),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.sm),

                                  // Price per period row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Price / '
                                        '${state.rentType == 'Bulanan' ? 'month' : state.rentType == 'Tahunan' ? 'year' : 'day'}',
                                        style:
                                            TextStyle(color: textSecondary),
                                      ),
                                      Text(
                                        state.rentType == 'Bulanan'
                                            ? room.priceFormatted
                                            : state.rentType == 'Tahunan'
                                            ? 'Rp ${NumberFormat.decimalPattern('id').format((room.price * 12).toInt()).replaceAll(',', '.')}'
                                            : room.priceDailyFormatted,
                                        style:
                                            TextStyle(color: textSecondary),
                                      ),
                                    ],
                                  ),

                                  // ── Divider borderLight ──────────────────
                                  const SizedBox(height: AppSpacing.sm),
                                  Container(
                                    height: 1,
                                    color: borderColor,
                                  ),
                                  const SizedBox(height: AppSpacing.sm),

                                  // Total cost row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Total Cost',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'Rp ${NumberFormat.decimalPattern('id').format(state.totalPrice).replaceAll(',', '.')}',
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),

                                  if (state.paymentScheme == 'dp') ...[
                                    const SizedBox(height: AppSpacing.xs),
                                    Container(height: 1, color: borderColor),
                                    const SizedBox(height: AppSpacing.xs),

                                    // Current down payment row
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Pay Now (DP)',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: textPrimary,
                                          ),
                                        ),
                                        Text(
                                          'Rp ${NumberFormat.decimalPattern('id').format(state.dpAmount.toInt()).replaceAll(',', '.')}',
                                          style: TextStyle(
                                            color: statusWaiting,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.xs),

                                    // Remaining payment row
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Remaining payment (before check-in date)',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: textSecondary,
                                          ),
                                        ),
                                        Text(
                                          'Rp ${NumberFormat.decimalPattern('id').format(state.dpAmount.toInt()).replaceAll(',', '.')}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            const SizedBox(height: AppSpacing.xl),

                            // ── Book room button ──────────────────────────
                            SizedBox(
                              width: double.infinity,
                              child: BasicButton(
                                label: 'Book Room',
                                isLoading: state.status ==
                                    FormzSubmissionStatus.inProgress,
                                onPressed: () {
                                  _showConfirmReservationDialog(context);
                                },
                              ),
                            ),

                            const SizedBox(height: AppSpacing.sm),

                            // ── Note below ────────────────────────────────
                            Text(
                              'After submitting, you will be redirected to make the payment',
                              style: TextStyle(
                                fontSize: 12,
                                color: textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                            .animate()
                            .fadeIn(delay: 100.ms, duration: 300.ms)
                            .slideY(
                              begin: 0.05,
                              end: 0,
                              duration: 300.ms,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkeleton(bool isDark) {
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: List.generate(
                3,
                (i) => Padding(
                  padding: EdgeInsets.only(
                    bottom: i < 2 ? AppSpacing.xxl : 0,
                  ),
                  child: Shimmer.fromColors(
                    baseColor: baseColor,
                    highlightColor: highlightColor,
                    child: Container(
                      height: i == 0 ? 120 : 180,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusLg,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xxl),
          Expanded(
            flex: 1,
            child: Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Container(
                height: 260,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmReservationDialog(BuildContext context) {
    final state = context.read<ReservationDetailFormBloc>().state;
    final authState = context.read<AuthBloc>().state;

    // 1. Login check
    if (!authState.isLoggedIn) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Login Required'),
          content: const Text(
            'To book a room, you need to sign in or create an account first.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Not Now'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.router.push(LoginRoute(pendingRoom: state.room));
              },
              child: const Text('Sign In Now'),
            ),
          ],
        ),
      );
      return;
    }

    // 2. Start date check
    if (state.startDate == null) {
      AppSnackbar.showError('Select a start date first');
      return;
    }

    // 3. Midtrans method availability check
    if (state.paymentMethod == 'online') {
      final methods = state.midtransPaymentMethods;
      if (methods.isEmpty || methods.every((m) => !m.available)) {
        AppSnackbar.showError(
          methods.isEmpty
              ? 'No online payment method is active. Use Manual Payment.'
              : 'All online payment methods are under maintenance. Use Manual Payment.',
        );
        return;
      }
    }

    // 4. Profile check
    if (!state.isProfileComplete) {
      AppSnackbar.showInfo(
        'Please complete your personal data (national ID number, phone number, and ID card address) before continuing the booking.',
      );
      context.router.push(const CompleteProfileRoute()).then((_) {
        if (context.mounted) {
          context.read<ReservationDetailFormBloc>().add(
            const RefreshProfileStatusEvent(thenConfirm: true),
          );
        }
      });
      return;
    }

    final isDark = AppTheme.isDark(context);
    final statusWaiting =
        isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting;
    final statusWaitingBg = isDark
        ? AppColorsDark.statusWaitingBg
        : AppColorsLight.statusWaitingBg;
    final statusWaitingBorder = isDark
        ? AppColorsDark.statusWaitingBorder
        : AppColorsLight.statusWaitingBorder;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to book this room?',
            ),
            const SizedBox(height: AppSpacing.lg),
            _infoRow('Room', state.room?.title ?? '-'),
            _infoRow(
              'Start',
              DateFormat('dd/MM/yyyy').format(state.startDate!),
            ),
            _infoRow(
              'Total',
              'Rp ${NumberFormat.decimalPattern('id').format(state.totalPrice).replaceAll(',', '.')}',
            ),
            if (state.paymentScheme == 'dp') ...[
              _infoRow('Payment Scheme', 'DP (50% Down Payment)'),
              _infoRow(
                'Pay Now',
                'Rp ${NumberFormat.decimalPattern('id').format(state.dpAmount.toInt()).replaceAll(',', '.')}',
              ),
            ] else
              _infoRow('Payment Scheme', 'Full Payment'),
            _infoRow(
              'Method',
              state.paymentMethod == 'online'
                  ? (state.selectedMidtransMethod != null
                        ? 'Online · ${_kMidtransMethodMap[state.selectedMidtransMethod]?.name ?? state.selectedMidtransMethod!.toUpperCase()}'
                        : 'Online (Midtrans)')
                  : 'Manual',
            ),
            if (state.paymentScheme == 'dp') ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: statusWaitingBg,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: statusWaitingBorder),
                ),
                child: Text(
                  'The down payment must be paid within 15 minutes. The remaining payment must be settled before the check-in date.',
                  style: TextStyle(
                    fontSize: 11,
                    color: statusWaiting,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ReservationDetailFormBloc>().add(
                const SubmitReservation(),
              );
            },
            child: Text(
              state.paymentScheme == 'dp'
                  ? 'Yes, Pay DP Now'
                  : 'Yes, Book Now',
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ── Midtrans payment method metadata ─────────────────────────────────────────

class _MidtransMethodInfo {
  const _MidtransMethodInfo(this.name, this.desc, this.icon);
  final String name;
  final String desc;
  final IconData icon;
}

const Map<String, _MidtransMethodInfo> _kMidtransMethodMap = {
  'qris': _MidtransMethodInfo(
    'QRIS',
    'Scan QR from all e-wallets & banks',
    Icons.qr_code,
  ),
  'gopay': _MidtransMethodInfo(
    'GoPay',
    'Pay with your GoPay balance',
    Icons.account_balance_wallet,
  ),
  'shopeepay': _MidtransMethodInfo(
    'ShopeePay',
    'Pay with your ShopeePay balance',
    Icons.shopping_bag,
  ),
  'dana': _MidtransMethodInfo(
    'DANA',
    'Pay with your DANA balance',
    Icons.account_balance_wallet,
  ),
  'linkaja': _MidtransMethodInfo(
    'LinkAja',
    'Pay with your LinkAja balance',
    Icons.account_balance_wallet,
  ),
  'ovo': _MidtransMethodInfo(
    'OVO',
    'Pay with your OVO balance',
    Icons.account_balance_wallet,
  ),
  'bca_va': _MidtransMethodInfo(
    'BCA Virtual Account',
    'Transfer via ATM / m-BCA',
    Icons.account_balance,
  ),
  'bni_va': _MidtransMethodInfo(
    'BNI Virtual Account',
    'Transfer via ATM / BNI Mobile',
    Icons.account_balance,
  ),
  'bri_va': _MidtransMethodInfo(
    'BRI Virtual Account',
    'Transfer via ATM / BRImo',
    Icons.account_balance,
  ),
  'mandiri_va': _MidtransMethodInfo(
    'Mandiri Virtual Account',
    'Transfer via Mandiri Livin\'',
    Icons.account_balance,
  ),
  'echannel': _MidtransMethodInfo(
    'Mandiri Bill',
    'Bayar via Mandiri Livin\'',
    Icons.account_balance,
  ),
  'permata_va': _MidtransMethodInfo(
    'Permata Virtual Account',
    'Transfer via ATM Permata',
    Icons.account_balance,
  ),
  'other_va': _MidtransMethodInfo(
    'Virtual Account',
    'Transfer via another bank',
    Icons.account_balance,
  ),
  'alfamart': _MidtransMethodInfo(
    'Alfamart',
    'Pay at the Alfamart counter',
    Icons.store,
  ),
  'indomaret': _MidtransMethodInfo(
    'Indomaret',
    'Pay at the Indomaret counter',
    Icons.store,
  ),
  'credit_card': _MidtransMethodInfo(
    'Credit/Debit Card',
    'Visa, Mastercard, JCB',
    Icons.credit_card,
  ),
  'akulaku': _MidtransMethodInfo(
    'Akulaku',
    '0% installments via Akulaku',
    Icons.credit_card,
  ),
  'kredivo': _MidtransMethodInfo(
    'Kredivo',
    'Installments via Kredivo',
    Icons.credit_card,
  ),
};

/// Dynamic subtitle based on the available methods
String _midtransSubtitle(List<MidtransMethodEntity> methods) {
  if (methods.isEmpty) return 'No active method';
  final available = methods.where((m) => !m.maintenance).toList();
  if (available.isEmpty) return 'All methods are under maintenance';
  final names = available
      .map(
        (m) => m.label.isNotEmpty
            ? m.label
            : (_kMidtransMethodMap[m.code]?.name ?? m.code.toUpperCase()),
      )
      .take(3)
      .join(', ');
  return available.length > 3
      ? '$names, +${available.length - 3} more'
      : names;
}

/// Midtrans payment method card — list-tile style, fixed 72px height
Widget _midtransMethodCard({
  required MidtransMethodEntity method,
  required bool selected,
  required VoidCallback onTap,
}) {
  return Builder(
    builder: (context) {
      final isDark = AppTheme.isDark(context);
      final info =
          _kMidtransMethodMap[method.code] ??
          _MidtransMethodInfo(
            method.code.toUpperCase(),
            'Midtrans method',
            Icons.payment,
          );
      final displayName = method.label.isNotEmpty ? method.label : info.name;
      final isMaintenance = method.maintenance;
      final isUnavailable = !method.available;

      // ── Design system tokens ───────────────────────────────────────────────
      final primaryColor =
          isDark ? AppColorsDark.primary : AppColorsLight.primary;
      final primaryLight =
          isDark ? AppColorsDark.surfaceVariant : AppColorsLight.primaryLight;
      final surfaceColor =
          isDark ? AppColorsDark.surface : AppColorsLight.surface;
      final borderColor =
          isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight;
      final textPrimary =
          isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;
      final textSecondary =
          isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;
      final statusWaiting =
          isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting;
      final iconBg =
          isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant;
      final iconBgSelected =
          isDark
          ? AppColorsDark.primary.withValues(alpha: 0.2)
          : AppColorsLight.primary.withValues(alpha: 0.12);

      return Opacity(
        opacity: isUnavailable ? 0.5 : 1.0,
        child: HoverTapWrapper(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          hoverColor: isUnavailable
              ? Colors.transparent
              : primaryColor.withValues(alpha: 0.04),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: selected ? primaryLight : surfaceColor,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: selected ? primaryColor : borderColor,
                width: selected ? 1.5 : 1.0,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: selected ? iconBgSelected : iconBg,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Icon(
                      info.icon,
                      size: 20,
                      color: selected ? primaryColor : textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Name + description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          displayName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                            height: 1.3,
                            color: selected ? primaryColor : textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        if (isMaintenance)
                          Text(
                            'Under Maintenance',
                            style: TextStyle(
                              fontSize: 10.5,
                              height: 1.2,
                              color: statusWaiting,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        else
                          Text(
                            info.desc,
                            style: TextStyle(
                              fontSize: 10.5,
                              height: 1.2,
                              color: textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  if (isMaintenance)
                    Icon(
                      Icons.build_outlined,
                      size: 16,
                      color: statusWaiting,
                    )
                  else
                    Icon(
                      selected ? Icons.check_circle : Icons.circle_outlined,
                      size: 18,
                      color: selected ? primaryColor : borderColor,
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
