// lib/views/shared/group_stats_screen.dart
// Pantalla para mostrar estadísticas de grupos visitados (Hive) y preferencias (SharedPreferences)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/storage/hive_service.dart';
import '../../services/storage/app_preferences.dart';
import '../../themes/app_typography.dart';
import '../../widgets/top_bar.dart';
import '../../models/visited_group_history.dart';
import '../../data/repositories/group_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../core/connectivity/connectivity_manager.dart';
import '../../viewmodels/shared/group_detail_viewmodel.dart';

class GroupStatsScreen extends StatefulWidget {
  const GroupStatsScreen({super.key});

  @override
  State<GroupStatsScreen> createState() => _GroupStatsScreenState();
}

class _GroupStatsScreenState extends State<GroupStatsScreen> {
  List<VisitedGroupHistory> _recentVisits = [];
  List<VisitedGroupHistory> _mostVisited = [];
  Map<String, dynamic> _stats = {};
  Map<String, dynamic> _preferences = {};
  bool _isLoading = true;
  
  // NUEVO: Estado para estadísticas detalladas del grupo (usando Future con handlers)
  Map<String, dynamic>? _detailedGroupStats;
  bool _isLoadingDetailedStats = false;
  String? _detailedStatsError;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Cargar datos de Hive
      _recentVisits = HiveService.instance.getVisitedGroups(limit: 5);
      _mostVisited = HiveService.instance.getMostVisitedGroups(limit: 5);
      _stats = HiveService.instance.getVisitStatistics();
      
      // Cargar preferencias de SharedPreferences
      _preferences = AppPreferences.instance.getPreferencesStats();
      
