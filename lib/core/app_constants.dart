class AppInfo {
  AppInfo._();

  static const String appName = 'Medical Care';
  static const String appNameAr = 'الرعاية الطبية';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  static const String packageName = 'com.medicalcare.app';

  static const String companyName = 'Medical Care Team';
  static const String companyWebsite = 'https://medicalcare.com';
  static const String supportEmail = 'support@medicalcare.com';
  static const String privacyPolicyUrl = 'https://medicalcare.com/privacy';
  static const String termsOfServiceUrl = 'https://medicalcare.com/terms';

  static const String androidAppId = 'com.medicalcare.app';
  static const String iosAppId = '123456789';
  static const String appStoreUrl = 'https://apps.apple.com/app/id123456789';
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=$androidAppId';
}
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.medicalcare.com';
  static const String apiVersion = 'v1';
  static const String apiBaseUrl = '$baseUrl/$apiVersion';

  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;
  static const int sendTimeout = 30;

  static const int maxRetryAttempts = 3;
  static const int retryDelaySeconds = 2;

  static const int maxRequestsPerMinute = 60;
  static const int maxLoginAttempts = 5;
  static const int loginLockoutMinutes = 30;

  static const String contentTypeJson = 'application/json';
  static const String acceptJson = 'application/json';
  static const String authHeaderKey = 'Authorization';
  static const String authHeaderPrefix = 'Bearer';
}
class FirebaseConstants {
  FirebaseConstants._();

  static const String usersCollection = 'users';
  static const String medicinesCollection = 'medicines';
  static const String healthReadingsCollection = 'health_readings';
  static const String appointmentsCollection = 'appointments';
  static const String prescriptionsCollection = 'prescriptions';
  static const String medicalRecordsCollection = 'medical_records';
  static const String notificationsCollection = 'notifications';
  static const String loginAttemptsCollection = 'login_attempts';
  static const String loginHistoryCollection = 'login_history';
  static const String auditLogsCollection = 'audit_logs';

  static const String profilePicturesFolder = 'profile_pictures';
  static const String medicineImagesFolder = 'medicine_images';
  static const String medicalDocumentsFolder = 'medical_documents';
  static const String prescriptionScansFolder = 'prescription_scans';
  static const String labResultsFolder = 'lab_results';

  static const String userIdField = 'id';
  static const String userNameField = 'name';
  static const String userEmailField = 'email';
  static const String userRoleField = 'role';
  static const String userPhotoUrlField = 'photoUrl';
  static const String userCreatedAtField = 'createdAt';
  static const String userUpdatedAtField = 'updatedAt';

  static const String medicineNameField = 'medicine_name';
  static const String medicineScientificNameField = 'scientific_name';
  static const String medicineDosageField = 'dosage';
  static const String medicineFrequencyField = 'frequency';
  static const String medicineTimesField = 'times';
  static const String medicineStartDateField = 'start_date';
  static const String medicineEndDateField = 'end_date';
  static const String medicineActiveField = 'is_active';
  static const String medicineUserIdField = 'user_id';

  static const String readingTypeField = 'reading_type';
  static const String readingValueField = 'value';
  static const String readingSystolicField = 'systolic';
  static const String readingDiastolicField = 'diastolic';
  static const String readingDateField = 'reading_date';
  static const String readingNotesField = 'notes';
  static const String readingUserIdField = 'user_id';
}
class StorageConstants {
  StorageConstants._();

  static const String keyIsFirstTime = 'is_first_time';
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyUserName = 'user_name';
  static const String keyUserRole = 'user_role';
  static const String keyAuthToken = 'auth_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyRememberMe = 'remember_me';
  static const String keyBiometricEnabled = 'biometric_enabled';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyLastSyncTime = 'last_sync_time';

  static const String databaseName = 'medical_care.db';
  static const int databaseVersion = 3;

  static const String medicinesTable = 'medicines';
  static const String medicineRecordsTable = 'medicine_records';
  static const String healthReadingsTable = 'health_readings';

  static const int userCacheDuration = 24;
  static const int dataCacheDuration = 6;
  static const int imageCacheDuration = 168; // 7 days

  static const int maxImageSize = 5;
  static const int maxDocumentSize = 10;
  static const int maxVideoSize = 50;

  static const int profilePictureWidth = 500;
  static const int profilePictureHeight = 500;
  static const int thumbnailWidth = 150;
  static const int thumbnailHeight = 150;
}
class ValidationConstants {
  ValidationConstants._();

