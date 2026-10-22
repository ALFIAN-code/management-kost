class MidtransMethodEntity {
  final String code;
  final String label;
  final bool enabled;     // admin: active in settings
  final bool available;   // user: not under maintenance
  final bool maintenance; // user: under maintenance

  const MidtransMethodEntity({
    required this.code,
    required this.label,
    this.enabled = false,
    this.available = true,
    this.maintenance = false,
  });

  MidtransMethodEntity copyWith({bool? enabled}) => MidtransMethodEntity(
        code: code,
        label: label,
        enabled: enabled ?? this.enabled,
        available: available,
        maintenance: maintenance,
      );
}
