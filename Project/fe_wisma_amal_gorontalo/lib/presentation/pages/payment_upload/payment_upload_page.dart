import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/dependency_injection/dependency_injection.dart';
import '../../../core/navigation/auto_route.gr.dart';
import '../../../domain/entity/reservation_entity.dart';
import '../../../domain/entity/setting/bank_account_entity.dart';
import '../../../domain/usecase/reservation/cancel_reservation_usecase.dart';
import '../../../domain/usecase/setting/get_public_bank_accounts_usecase.dart';
import '../../../domain/usecase/setting/get_public_settings_usecase.dart';
import '../../bloc/member_finance/member_finance_bloc.dart';
import '../../bloc/member_finance/member_finance_event.dart';
import '../../bloc/member_finance/member_finance_state.dart';
import '../../widget/core/appbar/custom_appbar.dart';
import '../../widget/core/botton/button.dart';
import '../../widget/core/card/basic_card.dart';

@RoutePage()
class PaymentUploadPage extends StatefulWidget {
  final ReservationEntity reservation;
  const PaymentUploadPage({super.key, required this.reservation});

  @override
  State<PaymentUploadPage> createState() => _PaymentUploadPageState();
}

class _PaymentUploadPageState extends State<PaymentUploadPage> {
  PlatformFile? _selectedFile;
  bool _isSubmitting = false;
  bool _isExpired = false;
  bool _isCancelling = false;
  int _remainingSeconds = 900; // 15 minutes default
  Timer? _countdownTimer;
  List<BankAccountEntity> _bankAccounts = [];
  String _wismaAddress = 'Jl. Wisma Amal No. 1, Gorontalo';
  String _wismaHours = 'Monday – Saturday, 08.00 – 17.00 WITA';
  String _wismaPhone = '0811-4300-XXX';

