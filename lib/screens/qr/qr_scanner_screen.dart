import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// ═══════════════════════════════════════════════════════════════
/// 📷 QR CODE SCANNER SCREEN - Modern Implementation
/// ═══════════════════════════════════════════════════════════════
/// المسار الصحيح: lib/screens/qr/qr_scanner_screen.dart
///
/// Features:
/// ✅ Modern mobile_scanner package (actively maintained)
/// ✅ Works with latest Gradle & Android versions
/// ✅ Better performance than qr_code_scanner
/// ✅ QR & Barcode support
/// ✅ Flash toggle
/// ✅ Camera switch (front/back)
/// ✅ Medical Blue design system
/// ✅ Beautiful scanning overlay with corners
/// ✅ Arabic RTL support
/// ✅ Production ready
/// ═══════════════════════════════════════════════════════════════

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  // ═══════════════════════════════════════════════════════════════
  // 🎯 STATE & CONTROLLERS
  // ═══════════════════════════════════════════════════════════════
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isScanning = true;
  String? _scannedCode;

  // ═══════════════════════════════════════════════════════════════
  // 🎨 MEDICAL BLUE COLORS
  // ═══════════════════════════════════════════════════════════════
  static const Color _primaryBlue = Color(0xFF1976D2); // Blue 700
  static const Color _darkBlue = Color(0xFF0D47A1); // Blue 900
  static const Color _accentBlue = Color(0xFF2196F3); // Blue 500

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════
  // 📷 HANDLE QR CODE DETECTION
  // ═══════════════════════════════════════════════════════════════
  void _handleBarcodeDetection(BarcodeCapture barcodeCapture) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = barcodeCapture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() {
      _isScanning = false;
      _scannedCode = code;
    });

    // Vibrate on success (optional)
    // HapticFeedback.mediumImpact();

    // Show success message
    _showSuccessSnackBar('تم مسح الكود بنجاح! ✓');

    // Return the scanned code to previous screen after short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pop(context, code);
      }
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔦 TOGGLE FLASH
  // ═══════════════════════════════════════════════════════════════
  void _toggleFlash() {
    _controller.toggleTorch();
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔄 SWITCH CAMERA
  // ═══════════════════════════════════════════════════════════════
  void _switchCamera() {
    _controller.switchCamera();
  }

  // ═══════════════════════════════════════════════════════════════
  // 💬 UI HELPERS
  // ═══════════════════════════════════════════════════════════════
  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🎨 BUILD UI
  // ═══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'مسح رمز QR',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'رجوع',
        ),
        actions: [
          // Flash Toggle
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.amber);
                }
              },
            ),
            onPressed: _toggleFlash,
            tooltip: 'الفلاش',
          ),
          // Camera Switch
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: _switchCamera,
            tooltip: 'تبديل الكاميرا',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Camera View
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcodeDetection,
            errorBuilder: (context, error, child) {
              return _buildErrorView(error);
            },
          ),

          // Scanning Overlay
          _buildScanningOverlay(),

          // Instructions
          _buildInstructions(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🎯 SCANNING OVERLAY WITH CORNERS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildScanningOverlay() {
    return CustomPaint(
      painter: ScannerOverlayPainter(),
      child: const SizedBox.expand(),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 📝 INSTRUCTIONS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildInstructions() {
    return Positioned(
      bottom: 60,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _accentBlue.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.qr_code_scanner,
              color: _accentBlue,
              size: 40,
            ),
            const SizedBox(height: 12),
            const Text(
              'وجّه الكاميرا نحو رمز QR',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'سيتم المسح تلقائياً',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ❌ ERROR VIEW
  // ═══════════════════════════════════════════════════════════════
  Widget _buildErrorView(MobileScannerException error) {
    String errorMessage = 'حدث خطأ في الكاميرا';
    IconData errorIcon = Icons.error_outline;

    switch (error.errorCode) {
      case MobileScannerErrorCode.permissionDenied:
        errorMessage = 'لم يتم منح إذن الكاميرا\nالرجاء تفعيل الإذن من الإعدادات';
        errorIcon = Icons.no_photography_outlined;
        break;
      case MobileScannerErrorCode.unsupported:
        errorMessage = 'هذا الجهاز لا يدعم مسح رموز QR';
        errorIcon = Icons.phone_disabled_outlined;
        break;
      default:
        errorMessage = 'خطأ في الكاميرا: ${error.errorCode.name}';
    }

    return Container(
      color: Colors.black,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.red, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                errorIcon,
                color: Colors.red,
                size: 80,
              ),
              const SizedBox(height: 24),
              Text(
                'خطأ في الكاميرا',
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('رجوع'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════
/// 🎨 SCANNER OVERLAY PAINTER - Beautiful Design
/// ═══════════════════════════════════════════════════════════════
class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Semi-transparent black overlay
    final Paint backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    // Scanning area size (70% of screen width)
    final double scanAreaSize = size.width * 0.7;
    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaSize) / 2;

    final Rect scanArea = Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize);

    // Draw overlay with transparent scanning area
    final Path path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(scanArea, const Radius.circular(24)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, backgroundPaint);

    // Draw animated scanning line (optional)
    _drawScanningLine(canvas, scanArea);

    // Draw corner borders (L-shaped corners)
    _drawCornerBorders(canvas, scanArea);

    // Draw border around scan area
    _drawBorder(canvas, scanArea);
  }

  void _drawScanningLine(Canvas canvas, Rect scanArea) {
    final Paint linePaint = Paint()
      ..color = const Color(0xFF2196F3).withValues(alpha: 0.8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Draw horizontal line in middle
    final double lineY = scanArea.top + scanArea.height / 2;
    canvas.drawLine(
      Offset(scanArea.left + 20, lineY),
      Offset(scanArea.right - 20, lineY),
      linePaint,
    );
  }

  void _drawCornerBorders(Canvas canvas, Rect scanArea) {
    final Paint borderPaint = Paint()
      ..color = const Color(0xFF2196F3)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double cornerLength = 40;
    const double radius = 24;

    // Top-left corner
    canvas.drawLine(
      Offset(scanArea.left, scanArea.top + cornerLength + radius),
      Offset(scanArea.left, scanArea.top + radius),
      borderPaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(scanArea.left, scanArea.top, radius * 2, radius * 2),
      3.14, // 180 degrees
      1.57, // 90 degrees
      false,
      borderPaint,
    );
    canvas.drawLine(
      Offset(scanArea.left + radius, scanArea.top),
      Offset(scanArea.left + cornerLength + radius, scanArea.top),
      borderPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(scanArea.right - cornerLength - radius, scanArea.top),
      Offset(scanArea.right - radius, scanArea.top),
      borderPaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(
          scanArea.right - radius * 2, scanArea.top, radius * 2, radius * 2),
      4.71, // 270 degrees
      1.57, // 90 degrees
      false,
      borderPaint,
    );
    canvas.drawLine(
      Offset(scanArea.right, scanArea.top + radius),
      Offset(scanArea.right, scanArea.top + cornerLength + radius),
      borderPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(scanArea.left, scanArea.bottom - cornerLength - radius),
      Offset(scanArea.left, scanArea.bottom - radius),
      borderPaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(
          scanArea.left, scanArea.bottom - radius * 2, radius * 2, radius * 2),
      1.57, // 90 degrees
      1.57, // 90 degrees
      false,
      borderPaint,
    );
    canvas.drawLine(
      Offset(scanArea.left + radius, scanArea.bottom),
      Offset(scanArea.left + cornerLength + radius, scanArea.bottom),
      borderPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(scanArea.right - cornerLength - radius, scanArea.bottom),
      Offset(scanArea.right - radius, scanArea.bottom),
      borderPaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(scanArea.right - radius * 2,
          scanArea.bottom - radius * 2, radius * 2, radius * 2),
      0, // 0 degrees
      1.57, // 90 degrees
      false,
      borderPaint,
    );
    canvas.drawLine(
      Offset(scanArea.right, scanArea.bottom - radius),
      Offset(scanArea.right, scanArea.bottom - cornerLength - radius),
      borderPaint,
    );
  }

  void _drawBorder(Canvas canvas, Rect scanArea) {
    final Paint borderPaint = Paint()
      ..color = const Color(0xFF2196F3).withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(scanArea, const Radius.circular(24)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
