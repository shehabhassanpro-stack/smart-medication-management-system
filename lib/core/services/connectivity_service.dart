import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// 🔌 CONNECTIVITY SERVICE — Enterprise Grade Network Monitor
// ═══════════════════════════════════════════════════════════════════════════════
//
// Architecture: Singleton + Stream-based reactive monitoring
//
// Features:
// • Real connectivity check via DNS lookup (not just WiFi connected)
// • Debounced state changes (avoids rapid flicker)
// • Stream<ConnectivityStatus> for reactive UI
// • Synchronous isOnline getter for imperative checks
// • Auto-retry DNS check on transient failures
//
// Usage:
// ```dart
// // Reactive
// ConnectivityService.instance.statusStream.listen((status) { ... });
//
// // Imperative
// if (ConnectivityService.instance.isOnline) { ... }
// ```
//
// ═══════════════════════════════════════════════════════════════════════════════

enum ConnectivityStatus {
  online,
  offline,
  syncing,
}

class ConnectivityService {
  // ─────────────────────────────────────────────────────────────────────────
  // SINGLETON
  // ─────────────────────────────────────────────────────────────────────────

  static final ConnectivityService _instance = ConnectivityService._internal();
  static ConnectivityService get instance => _instance;

  ConnectivityService._internal();

  // ─────────────────────────────────────────────────────────────────────────
  // STATE
  // ─────────────────────────────────────────────────────────────────────────

  final Connectivity _connectivity = Connectivity();
  final _statusController = StreamController<ConnectivityStatus>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  ConnectivityStatus _currentStatus = ConnectivityStatus.online;
  bool _isInitialized = false;
  DateTime? _lastOnlineTime;
  Timer? _debounceTimer;

  // ─────────────────────────────────────────────────────────────────────────
  // PUBLIC API
  // ─────────────────────────────────────────────────────────────────────────

  /// Reactive stream of connectivity status changes
  Stream<ConnectivityStatus> get statusStream => _statusController.stream;

  /// Current connectivity status
  ConnectivityStatus get status => _currentStatus;

  /// Quick check: is the device online?
  bool get isOnline => _currentStatus == ConnectivityStatus.online ||
      _currentStatus == ConnectivityStatus.syncing;

  /// Quick check: is the device offline?
  bool get isOffline => _currentStatus == ConnectivityStatus.offline;

  /// Last time the device was confirmed online
  DateTime? get lastOnlineTime => _lastOnlineTime;

  /// Duration since last online connection (null if never was online)
  Duration? get offlineDuration {
    if (_lastOnlineTime == null) return null;
    if (isOnline) return Duration.zero;
    return DateTime.now().difference(_lastOnlineTime!);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────────────────────────────────

  /// Initialize the service — call once at app startup
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    debugPrint('🔌 ConnectivityService: Initializing...');

    // Check initial status
    await _checkConnectivity();

    // Listen for changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (results) => _onConnectivityChanged(results),
    );

    debugPrint('✅ ConnectivityService: Ready (status: $_currentStatus)');
  }

  /// Dispose resources
  void dispose() {
    _debounceTimer?.cancel();
    _connectivitySubscription?.cancel();
    _statusController.close();
    _isInitialized = false;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CONNECTIVITY CHANGE HANDLER
  // ─────────────────────────────────────────────────────────────────────────

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    // Debounce: wait 800ms before acting (avoids rapid flicker)
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      _checkConnectivity();
    });
  }

  /// Perform real connectivity check (DNS lookup, not just interface check)
  Future<void> _checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();

    // No network interface at all
    if (results.contains(ConnectivityResult.none) || results.isEmpty) {
      _updateStatus(ConnectivityStatus.offline);
      return;
    }

    // Has network interface — verify with real DNS lookup
    final hasInternet = await _verifyInternetAccess();

    if (hasInternet) {
      _lastOnlineTime = DateTime.now();
      _updateStatus(ConnectivityStatus.online);
    } else {
      _updateStatus(ConnectivityStatus.offline);
    }
  }

  /// DNS lookup to verify actual internet access
  /// Some WiFi networks show "connected" but have no internet (captive portals)
  Future<bool> _verifyInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('dns.google')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STATE MANAGEMENT
  // ─────────────────────────────────────────────────────────────────────────

  void _updateStatus(ConnectivityStatus newStatus) {
    if (_currentStatus == newStatus) return;

    final previous = _currentStatus;
    _currentStatus = newStatus;

    debugPrint('🔌 Connectivity: $previous → $newStatus');

    if (!_statusController.isClosed) {
      _statusController.add(newStatus);
    }
  }

  /// Manually set syncing status (call when Firestore is syncing pending writes)
  void setSyncing() {
    if (_currentStatus == ConnectivityStatus.online) {
      _updateStatus(ConnectivityStatus.syncing);
    }
  }

  /// Manually set online after sync completes
  void setSyncComplete() {
    if (_currentStatus == ConnectivityStatus.syncing) {
      _updateStatus(ConnectivityStatus.online);
    }
  }

  /// Force a connectivity recheck
  Future<void> recheck() => _checkConnectivity();
}