  final currencyFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _initTimer();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final accounts = await serviceLocator.get<GetPublicBankAccountsUseCase>().execute();
      if (mounted) setState(() => _bankAccounts = accounts);
    } catch (_) {}
    try {
      final settings = await serviceLocator.get<GetPublicSettingsUseCase>().execute();
      if (mounted) {
        setState(() {
          _wismaAddress = settings.getString('wisma_address') ?? _wismaAddress;
          _wismaHours = settings.getString('wisma_operational_hours') ?? _wismaHours;
          _wismaPhone = settings.getString('wisma_phone') ?? _wismaPhone;
        });
      }
    } catch (_) {}
  }

  void _initTimer() {
    final expiresAt = widget.reservation.paymentExpiresAt;

    if (expiresAt != null) {
      final expiry = DateTime.tryParse(expiresAt);
      if (expiry != null) {
        final remaining = expiry.difference(DateTime.now()).inSeconds;
        _remainingSeconds = remaining > 0 ? remaining : 0;
      }
    }

    if (_remainingSeconds <= 0) {
      _isExpired = true;
      return;
    }

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _isExpired = true;
          timer.cancel();
          _showExpiredDialog();
        }
      });
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  String get _timerDisplay {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Color get _timerColor {
    if (_remainingSeconds <= 60) return Colors.red;
    if (_remainingSeconds <= 120) return Colors.orange;
    return Colors.green;
  }

  Future<void> _cancelAndGoBack() async {
    setState(() => _isCancelling = true);
    try {
      await serviceLocator.get<CancelReservationUseCase>().execute(widget.reservation.id);
    } catch (_) {
      // No need to handle the error, the backend scheduler cancels automatically
    } finally {
      if (mounted) {
        context.router.replaceAll([const LandingRoute()]);
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (_isSubmitting) return false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking?'),
        content: const Text(
          'If you leave this page without making a payment, the booking will be cancelled and the room will become available to other users.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Continue Payment'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      _countdownTimer?.cancel();
      await _cancelAndGoBack();
      return false;
    }
    return false;
  }

  void _showExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Payment Time Expired'),
        content: const Text(
          'The 15-minute limit for uploading payment proof has expired. The booking was cancelled automatically and the room is available again.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _cancelAndGoBack();
            },
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    _countdownTimer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 8),
            const Text('Proof Submitted'),
          ],
        ),
        content: const Text(
          'Your payment proof was submitted successfully and is awaiting confirmation from the admin. '
          'You will become an official resident once the payment is verified.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.router.replaceAll([const LandingRoute()]);
            },
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator.get<MemberFinanceBloc>(),
      child: BlocListener<MemberFinanceBloc, MemberFinanceState>(
        listenWhen: (prev, curr) =>
            curr.status == MemberFinanceStatus.paymentSuccess ||
            (curr.status == MemberFinanceStatus.failure &&
                prev.status == MemberFinanceStatus.loading),
        listener: (context, state) {
          if (state.status == MemberFinanceStatus.paymentSuccess) {
            setState(() => _isSubmitting = false);
            _showSuccessDialog();
          } else if (state.status == MemberFinanceStatus.failure) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Failed to upload the payment proof'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: WillPopScope(
          onWillPop: _onWillPop,
          child: Scaffold(
            appBar: CustomAppbar(
              title: 'Manual Payment',
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _onWillPop(),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStepIndicator(),
                      const SizedBox(height: 24),
                      _buildTimerBanner(),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: _buildInstructionSection()),
                          const SizedBox(width: 24),
                          Expanded(flex: 2, child: _buildSummarySection()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: _isExpired ? Colors.red.shade50 : _timerColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isExpired ? Colors.red : _timerColor,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isExpired ? Icons.timer_off : Icons.timer,
            color: _isExpired ? Colors.red : _timerColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isExpired
                      ? 'Payment Time Expired'
                      : 'Payment Proof Upload Deadline',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _isExpired ? Colors.red : _timerColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isExpired
                      ? 'The booking will be cancelled automatically.'
                      : 'Upload your payment proof before the time runs out. Otherwise, the room will become available again for other users.',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isExpired ? Colors.red.shade700 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          if (!_isExpired)
            Text(
              _timerDisplay,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _timerColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _stepCircle('1', 'Booking', true, done: true),
        _stepLine(true),
        _stepCircle('2', 'Payment', true),
        _stepLine(false),
        _stepCircle('3', 'Verification', false),
      ],
    );
  }

  Widget _stepCircle(String num, String label, bool isActive, {bool done = false}) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    num,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
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

  Widget _buildInstructionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Transfer Bank
        BasicCard(
          title: 'Payment via Bank Transfer',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _instructionStep(
                1,
                'Make a Transfer to the Following Account',
                'Make sure the transfer amount matches the total invoice.',
              ),
              const SizedBox(height: 16),
              if (_bankAccounts.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: const Text(
                    'Contact the dormitory administrator for transfer account details.',
                    style: TextStyle(fontSize: 13),
                  ),
                )
              else
                ..._bankAccounts.map((account) => Padding(
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
                        Text(
                          account.bankName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        _bankInfoRow('Account Number', account.accountNumber),
                        _bankInfoRow('Account Holder', account.accountHolder),
                        if (account.paymentInstructions != null && account.paymentInstructions!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(account.paymentInstructions!,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                        ],
                        const SizedBox(height: 12),
                        if (widget.reservation.invoiceAmount != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Transfer Amount:',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Text(
                                  currencyFormat.format(widget.reservation.invoiceAmount!),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                )),
              const SizedBox(height: 16),
              _instructionStep(
                2,
                'Save the Transfer Proof',
                'Screenshot or photo the transfer receipt from your mobile banking / ATM app.',
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Cash Payment
        BasicCard(
          title: 'Cash Payment (In Person)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _instructionStep(
                1,
                'Visit the Dormitory Office',
                'Come directly to the Wisma Amal Gorontalo management office.',
              ),
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
                    _bankInfoRow('Address', _wismaAddress),
                    _bankInfoRow('Operating Hours', _wismaHours),
                    _bankInfoRow('Contact', _wismaPhone),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _instructionStep(
                2,
                'Pay & Request a Receipt',
                'Make the cash payment and ask for an official receipt from the administrator.',
              ),
              const SizedBox(height: 12),
              _instructionStep(
                3,
                'Photo of the Receipt',
                'Take a clear photo of the payment receipt as proof.',
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Upload Proof
        BasicCard(
          title: 'Upload Payment Proof',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _instructionStep(
                1,
                'Choose a Proof File',
                'Choose a clear, readable photo of the transfer receipt or cash receipt.',
              ),
              const SizedBox(height: 16),
              _buildUploadArea(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _instructionStep(int num, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              num.toString(),
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
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
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadArea() {
    return Column(
      children: [
        if (_selectedFile != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Selected file: ${_selectedFile!.name}',
                    style: const TextStyle(fontSize: 13, color: Colors.green),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => setState(() => _selectedFile = null),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isExpired
                ? null
                : () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.image,
                      withData: true, // ensure bytes are available on all platforms including web
                    );
                    if (result != null) {
                      setState(() => _selectedFile = result.files.first);
                    }
                  },
            icon: const Icon(Icons.image_outlined),
            label: Text(_selectedFile == null ? 'Choose Proof Image' : 'Change Image'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection() {
    return Column(
      children: [
        BasicCard(
          title: 'Booking Summary',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _summaryRow('Room', widget.reservation.roomTitle),
              _summaryRow('Room No.', widget.reservation.roomNumber),
              _summaryRow(
                'Lease Type',
                widget.reservation.rentalType == 'monthly' ? 'Monthly' : 'Daily',
              ),
              _summaryRow('Start', widget.reservation.startDate),
              _summaryRow('End', widget.reservation.endDate),
              const Divider(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Payment',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.reservation.invoiceAmount != null
                        ? currencyFormat.format(widget.reservation.invoiceAmount!)
                        : 'Rp -',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (widget.reservation.invoiceId != null)
                Text(
                  'Invoice ID: #${widget.reservation.invoiceId}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Submit Button
        Builder(builder: (context) {
          return BasicButton(
            label: _isSubmitting ? 'Sending...' : 'Submit Payment Proof',
            isLoading: _isSubmitting,
            onPressed: (_selectedFile == null || _isExpired || _isSubmitting)
                ? null
                : () {
                    final invoiceId = widget.reservation.invoiceId;
                    if (invoiceId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Invoice ID not found. Contact the admin.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    final bytes = _selectedFile!.bytes;
                    if (bytes == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to read the file. Try selecting the image again.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    setState(() => _isSubmitting = true);
                    context.read<MemberFinanceBloc>().add(
                      PayInvoiceEvent(
                        invoiceId,
                        'manual',
                        paymentProofBytes: bytes,
                        paymentProofName: _selectedFile!.name,
                      ),
                    );
                  },
          );
        }),

        const SizedBox(height: 12),

        // Cancel Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _isCancelling || _isSubmitting
                ? null
                : () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Cancel Booking?'),
                        content: const Text(
                          'The booking will be cancelled and the room will become available to other users.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('No'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text(
                              'Yes, Cancel',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      _countdownTimer?.cancel();
                      await _cancelAndGoBack();
                    }
                  },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isCancelling
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
                  )
                : const Text('Cancel Booking'),
          ),
        ),

        const SizedBox(height: 12),

        Text(
          'This room is locked for you during the payment period.',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          textAlign: TextAlign.center,
        ),
      ],
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
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
