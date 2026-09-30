import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'Medical Care'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In ar, this message translates to:
  /// **'صحتك أولويتنا'**
  String get appTagline;

  /// No description provided for @common_save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get common_save;

  /// No description provided for @common_cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get common_cancel;

  /// No description provided for @common_delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get common_delete;

  /// No description provided for @common_edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get common_edit;

  /// No description provided for @common_done.
  ///
  /// In ar, this message translates to:
  /// **'تم'**
  String get common_done;

  /// No description provided for @common_close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get common_close;

  /// No description provided for @common_back.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get common_back;

  /// No description provided for @common_next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get common_next;

  /// No description provided for @common_confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get common_confirm;

  /// No description provided for @common_retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get common_retry;

  /// No description provided for @common_loading.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل...'**
  String get common_loading;

  /// No description provided for @common_error.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ'**
  String get common_error;

  /// No description provided for @common_success.
  ///
  /// In ar, this message translates to:
  /// **'تم بنجاح'**
  String get common_success;

  /// No description provided for @common_noData.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات'**
  String get common_noData;

  /// No description provided for @common_search.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get common_search;

  /// No description provided for @common_viewAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get common_viewAll;

  /// No description provided for @common_viewMore.
  ///
  /// In ar, this message translates to:
  /// **'عرض المزيد'**
  String get common_viewMore;

  /// No description provided for @common_showAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get common_showAll;

  /// No description provided for @common_processing.
  ///
  /// In ar, this message translates to:
  /// **'جاري التنفيذ...'**
  String get common_processing;

  /// No description provided for @common_yes.
  ///
  /// In ar, this message translates to:
  /// **'نعم'**
  String get common_yes;

  /// No description provided for @common_no.
  ///
  /// In ar, this message translates to:
  /// **'لا'**
  String get common_no;

  /// No description provided for @common_ok.
  ///
  /// In ar, this message translates to:
  /// **'موافق'**
  String get common_ok;

  /// No description provided for @common_logout.
  ///
  /// In ar, this message translates to:
  /// **'خروج'**
  String get common_logout;

  /// No description provided for @common_logoutConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من رغبتك في الخروج؟'**
  String get common_logoutConfirm;

  /// No description provided for @common_logoutTitle.
  ///
  /// In ar, this message translates to:
  /// **'الخروج من التطبيق'**
  String get common_logoutTitle;

  /// No description provided for @common_today.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get common_today;

  /// No description provided for @common_yesterday.
  ///
  /// In ar, this message translates to:
  /// **'أمس'**
  String get common_yesterday;

  /// No description provided for @common_daysAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ {count} أيام'**
  String common_daysAgo(int count);

  /// No description provided for @common_normal.
  ///
  /// In ar, this message translates to:
  /// **'طبيعي'**
  String get common_normal;

  /// No description provided for @common_high.
  ///
  /// In ar, this message translates to:
  /// **'مرتفع'**
  String get common_high;

  /// No description provided for @common_low.
  ///
  /// In ar, this message translates to:
  /// **'منخفض'**
  String get common_low;

  /// No description provided for @common_critical.
  ///
  /// In ar, this message translates to:
  /// **'حرج'**
  String get common_critical;

  /// No description provided for @common_warning.
  ///
  /// In ar, this message translates to:
  /// **'تحذير'**
  String get common_warning;

  /// No description provided for @nav_home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get nav_home;

  /// No description provided for @nav_medicines.
  ///
  /// In ar, this message translates to:
  /// **'الأدوية'**
  String get nav_medicines;

  /// No description provided for @nav_readings.
  ///
  /// In ar, this message translates to:
  /// **'القراءات'**
  String get nav_readings;

  /// No description provided for @nav_profile.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get nav_profile;

  /// No description provided for @nav_patients.
  ///
  /// In ar, this message translates to:
  /// **'المرضى'**
  String get nav_patients;

  /// No description provided for @nav_reports.
  ///
  /// In ar, this message translates to:
  /// **'التقارير'**
  String get nav_reports;

  /// No description provided for @nav_homeSemantics.
  ///
  /// In ar, this message translates to:
  /// **'الصفحة الرئيسية'**
  String get nav_homeSemantics;

  /// No description provided for @nav_medicinesSemantics.
  ///
  /// In ar, this message translates to:
  /// **'قائمة الأدوية'**
  String get nav_medicinesSemantics;

  /// No description provided for @nav_readingsSemantics.
  ///
  /// In ar, this message translates to:
  /// **'القراءات الصحية'**
  String get nav_readingsSemantics;

  /// No description provided for @nav_profileSemantics.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي والإعدادات'**
  String get nav_profileSemantics;

  /// No description provided for @nav_doctorHomeSemantics.
  ///
  /// In ar, this message translates to:
  /// **'الصفحة الرئيسية للطبيب'**
  String get nav_doctorHomeSemantics;

  /// No description provided for @nav_patientsSemantics.
  ///
  /// In ar, this message translates to:
  /// **'قائمة المرضى'**
  String get nav_patientsSemantics;

  /// No description provided for @nav_reportsSemantics.
  ///
  /// In ar, this message translates to:
  /// **'التقارير والإحصائيات'**
  String get nav_reportsSemantics;

  /// No description provided for @greeting_morning.
  ///
  /// In ar, this message translates to:
  /// **'صباح الخير'**
  String get greeting_morning;

  /// No description provided for @greeting_afternoon.
  ///
  /// In ar, this message translates to:
  /// **'مساء الخير'**
  String get greeting_afternoon;

  /// No description provided for @greeting_evening.
  ///
  /// In ar, this message translates to:
  /// **'مساء الخير'**
  String get greeting_evening;

  /// No description provided for @greeting_night.
  ///
  /// In ar, this message translates to:
  /// **'مساء الخير'**
  String get greeting_night;

  /// No description provided for @greeting_tip1.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ يومك بنشاط وحيوية! 💪'**
  String get greeting_tip1;

  /// No description provided for @greeting_tip2.
  ///
  /// In ar, this message translates to:
  /// **'صحتك أولوية، اعتنِ بها اليوم'**
  String get greeting_tip2;

  /// No description provided for @greeting_tip3.
  ///
  /// In ar, this message translates to:
  /// **'يوم جديد، فرصة جديدة للصحة'**
  String get greeting_tip3;

  /// No description provided for @greeting_waterTip.
  ///
  /// In ar, this message translates to:
  /// **'لا تنسَ شرب الماء! 💧'**
  String get greeting_waterTip;

  /// No description provided for @greeting_breakTip.
  ///
  /// In ar, this message translates to:
  /// **'خذ استراحة قصيرة للتجدد'**
  String get greeting_breakTip;

  /// No description provided for @health_status.
  ///
  /// In ar, this message translates to:
  /// **'الحالة الصحية'**
  String get health_status;

  /// No description provided for @health_dailySummary.
  ///
  /// In ar, this message translates to:
  /// **'ملخص يومي محدث'**
  String get health_dailySummary;

  /// No description provided for @health_needsFollowUp.
  ///
  /// In ar, this message translates to:
  /// **'تحتاج متابعة'**
  String get health_needsFollowUp;

  /// No description provided for @health_bloodPressure.
  ///
  /// In ar, this message translates to:
  /// **'ضغط الدم'**
  String get health_bloodPressure;

  /// No description provided for @health_bloodSugar.
  ///
  /// In ar, this message translates to:
  /// **'السكر'**
  String get health_bloodSugar;

  /// No description provided for @health_weight.
  ///
  /// In ar, this message translates to:
  /// **'الوزن'**
  String get health_weight;

  /// No description provided for @health_temperature.
  ///
  /// In ar, this message translates to:
  /// **'درجة الحرارة'**
  String get health_temperature;

  /// No description provided for @health_heartRate.
  ///
  /// In ar, this message translates to:
  /// **'معدل النبض'**
  String get health_heartRate;

  /// No description provided for @health_oxygen.
  ///
  /// In ar, this message translates to:
  /// **'الأكسجين'**
  String get health_oxygen;

  /// No description provided for @health_addReading.
  ///
  /// In ar, this message translates to:
  /// **'إضافة قراءة'**
  String get health_addReading;

  /// No description provided for @health_addReadingSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'سجّل قراءة جديدة'**
  String get health_addReadingSubtitle;

  /// No description provided for @health_noReadings.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد قراءات'**
  String get health_noReadings;

  /// No description provided for @health_readingAdded.
  ///
  /// In ar, this message translates to:
  /// **'تم إضافة القراءة بنجاح'**
  String get health_readingAdded;

  /// No description provided for @health_readingDeleted.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف القراءة'**
  String get health_readingDeleted;

  /// No description provided for @health_value.
  ///
  /// In ar, this message translates to:
  /// **'القيمة'**
  String get health_value;

  /// No description provided for @health_unit.
  ///
  /// In ar, this message translates to:
  /// **'الوحدة'**
  String get health_unit;

  /// No description provided for @health_date.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get health_date;

  /// No description provided for @health_time.
  ///
  /// In ar, this message translates to:
  /// **'الوقت'**
  String get health_time;

  /// No description provided for @health_notes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات'**
  String get health_notes;

  /// No description provided for @health_systolic.
  ///
  /// In ar, this message translates to:
  /// **'الضغط الانقباضي'**
  String get health_systolic;

  /// No description provided for @health_diastolic.
  ///
  /// In ar, this message translates to:
  /// **'الضغط الانبساطي'**
  String get health_diastolic;

  /// No description provided for @health_chart.
  ///
  /// In ar, this message translates to:
  /// **'الرسم البياني'**
  String get health_chart;

  /// No description provided for @health_table.
  ///
  /// In ar, this message translates to:
  /// **'الجدول'**
  String get health_table;

  /// No description provided for @health_exportFeature.
  ///
  /// In ar, this message translates to:
  /// **'ميزة التصدير قريباً'**
  String get health_exportFeature;

  /// No description provided for @health_weeklySummary.
  ///
  /// In ar, this message translates to:
  /// **'ملخص الأسبوع'**
  String get health_weeklySummary;

  /// No description provided for @quickActions_title.
  ///
  /// In ar, this message translates to:
  /// **'الإجراءات السريعة'**
  String get quickActions_title;

  /// No description provided for @quickActions_addReading.
  ///
  /// In ar, this message translates to:
  /// **'إضافة قراءة'**
  String get quickActions_addReading;

  /// No description provided for @quickActions_addReadingSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'سجّل قراءة جديدة'**
  String get quickActions_addReadingSubtitle;

  /// No description provided for @quickActions_medicines.
  ///
  /// In ar, this message translates to:
  /// **'الأدوية'**
  String get quickActions_medicines;

  /// No description provided for @quickActions_medicinesSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إدارة أدويتك'**
  String get quickActions_medicinesSubtitle;

  /// No description provided for @quickActions_medicinesCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} دواء'**
  String quickActions_medicinesCount(int count);

  /// No description provided for @quickActions_statistics.
  ///
  /// In ar, this message translates to:
  /// **'الإحصائيات'**
  String get quickActions_statistics;

  /// No description provided for @quickActions_statisticsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تحليل بياناتك'**
  String get quickActions_statisticsSubtitle;

  /// No description provided for @quickActions_history.
  ///
  /// In ar, this message translates to:
  /// **'السجل'**
  String get quickActions_history;

  /// No description provided for @quickActions_historySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'سجلك الصحي'**
  String get quickActions_historySubtitle;

  /// No description provided for @quickActions_readingsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} قراءة'**
  String quickActions_readingsCount(int count);

  /// No description provided for @todayMeds_title.
  ///
  /// In ar, this message translates to:
  /// **'أدوية اليوم'**
  String get todayMeds_title;

  /// No description provided for @todayMeds_noMeds.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أدوية مجدولة'**
  String get todayMeds_noMeds;

  /// No description provided for @todayMeds_addPrompt.
  ///
  /// In ar, this message translates to:
  /// **'أضف أدويتك لتتبع مواعيدها وتلقي تذكيرات'**
  String get todayMeds_addPrompt;

  /// No description provided for @todayMeds_taken.
  ///
  /// In ar, this message translates to:
  /// **'تم تناوله'**
  String get todayMeds_taken;

  /// No description provided for @todayMeds_skip.
  ///
  /// In ar, this message translates to:
  /// **'تخطي'**
  String get todayMeds_skip;

  /// No description provided for @todayMeds_later.
  ///
  /// In ar, this message translates to:
  /// **'لاحقاً'**
  String get todayMeds_later;

  /// No description provided for @todayMeds_statusUpcoming.
  ///
  /// In ar, this message translates to:
  /// **'قادم'**
  String get todayMeds_statusUpcoming;

  /// No description provided for @todayMeds_statusDue.
  ///
  /// In ar, this message translates to:
  /// **'حان الموعد'**
  String get todayMeds_statusDue;

  /// No description provided for @todayMeds_statusOverdue.
  ///
  /// In ar, this message translates to:
  /// **'تناوله الآن'**
  String get todayMeds_statusOverdue;

  /// No description provided for @todayMeds_statusTaken.
  ///
  /// In ar, this message translates to:
  /// **'تم التناول'**
  String get todayMeds_statusTaken;

  /// No description provided for @todayMeds_statusSkipped.
  ///
  /// In ar, this message translates to:
  /// **'تم التخطي'**
  String get todayMeds_statusSkipped;

  /// No description provided for @todayMeds_statusSnoozed.
  ///
  /// In ar, this message translates to:
  /// **'مؤجل'**
  String get todayMeds_statusSnoozed;

  /// No description provided for @todayMeds_statusMissed.
  ///
  /// In ar, this message translates to:
  /// **'فائت'**
  String get todayMeds_statusMissed;

  /// No description provided for @weeklyProgress_medicines.
  ///
  /// In ar, this message translates to:
  /// **'الأدوية'**
  String get weeklyProgress_medicines;

  /// No description provided for @weeklyProgress_readings.
  ///
  /// In ar, this message translates to:
  /// **'القراءات'**
  String get weeklyProgress_readings;

  /// No description provided for @weeklyProgress_adherence.
  ///
  /// In ar, this message translates to:
  /// **'الالتزام'**
  String get weeklyProgress_adherence;

  /// No description provided for @weeklyProgress_sat.
  ///
  /// In ar, this message translates to:
  /// **'سبت'**
  String get weeklyProgress_sat;

  /// No description provided for @weeklyProgress_sun.
  ///
  /// In ar, this message translates to:
  /// **'أحد'**
  String get weeklyProgress_sun;

  /// No description provided for @weeklyProgress_mon.
  ///
  /// In ar, this message translates to:
  /// **'إثن'**
  String get weeklyProgress_mon;

  /// No description provided for @weeklyProgress_tue.
  ///
  /// In ar, this message translates to:
  /// **'ثلا'**
  String get weeklyProgress_tue;

  /// No description provided for @weeklyProgress_wed.
  ///
  /// In ar, this message translates to:
  /// **'أرب'**
  String get weeklyProgress_wed;

  /// No description provided for @weeklyProgress_thu.
  ///
  /// In ar, this message translates to:
  /// **'خمي'**
  String get weeklyProgress_thu;

  /// No description provided for @weeklyProgress_fri.
  ///
  /// In ar, this message translates to:
  /// **'جمع'**
  String get weeklyProgress_fri;

  /// No description provided for @medicines_title.
  ///
  /// In ar, this message translates to:
  /// **'الأدوية'**
  String get medicines_title;

  /// No description provided for @medicines_addMedicine.
  ///
  /// In ar, this message translates to:
  /// **'إضافة دواء'**
  String get medicines_addMedicine;

  /// No description provided for @medicines_medicineName.
  ///
  /// In ar, this message translates to:
  /// **'اسم الدواء'**
  String get medicines_medicineName;

  /// No description provided for @medicines_dosage.
  ///
  /// In ar, this message translates to:
  /// **'الجرعة'**
  String get medicines_dosage;

  /// No description provided for @medicines_frequency.
  ///
  /// In ar, this message translates to:
  /// **'التكرار'**
  String get medicines_frequency;

  /// No description provided for @medicines_startDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ البدء'**
  String get medicines_startDate;

  /// No description provided for @medicines_endDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الانتهاء'**
  String get medicines_endDate;

  /// No description provided for @medicines_times.
  ///
  /// In ar, this message translates to:
  /// **'مواعيد الجرعات'**
  String get medicines_times;

  /// No description provided for @medicines_instructions.
  ///
  /// In ar, this message translates to:
  /// **'تعليمات'**
  String get medicines_instructions;

  /// No description provided for @medicines_active.
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get medicines_active;

  /// No description provided for @medicines_inactive.
  ///
  /// In ar, this message translates to:
  /// **'غير نشط'**
  String get medicines_inactive;

  /// No description provided for @medicines_all.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get medicines_all;

  /// No description provided for @medicines_critical.
  ///
  /// In ar, this message translates to:
  /// **'مهم'**
  String get medicines_critical;

  /// No description provided for @medicines_noMedicines.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أدوية'**
  String get medicines_noMedicines;

  /// No description provided for @medicines_addMedicinePrompt.
  ///
  /// In ar, this message translates to:
  /// **'أضف دواءً جديداً لمتابعة جدولك الدوائي'**
  String get medicines_addMedicinePrompt;

  /// No description provided for @medicines_deleteConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذا الدواء؟'**
  String get medicines_deleteConfirm;

  /// No description provided for @medicines_deleteSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف الدواء بنجاح'**
  String get medicines_deleteSuccess;

  /// No description provided for @medicines_addSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إضافة الدواء بنجاح'**
  String get medicines_addSuccess;

  /// No description provided for @medicines_editSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الدواء بنجاح'**
  String get medicines_editSuccess;

  /// No description provided for @medicines_searchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن دواء...'**
  String get medicines_searchHint;

  /// No description provided for @medicines_stats.
  ///
  /// In ar, this message translates to:
  /// **'الإحصائيات'**
  String get medicines_stats;

  /// No description provided for @medicines_adherenceRate.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الالتزام'**
  String get medicines_adherenceRate;

  /// No description provided for @medicines_totalDoses.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الجرعات'**
  String get medicines_totalDoses;

  /// No description provided for @medicines_takenDoses.
  ///
  /// In ar, this message translates to:
  /// **'الجرعات المتناولة'**
  String get medicines_takenDoses;

  /// No description provided for @medicines_missedDoses.
  ///
  /// In ar, this message translates to:
  /// **'الجرعات الفائتة'**
  String get medicines_missedDoses;

  /// No description provided for @medicines_daily.
  ///
  /// In ar, this message translates to:
  /// **'يومي'**
  String get medicines_daily;

  /// No description provided for @medicines_weekly.
  ///
  /// In ar, this message translates to:
  /// **'أسبوعي'**
  String get medicines_weekly;

  /// No description provided for @medicines_monthly.
  ///
  /// In ar, this message translates to:
  /// **'شهري'**
  String get medicines_monthly;

  /// No description provided for @medicines_asNeeded.
  ///
  /// In ar, this message translates to:
  /// **'عند الحاجة'**
  String get medicines_asNeeded;

  /// No description provided for @medicines_beforeFood.
  ///
  /// In ar, this message translates to:
  /// **'قبل الأكل'**
  String get medicines_beforeFood;

  /// No description provided for @medicines_afterFood.
  ///
  /// In ar, this message translates to:
  /// **'بعد الأكل'**
  String get medicines_afterFood;

  /// No description provided for @medicines_withFood.
  ///
  /// In ar, this message translates to:
  /// **'مع الأكل'**
  String get medicines_withFood;

  /// No description provided for @medicines_noInstructions.
  ///
  /// In ar, this message translates to:
  /// **'بدون تعليمات'**
  String get medicines_noInstructions;

  /// No description provided for @profile_title.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get profile_title;

  /// No description provided for @profile_editProfile.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الملف الشخصي'**
  String get profile_editProfile;

  /// No description provided for @profile_changePassword.
  ///
  /// In ar, this message translates to:
  /// **'تغيير كلمة المرور'**
  String get profile_changePassword;

  /// No description provided for @profile_notifications.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الإشعارات'**
  String get profile_notifications;

  /// No description provided for @profile_appSettings.
  ///
  /// In ar, this message translates to:
  /// **'تفضيلات التطبيق'**
  String get profile_appSettings;

  /// No description provided for @profile_qrCode.
  ///
  /// In ar, this message translates to:
  /// **'رمز QR الخاص بك'**
  String get profile_qrCode;

  /// No description provided for @profile_helpSupport.
  ///
  /// In ar, this message translates to:
  /// **'المساعدة والدعم'**
  String get profile_helpSupport;

  /// No description provided for @profile_about.
  ///
  /// In ar, this message translates to:
  /// **'عن التطبيق'**
  String get profile_about;

  /// No description provided for @profile_logoutButton.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get profile_logoutButton;

  /// No description provided for @profile_name.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get profile_name;

  /// No description provided for @profile_email.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get profile_email;

  /// No description provided for @profile_phone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get profile_phone;

  /// No description provided for @profile_age.
  ///
  /// In ar, this message translates to:
  /// **'العمر'**
  String get profile_age;

  /// No description provided for @profile_gender.
  ///
  /// In ar, this message translates to:
  /// **'الجنس'**
  String get profile_gender;

  /// No description provided for @profile_male.
  ///
  /// In ar, this message translates to:
  /// **'ذكر'**
  String get profile_male;

  /// No description provided for @profile_female.
  ///
  /// In ar, this message translates to:
  /// **'أنثى'**
  String get profile_female;

  /// No description provided for @profile_bloodType.
  ///
  /// In ar, this message translates to:
  /// **'فصيلة الدم'**
  String get profile_bloodType;

  /// No description provided for @profile_height.
  ///
  /// In ar, this message translates to:
  /// **'الطول'**
  String get profile_height;

  /// No description provided for @profile_weight.
  ///
  /// In ar, this message translates to:
  /// **'الوزن'**
  String get profile_weight;

  /// No description provided for @profile_updateSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الملف الشخصي بنجاح'**
  String get profile_updateSuccess;

  /// No description provided for @profile_currentPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الحالية'**
  String get profile_currentPassword;

  /// No description provided for @profile_newPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الجديدة'**
  String get profile_newPassword;

  /// No description provided for @profile_confirmPassword.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور الجديدة'**
  String get profile_confirmPassword;

  /// No description provided for @profile_passwordChanged.
  ///
  /// In ar, this message translates to:
  /// **'تم تغيير كلمة المرور بنجاح'**
  String get profile_passwordChanged;

  /// No description provided for @profile_passwordMismatch.
  ///
  /// In ar, this message translates to:
  /// **'كلمتا المرور غير متطابقتين'**
  String get profile_passwordMismatch;

  /// No description provided for @settings_title.
  ///
  /// In ar, this message translates to:
  /// **'تفضيلات التطبيق'**
  String get settings_title;

  /// No description provided for @settings_subtitle.
  ///
  /// In ar, this message translates to:
  /// **'تخصيص تجربة الاستخدام'**
  String get settings_subtitle;

  /// No description provided for @settings_appearance.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get settings_appearance;

  /// No description provided for @settings_language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get settings_language;

  /// No description provided for @settings_theme.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get settings_theme;

  /// No description provided for @settings_themeLight.
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get settings_themeLight;

  /// No description provided for @settings_themeDark.
  ///
  /// In ar, this message translates to:
  /// **'داكن'**
  String get settings_themeDark;

  /// No description provided for @settings_themeSystem.
  ///
  /// In ar, this message translates to:
  /// **'تلقائي'**
  String get settings_themeSystem;

  /// No description provided for @settings_langArabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get settings_langArabic;

  /// No description provided for @settings_langEnglish.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get settings_langEnglish;

  /// No description provided for @settings_measurementUnits.
  ///
  /// In ar, this message translates to:
  /// **'وحدات القياس'**
  String get settings_measurementUnits;

  /// No description provided for @settings_weightUnit.
  ///
  /// In ar, this message translates to:
  /// **'وحدة الوزن'**
  String get settings_weightUnit;

  /// No description provided for @settings_heightUnit.
  ///
  /// In ar, this message translates to:
  /// **'وحدة الطول'**
  String get settings_heightUnit;

  /// No description provided for @settings_temperatureUnit.
  ///
  /// In ar, this message translates to:
  /// **'وحدة درجة الحرارة'**
  String get settings_temperatureUnit;

  /// No description provided for @settings_glucoseUnit.
  ///
  /// In ar, this message translates to:
  /// **'وحدة سكر الدم'**
  String get settings_glucoseUnit;

  /// No description provided for @settings_data.
  ///
  /// In ar, this message translates to:
  /// **'البيانات'**
  String get settings_data;

  /// No description provided for @settings_clearCache.
  ///
  /// In ar, this message translates to:
  /// **'مسح الذاكرة المؤقتة'**
  String get settings_clearCache;

  /// No description provided for @settings_clearCacheSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف البيانات المخزنة مؤقتاً'**
  String get settings_clearCacheSubtitle;

  /// No description provided for @settings_clearCacheConfirm.
  ///
  /// In ar, this message translates to:
  /// **'سيتم حذف البيانات المخزنة مؤقتاً. هذا لن يؤثر على بياناتك المحفوظة.'**
  String get settings_clearCacheConfirm;

  /// No description provided for @settings_cacheCleared.
  ///
  /// In ar, this message translates to:
  /// **'تم مسح الذاكرة المؤقتة بنجاح'**
  String get settings_cacheCleared;

  /// No description provided for @settings_kgUnit.
  ///
  /// In ar, this message translates to:
  /// **'كيلوجرام (kg)'**
  String get settings_kgUnit;

  /// No description provided for @settings_lbUnit.
  ///
  /// In ar, this message translates to:
  /// **'رطل (lb)'**
  String get settings_lbUnit;

  /// No description provided for @settings_cmUnit.
  ///
  /// In ar, this message translates to:
  /// **'سنتيمتر (cm)'**
  String get settings_cmUnit;

  /// No description provided for @settings_ftUnit.
  ///
  /// In ar, this message translates to:
  /// **'قدم/بوصة (ft/in)'**
  String get settings_ftUnit;

  /// No description provided for @settings_celsiusUnit.
  ///
  /// In ar, this message translates to:
  /// **'مئوية (°C)'**
  String get settings_celsiusUnit;

  /// No description provided for @settings_fahrenheitUnit.
  ///
  /// In ar, this message translates to:
  /// **'فهرنهايت (°F)'**
  String get settings_fahrenheitUnit;

  /// No description provided for @notifications_title.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notifications_title;

  /// No description provided for @notifications_noNotifications.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات'**
  String get notifications_noNotifications;

  /// No description provided for @notifications_markAllRead.
  ///
  /// In ar, this message translates to:
  /// **'قراءة الكل'**
  String get notifications_markAllRead;

  /// No description provided for @notifications_medicineReminder.
  ///
  /// In ar, this message translates to:
  /// **'تذكير الأدوية'**
  String get notifications_medicineReminder;

  /// No description provided for @notifications_healthAlert.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه صحي'**
  String get notifications_healthAlert;

  /// No description provided for @notifications_settings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الإشعارات'**
  String get notifications_settings;

  /// No description provided for @notifications_enableAll.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الإشعارات'**
  String get notifications_enableAll;

  /// No description provided for @notifications_sound.
  ///
  /// In ar, this message translates to:
  /// **'الصوت'**
  String get notifications_sound;

  /// No description provided for @notifications_vibration.
  ///
  /// In ar, this message translates to:
  /// **'الاهتزاز'**
  String get notifications_vibration;

  /// No description provided for @notifications_medicineNotifications.
  ///
  /// In ar, this message translates to:
  /// **'إشعارات الأدوية'**
  String get notifications_medicineNotifications;

  /// No description provided for @notifications_healthNotifications.
  ///
  /// In ar, this message translates to:
  /// **'إشعارات صحية'**
  String get notifications_healthNotifications;

  /// No description provided for @auth_login.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get auth_login;

  /// No description provided for @auth_register.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get auth_register;

  /// No description provided for @auth_email.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get auth_email;

  /// No description provided for @auth_password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get auth_password;

  /// No description provided for @auth_forgotPassword.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get auth_forgotPassword;

  /// No description provided for @auth_noAccount.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟'**
  String get auth_noAccount;

  /// No description provided for @auth_hasAccount.
  ///
  /// In ar, this message translates to:
  /// **'لديك حساب بالفعل؟'**
  String get auth_hasAccount;

  /// No description provided for @auth_loginButton.
  ///
  /// In ar, this message translates to:
  /// **'دخول'**
  String get auth_loginButton;

  /// No description provided for @auth_registerButton.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل'**
  String get auth_registerButton;

  /// No description provided for @auth_fullName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get auth_fullName;

  /// No description provided for @auth_confirmPassword.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get auth_confirmPassword;

  /// No description provided for @auth_rememberMe.
  ///
  /// In ar, this message translates to:
  /// **'تذكرني'**
  String get auth_rememberMe;

  /// No description provided for @auth_welcomeTitle.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك'**
  String get auth_welcomeTitle;

  /// No description provided for @auth_welcomeSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'سجّل دخولك للوصول إلى سجلك الصحي'**
  String get auth_welcomeSubtitle;

  /// No description provided for @auth_verifyEmail.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد البريد الإلكتروني'**
  String get auth_verifyEmail;

  /// No description provided for @auth_verifyEmailSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رابط التحقق إلى بريدك الإلكتروني'**
  String get auth_verifyEmailSent;

  /// No description provided for @auth_resendEmail.
  ///
  /// In ar, this message translates to:
  /// **'إعادة إرسال'**
  String get auth_resendEmail;

  /// No description provided for @auth_patient.
  ///
  /// In ar, this message translates to:
  /// **'مريض'**
  String get auth_patient;

  /// No description provided for @auth_doctor.
  ///
  /// In ar, this message translates to:
  /// **'طبيب'**
  String get auth_doctor;

  /// No description provided for @auth_selectRole.
  ///
  /// In ar, this message translates to:
  /// **'اختر نوع الحساب'**
  String get auth_selectRole;

  /// No description provided for @doctor_home_title.
  ///
  /// In ar, this message translates to:
  /// **'لوحة التحكم'**
  String get doctor_home_title;

  /// No description provided for @doctor_myPatients.
  ///
  /// In ar, this message translates to:
  /// **'المرضى'**
  String get doctor_myPatients;

  /// No description provided for @doctor_totalPatients.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المرضى'**
  String get doctor_totalPatients;

  /// No description provided for @doctor_activeMedicines.
  ///
  /// In ar, this message translates to:
  /// **'الوصفات النشطة'**
  String get doctor_activeMedicines;

  /// No description provided for @doctor_scanQr.
  ///
  /// In ar, this message translates to:
  /// **'مسح رمز QR'**
  String get doctor_scanQr;

  /// No description provided for @doctor_scanQrSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'ربط مريض جديد'**
  String get doctor_scanQrSubtitle;

  /// No description provided for @doctor_patientLinked.
  ///
  /// In ar, this message translates to:
  /// **'تم ربط المريض بنجاح'**
  String get doctor_patientLinked;

  /// No description provided for @doctor_patientNotFound.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على المريض'**
  String get doctor_patientNotFound;

  /// No description provided for @doctor_noPatients.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد مرضى مرتبطين'**
  String get doctor_noPatients;

  /// No description provided for @doctor_addPatientPrompt.
  ///
  /// In ar, this message translates to:
  /// **'امسح رمز QR الخاص بالمريض لربطه'**
  String get doctor_addPatientPrompt;

  /// No description provided for @doctor_patientDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المريض'**
  String get doctor_patientDetails;

  /// No description provided for @doctor_healthReadings.
  ///
  /// In ar, this message translates to:
  /// **'القراءات الصحية'**
  String get doctor_healthReadings;

  /// No description provided for @doctor_medicines.
  ///
  /// In ar, this message translates to:
  /// **'الأدوية'**
  String get doctor_medicines;

  /// No description provided for @doctor_adherence.
  ///
  /// In ar, this message translates to:
  /// **'الالتزام'**
  String get doctor_adherence;

  /// No description provided for @doctor_unlinkPatient.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الربط'**
  String get doctor_unlinkPatient;

  /// No description provided for @doctor_unlinkConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من إلغاء ربط هذا المريض؟'**
  String get doctor_unlinkConfirm;

  /// No description provided for @doctor_searchPatients.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن مريض...'**
  String get doctor_searchPatients;

  /// No description provided for @reports_title.
  ///
  /// In ar, this message translates to:
  /// **'التقارير'**
  String get reports_title;

  /// No description provided for @reports_period7d.
  ///
  /// In ar, this message translates to:
  /// **'٧ أيام'**
  String get reports_period7d;

  /// No description provided for @reports_period30d.
  ///
  /// In ar, this message translates to:
  /// **'٣٠ يوم'**
  String get reports_period30d;

  /// No description provided for @reports_period90d.
  ///
  /// In ar, this message translates to:
  /// **'٩٠ يوم'**
  String get reports_period90d;

  /// No description provided for @reports_kpiPatients.
  ///
  /// In ar, this message translates to:
  /// **'المرضى'**
  String get reports_kpiPatients;

  /// No description provided for @reports_kpiPrescriptions.
  ///
  /// In ar, this message translates to:
  /// **'الوصفات'**
  String get reports_kpiPrescriptions;

  /// No description provided for @reports_kpiAdherence.
  ///
  /// In ar, this message translates to:
  /// **'متوسط الالتزام'**
  String get reports_kpiAdherence;

  /// No description provided for @reports_kpiAlerts.
  ///
  /// In ar, this message translates to:
  /// **'التنبيهات'**
  String get reports_kpiAlerts;

  /// No description provided for @reports_criticalAlerts.
  ///
  /// In ar, this message translates to:
  /// **'التنبيهات الحرجة'**
  String get reports_criticalAlerts;

  /// No description provided for @reports_noCriticalAlerts.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تنبيهات حرجة'**
  String get reports_noCriticalAlerts;

  /// No description provided for @reports_adherenceRanking.
  ///
  /// In ar, this message translates to:
  /// **'ترتيب الالتزام'**
  String get reports_adherenceRanking;

  /// No description provided for @reports_noAdherenceData.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات التزام'**
  String get reports_noAdherenceData;

  /// No description provided for @reports_noData.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات متاحة'**
  String get reports_noData;

  /// No description provided for @reports_loadError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل التقارير'**
  String get reports_loadError;

  /// No description provided for @reports_highSugar.
  ///
  /// In ar, this message translates to:
  /// **'سكر مرتفع جداً'**
  String get reports_highSugar;

  /// No description provided for @reports_lowSugar.
  ///
  /// In ar, this message translates to:
  /// **'سكر منخفض جداً'**
  String get reports_lowSugar;

  /// No description provided for @reports_highSugarWarning.
  ///
  /// In ar, this message translates to:
  /// **'سكر مرتفع'**
  String get reports_highSugarWarning;

  /// No description provided for @reports_highBP.
  ///
  /// In ar, this message translates to:
  /// **'ضغط مرتفع جداً'**
  String get reports_highBP;

  /// No description provided for @reports_highBPWarning.
  ///
  /// In ar, this message translates to:
  /// **'ضغط مرتفع'**
  String get reports_highBPWarning;

  /// No description provided for @reports_highTemp.
  ///
  /// In ar, this message translates to:
  /// **'حرارة مرتفعة'**
  String get reports_highTemp;

  /// No description provided for @reports_patient.
  ///
  /// In ar, this message translates to:
  /// **'مريض'**
  String get reports_patient;

  /// No description provided for @reports_noMedicines.
  ///
  /// In ar, this message translates to:
  /// **'بدون أدوية'**
  String get reports_noMedicines;

  /// No description provided for @dailyTip_title.
  ///
  /// In ar, this message translates to:
  /// **'نصيحة اليوم'**
  String get dailyTip_title;

  /// No description provided for @units_mgdl.
  ///
  /// In ar, this message translates to:
  /// **'mg/dL'**
  String get units_mgdl;

  /// No description provided for @units_mmhg.
  ///
  /// In ar, this message translates to:
  /// **'mmHg'**
  String get units_mmhg;

  /// No description provided for @units_kg.
  ///
  /// In ar, this message translates to:
  /// **'kg'**
  String get units_kg;

  /// No description provided for @units_celsius.
  ///
  /// In ar, this message translates to:
  /// **'°C'**
  String get units_celsius;

  /// No description provided for @units_bpm.
  ///
  /// In ar, this message translates to:
  /// **'نبض/د'**
  String get units_bpm;

  /// No description provided for @period_days.
  ///
  /// In ar, this message translates to:
  /// **'أيام'**
  String get period_days;

  /// No description provided for @period_weeks.
  ///
  /// In ar, this message translates to:
  /// **'أسابيع'**
  String get period_weeks;

  /// No description provided for @period_months.
  ///
  /// In ar, this message translates to:
  /// **'أشهر'**
  String get period_months;

  /// No description provided for @period_7days.
  ///
  /// In ar, this message translates to:
  /// **'٧ أيام'**
  String get period_7days;

  /// No description provided for @period_30days.
  ///
  /// In ar, this message translates to:
  /// **'٣٠ يوم'**
  String get period_30days;

  /// No description provided for @period_90days.
  ///
  /// In ar, this message translates to:
  /// **'٩٠ يوم'**
  String get period_90days;

  /// No description provided for @period_all.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get period_all;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return SAr();
    case 'en':
      return SEn();
  }

  throw FlutterError(
      'S.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
