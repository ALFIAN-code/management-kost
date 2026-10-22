import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constant/permission_key.dart';
import 'package:frontend/core/constant/style_constant.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/main.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:frontend/presentation/bloc/auth/auth_event.dart';
import 'package:frontend/presentation/bloc/auth/auth_state.dart';
import 'package:frontend/presentation/widget/core/sidebar/sidebar.dart';

@RoutePage()
class AppLayoutPage extends StatefulWidget {
  const AppLayoutPage({super.key});

  @override
  State<AppLayoutPage> createState() => _AppLayoutPageState();
}

class _AppLayoutPageState extends State<AppLayoutPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh permissions automatically when the app is reopened from the background
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<AuthBloc>().add(const GetPermissionsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Read router here (outer context) so _AppLayoutPageState subscribes to
    // RouterScope — not BlocBuilder's inner element. This prevents a
    // bottom-up rebuild of BlocBuilder during route transitions which
    // conflicts with AutoRoute's element lifecycle management.
    final activeRouteNames = <String>{};
    try {
      final router = AutoRouter.of(context, watch: true);
      final current = router.current;
      activeRouteNames.add(current.name);

      final segments = router.currentSegments;
      for (final s in segments) {
        activeRouteNames.add(s.name);
      }

      final stack = router.stack;
      for (final entry in stack) {
        final name = entry.name;
        if (name != null) {
          activeRouteNames.add(name);
        }
      }
    } catch (_) {}

    return Scaffold(
      backgroundColor: StyleConstant.backgroundColor,

      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            previous.isLoggedIn == true && current.isLoggedIn == false,
        listener: (context, state) {
          // On logout, make sure to return to the public root (RoomRoute)
          context.router.replaceAll([
            const AppLayoutRoute(children: [RoomRoute()]),
          ]);
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isGuest = !state.isLoggedIn;

            final roles = state.userInfo?.roles ?? [];

            final isMember = roles.contains('member');

            final isResident = roles.contains('resident');

            return Row(
              children: [
                CustomSidebar(
                  activeRouteNames: activeRouteNames,

                  items: [
                    // ─── Dashboard ─────────────────────────────────────
                    if (context.can(PermissionKeys.viewDashboard))
                      SidebarItem(
                        label: 'Admin Dashboard',
                        icon: Icons.dashboard,
                        page: DashboardRoute(),
                        hasAccess: true,
                      ),

                    if (context.can(PermissionKeys.viewResidentDashboard))
                      SidebarItem(
                        label: 'Resident Dashboard',
                        icon: Icons.dashboard_customize_outlined,
                        page: const ResidentDashboardRoute(),
                        hasAccess: true,
                      ),

                    // ─── System Authentication (Permission & Role) ────────
                    if (context.can(PermissionKeys.viewPermission) ||
                        context.can(PermissionKeys.viewRole))
                      SidebarItem(
                        label: 'System Authentication',
                        icon: Icons.security,
                        hasAccess: true,
                        children: [
                          if (context.can(PermissionKeys.viewPermission))
                            SidebarItem(
                              label: 'Permissions',
                              icon: Icons.check_circle_outline,
                              page: const PermissionRoute(),
                            ),
                          if (context.can(PermissionKeys.viewRole))
                            SidebarItem(
                              label: 'Roles',
                              icon: Icons.security,
                              page: RoleManagementRoute(),
                            ),
                        ],
                      ),

                    // ─── Account Management ────────────────────────────────
                    if (context.can(PermissionKeys.viewUser))
                      SidebarItem(
                        label: 'Account Management',
                        icon: Icons.manage_accounts,
                        page: const UserManagementRoute(),
                        hasAccess: true,
                      ),

                    // ─── Resident Management (Admin) ────────────────────
                    // Shown if the user has any resident/guest management permission
                    if (context.can(PermissionKeys.viewResident) ||
                        (context.can(PermissionKeys.viewGuest) &&
                            context.isFeatureEnabled('guest')) ||
                        (context.can(PermissionKeys.viewGuestBill) &&
                            context.isFeatureEnabled('guest')))
                      SidebarItem(
                        label: 'Resident Management',
                        icon: Icons.admin_panel_settings,
                        hasAccess: true,
                        children: [
                          if (context.can(PermissionKeys.viewResident))
                            SidebarItem(
                              label: 'Resident List',
                              icon: Icons.people,
                              page: const ResidentRoute(),
                            ),
                          if (context.can(PermissionKeys.viewGuest) &&
                              context.isFeatureEnabled('guest'))
                            SidebarItem(
                              label: 'Guest List',
                              icon: Icons.groups,
                              page: const GuestListRoute(),
                            ),
                          if (context.can(PermissionKeys.viewGuestBill) &&
                              context.isFeatureEnabled('guest'))
                            SidebarItem(
                              label: 'Guest Invoices',
                              icon: Icons.receipt_long_outlined,
                              page: const AdminGuestBillRoute(),
                            ),
                        ],
                      ),

                    // ─── Rooms & Reservations (Admin) ─────────────────────
                    if (!isGuest &&
                        !isResident &&
                        !isMember &&
                        ((context.can(PermissionKeys.viewRooms) &&
                                context.isFeatureEnabled('room')) ||
                            context.isFeatureEnabled('schedule') ||
                            ((context.can(PermissionKeys.viewLease) ||
                                    context.can(PermissionKeys.approveLease)) &&
                                context.isFeatureEnabled('schedule'))))
                      SidebarItem(
                        label: 'Rooms & Reservations',
                        icon: Icons.room,
                        hasAccess: true,
                        children: [
                          if (context.can(PermissionKeys.viewRooms) &&
                              context.isFeatureEnabled('room'))
                            SidebarItem(
                              label: 'Rooms',
                              icon: Icons.meeting_room,
                              page: RoomRoute(),
                            ),
                          if (context.isFeatureEnabled('schedule'))
                            SidebarItem(
                              label: 'Room Schedule',
                              icon: Icons.calendar_month_outlined,
                              page: const RoomScheduleRoute(),
                            ),
                          if ((context.can(PermissionKeys.viewLease) ||
                                  context.can(PermissionKeys.approveLease)) &&
                              context.isFeatureEnabled('schedule'))
                            SidebarItem(
                              label: 'Reservations',
                              icon: Icons.book_online,
                              page: const ReservationRoute(),
                            ),
                        ],
                      ),

                    // ─── Finance (Admin) ──────────────────────────────
                    if (context.isFeatureEnabled('finance') &&
                        ((context.can(PermissionKeys.financeDashboardView) &&
                                context.isFeatureEnabled(
                                  'finance_dashboard',
                                )) ||
                            (context.can(PermissionKeys.financeExpenseView) ||
                                context.can(
                                  PermissionKeys.financeFixedExpenseView,
                                )) ||
                            (context.can(PermissionKeys.financeInvoiceView) &&
                                context.isFeatureEnabled('finance_invoice')) ||
                            (context.can(PermissionKeys.financePaymentVerify) &&
                                context.isFeatureEnabled('finance_invoice')) ||
                            (context.can(PermissionKeys.financePaymentView) &&
                                context.isFeatureEnabled('finance_invoice')) ||
                            (context.can(PermissionKeys.financeFineView) &&
                                context.isFeatureEnabled('finance_fine'))))
                      SidebarItem(
                        label: 'Finance',
                        icon: Icons.monetization_on,
                        hasAccess: true,
                        children: [
                          if (context.can(
                                PermissionKeys.financeDashboardView,
                              ) &&
                              context.isFeatureEnabled('finance_dashboard'))
                            SidebarItem(
                              label: 'Dashboard',
                              icon: Icons.dashboard_outlined,
                              page: const FinanceDashboardRoute(),
                            ),
                          if (context.can(PermissionKeys.financeExpenseView) ||
                              context.can(
                                PermissionKeys.financeFixedExpenseView,
                              ))
                            SidebarItem(
                              label: 'Expenses',
                              icon: Icons.receipt_long,
                              page: const ExpenseListRoute(),
                            ),
                          if (context.can(PermissionKeys.financeInvoiceView) &&
                              context.isFeatureEnabled('finance_invoice'))
                            SidebarItem(
                              label: 'Invoice List',
                              icon: Icons.description_outlined,
                              page: const InvoiceListRoute(),
                            ),
                          if (context.can(
                                PermissionKeys.financePaymentVerify,
                              ) &&
                              context.isFeatureEnabled('finance_invoice'))
                            SidebarItem(
                              label: 'Payment Management',
                              icon: Icons.payments_outlined,
                              page: const PaymentVerificationRoute(),
                            ),
                          if (context.can(
                                PermissionKeys.financePaymentRefund,
                              ) &&
                              context.isFeatureEnabled('finance_invoice'))
                            SidebarItem(
                              label: 'Refund Requests',
                              icon: Icons.currency_exchange_outlined,
                              page: const RefundRequestRoute(),
                            ),
                          if (context.can(PermissionKeys.financeFineView) &&
                              context.isFeatureEnabled('finance_fine'))
                            SidebarItem(
                              label: 'Fine Management',
                              icon: Icons.gavel_outlined,
                              page: const FineManagementRoute(),
                            ),
                        ],
                      ),

                    // ─── Inventory & Maintenance (Admin) ────────────
                    if (!isResident &&
                        !isMember &&
                        ((context.can(PermissionKeys.viewInventory) &&
                                context.isFeatureEnabled('inventory')) ||
                            (context.can(PermissionKeys.viewMaintenance) &&
                                context.isFeatureEnabled(
                                  'maintenance_schedule',
                                )) ||
                            (context.can(PermissionKeys.viewDamageReport) &&
                                context.isFeatureEnabled('damage_report'))))
                      SidebarItem(
                        label: 'Inventory & Maintenance',
                        icon: Icons.inventory,
                        hasAccess: true,
                        children: [
                          if (context.can(PermissionKeys.viewInventory) &&
                              context.isFeatureEnabled('inventory'))
                            SidebarItem(
                              label: 'Inventory',
                              icon: Icons.inventory,
                              page: const InventoryRoute(),
                            ),
                          if (context.can(PermissionKeys.viewMaintenance) &&
                              context.isFeatureEnabled('maintenance_schedule'))
                            SidebarItem(
                              label: 'Maintenance',
                              icon: Icons.build,
                              page: const MaintananceRoute(),
                            ),
                          if (context.can(PermissionKeys.viewDamageReport) &&
                              context.isFeatureEnabled('damage_report'))
                            SidebarItem(
                              label: 'Damage Reports',
                              icon: Icons.report_problem_outlined,
                              page: const MaintenanceReportListRoute(),
                            ),
                        ],
                      ),

                    // ══════════════════════════════════════════════════
                    // Area for registered users (Member & Resident)
                    // ══════════════════════════════════════════════════

                    // ─── Rooms (Member, Resident, Guest) ──────────────
                    if ((isGuest || isMember || isResident) &&
                        context.isFeatureEnabled('room'))
                      SidebarItem(
                        label: 'Rooms',
                        icon: Icons.meeting_room,
                        page: RoomRoute(),
                      ),

                    // ─── Reservations (Visitors not logged in) ────────────
                    // if (isGuest)
                    //   SidebarItem(
                    //     label: 'Reservations',
                    //     icon: Icons.book_online,
                    //     page: const ReservationRoute(),
                    //   ),

                    // ─── Member Area (registered users without a room) ──
                    if (isMember) ...[
                      if ((context.can(PermissionKeys.applyLease) ||
                              context.can(PermissionKeys.viewLease)) &&
                          context.isFeatureEnabled('schedule'))
                        SidebarItem(
                          label: 'My Reservations',
                          icon: Icons.book_online_outlined,
                          page: const MyReservationRoute(),
                        ),
                      if (context.can(PermissionKeys.financeMeSummaryView) &&
                          context.isFeatureEnabled('finance'))
                        SidebarItem(
                          label: 'My Finance',
                          icon: Icons.account_balance_wallet_outlined,
                          page: const MemberFinanceRoute(),
                        ),
                      if (context.isFeatureEnabled('guest'))
                        SidebarItem(
                          label: 'My Guests',
                          icon: Icons.people_alt_outlined,
                          page: const MyGuestRoute(),
                        ),
                    ],

                    // ─── Resident Area (active resident) ────────────────
                    if (isResident &&
                        ((context.can(PermissionKeys.financeMeSummaryView) &&
                                context.isFeatureEnabled('finance')) ||
                            ((context.can(PermissionKeys.applyLease) ||
                                    context.can(PermissionKeys.viewLease)) &&
                                context.isFeatureEnabled('schedule')) ||
                            ((context.can(PermissionKeys.viewMyGuest) ||
                                    context.can(PermissionKeys.createGuest) ||
                                    context.can(PermissionKeys.payGuestBill)) &&
                                context.isFeatureEnabled('guest')) ||
                            (context.can(PermissionKeys.createDamageReport) &&
                                context.isFeatureEnabled('damage_report')) ||
                            (context.can(PermissionKeys.viewMyDamageReport) &&
                                context.isFeatureEnabled('damage_report')) ||
                            (context.can(PermissionKeys.viewMaintenance) &&
                                context.isFeatureEnabled(
                                  'maintenance_schedule',
                                ))))
                      SidebarItem(
                        label: 'Resident Area',
                        icon: Icons.home_work_outlined,
                        hasAccess: true,
                        children: [
                          if (context.can(
                                PermissionKeys.financeMeSummaryView,
                              ) &&
                              context.isFeatureEnabled('finance'))
                            SidebarItem(
                              label: 'My Finance',
                              icon: Icons.account_balance_wallet_outlined,
                              page: const MemberFinanceRoute(),
                            ),
                          if ((context.can(PermissionKeys.applyLease) ||
                                  context.can(PermissionKeys.viewLease)) &&
                              context.isFeatureEnabled('schedule'))
                            SidebarItem(
                              label: 'My Reservations',
                              icon: Icons.book_online_outlined,
                              page: const MyReservationRoute(),
                            ),
                          if ((context.can(PermissionKeys.viewMyGuest) ||
                                  context.can(PermissionKeys.createGuest) ||
                                  context.can(PermissionKeys.payGuestBill)) &&
                              context.isFeatureEnabled('guest'))
                            SidebarItem(
                              label: 'My Guests',
                              icon: Icons.people_alt_outlined,
                              page: const MyGuestRoute(),
                            ),
                          if (context.can(PermissionKeys.createDamageReport) &&
                              context.isFeatureEnabled('damage_report'))
                            SidebarItem(
                              label: 'Report Damage',
                              icon: Icons.report_problem_outlined,
                              page: const MaintenanceCreateReportRoute(),
                            ),
                          if (context.can(PermissionKeys.viewMyDamageReport) &&
                              context.isFeatureEnabled('damage_report'))
                            SidebarItem(
                              label: 'Report Status',
                              icon: Icons.track_changes_outlined,
                              page: const MaintenanceReportListRoute(),
                            ),
                          if (context.can(PermissionKeys.viewMaintenance) &&
                              context.isFeatureEnabled('maintenance_schedule'))
                            SidebarItem(
                              label: 'Maintenance Schedule',
                              icon: Icons.calendar_today_outlined,
                              page: const MaintananceRoute(),
                            ),
                        ],
                      ),

                    // ─── System & Account ────────────────────────────
                    if (context.can(PermissionKeys.settingView) ||
                        state.isLoggedIn)
                      SidebarItem(
                        label: 'System & Account',
                        icon: Icons.settings_applications,
                        hasAccess: true,
                        children: [
                          if (context.can(PermissionKeys.settingView))
                            SidebarItem(
                              label: 'Settings',
                              icon: Icons.settings,
                              page: const SettingRoute(),
                            ),
                          if (context.can(PermissionKeys.settingView))
                            SidebarItem(
                              label: 'Landing Page',
                              icon: Icons.web,
                              page: const LandingCmsRoute(),
                            ),
                          if (!isResident &&
                              !isMember &&
                              context.can(PermissionKeys.notificationLogView) &&
                              context.isFeatureEnabled('notification'))
                            SidebarItem(
                              label: 'Notification Monitoring',
                              icon: Icons.notifications_outlined,
                              page: const NotificationMonitoringRoute(),
                            ),
                          if ((isMember || isResident) &&
                              context.can(
                                PermissionKeys.completeResidentProfile,
                              ))
                            SidebarItem(
                              label: 'Complete Profile',
                              icon: Icons.assignment_ind_outlined,
                              page: const CompleteProfileRoute(),
                            ),
                          if (state.isLoggedIn)
                            SidebarItem(
                              label: 'My Profile',
                              icon: Icons.person_outline,
                              page: const ProfileRoute(),
                            ),
                        ],
                      ),
                  ],
                ),

                Expanded(child: AutoRouter()),
              ],
            );
          },
        ),
      ),
    );
  }
}
