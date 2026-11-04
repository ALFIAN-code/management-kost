import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/services/network/dio_client.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';

class BatchRoomGeneratorDialog extends StatefulWidget {
  const BatchRoomGeneratorDialog({
    super.key,
    required this.onSuccess,
    this.buildingId,
  });

  final VoidCallback onSuccess;
  final int? buildingId;

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onSuccess,
    int? buildingId,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BatchRoomGeneratorDialog(
        onSuccess: onSuccess,
        buildingId: buildingId,
      ),
    );
  }

  @override
  State<BatchRoomGeneratorDialog> createState() =>
      _BatchRoomGeneratorDialogState();
}

class _BatchRoomGeneratorDialogState extends State<BatchRoomGeneratorDialog> {
  final _prefixController = TextEditingController(text: 'A-');
  final _startNumberController = TextEditingController(text: '101');
  final _endNumberController = TextEditingController(text: '110');
  final _priceController = TextEditingController(text: '1200000');
  final _priceDailyController = TextEditingController();
  final _titleTemplateController = TextEditingController(
    text: 'Kamar {number}',
  );
  final _descriptionController = TextEditingController();

  final List<String> _availableFacilities = [
    'AC',
    'WiFi',
    'Kamar Mandi Dalam',
    'Kasur Springbed',
    'Meja Kerja',
    'Lemari Pakaian',
    'Water Heater',
    'Balkon',
  ];

  final Set<String> _selectedFacilities = {
    'AC',
    'WiFi',
    'Kamar Mandi Dalam',
    'Kasur Springbed',
  };

  bool _isLoading = false;
  bool _skipExisting = true;

  @override
  void initState() {
    super.initState();
    _startNumberController.addListener(_onPatternChanged);
    _endNumberController.addListener(_onPatternChanged);
    _prefixController.addListener(_onPatternChanged);
  }

