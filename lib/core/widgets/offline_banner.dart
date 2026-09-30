import 'dart:async';
import 'package:flutter/material.dart';

import '../services/connectivity_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// 🔌 OFFLINE BANNER — Smart animated connectivity indicator
// ═══════════════════════════════════════════════════════════════════════════════
//
// Behaviors:
// • Slides DOWN when offline → auto-hides after 4 seconds
// • Re-shows when user tries to write (write-blocked flash)
// • GREEN flash "تم الاتصال بالإنترنت" on reconnect → auto-hides after 3s
// • Auto-triggers refresh callback on reconnect
//
// Global control via OfflineBanner.showWriteBlocked()
//
// ═══════════════════════════════════════════════════════════════════════════════

class OfflineBanner extends StatefulWidget {
  /// Called when connectivity is restored — use to refresh data
  final VoidCallback? onReconnect;

  const OfflineBanner({super.key, this.onReconnect});

  /// Use this factory in MainNavigation so showWriteBlocked() can reach the state
  factory OfflineBanner.connected({VoidCallback? onReconnect}) {
    return OfflineBanner(
      key: _globalKey,
      onReconnect: onReconnect,
    );
  }

  // Global key for external control (write-blocked flash)
  static final GlobalKey<_OfflineBannerState> _globalKey =
      GlobalKey<_OfflineBannerState>();

  /// Show the banner briefly when a write is blocked (called from providers)
  static void showWriteBlocked() {
    _globalKey.currentState?._showWriteBlockedFlash();
  }

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}


class _OfflineBannerState extends State<OfflineBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slideAnimation;
  StreamSubscription<ConnectivityStatus>? _subscription;

  bool _isOffline = false;
  _BannerMode _mode = _BannerMode.hidden;
  Timer? _autoHideTimer;

  static const Duration _autoHideDuration = Duration(seconds: 4);
  static const Duration _reconnectShowDuration = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _isOffline = ConnectivityService.instance.isOffline;
    if (_isOffline) {
      _mode = _BannerMode.offline;
      _controller.forward();
      _scheduleAutoHide();
    }

    _subscription =
        ConnectivityService.instance.statusStream.listen(_onStatusChanged);
  }

  void _onStatusChanged(ConnectivityStatus status) {
    if (!mounted) return;
    _autoHideTimer?.cancel();

    if (status == ConnectivityStatus.offline) {
      setState(() {
        _isOffline = true;
        _mode = _BannerMode.offline;
      });
      _controller.forward();
      _scheduleAutoHide();
    } else if (_isOffline || status == ConnectivityStatus.online) {
      // Just came online
      _isOffline = false;
      _showReconnectedFlash();
    }
  }

  void _showReconnectedFlash() {
    if (!mounted) return;
    _autoHideTimer?.cancel();

    setState(() => _mode = _BannerMode.reconnected);
    _controller.forward();

    // Trigger data refresh
    widget.onReconnect?.call();

    _autoHideTimer = Timer(_reconnectShowDuration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) setState(() => _mode = _BannerMode.hidden);
        });
      }
    });
  }

  // Called externally when a write is blocked offline
  void _showWriteBlockedFlash() {
    if (!mounted || !_isOffline) return;
    _autoHideTimer?.cancel();

    setState(() => _mode = _BannerMode.writeBlocked);
    _controller.forward();
    _scheduleAutoHide(duration: const Duration(seconds: 3));
  }

  void _scheduleAutoHide({Duration? duration}) {
    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(duration ?? _autoHideDuration, () {
      if (mounted && _isOffline) {
        // Return to subtle offline indicator (don't fully hide — stay visible
        // but smaller, or just reverse)
        setState(() => _mode = _BannerMode.offline);
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    _subscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Color get _gradientStart {
    switch (_mode) {
      case _BannerMode.reconnected:
        return const Color(0xFF1B5E20);
      case _BannerMode.writeBlocked:
        return const Color(0xFF6A1B9A);
      case _BannerMode.offline:
      default:
        return const Color(0xFFBF360C);
    }
  }

  Color get _gradientEnd {
    switch (_mode) {
      case _BannerMode.reconnected:
        return const Color(0xFF388E3C);
      case _BannerMode.writeBlocked:
        return const Color(0xFF8E24AA);
      case _BannerMode.offline:
      default:
        return const Color(0xFFE64A19);
    }
  }

  IconData get _icon {
    switch (_mode) {
      case _BannerMode.reconnected:
        return Icons.cloud_done_rounded;
      case _BannerMode.writeBlocked:
        return Icons.edit_off_rounded;
      case _BannerMode.offline:
      default:
        return Icons.cloud_off_rounded;
    }
  }

  String get _message {
    switch (_mode) {
      case _BannerMode.reconnected:
        return 'تم الاتصال — جارٍ تحديث البيانات... ✓';
      case _BannerMode.writeBlocked:
        return 'وضع القراءة فقط — اتصل بالإنترنت للإضافة أو التعديل';
      case _BannerMode.offline:
      default:
        return 'لا يوجد اتصال — عرض البيانات المحفوظة فقط';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_mode == _BannerMode.hidden) return const SizedBox.shrink();

    return SizeTransition(
      sizeFactor: _slideAnimation,
      axisAlignment: -1,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_gradientStart, _gradientEnd],
            ),
          ),
          child: Row(
            children: [
              Icon(_icon, color: Colors.white, size: 16),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
              if (_mode == _BannerMode.offline)
                _PulsingDot(),
            ],
          ),
        ),
      ),
    );
  }
}

enum _BannerMode { hidden, offline, reconnected, writeBlocked }

// Tiny pulsing dot for offline indicator
class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _pulse,
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: Colors.orangeAccent.shade100,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
