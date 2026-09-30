enum MeasurementTime {
  fasting(
    id: 'fasting',
    nameAr: 'صائم',
    nameEn: 'Fasting',
    descriptionAr: 'قبل تناول أي طعام أو شراب',
    descriptionEn: 'Before eating or drinking anything',
    sortOrder: 1,
    isRelevantForSugar: true,
  ),
  beforeMeal(
    id: 'beforeMeal',
    nameAr: 'قبل الأكل',
    nameEn: 'Before Meal',
    descriptionAr: 'قبل تناول الوجبة مباشرة',
    descriptionEn: 'Right before eating a meal',
    sortOrder: 2,
    isRelevantForSugar: true,
  ),
  afterMeal(
    id: 'afterMeal',
    nameAr: 'بعد الأكل',
    nameEn: 'After Meal',
    descriptionAr: 'بعد ساعتين من تناول الوجبة',
    descriptionEn: 'Two hours after eating a meal',
    sortOrder: 3,
    isRelevantForSugar: true,
  ),
  beforeSleep(
    id: 'beforeSleep',
    nameAr: 'قبل النوم',
    nameEn: 'Before Sleep',
    descriptionAr: 'قبل النوم مباشرة',
    descriptionEn: 'Right before going to sleep',
    sortOrder: 4,
    isRelevantForSugar: true,
  ),
  wakeUp(
    id: 'wakeUp',
    nameAr: 'عند الاستيقاظ',
    nameEn: 'Wake Up',
    descriptionAr: 'فور الاستيقاظ من النوم',
    descriptionEn: 'Immediately after waking up',
    sortOrder: 5,
    isRelevantForSugar: true,
  ),
  random(
    id: 'random',
    nameAr: 'عشوائي',
    nameEn: 'Random',
    descriptionAr: 'في أي وقت خلال اليوم',
    descriptionEn: 'Any time during the day',
    sortOrder: 6,
    isRelevantForSugar: false,
  );

  final String id;
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;
  final int sortOrder;
  final bool isRelevantForSugar;

  const MeasurementTime({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.sortOrder,
    required this.isRelevantForSugar,
  });

  bool get isFasting => this == MeasurementTime.fasting;

  bool get isPostMeal => this == MeasurementTime.afterMeal;

  bool get isPreMeal => this == MeasurementTime.beforeMeal || this == MeasurementTime.fasting;

  static MeasurementTime fromId(String id) {
    return MeasurementTime.values.firstWhere(
      (time) => time.id == id || time.id.toLowerCase() == id.toLowerCase(),
      orElse: () => MeasurementTime.random,
    );
  }

  static MeasurementTime? tryFromId(String? id) {
    if (id == null || id.isEmpty) return null;
    try {
      return MeasurementTime.values.firstWhere(
        (time) => time.id == id || time.id.toLowerCase() == id.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  static List<MeasurementTime> get sortedByOrder =>
      List.from(MeasurementTime.values)..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  static List<MeasurementTime> get sugarRelevant =>
      MeasurementTime.values.where((t) => t.isRelevantForSugar).toList();
}
