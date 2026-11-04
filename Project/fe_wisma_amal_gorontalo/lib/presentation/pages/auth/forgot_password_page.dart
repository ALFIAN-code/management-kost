import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:frontend/presentation/bloc/auth/auth_event.dart';
import 'package:frontend/presentation/bloc/auth/auth_state.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';

@RoutePage()
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  int _currentStep = 1; // 1: Email, 2: OTP, 3: New Password

  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Timer? _resendTimer;
  int _resendCountdown = 60;
  bool _canResend = false;

  @override
  void dispose() {
    _resendTimer?.cancel();
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendCountdown = 60;
      _canResend = false;
    });
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF0B0F19)
        : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF131B2E) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE2E8F0);
    final primaryColor = const Color(0xFF0D9488); // Emerald / Jade Accent
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedTextColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
            if (_currentStep > 1) {
              setState(() => _currentStep--);
            } else {
              context.router.maybePop();
            }
          },
        ),
        title: Text(
          'Pemulihan Akun',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status.isSuccess) {
            if (state.forgotPasswordSent && _currentStep == 1) {
              setState(() => _currentStep = 2);
              _startResendTimer();
            } else if (state.otpVerified && _currentStep == 2) {
              setState(() => _currentStep = 3);
            } else if (state.passwordResetSuccess && _currentStep == 3) {
              AppSnackbar.showSuccess(
                'Kata sandi berhasil diperbarui! Silakan login kembali.',
              );
              context.router.replaceAll([LoginRoute()]);
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
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.4 : 0.06),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Brand Tag
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'KEAMANAN AKUN',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Langkah $_currentStep dari 3',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: mutedTextColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Step Progress Bar
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: _currentStep >= 2
                                    ? primaryColor
                                    : borderColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: _currentStep >= 3
                                    ? primaryColor
                                    : borderColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Step 1: Input Email
                      if (_currentStep == 1) ...[
                        Text(
                          'Lupa Kata Sandi?',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Masukkan alamat email yang terdaftar. Kami akan mengirimkan 6 digit kode OTP verifikasi melalui sistem email terenkripsi.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: mutedTextColor,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildInputField(
                          label: 'Alamat Email',
                          hint: 'nama@domain.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.mail_outline_rounded,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 32),
                        _buildPrimaryButton(
                          label: isLoading
                              ? 'Mengirim Kode...'
                              : 'Kirim Kode Verifikasi',
                          isLoading: isLoading,
                          onPressed: () {
                            final email = _emailController.text.trim();
                            if (email.isEmpty || !email.contains('@')) {
                              AppSnackbar.showError(
                                'Masukkan alamat email yang valid.',
                              );
                              return;
                            }
                            context.read<AuthBloc>().add(
                              ForgotPasswordEvent(email: email),
                            );
                          },
                          primaryColor: primaryColor,
                        ),
                      ],

                      // Step 2: Input OTP
                      if (_currentStep == 2) ...[
                        Text(
                          'Verifikasi Kode OTP',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
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
                                    'Kami telah mengirimkan 6 digit kode OTP ke ',
                              ),
                              TextSpan(
                                text: _emailController.text.trim(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                              const TextSpan(
                                text: '. Kode berlaku selama 15 menit.',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildInputField(
                          label: '6 Digit Kode OTP',
                          hint: 'Contoh: 123456',
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.lock_clock_outlined,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _canResend
                                  ? 'Belum menerima email?'
                                  : 'Kirim ulang dalam ${_resendCountdown}s',
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
                                          ForgotPasswordEvent(
                                            email: _emailController.text.trim(),
                                          ),
                                        );
                                        _startResendTimer();
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
                        _buildPrimaryButton(
                          label: isLoading
                              ? 'Memverifikasi...'
                              : 'Verifikasi OTP',
                          isLoading: isLoading,
                          onPressed: () {
                            final otp = _otpController.text.trim();
                            if (otp.length != 6) {
                              AppSnackbar.showError(
                                'Kode OTP harus terdiri dari 6 digit angka.',
                              );
                              return;
                            }
                            context.read<AuthBloc>().add(
                              VerifyOtpEvent(
                                email: _emailController.text.trim(),
                                otp: otp,
                              ),
                            );
                          },
                          primaryColor: primaryColor,
                        ),
                      ],

                      // Step 3: New Password
                      if (_currentStep == 3) ...[
                        Text(
                          'Buat Kata Sandi Baru',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gunakan minimal 8 karakter dengan kombinasi huruf dan angka untuk keamanan maksimal.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: mutedTextColor,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildInputField(
                          label: 'Kata Sandi Baru',
                          hint: '••••••••',
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          prefixIcon: Icons.lock_outline_rounded,
                          isDark: isDark,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: mutedTextColor,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildInputField(
                          label: 'Konfirmasi Kata Sandi Baru',
                          hint: '••••••••',
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          prefixIcon: Icons.lock_reset_rounded,
                          isDark: isDark,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: mutedTextColor,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildPrimaryButton(
                          label: isLoading
                              ? 'Menyimpan...'
                              : 'Perbarui Kata Sandi',
                          isLoading: isLoading,
                          onPressed: () {
                            final pass = _passwordController.text;
                            final confirm = _confirmPasswordController.text;

                            if (pass.length < 8) {
                              AppSnackbar.showError(
                                'Kata sandi minimal 8 karakter.',
                              );
                              return;
                            }
                            if (pass != confirm) {
                              AppSnackbar.showError(
                                'Konfirmasi kata sandi tidak cocok.',
                              );
                              return;
                            }

                            context.read<AuthBloc>().add(
                              ResetPasswordEvent(
                                email: _emailController.text.trim(),
                                otp: _otpController.text.trim(),
                                password: pass,
                                passwordConfirm: confirm,
                              ),
                            );
                          },
                          primaryColor: primaryColor,
                        ),
                      ],

                      const SizedBox(height: 24),
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
                              fontSize: 14,
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

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData prefixIcon,
    required bool isDark,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    final borderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFCBD5E1);
    final inputBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final hintColor = isDark
        ? const Color(0xFF64748B)
        : const Color(0xFF94A3B8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: inputBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.plusJakartaSans(
                color: hintColor,
                fontSize: 14,
              ),
              prefixIcon: Icon(prefixIcon, color: hintColor, size: 20),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required bool isLoading,
    required VoidCallback onPressed,
    required Color primaryColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
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
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }
}
