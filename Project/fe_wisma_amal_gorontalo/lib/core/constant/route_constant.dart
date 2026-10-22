class RouteConstant {
  // If the path starts with / → it means root / landing page
  // If it doesn't start with / → it means child/nested

  // splash page
  static const String landingPath = '/';
  static const String rootPath = '/app';
  static const String rootName = 'root';

  // auth page
  static const String loginName = '/login';
  static const String registerName = '/register';

  // dashboard and admin panel
  static const String dashboardName = 'dashboard';
  static const String landingName = 'landing';
  static const String permissionName = 'permissions';
  static const String roleName = 'roles';
  static const String settingName = 'setting';
  static const String featureToggleName = 'setting/feature-toggles';
  static const String landingCmsName = 'setting/landing-cms';
  static const String userManagementName = 'users';
  static const String profileName = 'profile';
  static const String editProfileName = 'edit-profile';
  static const String changePasswordName = 'change-password';

  // Resident management
  static const String residentName = 'residents';
  static const String residentProfileName = '$residentName/profile';
  static const String myReservationName = 'my-reservation';

  // Room & reservation management
  static const String roomAndReservationName = 'room-reservations';
  static const String roomName = '$roomAndReservationName/rooms';
  static const String addRoomName = '$roomAndReservationName/$roomName/add';
  static const String detailRoomName = '$roomAndReservationName/$roomName/:id';
  static const String editRoomName =
      '$roomAndReservationName/$detailRoomName/form';
  static const String reservationName = '$roomAndReservationName/reservations';
  static const String reservationDetailFormName = 'reservation-detail-form';
  static const String roomScheduleName = '$roomAndReservationName/schedule';

  // Finance management
  static const String financeName = 'finances';

  // Inventory & maintenance management
  static const String inventory = 'inventory';
  static const String inventoryForm = '$inventory/form';
  static const String maintanance = 'maintanance';
  static const String maintananceForm = '$maintanance/form';
  static const String maintananceDetail = '$maintanance/detail';

  // Damage Reports
  static const String maintenanceReport = 'maintenance-reports';
  static const String maintenanceReportCreate = '$maintenanceReport/create';
  static const String maintenanceReportDetail = '$maintenanceReport/:id';

  // Finance module
  static const String financeDashboardName = 'finance/dashboard';

  // User identity form
  static const String identityFormName = 'profile/identity';
  static const String completeProfileName = 'profile/complete';

  static const String financeExpenseName = 'finance/expenses';
  static const String financeFixedExpenseName = 'finance/fixed-expenses';

  static const String financeInvoiceName = 'finance/invoices';
  static const String paymentVerificationName = 'finance/payment-verification';
  static const String refundRequestName = 'finance/refund-requests';
  static const String paymentHistoryName = 'finance/payment-history';
  static const String memberFinanceName = 'me/finance';
  static const String extendLeaseName = 'me/finance/extend-lease';
  static const String extendLeasePaymentName =
      'me/finance/extend-lease/payment';
  static const String invoicePaymentName = 'me/finance/invoice/payment';
  static const String myFinesName = 'me/fines';
  static const String fineManagementName = 'finance/fines';
  static const String myGuestName = 'me/guests';
  static const String adminGuestBillName = 'admin/guest-bills';

  // Notification
  static const String notificationMonitoringName = 'notification/monitoring';
}
