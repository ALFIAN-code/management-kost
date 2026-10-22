import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/domain/entity/schedule_entity.dart';
import 'package:frontend/presentation/bloc/schedule/schedule_action_bloc.dart';
import 'package:frontend/presentation/bloc/schedule/schedule_action_event.dart';
import 'package:frontend/presentation/bloc/schedule/schedule_action_state.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';
import 'package:frontend/presentation/widget/core/card/basic_card.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';
import 'package:frontend/presentation/widget/core/textform/textform.dart';
import 'package:intl/intl.dart';

@RoutePage()
class MaintananceFormPage extends StatelessWidget {
  const MaintananceFormPage({super.key, this.scheduleData});

  /// If not null, the form is in edit mode.
  final ScheduleEntity? scheduleData;

  bool get isEditMode => scheduleData != null;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: serviceLocator<ScheduleActionBloc>(),
      child: _MaintananceFormView(
        scheduleData: scheduleData,
        isEditMode: isEditMode,
      ),
    );
  }
}

class _MaintananceFormView extends StatefulWidget {
  const _MaintananceFormView({
    required this.scheduleData,
    required this.isEditMode,
  });

  final ScheduleEntity? scheduleData;
  final bool isEditMode;

  @override
  State<_MaintananceFormView> createState() => _MaintananceFormViewState();
}