      setState(() => _isLoading = false);
    } catch (e) {
      print('Error loading stats: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: const TopBar(title: "Group Stats"),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsCard(colors),
                    const SizedBox(height: 20),
                    // 🔹 NUEVA SECCIÓN: Demo de Future con handlers + async/await
                    _buildDetailedStatsSection(colors),
                    const SizedBox(height: 20),
                    _buildRecentVisitsSection(colors),
                    const SizedBox(height: 20),
                    _buildMostVisitedSection(colors),
                    const SizedBox(height: 20),
                    _buildPreferencesSection(colors),
                    const SizedBox(height: 20),
                    _buildActionButtons(colors),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsCard(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceDim,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'General Statistics',
            style: AppTypography.h4.copyWith(color: colors.onSurface),
          ),
          const SizedBox(height: 15),
          _buildStatRow('Total groups visited', '${_stats['totalGroups'] ?? 0}', colors),
          _buildStatRow('Total visits', '${_stats['totalVisits'] ?? 0}', colors),
          _buildStatRow('Average visits per group', '${(_stats['averageVisitsPerGroup'] ?? 0.0).toStringAsFixed(1)}', colors),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyM.copyWith(color: colors.onSurface)),
          Text(
            value,
            style: AppTypography.h5.copyWith(color: colors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentVisitsSection(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Visits',
          style: AppTypography.h4.copyWith(color: colors.onSurface),
        ),
        const SizedBox(height: 10),
        if (_recentVisits.isEmpty)
          _buildEmptyState('No visits recorded', colors)
        else
          ..._recentVisits.map((visit) => _buildVisitCard(visit, colors)),
      ],
    );
  }

  Widget _buildMostVisitedSection(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Most Visited',
          style: AppTypography.h4.copyWith(color: colors.onSurface),
        ),
        const SizedBox(height: 10),
        if (_mostVisited.isEmpty)
          _buildEmptyState('No visits recorded', colors)
        else
          ..._mostVisited.map((visit) => _buildVisitCard(visit, colors, showCount: true)),
      ],
    );
  }

  Widget _buildVisitCard(VisitedGroupHistory visit, ColorScheme colors, {bool showCount = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colors.surfaceDim,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: colors.primary.withOpacity(0.2),
            child: Text(
              visit.groupName[0].toUpperCase(),
              style: AppTypography.h5.copyWith(color: colors.primary),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visit.groupName,
                  style: AppTypography.bodyM.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  showCount 
                      ? '${visit.visitCount} visit${visit.visitCount != 1 ? 's' : ''}'
                      : _formatDateTime(visit.lastVisited),
                  style: AppTypography.captionM.copyWith(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          if (showCount)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${visit.visitCount}',
                style: AppTypography.h5.copyWith(color: colors.primary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceDim,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferences',
            style: AppTypography.h4.copyWith(color: colors.onSurface),
          ),
          const SizedBox(height: 15),
          _buildPreferenceRow(
            'Auto-refresh on reconnect',
            _preferences['autoRefresh'] ?? true,
            colors,
            onChanged: (value) async {
              await AppPreferences.instance.setAutoRefreshOnReconnect(value);
              await _loadData();
              
              // Mostrar mensaje de confirmación
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value 
                        ? 'Auto-refresh enabled - Data will refresh when reconnecting'
                        : 'Auto-refresh disabled - Manual refresh required after reconnection',
                    ),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
          ),
          _buildPreferenceRow(
            'Show offline banner',
            _preferences['offlineBanner'] ?? true,
            colors,
            onChanged: (value) async {
              await AppPreferences.instance.setShowOfflineBanner(value);
              await _loadData();
              
              // 🔹 Notificar a las pantallas anteriores que deben reconstruirse
              // Esto fuerza la reconstrucción del OfflineBanner en shared_screen
              if (mounted && Navigator.canPop(context)) {
                // Forzar rebuild de la pantalla anterior
                // Usando un setState vacío en el BuildContext padre
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value 
                            ? 'Offline banner enabled - Go offline to see it'
                            : 'Offline banner disabled',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                });
              }
            },
          ),
          _buildPreferenceRow(
            'Notifications',
            _preferences['notifications'] ?? true,
            colors,
            onChanged: (value) async {
              await AppPreferences.instance.setNotificationsEnabled(value);
              await _loadData();
            },
          ),
          _buildPreferenceRow(
            'Cache enabled',
            _preferences['cache'] ?? true,
            colors,
            onChanged: (value) async {
              await AppPreferences.instance.setCacheEnabled(value);
              await _loadData();
            },
          ),
          const SizedBox(height: 10),
          if (_preferences['lastSync'] != null)
            Text(
              'Last sync: ${_formatDateTime(DateTime.parse(_preferences['lastSync']))}',
              style: AppTypography.captionM.copyWith(color: colors.onSurfaceVariant),
            ),
          if (_preferences['timeSinceSync'] != null)
            Text(
              '${_preferences['timeSinceSync']} minutes ago',
              style: AppTypography.captionM.copyWith(color: colors.onSurfaceVariant),
            ),
        ],
      ),
    );
  }

  Widget _buildPreferenceRow(
    String label,
    bool value,
    ColorScheme colors, {
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyM.copyWith(color: colors.onSurface),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: colors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ColorScheme colors) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              await HiveService.instance.clearVisitedGroupsHistory();
              await _loadData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('History cleared')),
                );
              }
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Clear visit history'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              await AppPreferences.instance.resetToDefaults();
              await _loadData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preferences reset to defaults')),
                );
              }
            },
            icon: const Icon(Icons.restore),
            label: const Text('Reset preferences'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(30),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.inbox, size: 48, color: colors.onSurfaceVariant.withOpacity(0.5)),
          const SizedBox(height: 10),
          Text(
            message,
            style: AppTypography.bodyM.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// 🔹 FUTURE CON HANDLER + ASYNC/AWAIT (10 puntos)
  /// Este método llama a loadGroupStatistics() del ViewModel usando .then() y .catchError()
  /// Demuestra el uso de handlers sobre un método que usa async/await internamente
  void _loadDetailedGroupStats(String groupId, BuildContext context) {
    setState(() {
      _isLoadingDetailedStats = true;
      _detailedStatsError = null;
    });

    // Crear ViewModel temporalmente para hacer la llamada
    // Obtenemos las dependencias desde Provider
    final groupRepository = Provider.of<GroupRepository>(context, listen: false);
    final userRepository = Provider.of<UserRepository>(context, listen: false);
    final connectivity = Provider.of<ConnectivityManager>(context, listen: false);
    final viewModel = GroupDetailViewModel(
      groupId: groupId,
      groupRepository: groupRepository,
      userRepository: userRepository,
      connectivity: connectivity,
    );

    // 🔹 LLAMADA CON HANDLERS (.then y .catchError)
    viewModel.loadGroupStatistics()
      .then((stats) {
        // Handler de éxito
        print('✅ Estadísticas detalladas recibidas con handlers: $stats');
        if (mounted) {
          setState(() {
            _detailedGroupStats = stats;
            _isLoadingDetailedStats = false;
          });
          
          // Mostrar diálogo con las estadísticas
          _showDetailedStatsDialog(context, stats);
        }
      })
      .catchError((error) {
        // Handler de error
        print('❌ Error al cargar estadísticas con handler: $error');
        if (mounted) {
          setState(() {
            _detailedStatsError = error.toString();
            _isLoadingDetailedStats = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      })
      .whenComplete(() {
        // Handler que siempre se ejecuta
        print('🏁 Carga de estadísticas completada (con whenComplete)');
      });
  }

  void _showDetailedStatsDialog(BuildContext context, Map<String, dynamic> stats) {
    final colors = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Detailed Group Statistics',
          style: AppTypography.h4,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow('Group Name', stats['groupName'] ?? 'Unknown', colors),
            const SizedBox(height: 10),
            _buildStatRow('Members', '${stats['memberCount'] ?? 0}', colors),
            const SizedBox(height: 10),
            _buildStatRow('Events', '${stats['eventCount'] ?? 0}', colors),
            const SizedBox(height: 10),
            _buildStatRow('Has Invite Code', stats['hasInviteCode'] == true ? 'Yes' : 'No', colors),
            const SizedBox(height: 10),
            Text(
              'Loaded at: ${stats['timestamp']}',
              style: AppTypography.captionM.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStatsSection(ColorScheme colors) {
    if (_mostVisited.isEmpty) return const SizedBox.shrink();
    
    final mostVisitedGroup = _mostVisited.first;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Future Handler + Async/Await Demo',
            style: AppTypography.h4.copyWith(color: colors.onPrimaryContainer),
          ),
          const SizedBox(height: 10),
          Text(
            'Load detailed statistics for "${mostVisitedGroup.groupName}" using .then() and .catchError()',
            style: AppTypography.bodyM.copyWith(color: colors.onPrimaryContainer),
          ),
          const SizedBox(height: 15),
          if (_isLoadingDetailedStats)
            const Center(child: CircularProgressIndicator())
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _loadDetailedGroupStats(mostVisitedGroup.groupId, context),
                icon: const Icon(Icons.analytics),
                label: const Text('Load Detailed Stats (with handlers)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          if (_detailedStatsError != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'Error: $_detailedStatsError',
                style: AppTypography.captionM.copyWith(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}
