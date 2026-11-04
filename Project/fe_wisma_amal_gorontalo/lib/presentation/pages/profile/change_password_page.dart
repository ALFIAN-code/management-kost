import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/presentation/bloc/profile/profile_bloc.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';

@RoutePage()
class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: serviceLocator<ProfileBloc>(),
      child: const ChangePasswordView(),
    );
  }
}

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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
    final titleTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedTextColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    final hasMinLength = newPass.length >= 8;
    final hasMatch = confirmPass.isNotEmpty && confirmPass == newPass;

    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileActionSuccess) {
          AppSnackbar.showSuccess(state.message);
          context.router.maybePop();
        } else if (state is ProfileError) {
          AppSnackbar.showError(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: titleTextColor),
            onPressed: () => context.router.maybePop(),
          ),
          title: Text(
            'Ubah Kata Sandi',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: titleTextColor,
            ),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 580),
              child: Container(
                padding: const EdgeInsets.all(36),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.35 : 0.05,
                      ),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge Kategori
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
                          'KEAMANAN AKUN',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      Text(
                        'Perbarui Kata Sandi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: titleTextColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pastikan kata sandi baru Anda unik, kuat, dan terdiri dari minimal 8 karakter.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: mutedTextColor,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Input 1: Old Password
                      _buildPasswordField(
                        label: 'Kata Sandi Saat Ini',
                        hint: 'Masukkan kata sandi lama',
                        controller: _oldPasswordController,
                        obscureText: _obscureOld,
                        onToggleVisibility: () =>
                            setState(() => _obscureOld = !_obscureOld),
                        isDark: isDark,
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Kata sandi saat ini wajib diisi';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Input 2: New Password
                      _buildPasswordField(
                        label: 'Kata Sandi Baru',
                        hint: 'Minimal 8 karakter',
                        controller: _newPasswordController,
                        obscureText: _obscureNew,
                        onToggleVisibility: () =>
                            setState(() => _obscureNew = !_obscureNew),
                        isDark: isDark,
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Kata sandi baru wajib diisi';
                          if (v.length < 8)
                            return 'Kata sandi minimal 8 karakter';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Input 3: Confirm New Password
                      _buildPasswordField(
                        label: 'Konfirmasi Kata Sandi Baru',
                        hint: 'Ulangi kata sandi baru',
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirm,
                        onToggleVisibility: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                        isDark: isDark,
                        validator: (v) {
                          if (v != _newPasswordController.text)
                            return 'Konfirmasi kata sandi tidak cocok';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Password Strength Indicator Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Persyaratan Keamanan:',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: mutedTextColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildRequirementItem(
                              'Minimal 8 karakter',
                              hasMinLength,
                              primaryColor,
                              mutedTextColor,
                            ),
                            const SizedBox(height: 6),
                            _buildRequirementItem(
                              'Konfirmasi kata sandi cocok',
                              hasMatch,
                              primaryColor,
                              mutedTextColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Submit Button
                      BlocBuilder<ProfileBloc, ProfileState>(
                        builder: (context, state) {
                          final isLoading = state is ProfileLoading;
                          return SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        context.read<ProfileBloc>().add(
                                          ChangePassword(
                                            oldPassword:
                                                _oldPasswordController.text,
                                            newPassword:
                                                _newPasswordController.text,
                                            confirmPassword:
                                                _confirmPasswordController.text,
                                          ),
                                        );
                                      }
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
                                      'Perbarui Kata Sandi',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                            ),
                          );
                        },
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

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required bool isDark,
    required String? Function(String?) validator,
  }) {
    final borderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFCBD5E1);
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
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
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
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
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                color: hintColor,
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: hintColor,
                  size: 20,
                ),
                onPressed: onToggleVisibility,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementItem(
    String text,
    bool isMet,
    Color primaryColor,
    Color mutedColor,
  ) {
    return Row(
      children: [
        Icon(
          isMet
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          size: 16,
          color: isMet ? primaryColor : mutedColor,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: isMet ? FontWeight.w700 : FontWeight.w500,
            color: isMet ? primaryColor : mutedColor,
          ),
        ),
      ],
    );
  }
}
