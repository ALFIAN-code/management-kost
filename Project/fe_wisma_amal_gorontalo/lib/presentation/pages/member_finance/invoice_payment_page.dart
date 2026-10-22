import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/dependency_injection/dependency_injection.dart';
import '../../../core/navigation/auto_route.gr.dart';
import '../../../domain/entity/setting/midtrans_method_entity.dart';
import '../../../domain/usecase/finance/get_available_payment_methods_usecase.dart';
import '../../../domain/usecase/finance/get_member_invoice_by_id_usecase.dart';
import '../../bloc/member_finance/member_finance_bloc.dart';
import '../../bloc/member_finance/member_finance_event.dart';
import '../../bloc/member_finance/member_finance_state.dart';
import '../../widget/core/appbar/custom_appbar.dart';
import '../../widget/core/botton/button.dart';
import '../../widget/core/card/basic_card.dart';

const bool _kMidtransProduction = false;
const int _kMaxPollAttempts = 10;
const Duration _kPollInterval = Duration(seconds: 3);

// ── Midtrans method metadata (exactly the same as reservation_detail_form_page) ──

class _MethodInfo {
  const _MethodInfo(this.name, this.desc, this.icon);
  final String name;
  final String desc;
  final IconData icon;
}

const Map<String, _MethodInfo> _kMethodMap = {
  'qris':        _MethodInfo('QRIS', 'Scan QR from all e-wallets & banks', Icons.qr_code),
  'gopay':       _MethodInfo('GoPay', 'Pay with your GoPay balance', Icons.account_balance_wallet),
  'shopeepay':   _MethodInfo('ShopeePay', 'Pay with your ShopeePay balance', Icons.shopping_bag),
  'dana':        _MethodInfo('DANA', 'Pay with your DANA balance', Icons.account_balance_wallet),
  'linkaja':     _MethodInfo('LinkAja', 'Pay with LinkAja', Icons.account_balance_wallet),
  'ovo':         _MethodInfo('OVO', 'Pay with your OVO balance', Icons.account_balance_wallet),
  'bca_va':      _MethodInfo('BCA Virtual Account', 'Transfer via ATM / m-BCA', Icons.account_balance),
  'bni_va':      _MethodInfo('BNI Virtual Account', 'Transfer via ATM / BNI Mobile', Icons.account_balance),
  'bri_va':      _MethodInfo('BRI Virtual Account', 'Transfer via ATM / BRImo', Icons.account_balance),
  'mandiri_va':  _MethodInfo('Mandiri Virtual Account', 'Transfer via Mandiri Livin\'', Icons.account_balance),
  'echannel':    _MethodInfo('Mandiri Bill', 'Pay via Mandiri Livin\'', Icons.account_balance),
  'permata_va':  _MethodInfo('Permata Virtual Account', 'Transfer via ATM Permata', Icons.account_balance),
  'other_va':    _MethodInfo('Virtual Account', 'Transfer via other banks', Icons.account_balance),
  'alfamart':    _MethodInfo('Alfamart', 'Pay at the Alfamart counter', Icons.store),
  'indomaret':   _MethodInfo('Indomaret', 'Pay at the Indomaret counter', Icons.store),
  'credit_card': _MethodInfo('Credit/Debit Card', 'Visa, Mastercard, JCB', Icons.credit_card),
  'akulaku':     _MethodInfo('Akulaku', '0% installments via Akulaku', Icons.credit_card),
  'kredivo':     _MethodInfo('Kredivo', 'Installments via Kredivo', Icons.credit_card),
};

String _methodName(String code) => _kMethodMap[code]?.name ?? code.toUpperCase();

enum _PayPageState { selecting, midtransActive }

@RoutePage()
class InvoicePaymentPage extends StatefulWidget {
  const InvoicePaymentPage({
    super.key,
    required this.invoiceId,
    required this.invoiceNumber,
    required this.amount,
    this.roomNumber,
    this.invoiceType,
    this.dueDate,
    // Used only for test widgets — production uses serviceLocator
    this.bloc,
  });