  static const int nameMinLength = 2;
  static const int nameMaxLength = 50;
  static const int emailMaxLength = 100;
  static const int passwordMinLength = 8;
  static const int passwordMaxLength = 50;
  static const int phoneMinLength = 10;
  static const int phoneMaxLength = 15;
  static const int otpLength = 6;

  static const int medicineNameMinLength = 2;
  static const int medicineNameMaxLength = 100;
  static const int dosageMaxLength = 50;
  static const int instructionsMaxLength = 500;
  static const int notesMaxLength = 1000;
  static const int maxTimesPerDay = 10;
  static const int maxMedicineDurationDays = 365;

  static const double minBloodPressureSystolic = 40.0;
  static const double maxBloodPressureSystolic = 250.0;
  static const double minBloodPressureDiastolic = 20.0;
  static const double maxBloodPressureDiastolic = 150.0;
  static const double minBloodSugar = 20.0;
  static const double maxBloodSugar = 600.0;
  static const double minWeight = 10.0;
  static const double maxWeight = 300.0;
  static const double minTemperature = 30.0;
  static const double maxTemperature = 45.0;

  static const bool requireUppercase = true;
  static const bool requireLowercase = true;
  static const bool requireDigit = true;
  static const bool requireSpecialChar = true;
  static const int minPasswordStrength = 3; // out of 5

  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentExtensions = ['pdf', 'doc', 'docx'];
  static const List<String> allowedImageMimeTypes = [
    'image/jpeg',
    'image/png',
    'image/gif',
  ];
}
class TimeConstants {
  TimeConstants._();

  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateFormatArabic = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String timeFormat12Hour = 'hh:mm a';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayDateTimeFormat = 'MMM dd, yyyy - hh:mm a';
  static const String monthYearFormat = 'MMMM yyyy';
  static const String dayMonthYearFormat = 'dd MMMM yyyy';

  static const int splashDuration = 3000;
  static const int animationDuration = 300;
  static const int snackbarDuration = 3000;
  static const int toastDuration = 2000;
  static const int debounceDelay = 500;
  static const int autoLogoutMinutes = 30;

  static const int morningNotificationHour = 8;
  static const int afternoonNotificationHour = 14;
  static const int eveningNotificationHour = 20;
  static const int nightNotificationHour = 22;

  static const int defaultReminderMinutesBefore = 15;
  static const int maxRemindersPerMedicine = 5;

  static const int chartRangeWeek = 7;
  static const int chartRangeMonth = 30;
  static const int chartRange3Months = 90;
  static const int chartRangeYear = 365;
}
class MedicalConstants {
  MedicalConstants._();

  static const String frequencyOnce = 'once';
  static const String frequencyDaily = 'daily';
  static const String frequencyTwiceDaily = 'twice_daily';
  static const String frequencyThreeTimesDaily = 'three_times_daily';
  static const String frequencyFourTimesDaily = 'four_times_daily';
  static const String frequencyWeekly = 'weekly';
  static const String frequencyAsNeeded = 'as_needed';

  static const String formTablet = 'tablet';
  static const String formCapsule = 'capsule';
  static const String formSyrup = 'syrup';
  static const String formInjection = 'injection';
  static const String formDrop = 'drop';
  static const String formCream = 'cream';
  static const String formInhaler = 'inhaler';
  static const String formPatch = 'patch';

  static const String readingTypeBloodPressure = 'blood_pressure';
  static const String readingTypeBloodSugar = 'blood_sugar';
  static const String readingTypeWeight = 'weight';
  static const String readingTypeTemperature = 'temperature';
  static const String readingTypeHeartRate = 'heart_rate';
  static const String readingTypeOxygenSaturation = 'oxygen_saturation';

  static const String bpNormal = 'normal';
  static const String bpElevated = 'elevated';
  static const String bpHypertensionStage1 = 'hypertension_stage_1';
  static const String bpHypertensionStage2 = 'hypertension_stage_2';
  static const String bpHypertensiveCrisis = 'hypertensive_crisis';

  static const double bloodSugarLowThreshold = 70.0;
  static const double bloodSugarNormalMin = 70.0;
  static const double bloodSugarNormalMax = 140.0;
  static const double bloodSugarHighThreshold = 180.0;
  static const double bloodSugarCriticalHigh = 250.0;

  static const int systolicNormalMax = 120;
  static const int systolicElevatedMax = 129;
  static const int systolicStage1Max = 139;
  static const int systolicStage2Max = 180;
  static const int diastolicNormalMax = 80;
  static const int diastolicStage1Max = 89;
  static const int diastolicStage2Max = 120;

  static const double temperatureNormalMin = 36.1;
  static const double temperatureNormalMax = 37.2;
  static const double temperatureFeverThreshold = 38.0;
  static const double temperatureHighFever = 39.5;

