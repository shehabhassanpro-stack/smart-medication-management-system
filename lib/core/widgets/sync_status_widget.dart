import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/connectivity_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// 🔄 SYNC STATUS WIDGET — Firestore pending writes indicator
// ═══════════════════════════════════════════════════════════════════════════════
//
// Shows a small animated icon when Firestore has pending local writes
// waiting to be synced to the server.
//
// Usage: Place in AppBar actions.
//
// ═══════════════════════════════════════════════════════════════════════════════

class SyncStatusWidget extends StatefulWidget {
  const SyncStatusWidget({super.key});

  @override
  State<SyncStatusWidget> createState() => _SyncStatusWidgetState();
}

class _SyncStatusWidgetState extends State<SyncStatusWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;
  StreamSubscription<ConnectivityStatus>? _connectivitySub;

  bool _isSyncing = false;
  bool _justSynced = false;

  @override
  void initState() {
    super.initState();

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _connectivitySub = ConnectivityService.instance.statusStream.listen((status) {
      if (status == ConnectivityStatus.online && !_isSyncing) {
        _checkPendingWrites();
      }
    });

    // Check on init
    if (ConnectivityService.instance.isOnline) {
      _checkPendingWrites();
    }
  }

  Future<void> _checkPendingWrites() async {
    if (!mounted) return;

    setState(() => _isSyncing = true);
    _spinController.repeat();

    ConnectivityService.instance.setSyncing();

    try {
      await FirebaseFirestore.instance.waitForPendingWrites();
    } catch (_) {
      // Ignore — offline or no pending writes
    }

    if (!mounted) return;

    ConnectivityService.instance.setSyncComplete();

    setState(() {
      _isSyncing = false;
      _justSynced = true;
    });
    _spinController.stop();

    // Hide the "synced" checkmark after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _justSynced = false);
    });
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isSyncing && !_justSynced) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: _isSyncing
          ? RotationTransition(
              turns: _spinController,
              child: const Icon(
                Icons.sync_rounded,
                color: Colors.white70,
                size: 20,
              ),
            )
          : const Icon(
              Icons.cloud_done_rounded,
              color: Colors.white,
              size: 20,
            ),
    );
  }
}
