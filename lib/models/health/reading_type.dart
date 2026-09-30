enum ReadingType {
  bloodPressure(
    id: 'bloodPressure',
    nameAr: 'ضغط الدم',
    nameEn: 'Blood Pressure',
    unit: 'mmHg',
    emoji: '❤️',
    descriptionAr: 'قياس ضغط الدم الانقباضي والانبساطي',
    descriptionEn: 'Systolic and diastolic blood pressure measurement',
    minValue: 40,
    maxValue: 300,
    decimalPlaces: 0,
  ),
  bloodSugar(
    id: 'bloodSugar',
    nameAr: 'سكر الدم',
    nameEn: 'Blood Sugar',
    unit: 'mg/dL',
    emoji: '🩸',
    descriptionAr: 'قياس مستوى الجلوكوز في الدم',
    descriptionEn: 'Blood glucose level measurement',
    minValue: 20,
    maxValue: 800,
    decimalPlaces: 0,
  ),
  weight(
    id: 'weight',
    nameAr: 'الوزن',
    nameEn: 'Weight',
    unit: 'kg',
    emoji: '⚖️',
    descriptionAr: 'قياس وزن الجسم',
    descriptionEn: 'Body weight measurement',
    minValue: 1,
    maxValue: 500,
    decimalPlaces: 1,
  ),
  temperature(
    id: 'temperature',
    nameAr: 'الحرارة',
    nameEn: 'Temperature',
    unit: '°C',
    emoji: '🌡️',
    descriptionAr: 'قياس درجة حرارة الجسم',
    descriptionEn: 'Body temperature measurement',
    minValue: 30,
    maxValue: 45,
    decimalPlaces: 1,
  );

  final String id;
  final String nameAr;
  final String nameEn;
  final String unit;
  final String emoji;
  final String descriptionAr;
  final String descriptionEn;
  final double minValue;
  final double maxValue;
  final int decimalPlaces;

  const ReadingType({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.unit,
    required this.emoji,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.minValue,
    required this.maxValue,
    required this.decimalPlaces,
  });

  String get displayValueFormat => decimalPlaces == 0 ? '0' : '0.${'0' * decimalPlaces}';

  bool get requiresDualInput => this == ReadingType.bloodPressure;

  bool isValidValue(double value) => value >= minValue && value <= maxValue;

  String get rangeText => '${minValue.toInt()} - ${maxValue.toInt()} $unit';

  static ReadingType fromId(String id) {
    return ReadingType.values.firstWhere(
          (type) => type.id == id || type.id.toLowerCase() == id.toLowerCase(),
      orElse: () => ReadingType.bloodPressure,
    );
  }

  static ReadingType? tryFromId(String? id) {
    if (id == null || id.isEmpty) return null;
    try {
      return ReadingType.values.firstWhere(
            (type) => type.id == id || type.id.toLowerCase() == id.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  static List<String> get allIds => ReadingType.values.map((e) => e.id).toList();
}