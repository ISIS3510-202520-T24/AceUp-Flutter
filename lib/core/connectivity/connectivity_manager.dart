// lib/core/connectivity/connectivity_manager.dart

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Manages network connectivity state and provides reactive updates
class ConnectivityManager {
  static final ConnectivityManager _instance = ConnectivityManager._internal();
  factory ConnectivityManager() => _instance;
  ConnectivityManager._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();
  
  bool _isOnline = true;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Current connectivity status
  bool get isOnline => _isOnline;

  /// Stream of connectivity changes (true = online, false = offline)
  Stream<bool> get onConnectivityChanged => _connectivityController.stream;

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    // Check initial connectivity
    final result = await _connectivity.checkConnectivity();
    _isOnline = _isConnected(result);
    
    // Listen to connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      final wasOnline = _isOnline;
      _isOnline = _isConnected(result);
      
      // Only emit if connectivity state changed
      if (wasOnline != _isOnline) {
        _connectivityController.add(_isOnline);
        print('📡 Connectivity changed: ${_isOnline ? "ONLINE" : "OFFLINE"}');
      }
    });
  }

  /// Check if device has internet connectivity
  bool _isConnected(List<ConnectivityResult> results) {
    return results.any((result) => 
      result == ConnectivityResult.mobile || 
      result == ConnectivityResult.wifi ||
      result == ConnectivityResult.ethernet
    );
  }

  /// Manually check connectivity (useful for operations that need confirmation)
  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _isOnline = _isConnected(result);
    return _isOnline;
  }

  /// Wait for connection to be available
  Future<void> waitForConnection({Duration timeout = const Duration(seconds: 30)}) async {
    if (_isOnline) return;
    
    await onConnectivityChanged
        .firstWhere((isOnline) => isOnline)
        .timeout(timeout, onTimeout: () => false);
  }

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
    _connectivityController.close();
  }
}