  final int invoiceId;
  final String invoiceNumber;
  final double amount;
  final String? roomNumber;
  final String? invoiceType;
  final DateTime? dueDate;
  final MemberFinanceBloc? bloc;

  @override
  State<InvoicePaymentPage> createState() => _InvoicePaymentPageState();
}

class _InvoicePaymentPageState extends State<InvoicePaymentPage> {
  late final MemberFinanceBloc _bloc;

  // Main payment method: 'manual' | 'online'
  String _selectedMethod = 'manual';

  // Specific Midtrans method selected (code, e.g. 'qris', 'gopay')
  String? _selectedMidtransMethod;

  // List of available Midtrans methods from the settings
  List<MidtransMethodEntity> _midtransMethods = [];
  bool _methodsLoading = false;

  // Upload proof (manual)
  PlatformFile? _selectedFile;

  // Page state after the Midtrans submit
  _PayPageState _pageState = _PayPageState.selecting;
  String? _snapToken;
  Map<String, dynamic>? _midtransData;
  bool _snapOpened = false;
  bool _isPolling = false;
  bool _paymentConfirmed = false;
  int _pollAttempts = 0;
  Timer? _pollTimer;

  final _currencyFmt = NumberFormat.currency(locale: 'en_US', symbol: 'Rp ', decimalDigits: 0);
  final _dateFmt = DateFormat('dd MMMM yyyy', 'en_US');

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? serviceLocator<MemberFinanceBloc>();
    _loadMidtransMethods();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadMidtransMethods() async {
    setState(() => _methodsLoading = true);
    try {
      final methods = await serviceLocator.get<GetAvailablePaymentMethodsUseCase>().execute();
      if (mounted) setState(() => _midtransMethods = methods);
    } catch (_) {}
    if (mounted) setState(() => _methodsLoading = false);
  }

  // ── Labels ────────────────────────────────────────────────────────────────

  String get _pageTitle => switch (widget.invoiceType) {
        'pelunasan' => 'Pay Full Amount',
        'dp'        => 'Pay Down Payment (DP)',
        'extension' => 'Pay Lease Extension',
        'fine'      => 'Pay Fine',
        _           => 'Pay Invoice',
      };

  String get _invoiceTypeLabel => switch (widget.invoiceType) {
        'pelunasan' => 'Full Payment',
        'dp'        => 'Down Payment (DP)',
        'extension' => 'Extension',
        'fine'      => 'Fine',
        'sewa'      => 'Monthly Lease',
        _           => 'Invoice',
      };

  Color get _invoiceTypeColor => switch (widget.invoiceType) {
        'pelunasan' => Colors.teal.shade700,
        'dp'        => Colors.amber.shade700,
        'extension' => Colors.blue.shade700,
        'fine'      => Colors.red.shade700,
        _           => Colors.indigo.shade600,
      };

  // ── Actions ───────────────────────────────────────────────────────────────

  void _submitManual() {
    if (_selectedFile == null) return;
    _bloc.add(PayInvoiceEvent(
      widget.invoiceId,
      'manual',
      paymentProofBytes: _selectedFile!.bytes,
      paymentProofName: _selectedFile!.name,
    ));
  }

  void _submitOnline() {
    _bloc.add(PayInvoiceEvent(
      widget.invoiceId,
      'midtrans',
      preferredPaymentType: _selectedMidtransMethod,
    ));
  }

