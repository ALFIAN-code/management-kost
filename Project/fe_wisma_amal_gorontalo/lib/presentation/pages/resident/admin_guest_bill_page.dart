import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/domain/entity/guest/guest_bill_entity.dart';
import 'package:frontend/presentation/bloc/guest/guest_bill_bloc.dart';
import 'package:frontend/presentation/widget/core/appbar/app_topbar.dart';
import 'package:frontend/presentation/widget/core/appbar/search_and_filter_bar.dart';
import 'package:frontend/presentation/widget/core/chip/status_badge.dart';
import 'package:frontend/presentation/widget/core/table/app_data_table.dart';
import 'package:frontend/presentation/widget/core/wrapper/empty_state_widget.dart';
import 'package:frontend/presentation/widget/core/dialog/app_dialog.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';
import 'package:frontend/presentation/widget/core/textform/textfield.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

@RoutePage()
class AdminGuestBillPage extends StatelessWidget {
  const AdminGuestBillPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<GuestBillBloc>(),
      child: const _AdminGuestBillView(),
    );
  }
}

class _AdminGuestBillView extends StatefulWidget {
  const _AdminGuestBillView();

  @override
  State<_AdminGuestBillView> createState() => _AdminGuestBillViewState();
}

class _AdminGuestBillViewState extends State<_AdminGuestBillView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int _currentPage = 1;
  static const int _perPage = 10;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  List<AdminGuestBillItem> _cache = [];
  Timer? _debounce;
  String _selectedStatus = 'All';

  final _currency = NumberFormat.currency(
    locale: 'en_US',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetch();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _fetch() {
    context.read<GuestBillBloc>().add(FetchAdminGuestBills(
          page: _currentPage,
          perPage: _perPage,
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
        ));
  }

  void _onSearch(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _currentPage = 1;
        _cache = [];
        _hasMore = true;
      });
      _fetch();
    });
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 120) {
      setState(() {
        _isLoadingMore = true;
        _currentPage += 1;
      });
      _fetch();
    }
  }

  void _reload() {
    setState(() {
      _currentPage = 1;
      _cache = [];
      _hasMore = true;
    });
    _fetch();
  }

  Future<void> _showVerifyDialog(AdminGuestBillItem item) async {
    final theme = Theme.of(context);
    final notesController = TextEditingController();
    bool? isApproved;

    // Payment method label
    String methodLabel;
    switch (item.paymentMethod) {
      case 'cash':
        methodLabel = 'Cash';
        break;
      case 'midtrans':
        methodLabel = 'Midtrans';
        break;
      case 'manual':
        methodLabel = 'Manual Transfer';
        break;
      default:
        methodLabel = item.paymentMethod ?? '-';
    }

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Payment Verification'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Invoice: ${item.billNumber}'),
              Text('Resident: ${item.penghuni}'),
              Text('Guest: ${item.guestName}'),
              Text('Amount: ${_currency.format(item.amount)}'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('Method: ', style: theme.textTheme.bodyMedium),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: item.paymentMethod == 'cash'
                          ? Colors.green.withAlpha(30)
                          : theme.colorScheme.primaryContainer.withAlpha(80),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      methodLabel,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: item.paymentMethod == 'cash'
                            ? Colors.green[700]
                            : theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (item.paymentMethod == 'manual' && item.paymentProofUrl != null)
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('View Payment Proof'),
                ),
              if (item.paymentMethod == 'cash')
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.withAlpha(80)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: Colors.amber[800]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cash payment — make sure the money has been received before verifying.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.amber[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: notesController,
                hintText: 'Admin Notes (optional)',
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: BasicButton(
                      type: ButtonType.secondary,
                      foregroundColor: theme.colorScheme.error,
                      onPressed: () {
                        setDialogState(() => isApproved = false);
                        Navigator.pop(ctx);
                      },
                      leadIcon: Icon(Icons.close, color: theme.colorScheme.error, size: 18),
                      label: 'Reject',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BasicButton(
                      type: ButtonType.primary,
                      onPressed: () {
                        setDialogState(() => isApproved = true);
                        Navigator.pop(ctx);
                      },
                      leadIcon: Icon(Icons.check, color: theme.colorScheme.onPrimary, size: 18),
                      label: 'Approve',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (isApproved != null && mounted) {
      context.read<GuestBillBloc>().add(VerifyAdminGuestBill(
            billId: item.id,
            isApproved: isApproved!,
            adminNotes:
                notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return BlocListener<GuestBillBloc, GuestBillState>(
      listener: (context, state) {
        if (state is GuestBillLoaded) {
          setState(() {
            if (_currentPage == 1) {
              _cache = List.from(state.data.bills);
            } else {
              _cache.addAll(state.data.bills);
            }
            _hasMore = state.data.pagination.currentPage <
                state.data.pagination.lastPage;
            _isLoadingMore = false;
          });
        }
        if (state is GuestBillError) {
          setState(() => _isLoadingMore = false);
        }
        if (state is GuestBillVerifySuccess) {
          AppSnackbar.showSuccess(state.message);
          _reload();
        }
        if (state is GuestBillVerifyError) {
          AppSnackbar.showError(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColorsDark.background : AppColorsLight.background,
        body: Column(
          children: [
            AppTopBar(
              title: 'Guest Invoices',
              breadcrumb: 'Management / Guest Invoices',
            ),
            Expanded(
              child: BlocBuilder<GuestBillBloc, GuestBillState>(
                builder: (context, state) {
                  if (state is GuestBillLoading && _cache.isEmpty) {
                    return _buildSkeleton(isDark);
                  }
                  if (state is GuestBillError && _cache.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.error_outline,
                      title: 'Failed to Load Data',
                      subtitle: state.message,
                      action: BasicButton(
                        onPressed: _reload,
                        label: 'Try Again',
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppSpacing.xxxl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Bar
                        SearchAndFilterBar(
                          searchController: _searchController,
                          searchHint: 'Search resident, guest...',
                          onSearchChanged: _onSearch,
                          dropdownFilter: DropdownButton<String>(
                            value: _selectedStatus,
                            items: ['All', 'Unpaid', 'Pending', 'Verified', 'Paid', 'Rejected', 'Failed']
                                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() {
                                  _selectedStatus = v;
                                });
                              }
                            },
                            underline: const SizedBox(),
                            focusColor: Colors.transparent,
                          ),
                        ).animate().fadeIn(duration: 300.ms),

                        const SizedBox(height: AppSpacing.lg),

                        // Table
                        AppDataTable(
                          columns: const [
                            DataColumn(label: Text('NO')),
                            DataColumn(label: Text('INVOICE NO.')),
                            DataColumn(label: Text('RESIDENT')),
                            DataColumn(label: Text('GUEST NAME')),
                            DataColumn(label: Text('AMOUNT')),
                            DataColumn(label: Text('METHOD')),
                            DataColumn(label: Text('STATUS')),
                            DataColumn(label: Text('ACTION')),
                          ],
                          rows: (() {
                            final filteredCache = _cache.where((item) {
                              if (_selectedStatus == 'All') return true;
                              return item.status.toLowerCase() == _selectedStatus.toLowerCase();
                            }).toList();
                            return filteredCache.asMap().entries.map((entry) {
                              final index = entry.key + 1;
                              final row = entry.value;
                            return DataRow(
                              cells: [
                                DataCell(Text('$index')),
                                DataCell(Text(row.billNumber)),
                                DataCell(Text(row.penghuni, style: const TextStyle(fontWeight: FontWeight.w600))),
                                DataCell(Text(row.guestName)),
                                DataCell(Text(_currency.format(row.amount), style: const TextStyle(fontWeight: FontWeight.w600))),
                                DataCell(Text(row.paymentMethod ?? '-')),
                                DataCell(StatusBadge(status: row.status)),
                                DataCell(
                                  TextButton(
                                    onPressed: () => _showVerifyDialog(row),
                                    child: const Text('Detail', style: TextStyle(fontSize: 12)),
                                  ),
                                ),
                                  ],
                                );
                              }).toList();
                            })(),
                          ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

                        // Loading more indicator
                        if (_isLoadingMore)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton(bool isDark) {
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              height: 40,
              width: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
