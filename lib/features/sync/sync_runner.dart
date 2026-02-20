import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';

import 'sync_service.dart';

class SyncRunner extends StatefulWidget {
  final String uid;

  const SyncRunner({super.key, required this.uid});

  @override
  State<SyncRunner> createState() => _SyncRunnerState();
}

class _SyncRunnerState extends State<SyncRunner> {
  final _service = SyncService();
  StreamSubscription<List<ConnectivityResult>>? _sub;

  @override
  void initState() {
    super.initState();

    scheduleMicrotask(() => _trySync());

    _sub = Connectivity().onConnectivityChanged.listen((results) {
      final hasNetwork = results.any((r) => r != ConnectivityResult.none);
      if (!hasNetwork) return;
      _trySync();
    });
  }

  Future<void> _trySync() async {
    try {
      await _service.syncNow(uid: widget.uid);
    } catch (_) {
      // Silent by default: offline-first app should keep working.
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