  static const double bmiUnderweight = 18.5;
  static const double bmiNormalWeight = 24.9;
  static const double bmiOverweight = 29.9;
  static const double bmiObese = 30.0;

  static const String rolePatient = 'patient';
  static const String roleDoctor = 'doctor';
  static const String roleAdmin = 'admin';

  static const String appointmentPending = 'pending';
  static const String appointmentConfirmed = 'confirmed';
  static const String appointmentCompleted = 'completed';
  static const String appointmentCancelled = 'cancelled';

  static const List<String> doctorSpecialties = [
    'General Practitioner',
    'Cardiologist',
    'Dermatologist',
    'Endocrinologist',
    'Gastroenterologist',
    'Neurologist',
    'Ophthalmologist',
    'Orthopedist',
    'Pediatrician',
    'Psychiatrist',
    'Pulmonologist',
    'Urologist',
  ];

  static const List<String> bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];
}
class NotificationConstants {
  NotificationConstants._();

  static const int medicineReminderIdStart = 1000;
  static const int appointmentReminderId = 2000;
  static const int healthCheckReminderId = 3000;
  static const int generalNotificationId = 9999;

  static const String channelIdMedicine = 'medicine_reminders';
  static const String channelNameMedicine = 'Medicine Reminders';
  static const String channelDescriptionMedicine = 'Reminders to take your medicines';

  static const String channelIdAppointment = 'appointments';
  static const String channelNameAppointment = 'Appointments';
  static const String channelDescriptionAppointment = 'Doctor appointment reminders';

  static const String channelIdHealth = 'health_checks';
  static const String channelNameHealth = 'Health Checks';
  static const String channelDescriptionHealth = 'Health monitoring reminders';

  static const String channelIdGeneral = 'general';
  static const String channelNameGeneral = 'General Notifications';
  static const String channelDescriptionGeneral = 'General app notifications';

  static const String actionTaken = 'taken';
  static const String actionSkip = 'skip';
  static const String actionSnooze = 'snooze';
  static const String actionView = 'view';

  static const int snoozeDuration = 15;

  static const bool defaultSound = true;
  static const bool defaultVibration = true;
  static const String soundFileName = 'notification_sound.mp3';
}
class UIConstants {
  UIConstants._();

  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  static const double paddingXs = 4.0;
  static const double paddingSm = 8.0;
  static const double paddingMd = 16.0;
  static const double paddingLg = 24.0;
  static const double paddingXl = 32.0;

  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusPill = 999.0;

  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightMedium = 48.0;
  static const double buttonHeightLarge = 56.0;
  static const double buttonMinWidth = 88.0;

  static const double cardElevation = 2.0;
  static const double cardBorderRadius = 12.0;
  static const double cardPadding = 16.0;

  static const double avatarSmall = 32.0;
  static const double avatarMedium = 48.0;
  static const double avatarLarge = 64.0;
  static const double avatarXLarge = 96.0;

  static const double dividerThickness = 1.0;
  static const double dividerIndent = 16.0;

  static const double appBarHeight = 56.0;
  static const double appBarElevation = 0.0;

  static const double bottomNavHeight = 60.0;
  static const double bottomNavIconSize = 24.0;

  static const double listItemHeight = 72.0;
  static const double listItemMinHeight = 48.0;

  static const double fabSize = 56.0;
  static const double fabMiniSize = 40.0;

  static const double dialogMaxWidth = 560.0;
  static const double dialogBorderRadius = 28.0;

  static const double bottomSheetMaxHeight = 0.9;
  static const double bottomSheetBorderRadius = 28.0;

  static const double chartHeightSmall = 200.0;
  static const double chartHeightMedium = 250.0;
  static const double chartHeightLarge = 300.0;
}
class RegexPatterns {
  RegexPatterns._();

  static const String email = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';

  static const String password = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';

  static const String phone = r'^\+?[1-9]\d{1,14}$';
  static const String phoneEgypt = r'^(01)[0-9]{9}$';

  static const String name = r'^[a-zA-Z\u0621-\u064A\s\-]+$';

  static const String numbersOnly = r'^[0-9]+$';

  static const String decimal = r'^\d+\.?\d*$';

  static const String url = r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$';

  static const String date = r'^\d{4}-\d{2}-\d{2}$';

  static const String time = r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$';
}
class ErrorMessages {
  ErrorMessages._();

  static const String noInternetConnection = 'لا يوجد اتصال بالإنترنت';
  static const String connectionTimeout = 'انتهت مهلة الاتصال';
  static const String serverError = 'حدث خطأ في الخادم';
  static const String requestCancelled = 'تم إلغاء الطلب';