class _MaintananceFormViewState extends State<_MaintananceFormView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _teknisiController;
  late final TextEditingController _lokasiController;
  late final TextEditingController _notesController;

  String? _selectedTipe;
  String? _selectedSubtipe;
  String? _selectedStatus;
  DateTime? _waktuMulai;
  DateTime? _waktuSelesai;

  // ─── Options ───
  static const _tipeOptions = ['pembersihan', 'perawatan'];
  static const _tipeLabels = {'pembersihan': 'Cleaning', 'perawatan': 'Maintenance'};

  static const _subtipeOptions = [
    'rutin', 'deep_cleaning', 'darurat', 'perbaikan', 'maintenance',
  ];
  static const _subtipeLabels = {
    'rutin': 'Routine',
    'deep_cleaning': 'Deep Cleaning',
    'darurat': 'Emergency',
    'perbaikan': 'Repair',
    'maintenance': 'Maintenance',
  };

  static const _statusOptions = ['in_progress', 'done', 'cancelled'];
  static const _statusLabels = {
    'in_progress': 'In Progress',
    'done': 'Done',
    'cancelled': 'Cancelled',
  };

  @override
  void initState() {
    super.initState();
    final data = widget.scheduleData;
    _teknisiController = TextEditingController(text: data?.technicianName ?? '');
    _lokasiController  = TextEditingController(text: data?.location ?? '');
    _notesController   = TextEditingController(text: data?.notes ?? '');
    _selectedTipe    = data?.type    ?? 'pembersihan';
    _selectedSubtipe = data?.subtype ?? 'rutin';
    _selectedStatus  = data?.status  ?? 'in_progress';
    _waktuMulai   = data?.startTime;
    _waktuSelesai = data?.endTime;
  }

  @override
  void dispose() {
    _teknisiController.dispose();
    _lokasiController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final now = DateTime.now();
    final initialDate = isStart
        ? (_waktuMulai ?? now)
        : (_waktuSelesai ?? _waktuMulai ?? now);

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (time == null || !mounted) return;

    final picked = DateTime(
      date.year, date.month, date.day, time.hour, time.minute,
    );

    setState(() {
      if (isStart) {
        _waktuMulai = picked;
      } else {
        _waktuSelesai = picked;
      }
    });
  }

  void _handleSubmit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    if (_waktuMulai == null) {
      AppSnackbar.showError('Start time is required');
      return;
    }

    final entity = ScheduleEntity(
      id: widget.scheduleData?.id,
      technicianName: _teknisiController.text.trim(),
      location: _lokasiController.text.trim(),
      type: _selectedTipe!,
      subtype: _selectedSubtipe!,
      status: _selectedStatus!,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      startTime: _waktuMulai!,
      endTime: _waktuSelesai,
    );

    if (widget.isEditMode) {
      context.read<ScheduleActionBloc>().add(
        UpdateSchedule(widget.scheduleData!.id!, entity),
      );
    } else {
      context.read<ScheduleActionBloc>().add(CreateSchedule(entity));
    }
  }

  static String _fmtDt(DateTime? dt) {
    if (dt == null) return 'Select date & time';
    return DateFormat('d MMM yyyy, HH:mm', 'en_US').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<ScheduleActionBloc, ScheduleActionState>(
      listener: (context, state) {
        if (state is ScheduleActionSuccess) {
          AppSnackbar.showSuccess(state.message);
          context.router.maybePop(true);
        } else if (state is ScheduleActionFailure) {
          AppSnackbar.showError(state.message);
        }
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Top bar ───
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.router.maybePop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      widget.isEditMode ? 'Edit Schedule' : 'Add Schedule',
                      style: theme.textTheme.headlineLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ─── Form card ───
                BasicCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section title
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Schedule Information',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Row 1: Technician Name & Location
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: CustomTextForm(
                                title: 'Technician Name',
                                hintText: 'Enter the technician name',
                                isRequired: true,
                                controller: _teknisiController,
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Technician name is required'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: CustomTextForm(
                                title: 'Location',
                                hintText: 'Example: Corridor 2nd Floor, Kitchen',
                                isRequired: true,
                                controller: _lokasiController,
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Location is required'
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Row 2: Type, Subtype, Status
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _DropdownField(
                                title: 'Type',
                                isRequired: true,
                                hint: 'Select a type',
                                value: _selectedTipe,
                                items: _tipeOptions,
                                labelOf: (v) => _tipeLabels[v] ?? v,
                                onChanged: (v) =>
                                    setState(() => _selectedTipe = v),
                                validator: (v) =>
                                    v == null ? 'Type is required' : null,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _DropdownField(
                                title: 'Subtype',
                                isRequired: true,
                                hint: 'Select a subtype',
                                value: _selectedSubtipe,
                                items: _subtipeOptions,
                                labelOf: (v) => _subtipeLabels[v] ?? v,
                                onChanged: (v) =>
                                    setState(() => _selectedSubtipe = v),
                                validator: (v) =>
                                    v == null ? 'Subtype is required' : null,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _DropdownField(
                                title: 'Status',
                                isRequired: true,
                                hint: 'Select a status',
                                value: _selectedStatus,
                                items: _statusOptions,
                                labelOf: (v) => _statusLabels[v] ?? v,
                                onChanged: (v) =>
                                    setState(() => _selectedStatus = v),
                                validator: (v) =>
                                    v == null ? 'Status is required' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Row 3: Start Time & End Time
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _DateTimePickerField(
                                title: 'Start Time',
                                isRequired: true,
                                value: _waktuMulai,
                                displayText: _fmtDt(_waktuMulai),
                                onTap: () => _pickDateTime(isStart: true),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _DateTimePickerField(
                                title: 'End Time',
                                value: _waktuSelesai,
                                displayText: _fmtDt(_waktuSelesai),
                                onTap: () => _pickDateTime(isStart: false),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Notes
                        CustomTextForm(
                          title: 'Notes',
                          hintText: 'Additional notes (optional)',
                          controller: _notesController,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 32),

                        // Action buttons
                        BlocBuilder<ScheduleActionBloc, ScheduleActionState>(
                          builder: (context, state) {
                            final isLoading =
                                state is ScheduleActionSubmitting;
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: 140,
                                  height: 44,
                                  child: BasicButton(
                                    type: ButtonType.secondary,
                                    label: 'Cancel',
                                    onPressed: isLoading
                                        ? null
                                        : () => context.router.maybePop(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 140,
                                  height: 44,
                                  child: BasicButton(
                                    label: widget.isEditMode
                                        ? 'Save'
                                        : 'Add',
                                    isLoading: isLoading,
                                    onPressed: isLoading
                                        ? null
                                        : () => _handleSubmit(context),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── DateTime picker field ───

class _DateTimePickerField extends StatelessWidget {
  const _DateTimePickerField({
    required this.title,
    required this.onTap,
    required this.displayText,
    this.value,
    this.isRequired = false,
  });

  final String title;
  final DateTime? value;
  final String displayText;
  final bool isRequired;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: title,
            style: theme.textTheme.titleMedium,
            children: isRequired
                ? [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: Colors.red.shade300,
                        fontSize: 12,
                      ),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: value != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Reusable dropdown field ───

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.title,
    required this.hint,
    required this.items,
    required this.labelOf,
    required this.onChanged,
    this.value,
    this.isRequired = false,
    this.validator,
  });

  final String title;
  final String hint;
  final List<String> items;
  final String Function(String) labelOf;
  final String? value;
  final bool isRequired;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: title,
            style: theme.textTheme.titleMedium,
            children: isRequired
                ? [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: Colors.red.shade300,
                        fontSize: 12,
                      ),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text(
            hint,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.error),
            ),
          ),
          items: items
              .map((v) => DropdownMenuItem(value: v, child: Text(labelOf(v))))
              .toList(),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }
}
