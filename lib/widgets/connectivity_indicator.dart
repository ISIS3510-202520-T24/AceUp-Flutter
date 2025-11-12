// lib/widgets/connectivity_indicator.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/connectivity/connectivity_manager.dart';
import '../services/shared/sync_service.dart';
import '../services/storage/app_preferences.dart';

/// Widget que muestra el estado de conectividad y sincronización
class ConnectivityIndicator extends StatelessWidget {
  const ConnectivityIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivity = context.watch<ConnectivityManager>();
    final syncService = context.watch<SyncService>();
    final colors = Theme.of(context).colorScheme;

    // Si está online y no hay operaciones pendientes, no mostrar nada
    if (connectivity.isOnline && !syncService.isSyncing && syncService.pendingOperationsCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: connectivity.isOnline 
            ? colors.primaryContainer.withOpacity(0.3)
            : colors.errorContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: connectivity.isOnline 
              ? colors.primary.withOpacity(0.3)
              : colors.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ícono de estado
          Icon(
            connectivity.isOnline 
                ? (syncService.isSyncing ? Icons.sync : Icons.cloud_done)
                : Icons.cloud_off,
            size: 16,
            color: connectivity.isOnline ? colors.primary : colors.error,
          ),
          const SizedBox(width: 8),
          
          // Texto de estado
          Expanded(
            child: Text(
              _getStatusText(connectivity.isOnline, syncService),
              style: TextStyle(
                fontSize: 12,
                color: connectivity.isOnline ? colors.onPrimaryContainer : colors.onErrorContainer,
              ),
            ),
          ),
          
          // Botón de sincronización manual
          if (connectivity.isOnline && syncService.pendingOperationsCount > 0 && !syncService.isSyncing)
            IconButton(
              icon: const Icon(Icons.sync, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              color: colors.primary,
              onPressed: () {
                syncService.syncPendingOperations();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Syncing ${syncService.pendingOperationsCount} pending changes...'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: colors.primary,
                  ),
                );
              },
              tooltip: 'Sync now',
            ),
          
          // Animación de sincronización
          if (syncService.isSyncing)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
    );
  }

  String _getStatusText(bool isOnline, SyncService syncService) {
    if (!isOnline) {
      final pending = syncService.pendingOperationsCount;
      return pending > 0
          ? 'No connection - $pending pending change${pending > 1 ? 's' : ''}'
          : 'No connection - working offline';
    }

    if (syncService.isSyncing) {
      return 'Syncing changes...';
    }

    final pending = syncService.pendingOperationsCount;
    if (pending > 0) {
      return '$pending operation${pending > 1 ? 's' : ''} in queue';
    }

    return 'All synced';
  }
}

/// Banner persistente para mostrar estado offline
/// Banner que se muestra cuando el usuario está offline
/// Respeta la preferencia del usuario (showOfflineBanner)
/// 
/// IMPORTANTE: Este widget escucha cambios en AppPreferences
/// y se reconstruye automáticamente cuando cambia showOfflineBanner
class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  StreamSubscription? _preferencesSubscription;

  @override
  void initState() {
    super.initState();
    // 🔹 Escuchar cambios en las preferencias
    _preferencesSubscription = AppPreferences.instance.onPreferenceChanged.listen((key) {
      // Si cambió showOfflineBanner, reconstruir el widget
      if (key == 'show_offline_banner' && mounted) {
        print('🔔 OfflineBanner: Recibida notificación de cambio en preferencia');
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _preferencesSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectivity = context.watch<ConnectivityManager>();
    final colors = Theme.of(context).colorScheme;

    // No mostrar si está online
    if (connectivity.isOnline) {
      return const SizedBox.shrink();
    }

    // 🔹 CONSULTAR PREFERENCIA DEL USUARIO
    // Si el usuario deshabilitó el banner, no mostrarlo
    // Esta lectura se ejecuta cada vez que se reconstruye el widget
    final showBanner = AppPreferences.instance.showOfflineBanner;
    if (!showBanner) {
      print('🚫 OfflineBanner: Banner deshabilitado por preferencia del usuario');
      return const SizedBox.shrink();
    }

    print('✅ OfflineBanner: Mostrando banner (preferencia habilitada)');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: colors.errorContainer,
      child: Row(
        children: [
          Icon(Icons.cloud_off, size: 16, color: colors.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Offline mode - Changes will sync when connection is restored',
              style: TextStyle(
                fontSize: 12,
                color: colors.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ícono pequeño de conectividad para la AppBar
class ConnectivityAppBarIcon extends StatelessWidget {
  const ConnectivityAppBarIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivity = context.watch<ConnectivityManager>();
    final syncService = context.watch<SyncService>();

    if (connectivity.isOnline && !syncService.isSyncing && syncService.pendingOperationsCount == 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: IconButton(
        icon: Icon(
          connectivity.isOnline 
              ? (syncService.isSyncing ? Icons.sync : Icons.cloud_queue)
              : Icons.cloud_off,
          size: 20,
        ),
        tooltip: connectivity.isOnline 
            ? (syncService.isSyncing 
                ? 'Syncing...' 
                : '${syncService.pendingOperationsCount} pending operation(s)')
            : 'No connection',
        onPressed: () async {
          if (connectivity.isOnline && syncService.pendingOperationsCount > 0 && !syncService.isSyncing) {
            // Force manual sync
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Forcing sync...'),
                duration: Duration(seconds: 1),
              ),
            );
            await syncService.syncPendingOperations();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  connectivity.isOnline
                      ? (syncService.isSyncing 
                          ? 'Sync in progress...'
                          : 'Sync: ${syncService.pendingOperationsCount} pending operation(s)')
                      : 'No Internet connection',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
      ),
    );
  }
}
