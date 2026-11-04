import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/services/network/dio_client.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';

class PropertySelectorWidget extends StatefulWidget {
  const PropertySelectorWidget({super.key, this.onPropertySwitched});

  final VoidCallback? onPropertySwitched;

  @override
  State<PropertySelectorWidget> createState() => _PropertySelectorWidgetState();
}

class _PropertySelectorWidgetState extends State<PropertySelectorWidget> {
  List<Map<String, dynamic>> _buildings = [];
  Map<String, dynamic>? _activeBuilding;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchBuildings();
  }

  Future<void> _fetchBuildings() async {
    setState(() => _isLoading = true);
    try {
      final dio = serviceLocator.get<DioClient>();
      final res = await dio.get('/buildings');
      if (res.statusCode == 200) {
        final list = List<Map<String, dynamic>>.from(res.data['data'] ?? []);
        setState(() {
          _buildings = list;
          if (list.isNotEmpty && _activeBuilding == null) {
            _activeBuilding = list.first;
          }
        });
      }
    } catch (_) {
      // Fail open gracefully
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _switchBuilding(Map<String, dynamic> building) async {
    try {
      final dio = serviceLocator.get<DioClient>();
      final res = await dio.post('/buildings/${building['id']}/switch');
      if (res.statusCode == 200) {
        setState(() => _activeBuilding = building);
        AppSnackbar.showSuccess('Beralih ke properti: ${building['name']}');
        widget.onPropertySwitched?.call();
      }
    } catch (e) {
      AppSnackbar.showError('Gagal beralih properti: $e');
    }
  }

  void _showBranchDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.domain_rounded, color: Color(0xFF0D9488)),
              const SizedBox(width: 10),
              Text(
                'Pilih Cabang / Properti Kost',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: _buildings.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Belum ada data cabang properti lain.'),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: _buildings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final item = _buildings[index];
                      final isSelected = _activeBuilding?['id'] == item['id'];
                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF0D9488)
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        tileColor: isSelected
                            ? const Color(0xFF0D9488).withOpacity(0.08)
                            : (isDark
                                  ? const Color(0xFF1F2937)
                                  : const Color(0xFFF3F4F6)),
                        leading: CircleAvatar(
                          backgroundColor: const Color(
                            0xFF0D9488,
                          ).withOpacity(0.2),
                          child: const Icon(
                            Icons.apartment_rounded,
                            color: Color(0xFF0D9488),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          item['name'] ?? 'Properti',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          item['address'] ?? '-',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF0D9488),
                              )
                            : null,
                        onTap: () {
                          Navigator.of(ctx).pop();
                          _switchBuilding(item);
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0D9488);
    final propertyName = _activeBuilding?['name'] ?? 'Wisma Amal Utama';

    return InkWell(
      onTap: _showBranchDialog,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _isLoading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.8,
                      color: Color(0xFF0D9488),
                    ),
                  )
                : Icon(Icons.apartment_rounded, size: 16, color: primaryColor),
            const SizedBox(width: 8),
            Text(
              propertyName,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: isDark ? Colors.white70 : const Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }
}
