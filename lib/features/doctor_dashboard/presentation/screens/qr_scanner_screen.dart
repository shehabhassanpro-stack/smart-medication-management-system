import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/design_tokens.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../core/services/doctor_patient_service.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> with SingleTickerProviderStateMixin {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal, // Normal speed for multi-scan validation
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  
  late final DoctorPatientService _doctorPatientService;
  late final AnimationController _scanAnimationController;
  
  bool _isProcessing = false;
  
  // Enterprise QR Validation: require multiple consistent reads (like WhatsApp)
  // This prevents partial/accidental scans from triggering the flow.
  String? _lastScannedValue;
  int _scanConfirmCount = 0;
  static const int _requiredScans = 3; // Must see same QR 3 times before accepting

  @override
  void initState() {
    super.initState();
    _doctorPatientService = DoctorPatientService();
    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    _scanAnimationController.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    // Enterprise Multi-Scan Validation:
    // The same QR must be read _requiredScans times consecutively.
    // This ensures the QR is fully in frame and stable (like WhatsApp).
    if (rawValue == _lastScannedValue) {
      _scanConfirmCount++;
    } else {
      _lastScannedValue = rawValue;
      _scanConfirmCount = 1;
    }
    
    if (_scanConfirmCount < _requiredScans) {
      return; // Not enough consistent reads yet
    }
    
    // Reset for next scan session
    _scanConfirmCount = 0;
    _lastScannedValue = null;

    HapticFeedback.heavyImpact();
    setState(() {
      _isProcessing = true;
    });

    try {
      // Decode URI Component (same logic used in generating QR)
      final decodedData = Uri.decodeComponent(rawValue);
      final parts = decodedData.split('|');
      
      debugPrint('📷 QR decoded: ${parts.length} parts, type=${parts.length >= 4 ? parts[3] : "unknown"}');

      if (parts.length >= 4 && parts[3] == 'patient') {
        final patientId = parts[0];
        final patientName = parts[1];
        final expTimestamp = int.tryParse(parts[2]) ?? 0;

        // Check if expired
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now > expTimestamp) {
          if (mounted) setState(() => _isProcessing = false);
          _showError('هذا الكود منتهي الصلاحية. يرجى طلب كود جديد.');
          return;
        }

        debugPrint('📷 QR valid: patient=$patientName, id=$patientId');
        // Show confirmation dialog before linking.
        // _isProcessing stays TRUE here — dialog manages the lifecycle.
        _showConfirmationDialog(patientId, patientName);
      } else {
        if (mounted) setState(() => _isProcessing = false);
        _showError('رمز QR غير صالح لمعلومات المريض');
      }
    } catch (e) {
      debugPrint('❌ QR decode error: $e');
      if (mounted) setState(() => _isProcessing = false);
      _showError('حدث خطأ في قراءة الرمز');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
     // Delay before re-enabling scanning to prevent spamming
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) controller.start();
    });
  }

  void _showConfirmationDialog(String patientId, String patientName) {
    final authProvider = context.read<AuthProvider>();
    final doctorId = authProvider.userModel?.uid;

    if (doctorId == null) {
      _showError('\u063a\u064a\u0631 \u0645\u0635\u0631\u062d \u0644\u0643 \u0628\u0627\u0644\u0642\u064a\u0627\u0645 \u0628\u0647\u0630\u0647 \u0627\u0644\u0639\u0645\u0644\u064a\u0629');
      return;
    }

    controller.stop();
    
    // CRITICAL: Capture the SCANNER SCREEN's context BEFORE opening the bottom sheet.
    // The `builder: (context)` in showModalBottomSheet SHADOWS this variable
    // with the sheet's own BuildContext, which dies after the sheet is popped.
    final scannerContext = context;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _ConfirmationBottomSheet(
        patientName: patientName,
        onConfirm: () async {
          Navigator.pop(sheetContext); // close sheet using SHEET's context
          setState(() => _isProcessing = true);
          
          debugPrint('\u{1F517} Linking patient $patientId to doctor $doctorId...');
          final (success, message) = await _doctorPatientService.linkPatient(
            doctorId: doctorId,
            patientId: patientId,
            patientName: patientName,
          );
          debugPrint('\u{1F517} Link result: success=$success, message=$message');

          if (!mounted) return;
          setState(() => _isProcessing = false);

          // Use the SCANNER SCREEN's context for UI actions after sheet is closed
          ScaffoldMessenger.of(scannerContext).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: success ? AppColors.success : AppColors.warning,
              behavior: SnackBarBehavior.floating,
            ),
          );

          if (success) {
            Navigator.pop(scannerContext); // close scanner using SCANNER's context
          } else {
            controller.start(); // resume scanning
          }
        },
        onCancel: () {
          Navigator.pop(sheetContext);
          controller.start(); // resume scanning
          setState(() => _isProcessing = false);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera View
          MobileScanner(
            controller: controller,
            onDetect: _handleBarcode,
          ),
          
          // Overlay UI
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: tokens.screenPadding,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: tokens.borderRadiusMedium,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: tokens.borderRadiusMedium,
                        ),
                        child: IconButton(
                          icon: ValueListenableBuilder(
                            valueListenable: controller.torchState,
                            builder: (context, state, child) {
                              switch (state) {
                                case TorchState.off:
                                  return const Icon(Icons.flash_off_rounded, color: Colors.white);
                                case TorchState.on:
                                  return const Icon(Icons.flash_on_rounded, color: Colors.amber);
                              }
                            },
                          ),
                          onPressed: () => controller.toggleTorch(),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Scanner Frame Overlay
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.width * 0.7,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary, width: 2),
                        borderRadius: tokens.borderRadiusLarge,
                      ),
                    ),
                    // Scan Line Animation
                    AnimatedBuilder(
                      animation: _scanAnimationController,
                      builder: (context, child) {
                        return Positioned(
                          top: (MediaQuery.of(context).size.width * 0.7) * _scanAnimationController.value,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.65,
                            height: 3,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // Instructions Footer
                Container(
                  padding: EdgeInsets.all(tokens.paddingXLarge),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Colors.white,
                        size: tokens.responsive.scale(40),
                      ),
                      tokens.spacerMedium,
                      Text(
                        'امسح كود المريض',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: tokens.fontHeadline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      tokens.spacerSmall,
                      Text(
                        'قم بتوجيه الكاميرا نحو رمز QR الخاص بالمريض من جهازه لربط ملفه الصحي.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: tokens.fontBody,
                        ),
                      ),
                      tokens.spacerLarge,
                      if (_isProcessing)
                        const CircularProgressIndicator(color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmationBottomSheet extends StatelessWidget {
  final String patientName;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _ConfirmationBottomSheet({
    required this.patientName,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: tokens.screenPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(tokens.radiusXL),
          topRight: Radius.circular(tokens.radiusXL),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          tokens.spacerMedium,
          Container(
            padding: tokens.paddingAllMedium,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.link_rounded,
              size: tokens.iconLarge,
              color: AppColors.primary,
            ),
          ),
          tokens.spacerMedium,
          Text(
            'تأكيد ربط المريض',
            style: TextStyle(
              fontSize: tokens.fontHeadline,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          tokens.spacerSmall,
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: tokens.fontBody,
                color: AppColors.textSecondary,
                fontFamily: 'Cairo',
              ),
              children: [
                const TextSpan(text: 'هل أنت متأكد من رغبتك في ربط ملف المريض\n'),
                TextSpan(
                  text: patientName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const TextSpan(text: ' بحسابك؟'),
              ],
            ),
          ),
          tokens.spacerXLarge,
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: tokens.paddingMedium),
                    side: BorderSide(color: AppColors.textSecondary),
                    shape: RoundedRectangleBorder(
                      borderRadius: tokens.borderRadiusMedium,
                    ),
                  ),
                  child: Text(
                    'إلغاء',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              tokens.spacerMedium,
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: tokens.paddingMedium),
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: tokens.borderRadiusMedium,
                    ),
                  ),
                  child: const Text(
                    'تأكيد الربط',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          tokens.spacerXLarge,
          tokens.spacerLarge,
        ],
      ),
    );
  }
}