  static const String invalidCredentials = 'بيانات الدخول غير صحيحة';
  static const String emailAlreadyExists = 'البريد الإلكتروني مسجل مسبقاً';
  static const String weakPassword = 'كلمة المرور ضعيفة';
  static const String userNotFound = 'المستخدم غير موجود';
  static const String accountDisabled = 'الحساب معطل';
  static const String tooManyRequests = 'محاولات كثيرة، يرجى المحاولة لاحقاً';

  static const String fieldRequired = 'هذا الحقل مطلوب';
  static const String invalidEmail = 'البريد الإلكتروني غير صحيح';
  static const String invalidPhone = 'رقم الهاتف غير صحيح';
  static const String passwordTooShort = 'كلمة المرور قصيرة جداً';
  static const String passwordsNotMatch = 'كلمات المرور غير متطابقة';
  static const String invalidDate = 'التاريخ غير صحيح';
  static const String invalidTime = 'الوقت غير صحيح';

  static const String medicineNotFound = 'الدواء غير موجود';
  static const String duplicateMedicine = 'الدواء مضاف مسبقاً';
  static const String invalidDosage = 'الجرعة غير صحيحة';
  static const String invalidFrequency = 'التكرار غير صحيح';

  static const String invalidReading = 'القراءة غير صحيحة';
  static const String readingOutOfRange = 'القراءة خارج النطاق الطبيعي';
  static const String duplicateReading = 'القراءة مسجلة مسبقاً';

  static const String fileTooLarge = 'حجم الملف كبير جداً';
  static const String invalidFileType = 'نوع الملف غير مدعوم';
  static const String uploadFailed = 'فشل رفع الملف';

  static const String permissionDenied = 'تم رفض الإذن';
  static const String cameraPermissionRequired = 'يتطلب إذن الكاميرا';
  static const String storagePermissionRequired = 'يتطلب إذن التخزين';
  static const String locationPermissionRequired = 'يتطلب إذن الموقع';

  static const String unknownError = 'حدث خطأ غير متوقع';
  static const String operationFailed = 'فشلت العملية';
  static const String dataNotFound = 'البيانات غير موجودة';
  static const String updateFailed = 'فشل التحديث';
  static const String deleteFailed = 'فشل الحذف';
}
class SuccessMessages {
  SuccessMessages._();

  static const String loginSuccess = 'تم تسجيل الدخول بنجاح';
  static const String registerSuccess = 'تم التسجيل بنجاح';
  static const String logoutSuccess = 'تم تسجيل الخروج بنجاح';
  static const String passwordResetSent = 'تم إرسال رابط إعادة تعيين كلمة المرور';
  static const String passwordChanged = 'تم تغيير كلمة المرور بنجاح';

  static const String medicineAdded = 'تم إضافة الدواء بنجاح';
  static const String medicineUpdated = 'تم تحديث الدواء بنجاح';
  static const String medicineDeleted = 'تم حذف الدواء بنجاح';
  static const String medicineTaken = 'تم تسجيل تناول الدواء';

  static const String readingAdded = 'تم إضافة القراءة بنجاح';
  static const String readingUpdated = 'تم تحديث القراءة بنجاح';
  static const String readingDeleted = 'تم حذف القراءة بنجاح';

  static const String profileUpdated = 'تم تحديث الملف الشخصي بنجاح';
  static const String photoUpdated = 'تم تحديث الصورة بنجاح';

  static const String operationSuccess = 'تمت العملية بنجاح';
  static const String dataSaved = 'تم حفظ البيانات بنجاح';
  static const String dataDeleted = 'تم حذف البيانات بنجاح';
}
class DefaultValues {
  DefaultValues._();

  static const String defaultLanguage = 'ar';
  static const String defaultThemeMode = 'light';
  static const bool defaultNotificationsEnabled = true;
  static const bool defaultBiometricEnabled = false;

  static const String defaultFrequency = MedicalConstants.frequencyDaily;
  static const int defaultTimesPerDay = 1;
  static const String defaultForm = MedicalConstants.formTablet;
  static const bool defaultWithFood = false;
  static const bool defaultIsCritical = false;

  static const int defaultChartRange = TimeConstants.chartRangeWeek;
  static const bool defaultShowGrid = true;
  static const bool defaultShowTooltip = true;

  static const int defaultPageSize = 20;
  static const int defaultPage = 1;

  static const String defaultAvatarUrl = 'https://via.placeholder.com/150';
  static const String placeholderImageUrl = 'https://via.placeholder.com/300';
  static const String defaultMedicineImageUrl = 'assets/images/default_medicine.png';
}