  Future<void> _openSnapUrl(String token) async {
    final env = _kMidtransProduction ? '' : 'sandbox.';
    final url = Uri.parse('https://app.${env}midtrans.com/snap/v2/vtweb/$token');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      setState(() => _snapOpened = true);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open the payment page')),
        );
      }
    }
  }

  void _startPolling() {
    setState(() { _isPolling = true; _pollAttempts = 0; });
    _pollTimer = Timer.periodic(_kPollInterval, (timer) async {
      if (!mounted) { timer.cancel(); return; }
      _pollAttempts++;
      try {
        final invoice = await serviceLocator
            .get<GetMemberInvoiceByIdUseCase>()
            .execute(widget.invoiceId);
        if (invoice.status.toLowerCase() == 'paid') {
          timer.cancel();
          if (mounted) setState(() { _isPolling = false; _paymentConfirmed = true; });
          return;
        }
      } catch (_) {}

      if (_pollAttempts >= _kMaxPollAttempts) {
        timer.cancel();
        if (mounted) {
          setState(() => _isPolling = false);
          _showPendingDialog();
        }
      }
    });
  }

  void _showPendingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(children: [
          const Icon(Icons.hourglass_top, color: Colors.orange, size: 28),
          const SizedBox(width: 8),
          const Text('Payment Is Being Processed'),
        ]),
        content: const Text(
          'Payment confirmation has not been received. '
          'The status will update automatically. '
          'Track it on your finance page.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.router.replaceAll([const MemberFinanceRoute()]);
            },
            child: const Text('View Payment Status'),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<MemberFinanceBloc, MemberFinanceState>(
        listenWhen: (prev, curr) =>
            prev.status == MemberFinanceStatus.loading &&
            (curr.status == MemberFinanceStatus.paymentSuccess ||
                curr.status == MemberFinanceStatus.failure),
        listener: (context, state) {
          if (state.status == MemberFinanceStatus.paymentSuccess) {
            if (state.snapToken != null || state.paymentData != null) {
              // Online: show the payment code on this page
              setState(() {
                _pageState = _PayPageState.midtransActive;
                _snapToken = state.snapToken;
                _midtransData = state.paymentData;
              });
            } else {
              // Manual: success → snackbar + return to finance
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment proof uploaded successfully. Waiting for admin verification.'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 4),
                ),
              );
              context.router.replaceAll([const MemberFinanceRoute()]);
            }
          } else if (state.status == MemberFinanceStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Failed to process the payment'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (_paymentConfirmed) return _buildSuccessView(context);

          final isLoading = state.status == MemberFinanceStatus.loading;

          return PopScope(
            canPop: !isLoading && !_isPolling,
            child: Scaffold(
              appBar: CustomAppbar(
                title: _pageTitle,
                icon: const Icon(Icons.arrow_back),
                onPressed: (isLoading || _isPolling)
                    ? null
                    : () => context.router.maybePop(),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStepIndicator(),
                        const SizedBox(height: 24),
                        if (isLoading && _pageState == _PayPageState.selecting)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 48),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: _pageState == _PayPageState.midtransActive
                                    ? _buildMidtransPaymentCard(state)
                                    : _buildSelectingContent(state, isLoading),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 2,
                                child: _buildSummarySection(state, isLoading),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Step indicator ────────────────────────────────────────────────────────

  Widget _buildStepIndicator() {
    final step = _pageState == _PayPageState.midtransActive ? 2 : 1;
    return Row(
      children: [
        _stepCircle('1', 'Invoice', step >= 1, done: step > 1),
        _stepLine(step > 1),
        _stepCircle('2', 'Payment', step >= 2, done: _paymentConfirmed),
        _stepLine(_paymentConfirmed),
        _stepCircle('3', 'Done', _paymentConfirmed),
      ],
    );
  }

  Widget _stepCircle(String num, String label, bool isActive, {bool done = false}) {
    return Column(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(num, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.blue : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _stepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: isActive ? Colors.blue : Colors.grey.shade300,
      ),
    );
  }

  // ── Selecting content ─────────────────────────────────────────────────────

  Widget _buildSelectingContent(MemberFinanceState state, bool isLoading) {
    final bankAccounts = state.bankAccounts;
    final isMidtrans = state.isMidtransEnabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Main method selection card ────────────────────────────────────
        BasicCard(
          title: 'Payment Method',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  if (isMidtrans)
                    _mainMethodCard(
                      title: 'Online Payment',
                      subtitle: _onlineSubtitle(),
                      icon: Icons.account_balance_wallet,
                      selected: _selectedMethod == 'online',
                      onTap: () => setState(() => _selectedMethod = 'online'),
                    ),
                  _mainMethodCard(
                    title: 'Manual Payment',
                    subtitle: 'Transfer or cash with proof',
                    icon: Icons.payments,
                    selected: _selectedMethod == 'manual',
                    onTap: () => setState(() => _selectedMethod = 'manual'),
                  ),
                ],
              ),

              // Midtrans method grid
              if (_selectedMethod == 'online') ...[
                const SizedBox(height: 20),
                Text(
                  'Choose a Payment Method',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey.shade800),
                ),
                const SizedBox(height: 4),
                Text(
                  'The payment code will be shown directly in the app after you tap Process Payment.',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 12),
                if (_methodsLoading)
                  const Center(child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ))
                else if (_midtransMethods.isEmpty)
                  _infoBox(
                    icon: Icons.info_outline,
                    color: Colors.grey,
                    text: 'No online payment methods are active. Contact the management or use Manual Payment.',
                  )
                else if (_midtransMethods.every((m) => !m.available))
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: Row(children: [
                      Icon(Icons.build_outlined, color: Colors.orange.shade700, size: 20),
                      const SizedBox(width: 12),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('All methods are under maintenance',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange.shade800)),
                          const SizedBox(height: 4),
                          Text('Try again later or use Manual Payment.',
                              style: TextStyle(fontSize: 12, color: Colors.orange.shade700)),
                        ],
                      )),
                    ]),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      mainAxisExtent: 72,
                    ),
                    itemCount: _midtransMethods.length,
                    itemBuilder: (context, index) {
                      final method = _midtransMethods[index];
                      final isSelected = _selectedMidtransMethod == method.code;
                      return _midtransMethodCard(
                        method: method,
                        selected: isSelected,
                        onTap: method.available
                            ? () => setState(() => _selectedMidtransMethod = isSelected ? null : method.code)
                            : () {},
                      );
                    },
                  ),
              ],

              // Manual info
              if (_selectedMethod == 'manual') ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Manual Payment',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange.shade700)),
                        const SizedBox(height: 4),
                        Text('Make a bank transfer or pay cash, then upload the payment proof.',
                            style: TextStyle(fontSize: 12, color: Colors.orange.shade600)),
                      ],
                    )),
                  ]),
                ),
              ],
            ],
          ),
        ),

        // ── Content per method ────────────────────────────────────────────
        if (_selectedMethod == 'manual') ...[
          const SizedBox(height: 16),
          _buildTransferBankCard(bankAccounts),
          const SizedBox(height: 16),
          _buildCashCard(),
          const SizedBox(height: 16),
          _buildUploadCard(isLoading),
        ],
      ],
    );
  }

  // ── Main method card (Online / Manual) ────────────────────────────────────

  Widget _mainMethodCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 200, maxWidth: 320),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.blue : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? Colors.blue : Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? Colors.blue : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // ── Midtrans method card (grid item) ──────────────────────────────────────

  Widget _midtransMethodCard({
    required MidtransMethodEntity method,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final info = _kMethodMap[method.code] ??
        _MethodInfo(method.code.toUpperCase(), 'Midtrans method', Icons.payment);
    final displayName = method.label.isNotEmpty ? method.label : info.name;

    return Opacity(
      opacity: method.available ? 1.0 : 0.5,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.blue.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? Colors.blue : Colors.grey.shade300,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(info.icon,
                  size: 22,
                  color: selected ? Colors.blue : (method.maintenance ? Colors.grey.shade400 : Colors.grey.shade600)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: selected ? Colors.blue.shade800 : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (method.maintenance)
                      Text('Maintenance', style: TextStyle(fontSize: 10, color: Colors.orange.shade700))
                    else
                      Text(info.desc,
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? Colors.blue : Colors.grey.shade400,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bank transfer card ────────────────────────────────────────────────────

  Widget _buildTransferBankCard(bankAccounts) {
    return BasicCard(
      title: 'Payment via Bank Transfer',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _instructionStep(1, 'Transfer to the Following Account',
              'Make sure the transfer amount matches the invoice total.'),
          const SizedBox(height: 16),
          if (bankAccounts.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Text(
                'Contact the dormitory management for transfer account details.',
                style: TextStyle(fontSize: 13),
              ),
            )
          else
            ...bankAccounts.map((acc) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(acc.bankName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    _bankInfoRow('Account No.', acc.accountNumber),
                    _bankInfoRow('Account Holder', acc.accountHolder),
                    if (acc.paymentInstructions != null && acc.paymentInstructions!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(acc.paymentInstructions!,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                    ],
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Transfer Amount:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(
                            _currencyFmt.format(widget.amount),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
          const SizedBox(height: 16),
          _instructionStep(2, 'Save the Transfer Proof',
              'Screenshot or photo the transfer receipt from mobile banking / ATM.'),
        ],
      ),
    );
  }

  // ── Cash card ─────────────────────────────────────────────────────────────

  Widget _buildCashCard() {
    return BasicCard(
      title: 'Cash Payment',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _instructionStep(1, 'Visit the Management Office',
              'Come in person to the Wisma Amal Gorontalo management office.'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bankInfoRow('Address', 'Jl. Wisma Amal No. 1, Gorontalo'),
                _bankInfoRow('Operating Hours', 'Monday – Saturday, 08.00 – 17.00 WITA'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _instructionStep(2, 'Pay & Request a Receipt',
              'Make the cash payment and ask the management for an official receipt.'),
          const SizedBox(height: 12),
          _instructionStep(3, 'Photograph the Receipt',
              'Take a clear photo of the payment receipt as proof.'),
        ],
      ),
    );
  }

  // ── Upload card ───────────────────────────────────────────────────────────

  Widget _buildUploadCard(bool isLoading) {
    return BasicCard(
      title: 'Upload Payment Proof',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _instructionStep(1, 'Select a Proof File',
              'Choose a clear, readable photo of the transfer receipt or cash receipt.'),
          const SizedBox(height: 16),
          if (_selectedFile != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Selected file: ${_selectedFile!.name}',
                      style: const TextStyle(fontSize: 13, color: Colors.green)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => setState(() => _selectedFile = null),
                ),
              ]),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isLoading
                  ? null
                  : () async {
                      final result = await FilePicker.platform
                          .pickFiles(type: FileType.image, withData: true);
                      if (result != null) setState(() => _selectedFile = result.files.first);
                    },
              icon: const Icon(Icons.image_outlined),
              label: Text(_selectedFile == null ? 'Choose Proof Image' : 'Replace Image'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Midtrans payment display (after a successful submit) ────────────────────

  Widget _buildMidtransPaymentCard(MemberFinanceState state) {
    final data = _midtransData;
    final token = _snapToken;

    if (data != null) {
      return _buildCoreApiCard(data);
    }
    if (token != null && token.isNotEmpty) {
      return _buildSnapCard(token);
    }
    return const SizedBox.shrink();
  }

  Widget _buildCoreApiCard(Map<String, dynamic> data) {
    final paymentType = data['payment_type'] as String? ?? '';

    Widget paymentWidget;
    if (_hasQrCode(data)) {
      paymentWidget = _buildQrCodeUI(data, paymentType);
    } else if (data.containsKey('va_numbers')) {
      paymentWidget = _buildVaNumberUI(data);
    } else if (data.containsKey('bill_key')) {
      paymentWidget = _buildMandiriBillUI(data);
    } else if (data.containsKey('payment_code')) {
      paymentWidget = _buildCStoreUI(data);
    } else {
      paymentWidget = _buildGenericPaymentUI();
    }

    return BasicCard(
      title: 'Payment Code',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          paymentWidget,
          const SizedBox(height: 24),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildSnapCard(String token) {
    final methodName = _selectedMidtransMethod != null
        ? _methodName(_selectedMidtransMethod!)
        : 'Midtrans';

    return BasicCard(
      title: 'Payment via $methodName',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoBox(
            icon: Icons.security,
            color: Colors.blue,
            text: 'The payment continues on the $methodName page. '
                'After you finish paying, return here and tap the confirmation.',
          ),
          const SizedBox(height: 20),
          _instructionStep(1, 'Tap "Pay Now"',
              'You will be redirected to the $methodName page.'),
          const SizedBox(height: 10),
          _instructionStep(2, 'Complete the Payment',
              'Follow the instructions on the $methodName page.'),
          const SizedBox(height: 10),
          _instructionStep(3, 'Return to the App',
              'After you finish paying, come back and tap the confirmation button.'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isPolling ? null : () => _openSnapUrl(token),
              icon: const Icon(Icons.payment, color: Colors.white),
              label: Text('Pay Now',
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          if (_snapOpened) ...[
            const SizedBox(height: 12),
            _buildConfirmButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    if (_isPolling) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 18, height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue.shade700),
            ),
            const SizedBox(width: 12),
            Text('Verifying payment…',
                style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _startPolling,
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        label: const Text('I Have Paid',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // ── Summary section (right col) ───────────────────────────────────────────

  Widget _buildSummarySection(MemberFinanceState state, bool isLoading) {
    // Midtrans fee breakdown (available after the payment is initiated)
    final grossAmount   = state.paymentGrossAmount;
    final midtransFee   = state.paymentMidtransFee ?? 0;
    final isCustomer    = state.paymentFeeBearer == 'customer';
    final hasFee        = isCustomer && midtransFee > 0 && _pageState == _PayPageState.midtransActive;

    final isSelectingManual = _pageState == _PayPageState.selecting && _selectedMethod == 'manual';
    final isSelectingOnline = _pageState == _PayPageState.selecting && _selectedMethod == 'online';

    // Online submit validation
    final canSubmitOnline = _selectedMidtransMethod != null &&
        _midtransMethods.any((m) => m.code == _selectedMidtransMethod && m.available);

    return Column(
      children: [
        BasicCard(
          title: 'Invoice Summary',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Invoice type badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _invoiceTypeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _invoiceTypeColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  _invoiceTypeLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _invoiceTypeColor,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _summaryRow('Invoice No.', widget.invoiceNumber),
              if (widget.roomNumber != null)
                _summaryRow('Room', 'Room ${widget.roomNumber}'),
              if (widget.dueDate != null)
                _summaryRow('Due Date', _dateFmt.format(widget.dueDate!)),
              const Divider(height: 28),

              // Fee breakdown when a Midtrans fee applies
              if (hasFee) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Invoice', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                    Text(_currencyFmt.format(widget.amount),
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Transaction Fee', style: TextStyle(fontSize: 13, color: Colors.orange.shade700)),
                    Text(_currencyFmt.format(midtransFee),
                        style: TextStyle(fontSize: 13, color: Colors.orange.shade700)),
                  ],
                ),
                const Divider(height: 16),
              ],

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Payment', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    _currencyFmt.format(hasFee && grossAmount != null ? grossAmount : widget.amount),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 18),
                  ),
                ],
              ),

              if (hasFee) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(children: [
                    Icon(Icons.info_outline, size: 13, color: Colors.orange.shade700),
                    const SizedBox(width: 5),
                    Expanded(child: Text(
                      'The Midtrans transaction fee is borne by the resident and is already included in the total above.',
                      style: TextStyle(fontSize: 10, color: Colors.orange.shade700, height: 1.3),
                    )),
                  ]),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Submit button — only while selecting
        if (isSelectingManual)
          BasicButton(
            label: isLoading ? 'Sending...' : 'Submit Payment Proof',
            isLoading: isLoading,
            onPressed: (isLoading || _selectedFile == null) ? null : _submitManual,
          ),

        if (isSelectingOnline)
          BasicButton(
            label: isLoading ? 'Processing...' : 'Process Payment',
            isLoading: isLoading,
            onPressed: (isLoading || !canSubmitOnline) ? null : _submitOnline,
          ),

        if (isSelectingOnline && _selectedMidtransMethod == null) ...[
          const SizedBox(height: 8),
          Text(
            'Please choose a payment method first.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  // ── Success view ──────────────────────────────────────────────────────────

  Widget _buildSuccessView(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96, height: 96,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green.shade200, width: 2),
                ),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 56),
              ),
              const SizedBox(height: 24),
              const Text('Payment Successful!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                'The payment has been confirmed.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.router.replaceAll([const MemberFinanceRoute()]),
                  icon: const Icon(Icons.home, color: Colors.white),
                  label: const Text('View My Finance',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Core API sub-widgets ──────────────────────────────────────────────────

  bool _hasQrCode(Map<String, dynamic> data) {
    final actions = data['actions'] as List?;
    if (actions == null) return false;
    return actions.any((a) =>
        a is Map && (a['name'] == 'generate-qr-code' || a['name'] == 'get-qr-code'));
  }

  String? _getQrUrl(Map<String, dynamic> data) {
    final actions = data['actions'] as List?;
    if (actions == null) return null;
    for (final a in actions) {
      if (a is Map && (a['name'] == 'generate-qr-code' || a['name'] == 'get-qr-code')) {
        return a['url'] as String?;
      }
    }
    return null;
  }

  String? _getDeeplinkUrl(Map<String, dynamic> data) {
    final actions = data['actions'] as List?;
    if (actions == null) return null;
    for (final a in actions) {
      if (a is Map && a['name'] == 'deeplink-redirect') return a['url'] as String?;
    }
    return null;
  }

  Widget _buildQrCodeUI(Map<String, dynamic> data, String paymentType) {
    final qrUrl = _getQrUrl(data);
    final deeplinkUrl = _getDeeplinkUrl(data);
    final expiryTime = data['expiry_time'] as String?;
    final methodLabel = _kMethodMap[paymentType]?.name ?? paymentType.toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _infoBox(
          icon: Icons.qr_code_2,
          color: Colors.indigo,
          text: 'Scan the QR code below using the $methodLabel app or your phone camera.',
        ),
        const SizedBox(height: 20),
        if (qrUrl != null)
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.network(
                qrUrl,
                width: 200, height: 200, fit: BoxFit.contain,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : const SizedBox(
                        width: 200, height: 200,
                        child: Center(child: CircularProgressIndicator())),
                errorBuilder: (_, __, ___) => const SizedBox(
                    width: 200, height: 200,
                    child: Center(child: Text('Failed to load QR Code'))),
              ),
            ),
          ),
        if (expiryTime != null) ...[
          const SizedBox(height: 12),
          _expiryChip(expiryTime),
        ],
        if (deeplinkUrl != null) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final uri = Uri.parse(deeplinkUrl);
                if (await canLaunchUrl(uri)) await launchUrl(uri);
              },
              icon: const Icon(Icons.open_in_new),
              label: Text('Open in $methodLabel'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVaNumberUI(Map<String, dynamic> data) {
    final vaNumbers = data['va_numbers'] as List? ?? [];
    final expiryTime = data['expiry_time'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoBox(
          icon: Icons.account_balance,
          color: Colors.blue,
          text: 'Transfer to the Virtual Account number below before it expires.',
        ),
        const SizedBox(height: 16),
        for (final va in vaNumbers)
          if (va is Map) ...[
            _vaCard(
              bank: (va['bank'] as String? ?? '').toUpperCase(),
              vaNumber: va['va_number'] as String? ?? '-',
            ),
            const SizedBox(height: 8),
          ],
        if (expiryTime != null) _expiryChip(expiryTime),
      ],
    );
  }

  Widget _buildMandiriBillUI(Map<String, dynamic> data) {
    final billKey = data['bill_key'] as String? ?? '-';
    final billerCode = data['biller_code'] as String? ?? '-';
    final expiryTime = data['expiry_time'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoBox(
          icon: Icons.account_balance,
          color: Colors.blue,
          text: "Pay through Mandiri Livin' or a Mandiri ATM using the code below.",
        ),
        const SizedBox(height: 16),
        _codeCard(label: 'Biller Code', value: billerCode),
        const SizedBox(height: 8),
        _codeCard(label: 'Bill Key', value: billKey),
        if (expiryTime != null) ...[const SizedBox(height: 12), _expiryChip(expiryTime)],
      ],
    );
  }

  Widget _buildCStoreUI(Map<String, dynamic> data) {
    final paymentCode = data['payment_code'] as String? ?? '-';
    final store = data['store'] as String? ?? 'Minimarket';
    final expiryTime = data['expiry_time'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoBox(
          icon: Icons.store,
          color: Colors.red,
          text: 'Show the following code to the $store cashier to complete the payment.',
        ),
        const SizedBox(height: 16),
        _codeCard(label: '$store Payment Code', value: paymentCode),
        if (expiryTime != null) ...[const SizedBox(height: 12), _expiryChip(expiryTime)],
      ],
    );
  }

  Widget _buildGenericPaymentUI() {
    return _infoBox(
      icon: Icons.payment,
      color: Colors.grey,
      text: 'Continue the payment and tap "I Have Paid" when you are done.',
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────

  String _onlineSubtitle() {
    if (_midtransMethods.isEmpty) return 'No active methods';
    final available = _midtransMethods.where((m) => !m.maintenance).toList();
    if (available.isEmpty) return 'All methods are under maintenance';
    final names = available
        .map((m) => m.label.isNotEmpty ? m.label : (_kMethodMap[m.code]?.name ?? m.code.toUpperCase()))
        .take(3)
        .join(', ');
    return available.length > 3 ? '$names, +${available.length - 3} more' : names;
  }

  Widget _instructionStep(int num, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26, height: 26,
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(num.toString(),
                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 3),
              Text(desc, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bankInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
          ),
          const Text(': ', style: TextStyle(fontSize: 13)),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          Flexible(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  Widget _vaCard({required String bank, required String vaNumber}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Virtual Account $bank',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                Text(vaNumber,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: vaNumber));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('VA number copied'), duration: Duration(seconds: 2)),
              );
            },
            icon: const Icon(Icons.copy, color: Colors.blue),
            tooltip: 'Copy',
          ),
        ],
      ),
    );
  }

  Widget _codeCard({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Code copied'), duration: Duration(seconds: 2)),
              );
            },
            icon: const Icon(Icons.copy, color: Colors.blue),
            tooltip: 'Copy',
          ),
        ],
      ),
    );
  }

  Widget _expiryChip(String expiryTime) {
    return Row(
      children: [
        const Icon(Icons.schedule, size: 14, color: Colors.orange),
        const SizedBox(width: 6),
        Text('Valid until: $expiryTime',
            style: TextStyle(fontSize: 12, color: Colors.orange.shade700)),
      ],
    );
  }

  Widget _infoBox({required IconData icon, required Color color, required String text}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
          ),
        ],
      ),
    );
  }
}