  @override
  void dispose() {
    _startNumberController.removeListener(_onPatternChanged);
    _endNumberController.removeListener(_onPatternChanged);
    _prefixController.removeListener(_onPatternChanged);
    _prefixController.dispose();
    _startNumberController.dispose();
    _endNumberController.dispose();
    _priceController.dispose();
    _priceDailyController.dispose();
    _titleTemplateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onPatternChanged() {
    setState(() {});
  }

  List<String> _calculatePreviewNumbers() {
    final prefix = _prefixController.text.trim();
    final start = int.tryParse(_startNumberController.text.trim()) ?? 1;
    final end = int.tryParse(_endNumberController.text.trim()) ?? 1;

    if (end < start || (end - start) > 50) {
      return [];
    }

    final list = <String>[];
    for (int i = start; i <= end; i++) {
      list.add('$prefix$i');
    }
    return list;
  }

  Future<void> _submitBatchGenerate() async {
    final start = int.tryParse(_startNumberController.text.trim());
    final end = int.tryParse(_endNumberController.text.trim());
    final price = double.tryParse(_priceController.text.trim());
    final priceDaily = double.tryParse(_priceDailyController.text.trim());

    if (start == null || end == null || price == null) {
      AppSnackbar.showError(
        'Mohon isi nomor awal, nomor akhir, dan harga bulanan dengan angka valid.',
      );
      return;
    }

    if (end < start) {
      AppSnackbar.showError(
        'Nomor akhir harus lebih besar atau sama dengan nomor awal.',
      );
      return;
    }

    if ((end - start) > 100) {
      AppSnackbar.showError(
        'Maksimal pembuatan 100 kamar sekaligus dalam satu batch.',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dioClient = serviceLocator.get<DioClient>();
      final payload = {
        'prefix': _prefixController.text.trim(),
        'start_number': start,
        'end_number': end,
        'price': price,
        'price_daily': priceDaily,
        'title_template': _titleTemplateController.text.trim(),
        'facilities': _selectedFacilities.toList(),
        'description': _descriptionController.text.trim(),
        'building_id': widget.buildingId,
        'skip_existing': _skipExisting,
      };

      final response = await dioClient.post(
        '/rooms/batch-generate',
        data: payload,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final createdCount = data['created_count'] ?? 0;
        final skippedCount = data['skipped_count'] ?? 0;

        AppSnackbar.showSuccess(
          'Berhasil membuat $createdCount kamar baru! ($skippedCount dilewati karena sudah ada)',
        );
        widget.onSuccess();
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      AppSnackbar.showError('Gagal men-generate kamar: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF111827) : Colors.white;
    final surfaceBg = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8FAFC);
    final borderColor = isDark
        ? const Color(0xFF1F2937)
        : const Color(0xFFE2E8F0);
    final primaryColor = const Color(0xFF0D9488);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedColor = isDark
        ? const Color(0xFF9CA3AF)
        : const Color(0xFF64748B);

    final previewRooms = _calculatePreviewNumbers();
    final totalUnits = previewRooms.length;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 760),
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.5 : 0.08),
                blurRadius: 36,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            children: [
              // Dialog Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 20,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: primaryColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Generator Kamar Massal (Batch)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                        Text(
                          'Buat puluhan unit kamar kost sekaligus dalam hitungan detik',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: mutedColor,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.close, color: mutedColor),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: borderColor),

              // Scrollable Form Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Pola Penomoran
                      _buildSectionTag('1. POLA PENOMORAN UNIT', primaryColor),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildFormField(
                              label: 'Prefix / Awalan',
                              hint: 'A-, LT1-, KM-',
                              controller: _prefixController,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 3,
                            child: _buildFormField(
                              label: 'Nomor Awal',
                              hint: '101',
                              controller: _startNumberController,
                              isDark: isDark,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 3,
                            child: _buildFormField(
                              label: 'Nomor Akhir',
                              hint: '115',
                              controller: _endNumberController,
                              isDark: isDark,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Section 2: Spesifikasi & Harga
                      _buildSectionTag(
                        '2. SPESIFIKASI & TARIF SEWA',
                        primaryColor,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFormField(
                              label: 'Harga Sewa Bulanan (Rp)',
                              hint: '1200000',
                              controller: _priceController,
                              isDark: isDark,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildFormField(
                              label: 'Harga Harian (Opsional)',
                              hint: '150000',
                              controller: _priceDailyController,
                              isDark: isDark,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildFormField(
                        label: 'Template Judul Kamar',
                        hint: 'Kamar {number}',
                        controller: _titleTemplateController,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 24),

                      // Section 3: Fasilitas Kamar
                      _buildSectionTag('3. TEMPLATE FASILITAS', primaryColor),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableFacilities.map((facility) {
                          final isSelected = _selectedFacilities.contains(
                            facility,
                          );
                          return FilterChip(
                            label: Text(facility),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedFacilities.add(facility);
                                } else {
                                  _selectedFacilities.remove(facility);
                                }
                              });
                            },
                            selectedColor: primaryColor.withOpacity(0.18),
                            checkmarkColor: primaryColor,
                            labelStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected ? primaryColor : textColor,
                            ),
                            backgroundColor: surfaceBg,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: isSelected ? primaryColor : borderColor,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 28),

                      // Section 4: Live Dynamic Preview Matrix
                      _buildSectionTag(
                        '4. PRATINJAU REAL-TIME UNIT',
                        primaryColor,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: surfaceBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Total yang akan dibuat: ',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: mutedColor,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '$totalUnits Kamar',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (previewRooms.isEmpty)
                              Text(
                                'Pola penomoran belum valid atau melebihi batas 50 preview.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: Colors.amber.shade700,
                                ),
                              )
                            else
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: previewRooms.map((roomNum) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: cardBg,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: borderColor),
                                    ),
                                    child: Text(
                                      roomNum,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: primaryColor,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Dialog Footer Action
              Divider(height: 1, color: borderColor),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: Text(
                        'Batalkan',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          color: mutedColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    ElevatedButton.icon(
                      onPressed: _isLoading || totalUnits == 0
                          ? null
                          : _submitBatchGenerate,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.flash_on_rounded, size: 18),
                      label: Text(
                        _isLoading
                            ? 'Membuat Kamar...'
                            : 'Generate $totalUnits Kamar Sekarang',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTag(String title, Color primaryColor) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
        color: primaryColor,
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final borderColor = isDark
        ? const Color(0xFF374151)
        : const Color(0xFFD1D5DB);
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB);
    final textColor = isDark ? Colors.white : const Color(0xFF111827);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: isDark
                    ? const Color(0xFF6B7280)
                    : const Color(0xFF9CA3AF),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
