import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

/// Servicio para exportar eventos de analytics a Firestore
/// que luego se sincronizan automáticamente con BigQuery
/// 
/// **Business Question 3.1**: Trackea eventos de completitud de datos
/// para análisis en BigQuery y dashboard en tiempo real.
/// 
/// **Pipeline de Datos**:
/// 1. App Flutter → Firestore collection 'analytics_events'
/// 2. Firebase Export → BigQuery (automático cada 24h o streaming)
/// 3. BigQuery → Looker Studio Dashboard (tiempo real)
class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Registra evento de creación de subject
  Future<void> trackSubjectCreated({
    required String userId,
    required String subjectId,
    required String subjectName,
    required String termId,
    required int credits,
  }) async {
    try {
      await _firestore.collection('analytics_events').add({
        'event_type': 'subject_created',
        'event_timestamp': FieldValue.serverTimestamp(),
        'user_id': userId,
        'subject_id': subjectId,
        'subject_name': subjectName,
        'term_id': termId,
        'credits': credits,
        'has_credits': credits > 0,
        // Metadata para BQ 3.1
        'bq_question': '3.1',
        'metric_category': 'subject_completeness',
      });
      
      print('📊 Analytics: Subject created tracked');
    } catch (e) {
      print('❌ Error tracking subject creation: $e');
    }
  }

  /// Registra evento cuando un subject alcanza completitud para GPA
  Future<void> trackSubjectCompleted({
    required String userId,
    required String subjectId,
    required String subjectName,
    required String termId,
    required int credits,
    required int totalWeight,
  }) async {
    try {
      await _firestore.collection('analytics_events').add({
        'event_type': 'subject_completed_for_gpa',
        'event_timestamp': FieldValue.serverTimestamp(),
        'user_id': userId,
        'subject_id': subjectId,
        'subject_name': subjectName,
        'term_id': termId,
        'credits': credits,
        'total_weight': totalWeight,
        'has_complete_data': true,
        // Metadata para BQ 3.1
        'bq_question': '3.1',
        'metric_category': 'subject_completeness',
      });
      
      print('📊 Analytics: Subject completed for GPA tracked');
    } catch (e) {
      print('❌ Error tracking subject completion: $e');
    }
  }

  /// Registra evento de actualización de credits
  Future<void> trackCreditsUpdated({
    required String userId,
    required String subjectId,
    required int oldCredits,
    required int newCredits,
  }) async {
    try {
      await _firestore.collection('analytics_events').add({
        'event_type': 'subject_credits_updated',
        'event_timestamp': FieldValue.serverTimestamp(),
        'user_id': userId,
        'subject_id': subjectId,
        'old_credits': oldCredits,
        'new_credits': newCredits,
        'credits_added': newCredits > 0 && oldCredits == 0,
        // Metadata para BQ 3.1
        'bq_question': '3.1',
        'metric_category': 'subject_completeness',
      });
      
      print('📊 Analytics: Credits updated tracked');
    } catch (e) {
      print('❌ Error tracking credits update: $e');
    }
  }

  /// Registra evento de cambio de weight en assignment
  Future<void> trackAssignmentWeightChanged({
    required String userId,
    required String subjectId,
    required String assignmentId,
    required int oldWeight,
    required int newWeight,
    required int totalWeightAfter,
  }) async {
    try {
      await _firestore.collection('analytics_events').add({
        'event_type': 'assignment_weight_changed',
        'event_timestamp': FieldValue.serverTimestamp(),
        'user_id': userId,
        'subject_id': subjectId,
        'assignment_id': assignmentId,
        'old_weight': oldWeight,
        'new_weight': newWeight,
        'total_weight_after': totalWeightAfter,
        'weights_valid': totalWeightAfter == 100,
        // Metadata para BQ 3.1
        'bq_question': '3.1',
        'metric_category': 'subject_completeness',
      });
      
      print('Analytics: Assignment weight changed tracked');
    } catch (e) {
      print('Error tracking weight change: $e');
    }
  }

  /// Registra snapshot diario de completitud de subjects
  /// Este método se ejecuta periódicamente (ej: Cloud Function cada 24h)
  Future<void> trackDailyCompletenessSnapshot({
    required String userId,
    required int totalSubjects,
    required int completeSubjects,
    required int subjectsWithCredits,
    required int subjectsWithoutCredits,
    required int subjectsWithInvalidWeights,
    required double completionRate,
  }) async {
    try {
      await _firestore.collection('analytics_events').add({
        'event_type': 'daily_completeness_snapshot',
        'event_timestamp': FieldValue.serverTimestamp(),
        'snapshot_date': DateTime.now().toIso8601String().split('T')[0], // YYYY-MM-DD
        'user_id': userId,
        'total_subjects': totalSubjects,
        'complete_subjects': completeSubjects,
        'subjects_with_credits': subjectsWithCredits,
        'subjects_without_credits': subjectsWithoutCredits,
        'subjects_with_invalid_weights': subjectsWithInvalidWeights,
        'completion_rate': completionRate,
        // Metadata para BQ 3.1
        'bq_question': '3.1',
        'metric_category': 'subject_completeness',
      });
      
      print('Analytics: Daily completeness snapshot tracked');
    } catch (e) {
      print('Error tracking daily snapshot: $e');
    }
  }

  /// Obtiene eventos recientes para debugging
  Future<List<Map<String, dynamic>>> getRecentEvents({
    int limit = 50,
    String? eventType,
  }) async {
    try {
      Query query = _firestore
          .collection('analytics_events')
          .orderBy('event_timestamp', descending: true)
          .limit(limit);

      if (eventType != null) {
        query = query.where('event_type', isEqualTo: eventType);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching recent events: $e');
      return [];
    }
  }

  /// Genera reporte agregado de completitud (para validar datos antes de BigQuery)
  Future<Map<String, dynamic>> generateCompletenessReport() async {
    try {
      // Obtener todos los eventos de completitud
      final eventsSnapshot = await _firestore
          .collection('analytics_events')
          .where('bq_question', isEqualTo: '3.1')
          .where('event_type', isEqualTo: 'subject_completed_for_gpa')
          .get();

      final totalCompletedSubjects = eventsSnapshot.docs.length;

      // Obtener todos los eventos de creación de subjects
      final createdSnapshot = await _firestore
          .collection('analytics_events')
          .where('bq_question', isEqualTo: '3.1')
          .where('event_type', isEqualTo: 'subject_created')
          .get();

      final totalCreatedSubjects = createdSnapshot.docs.length;

      final completionRate = totalCreatedSubjects > 0
          ? (totalCompletedSubjects / totalCreatedSubjects) * 100
          : 0.0;

      // Agrupar por usuario
      final userStats = <String, Map<String, int>>{};
      
      for (var doc in createdSnapshot.docs) {
        final userId = doc.data()['user_id'] as String;
        userStats.putIfAbsent(userId, () => {'created': 0, 'completed': 0});
        userStats[userId]!['created'] = (userStats[userId]!['created'] ?? 0) + 1;
      }

      for (var doc in eventsSnapshot.docs) {
        final userId = doc.data()['user_id'] as String;
        userStats.putIfAbsent(userId, () => {'created': 0, 'completed': 0});
        userStats[userId]!['completed'] = (userStats[userId]!['completed'] ?? 0) + 1;
      }

      return {
        'total_subjects_created': totalCreatedSubjects,
        'total_subjects_completed': totalCompletedSubjects,
        'completion_rate': completionRate,
        'total_users': userStats.length,
        'users_with_complete_subjects': userStats.values.where((s) => (s['completed'] ?? 0) > 0).length,
        'avg_subjects_per_user': totalCreatedSubjects / (userStats.length > 0 ? userStats.length : 1),
        'generated_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error generating completeness report: $e');
      return {};
    }
  }

  /// Exporta datos en formato JSON para testing de BigQuery
  Future<String> exportEventsAsJSON({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 1000,
  }) async {
    try {
      Query query = _firestore
          .collection('analytics_events')
          .where('bq_question', isEqualTo: '3.1')
          .orderBy('event_timestamp', descending: true)
          .limit(limit);

      final snapshot = await query.get();
      
      final events = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        
        // Convertir Timestamp a String para JSON
        if (data['event_timestamp'] != null) {
          final timestamp = data['event_timestamp'] as Timestamp;
          data['event_timestamp'] = timestamp.toDate().toIso8601String();
        }
        
        return data;
      }).toList();

      return jsonEncode({
        'export_date': DateTime.now().toIso8601String(),
        'event_count': events.length,
        'events': events,
      });
    } catch (e) {
      print('Error exporting events: $e');
      return '{}';
    }
  }
}
