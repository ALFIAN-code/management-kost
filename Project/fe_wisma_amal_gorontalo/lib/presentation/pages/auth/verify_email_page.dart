import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/domain/entity/room_entity.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:frontend/presentation/bloc/auth/auth_event.dart';
import 'package:frontend/presentation/bloc/auth/auth_state.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';

@RoutePage()
class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key, required this.email, this.pendingRoom});

  final String email;
  final RoomEntity? pendingRoom;

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final _otpController = TextEditingController();
  Timer? _countdownTimer;
  int _countdown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    setState(() {
      _countdown = 60;
      _canResend = false;
    });
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0D9488);
    final cardBg = isDark ? const Color(0xFF131B2E) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedTextColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0B0F19)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => context.router.maybePop(),
        ),
        title: Text(
          'Verifikasi Alamat Email',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state.status.isSuccess && state.emailVerified) {
            AppSnackbar.showSuccess('Alamat email berhasil diverifikasi!');
            if (widget.pendingRoom != null) {
              await context.router.replaceAll([
                AppLayoutRoute(
                  children: [
                    ReservationDetailFormRoute(room: widget.pendingRoom!),
                  ],
                ),
              ]);
            } else {
              await context.router.replaceAll([
                const AppLayoutRoute(children: [RoomRoute()]),
              ]);
            }
          }
        },
        builder: (context, state) {
          final isLoading = state.status.isInProgress;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Container(
                  padding: const EdgeInsets.all(36),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.4 : 0.06,
                        ),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'VERIFIKASI AKUN',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      Text(
                        'Cek Kotak Masuk Email Anda',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: mutedTextColor,
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(
                              text:
                                  'Kami telah mengirimkan 6 digit kode verifikasi (OTP) ke alamat email ',
                            ),
                            TextSpan(
                              text: widget.email,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                            const TextSpan(
                              text:
                                  '. Masukkan kode tersebut di bawah untuk mengaktifkan akun Anda.',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Input 6-Digit OTP
                      Text(
                        'Kode Verifikasi OTP',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFCBD5E1),
                          ),
                        ),
                        child: TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.firaCode(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 10,
                            color: primaryColor,
                          ),
                          decoration: InputDecoration(
                            hintText: '123456',
                            hintStyle: GoogleFonts.firaCode(
                              fontSize: 24,
                              letterSpacing: 8,
                              color: isDark
                                  ? const Color(0xFF475569)
                                  : const Color(0xFF94A3B8),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Countdown & Resend Option
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _canResend
                                ? 'Tidak menemukan email?'
                                : 'Kirim ulang dalam $_countdown detik',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: mutedTextColor,
                            ),
                          ),
                          if (_canResend)
                            TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      context.read<AuthBloc>().add(
                                        ResendEmailOtpEvent(
                                          email: widget.email,
                                        ),
                                      );
                                      _startCountdown();
                                    },
                              child: Text(
                                'Kirim Ulang OTP',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Verification Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  final otp = _otpController.text.trim();
                                  if (otp.length != 6) {
                                    AppSnackbar.showError(
                                      'Kode OTP harus terdiri dari 6 digit angka.',
                                    );
                                    return;
                                  }
                                  context.read<AuthBloc>().add(
                                    VerifyEmailOtpEvent(
                                      email: widget.email,
                                      otp: otp,
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Verifikasi & Masuk',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Center(
                        child: TextButton.icon(
                          onPressed: () =>
                              context.router.replaceAll([LoginRoute()]),
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            size: 16,
                            color: mutedTextColor,
                          ),
                          label: Text(
                            'Kembali ke Halaman Masuk',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: mutedTextColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
