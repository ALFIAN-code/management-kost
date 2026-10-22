import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

// wrapper for the permission menu
@RoutePage(name: 'PermissionPlaceholderRoute')
class PermissionPlaceholderPage extends EmptyPlaceholderPage {
  const PermissionPlaceholderPage({super.key}) : super(title: 'Permission');
}

// wrapper for the role menu
@RoutePage(name: 'RolePlaceholderRoute')
class RolePlaceholderPage extends EmptyPlaceholderPage {
  const RolePlaceholderPage({super.key}) : super(title: 'Role');
}

// wrapper for the Residents menu
@RoutePage(name: 'ResidentPlaceholderRoute')
class ResidentPlaceholderPage extends EmptyPlaceholderPage {
  const ResidentPlaceholderPage({super.key}) : super(title: 'Residents');
}

// wrapper for the Reservations menu
@RoutePage(name: 'RoomAndReservationPlaceholderRoute')
class RoomAndReservationPlaceholderPage extends EmptyPlaceholderPage {
  const RoomAndReservationPlaceholderPage({super.key})
    : super(title: 'Reservations');
}

// wrapper for the Finance menu
@RoutePage(name: 'FinancePlaceholderRoute')
class FinancePlaceholderPage extends EmptyPlaceholderPage {
  const FinancePlaceholderPage({super.key}) : super(title: 'Finance');
}

// wrapper for the Inventory & Maintenance menu
@RoutePage(name: 'InventoryAndMaintenancePlaceholderRoute')
class InventoryAndMaintenancePlaceholderPage extends EmptyPlaceholderPage {
  const InventoryAndMaintenancePlaceholderPage({super.key})
    : super(title: 'Inventory & Maintenance');
}


class EmptyPlaceholderPage extends StatelessWidget {
  final String title;
  const EmptyPlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('The $title page is under development')),
    );
  }
}
