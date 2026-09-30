// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class SAr extends S {
  SAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'Medical Care';

  @override
  String get appTagline => 'صحتك أولويتنا';

  @override
  String get common_save => 'حفظ';

  @override
  String get common_cancel => 'إلغاء';

  @override
  String get common_delete => 'حذف';

  @override
  String get common_edit => 'تعديل';

  @override
  String get common_done => 'تم';

  @override
  String get common_close => 'إغلاق';

  @override
  String get common_back => 'رجوع';

  @override
  String get common_next => 'التالي';

  @override
  String get common_confirm => 'تأكيد';

  @override
  String get common_retry => 'إعادة المحاولة';

  @override
  String get common_loading => 'جاري التحميل...';

  @override
  String get common_error => 'حدث خطأ';

  @override
  String get common_success => 'تم بنجاح';

  @override
  String get common_noData => 'لا توجد بيانات';

  @override
  String get common_search => 'بحث';

  @override
  String get common_viewAll => 'عرض الكل';

  @override
  String get common_viewMore => 'عرض المزيد';

  @override
  String get common_showAll => 'عرض الكل';

  @override
  String get common_processing => 'جاري التنفيذ...';

  @override
  String get common_yes => 'نعم';

  @override
  String get common_no => 'لا';

  @override
  String get common_ok => 'موافق';

  @override
  String get common_logout => 'خروج';

  @override
  String get common_logoutConfirm => 'هل أنت متأكد من رغبتك في الخروج؟';

  @override
  String get common_logoutTitle => 'الخروج من التطبيق';

  @override
  String get common_today => 'اليوم';

  @override
  String get common_yesterday => 'أمس';

  @override
  String common_daysAgo(int count) {
    return 'منذ $count أيام';
  }

  @override
  String get common_normal => 'طبيعي';

  @override
  String get common_high => 'مرتفع';

  @override
  String get common_low => 'منخفض';

  @override
  String get common_critical => 'حرج';

  @override
  String get common_warning => 'تحذير';

  @override
  String get nav_home => 'الرئيسية';

  @override
  String get nav_medicines => 'الأدوية';

  @override
  String get nav_readings => 'القراءات';

  @override
  String get nav_profile => 'الملف الشخصي';

  @override
  String get nav_patients => 'المرضى';

  @override
  String get nav_reports => 'التقارير';

  @override
  String get nav_homeSemantics => 'الصفحة الرئيسية';

  @override
  String get nav_medicinesSemantics => 'قائمة الأدوية';

  @override
  String get nav_readingsSemantics => 'القراءات الصحية';

  @override
  String get nav_profileSemantics => 'الملف الشخصي والإعدادات';

  @override
  String get nav_doctorHomeSemantics => 'الصفحة الرئيسية للطبيب';

  @override
  String get nav_patientsSemantics => 'قائمة المرضى';

  @override
  String get nav_reportsSemantics => 'التقارير والإحصائيات';

  @override
  String get greeting_morning => 'صباح الخير';

  @override
  String get greeting_afternoon => 'مساء الخير';

  @override
  String get greeting_evening => 'مساء الخير';

  @override
  String get greeting_night => 'مساء الخير';

  @override
  String get greeting_tip1 => 'ابدأ يومك بنشاط وحيوية! 💪';

  @override
  String get greeting_tip2 => 'صحتك أولوية، اعتنِ بها اليوم';

  @override
  String get greeting_tip3 => 'يوم جديد، فرصة جديدة للصحة';

  @override
  String get greeting_waterTip => 'لا تنسَ شرب الماء! 💧';

  @override
  String get greeting_breakTip => 'خذ استراحة قصيرة للتجدد';

  @override
  String get health_status => 'الحالة الصحية';

  @override
  String get health_dailySummary => 'ملخص يومي محدث';

  @override
  String get health_needsFollowUp => 'تحتاج متابعة';

  @override
  String get health_bloodPressure => 'ضغط الدم';

  @override
  String get health_bloodSugar => 'السكر';

  @override
  String get health_weight => 'الوزن';

  @override
  String get health_temperature => 'درجة الحرارة';

  @override
  String get health_heartRate => 'معدل النبض';

  @override
  String get health_oxygen => 'الأكسجين';

  @override
  String get health_addReading => 'إضافة قراءة';

  @override
  String get health_addReadingSubtitle => 'سجّل قراءة جديدة';

  @override
  String get health_noReadings => 'لا توجد قراءات';

  @override
  String get health_readingAdded => 'تم إضافة القراءة بنجاح';

  @override
  String get health_readingDeleted => 'تم حذف القراءة';

  @override
  String get health_value => 'القيمة';

  @override
  String get health_unit => 'الوحدة';

  @override
  String get health_date => 'التاريخ';

  @override
  String get health_time => 'الوقت';

  @override
  String get health_notes => 'ملاحظات';

  @override
  String get health_systolic => 'الضغط الانقباضي';

  @override
  String get health_diastolic => 'الضغط الانبساطي';

  @override
  String get health_chart => 'الرسم البياني';

  @override
  String get health_table => 'الجدول';

  @override
  String get health_exportFeature => 'ميزة التصدير قريباً';

  @override
  String get health_weeklySummary => 'ملخص الأسبوع';

  @override
  String get quickActions_title => 'الإجراءات السريعة';

  @override
  String get quickActions_addReading => 'إضافة قراءة';

  @override
  String get quickActions_addReadingSubtitle => 'سجّل قراءة جديدة';

  @override
  String get quickActions_medicines => 'الأدوية';

  @override
  String get quickActions_medicinesSubtitle => 'إدارة أدويتك';

  @override
  String quickActions_medicinesCount(int count) {
    return '$count دواء';
  }

  @override
  String get quickActions_statistics => 'الإحصائيات';

  @override
  String get quickActions_statisticsSubtitle => 'تحليل بياناتك';

  @override
  String get quickActions_history => 'السجل';

  @override
  String get quickActions_historySubtitle => 'سجلك الصحي';

  @override
  String quickActions_readingsCount(int count) {
    return '$count قراءة';
  }

  @override
  String get todayMeds_title => 'أدوية اليوم';

  @override
  String get todayMeds_noMeds => 'لا توجد أدوية مجدولة';

  @override
  String get todayMeds_addPrompt => 'أضف أدويتك لتتبع مواعيدها وتلقي تذكيرات';

  @override
  String get todayMeds_taken => 'تم تناوله';

  @override
  String get todayMeds_skip => 'تخطي';

  @override
  String get todayMeds_later => 'لاحقاً';

  @override
  String get todayMeds_statusUpcoming => 'قادم';

  @override
  String get todayMeds_statusDue => 'حان الموعد';

  @override
  String get todayMeds_statusOverdue => 'تناوله الآن';

  @override
  String get todayMeds_statusTaken => 'تم التناول';

  @override
  String get todayMeds_statusSkipped => 'تم التخطي';

  @override
  String get todayMeds_statusSnoozed => 'مؤجل';

  @override
  String get todayMeds_statusMissed => 'فائت';

  @override
  String get weeklyProgress_medicines => 'الأدوية';

  @override
  String get weeklyProgress_readings => 'القراءات';

  @override
  String get weeklyProgress_adherence => 'الالتزام';

  @override
  String get weeklyProgress_sat => 'سبت';

  @override
  String get weeklyProgress_sun => 'أحد';

  @override
  String get weeklyProgress_mon => 'إثن';

  @override
  String get weeklyProgress_tue => 'ثلا';

  @override
  String get weeklyProgress_wed => 'أرب';

  @override
  String get weeklyProgress_thu => 'خمي';

  @override
  String get weeklyProgress_fri => 'جمع';

  @override
  String get medicines_title => 'الأدوية';

  @override
  String get medicines_addMedicine => 'إضافة دواء';

  @override
  String get medicines_medicineName => 'اسم الدواء';

  @override
  String get medicines_dosage => 'الجرعة';

  @override
  String get medicines_frequency => 'التكرار';

  @override
  String get medicines_startDate => 'تاريخ البدء';

  @override
  String get medicines_endDate => 'تاريخ الانتهاء';

  @override
  String get medicines_times => 'مواعيد الجرعات';

  @override
  String get medicines_instructions => 'تعليمات';

  @override
  String get medicines_active => 'نشط';

  @override
  String get medicines_inactive => 'غير نشط';

  @override
  String get medicines_all => 'الكل';

  @override
  String get medicines_critical => 'مهم';

  @override
  String get medicines_noMedicines => 'لا توجد أدوية';

  @override
  String get medicines_addMedicinePrompt =>
      'أضف دواءً جديداً لمتابعة جدولك الدوائي';

  @override
  String get medicines_deleteConfirm => 'هل أنت متأكد من حذف هذا الدواء؟';

  @override
  String get medicines_deleteSuccess => 'تم حذف الدواء بنجاح';

  @override
  String get medicines_addSuccess => 'تم إضافة الدواء بنجاح';

  @override
  String get medicines_editSuccess => 'تم تحديث الدواء بنجاح';

  @override
  String get medicines_searchHint => 'ابحث عن دواء...';

  @override
  String get medicines_stats => 'الإحصائيات';

  @override
  String get medicines_adherenceRate => 'نسبة الالتزام';

  @override
  String get medicines_totalDoses => 'إجمالي الجرعات';

  @override
  String get medicines_takenDoses => 'الجرعات المتناولة';

  @override
  String get medicines_missedDoses => 'الجرعات الفائتة';

  @override
  String get medicines_daily => 'يومي';

  @override
  String get medicines_weekly => 'أسبوعي';

  @override
  String get medicines_monthly => 'شهري';

  @override
  String get medicines_asNeeded => 'عند الحاجة';

  @override
  String get medicines_beforeFood => 'قبل الأكل';

  @override
  String get medicines_afterFood => 'بعد الأكل';

  @override
  String get medicines_withFood => 'مع الأكل';

  @override
  String get medicines_noInstructions => 'بدون تعليمات';

  @override
  String get profile_title => 'الملف الشخصي';

  @override
  String get profile_editProfile => 'تعديل الملف الشخصي';

  @override
  String get profile_changePassword => 'تغيير كلمة المرور';

  @override
  String get profile_notifications => 'إعدادات الإشعارات';

  @override
  String get profile_appSettings => 'تفضيلات التطبيق';

  @override
  String get profile_qrCode => 'رمز QR الخاص بك';

  @override
  String get profile_helpSupport => 'المساعدة والدعم';

  @override
  String get profile_about => 'عن التطبيق';

  @override
  String get profile_logoutButton => 'تسجيل الخروج';

  @override
  String get profile_name => 'الاسم';

  @override
  String get profile_email => 'البريد الإلكتروني';

  @override
  String get profile_phone => 'رقم الهاتف';

  @override
  String get profile_age => 'العمر';

  @override
  String get profile_gender => 'الجنس';

  @override
  String get profile_male => 'ذكر';

  @override
  String get profile_female => 'أنثى';

  @override
  String get profile_bloodType => 'فصيلة الدم';

  @override
  String get profile_height => 'الطول';

  @override
  String get profile_weight => 'الوزن';

  @override
  String get profile_updateSuccess => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String get profile_currentPassword => 'كلمة المرور الحالية';

  @override
  String get profile_newPassword => 'كلمة المرور الجديدة';

  @override
  String get profile_confirmPassword => 'تأكيد كلمة المرور الجديدة';

  @override
  String get profile_passwordChanged => 'تم تغيير كلمة المرور بنجاح';

  @override
  String get profile_passwordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get settings_title => 'تفضيلات التطبيق';

  @override
  String get settings_subtitle => 'تخصيص تجربة الاستخدام';

  @override
  String get settings_appearance => 'المظهر';

  @override
  String get settings_language => 'اللغة';

  @override
  String get settings_theme => 'المظهر';

  @override
  String get settings_themeLight => 'فاتح';

  @override
  String get settings_themeDark => 'داكن';

  @override
  String get settings_themeSystem => 'تلقائي';

  @override
  String get settings_langArabic => 'العربية';

  @override
  String get settings_langEnglish => 'English';

  @override
  String get settings_measurementUnits => 'وحدات القياس';

  @override
  String get settings_weightUnit => 'وحدة الوزن';

  @override
  String get settings_heightUnit => 'وحدة الطول';

  @override
  String get settings_temperatureUnit => 'وحدة درجة الحرارة';

  @override
  String get settings_glucoseUnit => 'وحدة سكر الدم';

  @override
  String get settings_data => 'البيانات';

  @override
  String get settings_clearCache => 'مسح الذاكرة المؤقتة';

  @override
  String get settings_clearCacheSubtitle => 'حذف البيانات المخزنة مؤقتاً';

  @override
  String get settings_clearCacheConfirm =>
      'سيتم حذف البيانات المخزنة مؤقتاً. هذا لن يؤثر على بياناتك المحفوظة.';

  @override
  String get settings_cacheCleared => 'تم مسح الذاكرة المؤقتة بنجاح';

  @override
  String get settings_kgUnit => 'كيلوجرام (kg)';

  @override
  String get settings_lbUnit => 'رطل (lb)';

  @override
  String get settings_cmUnit => 'سنتيمتر (cm)';

  @override
  String get settings_ftUnit => 'قدم/بوصة (ft/in)';

  @override
  String get settings_celsiusUnit => 'مئوية (°C)';

  @override
  String get settings_fahrenheitUnit => 'فهرنهايت (°F)';

  @override
  String get notifications_title => 'الإشعارات';

  @override
  String get notifications_noNotifications => 'لا توجد إشعارات';

  @override
  String get notifications_markAllRead => 'قراءة الكل';

  @override
  String get notifications_medicineReminder => 'تذكير الأدوية';

  @override
  String get notifications_healthAlert => 'تنبيه صحي';

  @override
  String get notifications_settings => 'إعدادات الإشعارات';

  @override
  String get notifications_enableAll => 'تفعيل الإشعارات';

  @override
  String get notifications_sound => 'الصوت';

  @override
  String get notifications_vibration => 'الاهتزاز';

  @override
  String get notifications_medicineNotifications => 'إشعارات الأدوية';

  @override
  String get notifications_healthNotifications => 'إشعارات صحية';

  @override
  String get auth_login => 'تسجيل الدخول';

  @override
  String get auth_register => 'إنشاء حساب';

  @override
  String get auth_email => 'البريد الإلكتروني';

  @override
  String get auth_password => 'كلمة المرور';

  @override
  String get auth_forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get auth_noAccount => 'ليس لديك حساب؟';

  @override
  String get auth_hasAccount => 'لديك حساب بالفعل؟';

  @override
  String get auth_loginButton => 'دخول';

  @override
  String get auth_registerButton => 'تسجيل';

  @override
  String get auth_fullName => 'الاسم الكامل';

  @override
  String get auth_confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get auth_rememberMe => 'تذكرني';

  @override
  String get auth_welcomeTitle => 'مرحباً بك';

  @override
  String get auth_welcomeSubtitle => 'سجّل دخولك للوصول إلى سجلك الصحي';

  @override
  String get auth_verifyEmail => 'تأكيد البريد الإلكتروني';

  @override
  String get auth_verifyEmailSent =>
      'تم إرسال رابط التحقق إلى بريدك الإلكتروني';

  @override
  String get auth_resendEmail => 'إعادة إرسال';

  @override
  String get auth_patient => 'مريض';

  @override
  String get auth_doctor => 'طبيب';

  @override
  String get auth_selectRole => 'اختر نوع الحساب';

  @override
  String get doctor_home_title => 'لوحة التحكم';

  @override
  String get doctor_myPatients => 'المرضى';

  @override
  String get doctor_totalPatients => 'إجمالي المرضى';

  @override
  String get doctor_activeMedicines => 'الوصفات النشطة';

  @override
  String get doctor_scanQr => 'مسح رمز QR';

  @override
  String get doctor_scanQrSubtitle => 'ربط مريض جديد';

  @override
  String get doctor_patientLinked => 'تم ربط المريض بنجاح';

  @override
  String get doctor_patientNotFound => 'لم يتم العثور على المريض';

  @override
  String get doctor_noPatients => 'لا يوجد مرضى مرتبطين';

  @override
  String get doctor_addPatientPrompt => 'امسح رمز QR الخاص بالمريض لربطه';

  @override
  String get doctor_patientDetails => 'تفاصيل المريض';

  @override
  String get doctor_healthReadings => 'القراءات الصحية';

  @override
  String get doctor_medicines => 'الأدوية';

  @override
  String get doctor_adherence => 'الالتزام';

  @override
  String get doctor_unlinkPatient => 'إلغاء الربط';

  @override
  String get doctor_unlinkConfirm => 'هل أنت متأكد من إلغاء ربط هذا المريض؟';

  @override
  String get doctor_searchPatients => 'ابحث عن مريض...';

  @override
  String get reports_title => 'التقارير';

  @override
  String get reports_period7d => '٧ أيام';

  @override
  String get reports_period30d => '٣٠ يوم';

  @override
  String get reports_period90d => '٩٠ يوم';

  @override
  String get reports_kpiPatients => 'المرضى';

  @override
  String get reports_kpiPrescriptions => 'الوصفات';

  @override
  String get reports_kpiAdherence => 'متوسط الالتزام';

  @override
  String get reports_kpiAlerts => 'التنبيهات';

  @override
  String get reports_criticalAlerts => 'التنبيهات الحرجة';

  @override
  String get reports_noCriticalAlerts => 'لا توجد تنبيهات حرجة';

  @override
  String get reports_adherenceRanking => 'ترتيب الالتزام';

  @override
  String get reports_noAdherenceData => 'لا توجد بيانات التزام';

  @override
  String get reports_noData => 'لا توجد بيانات متاحة';

  @override
  String get reports_loadError => 'تعذر تحميل التقارير';

  @override
  String get reports_highSugar => 'سكر مرتفع جداً';

  @override
  String get reports_lowSugar => 'سكر منخفض جداً';

  @override
  String get reports_highSugarWarning => 'سكر مرتفع';

  @override
  String get reports_highBP => 'ضغط مرتفع جداً';

  @override
  String get reports_highBPWarning => 'ضغط مرتفع';

  @override
  String get reports_highTemp => 'حرارة مرتفعة';

  @override
  String get reports_patient => 'مريض';

  @override
  String get reports_noMedicines => 'بدون أدوية';

  @override
  String get dailyTip_title => 'نصيحة اليوم';

  @override
  String get units_mgdl => 'mg/dL';

  @override
  String get units_mmhg => 'mmHg';

  @override
  String get units_kg => 'kg';

  @override
  String get units_celsius => '°C';

  @override
  String get units_bpm => 'نبض/د';

  @override
  String get period_days => 'أيام';

  @override
  String get period_weeks => 'أسابيع';

  @override
  String get period_months => 'أشهر';

  @override
  String get period_7days => '٧ أيام';

  @override
  String get period_30days => '٣٠ يوم';

  @override
  String get period_90days => '٩٠ يوم';

  @override
  String get period_all => 'الكل';
}
