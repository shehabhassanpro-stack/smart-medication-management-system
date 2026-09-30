enum ReadingStatus {
  normal(
    id: 'normal',
    nameAr: 'طبيعي',
    nameEn: 'Normal',
    severity: 0,
    requiresAttention: false,
    isCritical: false,
  ),
  borderline(
    id: 'borderline',
    nameAr: 'حدّي',
    nameEn: 'Borderline',
    severity: 1,
    requiresAttention: true,
    isCritical: false,
  ),
  high(
    id: 'high',
    nameAr: 'مرتفع',
    nameEn: 'High',
    severity: 2,
    requiresAttention: true,
    isCritical: false,
  ),
  low(
    id: 'low',
    nameAr: 'منخفض',
    nameEn: 'Low',
    severity: 2,
    requiresAttention: true,
    isCritical: false,
  ),
  critical(
    id: 'critical',
    nameAr: 'حرج',
    nameEn: 'Critical',
    severity: 3,
    requiresAttention: true,
    isCritical: true,
  );

  final String id;
  final String nameAr;
  final String nameEn;
  final int severity;
  final bool requiresAttention;
  final bool isCritical;

  const ReadingStatus({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.severity,
    required this.requiresAttention,
    required this.isCritical,
  });

  bool get isNormal => this == ReadingStatus.normal;

  bool get isAbnormal => this != ReadingStatus.normal;

  bool get isHighOrLow => this == ReadingStatus.high || this == ReadingStatus.low;

  bool operator >(ReadingStatus other) => severity > other.severity;

  bool operator <(ReadingStatus other) => severity < other.severity;

  bool operator >=(ReadingStatus other) => severity >= other.severity;

  bool operator <=(ReadingStatus other) => severity <= other.severity;

  static ReadingStatus fromId(String id) {
    return ReadingStatus.values.firstWhere(
      (status) => status.id == id || status.id.toLowerCase() == id.toLowerCase(),
      orElse: () => ReadingStatus.normal,
    );
  }

  static ReadingStatus? tryFromId(String? id) {
    if (id == null || id.isEmpty) return null;
    try {
      return ReadingStatus.values.firstWhere(
        (status) => status.id == id || status.id.toLowerCase() == id.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  static ReadingStatus mostSevere(List<ReadingStatus> statuses) {
    if (statuses.isEmpty) return ReadingStatus.normal;
    return statuses.reduce((a, b) => a.severity > b.severity ? a : b);
  }

  static List<ReadingStatus> get attentionRequired =>
      ReadingStatus.values.where((s) => s.requiresAttention).toList();

  static List<ReadingStatus> get criticalStatuses =>
      ReadingStatus.values.where((s) => s.isCritical).toList();
}
