// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Medical Care';

  @override
  String get appTagline => 'Your Health, Our Priority';

  @override
  String get common_save => 'Save';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_edit => 'Edit';

  @override
  String get common_done => 'Done';

  @override
  String get common_close => 'Close';

  @override
  String get common_back => 'Back';

  @override
  String get common_next => 'Next';

  @override
  String get common_confirm => 'Confirm';

  @override
  String get common_retry => 'Retry';

  @override
  String get common_loading => 'Loading...';

  @override
  String get common_error => 'An error occurred';

  @override
  String get common_success => 'Success';

  @override
  String get common_noData => 'No data available';

  @override
  String get common_search => 'Search';

  @override
  String get common_viewAll => 'View All';

  @override
  String get common_viewMore => 'View More';

  @override
  String get common_showAll => 'Show All';

  @override
  String get common_processing => 'Processing...';

  @override
  String get common_yes => 'Yes';

  @override
  String get common_no => 'No';

  @override
  String get common_ok => 'OK';

  @override
  String get common_logout => 'Logout';

  @override
  String get common_logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get common_logoutTitle => 'Logout';

  @override
  String get common_today => 'Today';

  @override
  String get common_yesterday => 'Yesterday';

  @override
  String common_daysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get common_normal => 'Normal';

  @override
  String get common_high => 'High';

  @override
  String get common_low => 'Low';

  @override
  String get common_critical => 'Critical';

  @override
  String get common_warning => 'Warning';

  @override
  String get nav_home => 'Home';

  @override
  String get nav_medicines => 'Medicines';

  @override
  String get nav_readings => 'Readings';

  @override
  String get nav_profile => 'Profile';

  @override
  String get nav_patients => 'Patients';

  @override
  String get nav_reports => 'Reports';

  @override
  String get nav_homeSemantics => 'Home Page';

  @override
  String get nav_medicinesSemantics => 'Medicines List';

  @override
  String get nav_readingsSemantics => 'Health Readings';

  @override
  String get nav_profileSemantics => 'Profile & Settings';

  @override
  String get nav_doctorHomeSemantics => 'Doctor Home Page';

  @override
  String get nav_patientsSemantics => 'Patients List';

  @override
  String get nav_reportsSemantics => 'Reports & Statistics';

  @override
  String get greeting_morning => 'Good Morning';

  @override
  String get greeting_afternoon => 'Good Afternoon';

  @override
  String get greeting_evening => 'Good Evening';

  @override
  String get greeting_night => 'Good Evening';

  @override
  String get greeting_tip1 => 'Start your day with energy! 💪';

  @override
  String get greeting_tip2 => 'Your health is a priority, take care today';

  @override
  String get greeting_tip3 => 'New day, new chance for health';

  @override
  String get greeting_waterTip => 'Don\'t forget to drink water! 💧';

  @override
  String get greeting_breakTip => 'Take a short break to refresh';

  @override
  String get health_status => 'Health Status';

  @override
  String get health_dailySummary => 'Updated daily summary';

  @override
  String get health_needsFollowUp => 'Needs follow-up';

  @override
  String get health_bloodPressure => 'Blood Pressure';

  @override
  String get health_bloodSugar => 'Blood Sugar';

  @override
  String get health_weight => 'Weight';

  @override
  String get health_temperature => 'Temperature';

  @override
  String get health_heartRate => 'Heart Rate';

  @override
  String get health_oxygen => 'Oxygen';

  @override
  String get health_addReading => 'Add Reading';

  @override
  String get health_addReadingSubtitle => 'Record a new reading';

  @override
  String get health_noReadings => 'No readings available';

  @override
  String get health_readingAdded => 'Reading added successfully';

  @override
  String get health_readingDeleted => 'Reading deleted';

  @override
  String get health_value => 'Value';

  @override
  String get health_unit => 'Unit';

  @override
  String get health_date => 'Date';

  @override
  String get health_time => 'Time';

  @override
  String get health_notes => 'Notes';

  @override
  String get health_systolic => 'Systolic';

  @override
  String get health_diastolic => 'Diastolic';

  @override
  String get health_chart => 'Chart';

  @override
  String get health_table => 'Table';

  @override
  String get health_exportFeature => 'Export feature coming soon';

  @override
  String get health_weeklySummary => 'Weekly Summary';

  @override
  String get quickActions_title => 'Quick Actions';

  @override
  String get quickActions_addReading => 'Add Reading';

  @override
  String get quickActions_addReadingSubtitle => 'Record a new reading';

  @override
  String get quickActions_medicines => 'Medicines';

  @override
  String get quickActions_medicinesSubtitle => 'Manage your medicines';

  @override
  String quickActions_medicinesCount(int count) {
    return '$count medicines';
  }

  @override
  String get quickActions_statistics => 'Statistics';

  @override
  String get quickActions_statisticsSubtitle => 'Analyze your data';

  @override
  String get quickActions_history => 'History';

  @override
  String get quickActions_historySubtitle => 'Your health record';

  @override
  String quickActions_readingsCount(int count) {
    return '$count readings';
  }

  @override
  String get todayMeds_title => 'Today\'s Medicines';

  @override
  String get todayMeds_noMeds => 'No scheduled medicines';

  @override
  String get todayMeds_addPrompt =>
      'Add your medicines to track schedules and receive reminders';

  @override
  String get todayMeds_taken => 'Taken';

  @override
  String get todayMeds_skip => 'Skip';

  @override
  String get todayMeds_later => 'Later';

  @override
  String get todayMeds_statusUpcoming => 'Upcoming';

  @override
  String get todayMeds_statusDue => 'Due Now';

  @override
  String get todayMeds_statusOverdue => 'Take Now';

  @override
  String get todayMeds_statusTaken => 'Taken';

  @override
  String get todayMeds_statusSkipped => 'Skipped';

  @override
  String get todayMeds_statusSnoozed => 'Snoozed';

  @override
  String get todayMeds_statusMissed => 'Missed';

  @override
  String get weeklyProgress_medicines => 'Medicines';

  @override
  String get weeklyProgress_readings => 'Readings';

  @override
  String get weeklyProgress_adherence => 'Adherence';

  @override
  String get weeklyProgress_sat => 'Sat';

  @override
  String get weeklyProgress_sun => 'Sun';

  @override
  String get weeklyProgress_mon => 'Mon';

  @override
  String get weeklyProgress_tue => 'Tue';

  @override
  String get weeklyProgress_wed => 'Wed';

  @override
  String get weeklyProgress_thu => 'Thu';

  @override
  String get weeklyProgress_fri => 'Fri';

  @override
  String get medicines_title => 'Medicines';

  @override
  String get medicines_addMedicine => 'Add Medicine';

  @override
  String get medicines_medicineName => 'Medicine Name';

  @override
  String get medicines_dosage => 'Dosage';

  @override
  String get medicines_frequency => 'Frequency';

  @override
  String get medicines_startDate => 'Start Date';

  @override
  String get medicines_endDate => 'End Date';

  @override
  String get medicines_times => 'Dose Times';

  @override
  String get medicines_instructions => 'Instructions';

  @override
  String get medicines_active => 'Active';

  @override
  String get medicines_inactive => 'Inactive';

  @override
  String get medicines_all => 'All';

  @override
  String get medicines_critical => 'Critical';

  @override
  String get medicines_noMedicines => 'No medicines';

  @override
  String get medicines_addMedicinePrompt =>
      'Add a new medicine to track your schedule';

  @override
  String get medicines_deleteConfirm =>
      'Are you sure you want to delete this medicine?';

  @override
  String get medicines_deleteSuccess => 'Medicine deleted successfully';

  @override
  String get medicines_addSuccess => 'Medicine added successfully';

  @override
  String get medicines_editSuccess => 'Medicine updated successfully';

  @override
  String get medicines_searchHint => 'Search for a medicine...';

  @override
  String get medicines_stats => 'Statistics';

  @override
  String get medicines_adherenceRate => 'Adherence Rate';

  @override
  String get medicines_totalDoses => 'Total Doses';

  @override
  String get medicines_takenDoses => 'Taken Doses';

  @override
  String get medicines_missedDoses => 'Missed Doses';

  @override
  String get medicines_daily => 'Daily';

  @override
  String get medicines_weekly => 'Weekly';

  @override
  String get medicines_monthly => 'Monthly';

  @override
  String get medicines_asNeeded => 'As Needed';

  @override
  String get medicines_beforeFood => 'Before Food';

  @override
  String get medicines_afterFood => 'After Food';

  @override
  String get medicines_withFood => 'With Food';

  @override
  String get medicines_noInstructions => 'No instructions';

  @override
  String get profile_title => 'Profile';

  @override
  String get profile_editProfile => 'Edit Profile';

  @override
  String get profile_changePassword => 'Change Password';

  @override
  String get profile_notifications => 'Notification Settings';

  @override
  String get profile_appSettings => 'App Preferences';

  @override
  String get profile_qrCode => 'Your QR Code';

  @override
  String get profile_helpSupport => 'Help & Support';

  @override
  String get profile_about => 'About App';

  @override
  String get profile_logoutButton => 'Logout';

  @override
  String get profile_name => 'Name';

  @override
  String get profile_email => 'Email';

  @override
  String get profile_phone => 'Phone Number';

  @override
  String get profile_age => 'Age';

  @override
  String get profile_gender => 'Gender';

  @override
  String get profile_male => 'Male';

  @override
  String get profile_female => 'Female';

  @override
  String get profile_bloodType => 'Blood Type';

  @override
  String get profile_height => 'Height';

  @override
  String get profile_weight => 'Weight';

  @override
  String get profile_updateSuccess => 'Profile updated successfully';

  @override
  String get profile_currentPassword => 'Current Password';

  @override
  String get profile_newPassword => 'New Password';

  @override
  String get profile_confirmPassword => 'Confirm New Password';

  @override
  String get profile_passwordChanged => 'Password changed successfully';

  @override
  String get profile_passwordMismatch => 'Passwords do not match';

  @override
  String get settings_title => 'App Preferences';

  @override
  String get settings_subtitle => 'Customize your experience';

  @override
  String get settings_appearance => 'Appearance';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_theme => 'Theme';

  @override
  String get settings_themeLight => 'Light';

  @override
  String get settings_themeDark => 'Dark';

  @override
  String get settings_themeSystem => 'Auto';

  @override
  String get settings_langArabic => 'العربية';

  @override
  String get settings_langEnglish => 'English';

  @override
  String get settings_measurementUnits => 'Measurement Units';

  @override
  String get settings_weightUnit => 'Weight Unit';

  @override
  String get settings_heightUnit => 'Height Unit';

  @override
  String get settings_temperatureUnit => 'Temperature Unit';

  @override
  String get settings_glucoseUnit => 'Blood Glucose Unit';

  @override
  String get settings_data => 'Data';

  @override
  String get settings_clearCache => 'Clear Cache';

  @override
  String get settings_clearCacheSubtitle => 'Delete temporary stored data';

  @override
  String get settings_clearCacheConfirm =>
      'Temporary data will be deleted. This will not affect your saved data.';

  @override
  String get settings_cacheCleared => 'Cache cleared successfully';

  @override
  String get settings_kgUnit => 'Kilogram (kg)';

  @override
  String get settings_lbUnit => 'Pound (lb)';

  @override
  String get settings_cmUnit => 'Centimeter (cm)';

  @override
  String get settings_ftUnit => 'Feet/Inches (ft/in)';

  @override
  String get settings_celsiusUnit => 'Celsius (°C)';

  @override
  String get settings_fahrenheitUnit => 'Fahrenheit (°F)';

  @override
  String get notifications_title => 'Notifications';

  @override
  String get notifications_noNotifications => 'No notifications';

  @override
  String get notifications_markAllRead => 'Mark All Read';

  @override
  String get notifications_medicineReminder => 'Medicine Reminder';

  @override
  String get notifications_healthAlert => 'Health Alert';

  @override
  String get notifications_settings => 'Notification Settings';

  @override
  String get notifications_enableAll => 'Enable Notifications';

  @override
  String get notifications_sound => 'Sound';

  @override
  String get notifications_vibration => 'Vibration';

  @override
  String get notifications_medicineNotifications => 'Medicine Notifications';

  @override
  String get notifications_healthNotifications => 'Health Notifications';

  @override
  String get auth_login => 'Login';

  @override
  String get auth_register => 'Create Account';

  @override
  String get auth_email => 'Email';

  @override
  String get auth_password => 'Password';

  @override
  String get auth_forgotPassword => 'Forgot Password?';

  @override
  String get auth_noAccount => 'Don\'t have an account?';

  @override
  String get auth_hasAccount => 'Already have an account?';

  @override
  String get auth_loginButton => 'Sign In';

  @override
  String get auth_registerButton => 'Sign Up';

  @override
  String get auth_fullName => 'Full Name';

  @override
  String get auth_confirmPassword => 'Confirm Password';

  @override
  String get auth_rememberMe => 'Remember Me';

  @override
  String get auth_welcomeTitle => 'Welcome';

  @override
  String get auth_welcomeSubtitle => 'Sign in to access your health record';

  @override
  String get auth_verifyEmail => 'Email Verification';

  @override
  String get auth_verifyEmailSent =>
      'A verification link has been sent to your email';

  @override
  String get auth_resendEmail => 'Resend';

  @override
  String get auth_patient => 'Patient';

  @override
  String get auth_doctor => 'Doctor';

  @override
  String get auth_selectRole => 'Select Account Type';

  @override
  String get doctor_home_title => 'Dashboard';

  @override
  String get doctor_myPatients => 'Patients';

  @override
  String get doctor_totalPatients => 'Total Patients';

  @override
  String get doctor_activeMedicines => 'Active Prescriptions';

  @override
  String get doctor_scanQr => 'Scan QR Code';

  @override
  String get doctor_scanQrSubtitle => 'Link a new patient';

  @override
  String get doctor_patientLinked => 'Patient linked successfully';

  @override
  String get doctor_patientNotFound => 'Patient not found';

  @override
  String get doctor_noPatients => 'No linked patients';

  @override
  String get doctor_addPatientPrompt =>
      'Scan a patient\'s QR code to link them';

  @override
  String get doctor_patientDetails => 'Patient Details';

  @override
  String get doctor_healthReadings => 'Health Readings';

  @override
  String get doctor_medicines => 'Medicines';

  @override
  String get doctor_adherence => 'Adherence';

  @override
  String get doctor_unlinkPatient => 'Unlink Patient';

  @override
  String get doctor_unlinkConfirm =>
      'Are you sure you want to unlink this patient?';

  @override
  String get doctor_searchPatients => 'Search patients...';

  @override
  String get reports_title => 'Reports';

  @override
  String get reports_period7d => '7 Days';

  @override
  String get reports_period30d => '30 Days';

  @override
  String get reports_period90d => '90 Days';

  @override
  String get reports_kpiPatients => 'Patients';

  @override
  String get reports_kpiPrescriptions => 'Prescriptions';

  @override
  String get reports_kpiAdherence => 'Avg Adherence';

  @override
  String get reports_kpiAlerts => 'Alerts';

  @override
  String get reports_criticalAlerts => 'Critical Alerts';

  @override
  String get reports_noCriticalAlerts => 'No critical alerts';

  @override
  String get reports_adherenceRanking => 'Adherence Ranking';

  @override
  String get reports_noAdherenceData => 'No adherence data';

  @override
  String get reports_noData => 'No data available';

  @override
  String get reports_loadError => 'Failed to load reports';

  @override
  String get reports_highSugar => 'Very High Sugar';

  @override
  String get reports_lowSugar => 'Very Low Sugar';

  @override
  String get reports_highSugarWarning => 'High Sugar';

  @override
  String get reports_highBP => 'Very High BP';

  @override
  String get reports_highBPWarning => 'High BP';

  @override
  String get reports_highTemp => 'High Temperature';

  @override
  String get reports_patient => 'patient';

  @override
  String get reports_noMedicines => 'No medicines';

  @override
  String get dailyTip_title => 'Daily Tip';

  @override
  String get units_mgdl => 'mg/dL';

  @override
  String get units_mmhg => 'mmHg';

  @override
  String get units_kg => 'kg';

  @override
  String get units_celsius => '°C';

  @override
  String get units_bpm => 'bpm';

  @override
  String get period_days => 'Days';

  @override
  String get period_weeks => 'Weeks';

  @override
  String get period_months => 'Months';

  @override
  String get period_7days => '7 Days';

  @override
  String get period_30days => '30 Days';

  @override
  String get period_90days => '90 Days';

  @override
  String get period_all => 'All';
}
