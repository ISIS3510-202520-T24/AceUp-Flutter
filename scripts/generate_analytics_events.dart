/// Script para generar eventos de analytics retroactivos
/// 
/// Este script lee todos los subjects existentes en Firestore y genera
/// eventos de analytics para el pipeline de BigQuery (BQ 3.1).
/// 
/// INSTRUCCIONES:
/// 1. Copia esta función a un lugar temporal en tu app (ej: main.dart)
/// 2. Llámala desde un botón o en initState
/// 3. Ejecuta la app y revisa la consola

import 'package:cloud_firestore/cloud_firestore.dart';

/// Función para generar eventos de analytics desde subjects existentes
Future<void> generateAnalyticsEventsFromExistingSubjects() async {
  print('🚀 Iniciando generación de eventos de analytics...\n');

  final firestore = FirebaseFirestore.instance;
  
  try {
    // Contadores
    int totalSubjects = 0;
    int totalCompleteSubjects = 0;
    int totalEvents = 0;
    
    // 1. Obtener todos los usuarios
    print('📂 Buscando usuarios...');
    final usersSnapshot = await firestore.collection('users').get();
    print('   Encontrados: ${usersSnapshot.docs.length} usuarios\n');
    
    for (var userDoc in usersSnapshot.docs) {
      final userId = userDoc.id;
      print('👤 Usuario: $userId');
      
      // 2. Obtener todos los términos del usuario
      final termsSnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .get();
      
      print('   📅 Términos: ${termsSnapshot.docs.length}');
      
      for (var termDoc in termsSnapshot.docs) {
        final termId = termDoc.id;
        
        // 3. Obtener todos los subjects del término
        final subjectsSnapshot = await firestore
            .collection('users')
            .doc(userId)
            .collection('terms')
            .doc(termId)
            .collection('subjects')
            .get();
        
        print('   📚 Subjects en término $termId: ${subjectsSnapshot.docs.length}');
        
        for (var subjectDoc in subjectsSnapshot.docs) {
          final subjectId = subjectDoc.id;
          final subjectData = subjectDoc.data();
          
          totalSubjects++;
          
          final name = subjectData['name'] ?? 'Sin nombre';
          final credits = subjectData['credits'] ?? 0;
          final createdAt = subjectData['createdAt'] as Timestamp?;
          
          print('      📖 $name (credits: $credits)');
          
          // 4. Generar evento: subject_created
          await firestore.collection('analytics_events').add({
            'event_type': 'subject_created',
            'event_timestamp': createdAt ?? FieldValue.serverTimestamp(),
            'user_id': userId,
            'term_id': termId,
            'subject_id': subjectId,
            'subject_name': name,
            'credits': credits,
            'has_credits': credits > 0,
            'bq_question': '3.1',
            'metric_category': 'subject_completeness',
            'migration': true, // Marca para identificar eventos migrados
          });
          totalEvents++;
          
          // 5. Verificar completitud (credits + weights = 100%)
          if (credits > 0) {
            // Obtener assignments del subject
            final assignmentsSnapshot = await firestore
                .collection('users')
                .doc(userId)
                .collection('terms')
                .doc(termId)
                .collection('subjects')
                .doc(subjectId)
                .collection('assignments')
                .get();
            
            // Calcular peso total
            double totalWeight = 0;
            for (var assignmentDoc in assignmentsSnapshot.docs) {
              final weight = assignmentDoc.data()['weight'];
              if (weight != null) {
                totalWeight += (weight is int) ? weight.toDouble() : weight;
              }
            }
            
            final isComplete = totalWeight == 100.0;
            
            print('         Assignments: ${assignmentsSnapshot.docs.length}, Weight total: $totalWeight%');
            
            // 6. Si está completo, generar evento: subject_completed_for_gpa
            if (isComplete) {
              await firestore.collection('analytics_events').add({
                'event_type': 'subject_completed_for_gpa',
                'event_timestamp': createdAt ?? FieldValue.serverTimestamp(),
                'user_id': userId,
                'term_id': termId,
                'subject_id': subjectId,
                'subject_name': name,
                'credits': credits,
                'total_weight': totalWeight,
                'assignment_count': assignmentsSnapshot.docs.length,
                'bq_question': '3.1',
                'metric_category': 'subject_completeness',
                'migration': true,
              });
              totalEvents++;
              totalCompleteSubjects++;
              
              print('         ✅ Subject COMPLETO para GPA');
            } else {
              print('         ⚠️  Subject INCOMPLETO (weight: $totalWeight%)');
            }
          } else {
            print('         ⚠️  Subject sin créditos');
          }
        }
      }
      print('');
    }
    
    // 7. Generar snapshot agregado
    print('\n📊 Generando snapshot agregado...');
    await firestore.collection('analytics_events').add({
      'event_type': 'daily_completeness_snapshot',
      'event_timestamp': FieldValue.serverTimestamp(),
      'total_subjects': totalSubjects,
      'complete_subjects': totalCompleteSubjects,
      'incomplete_subjects': totalSubjects - totalCompleteSubjects,
      'completion_percentage': totalSubjects > 0 
          ? (totalCompleteSubjects / totalSubjects * 100).round() 
          : 0,
      'bq_question': '3.1',
      'metric_category': 'subject_completeness',
      'migration': true,
      'snapshot_type': 'initial_migration',
    });
    totalEvents++;
    
    // Resumen final
    print('\n${'=' * 60}');
    print('✅ MIGRACIÓN COMPLETADA');
    print('=' * 60);
    print('📚 Total subjects procesados: $totalSubjects');
    print('✅ Subjects completos para GPA: $totalCompleteSubjects');
    print('⚠️  Subjects incompletos: ${totalSubjects - totalCompleteSubjects}');
    print('📈 Porcentaje de completitud: ${totalSubjects > 0 ? (totalCompleteSubjects / totalSubjects * 100).toStringAsFixed(1) : 0}%');
    print('🎉 Eventos generados: $totalEvents');
    print('=' * 60);
    print('\n✅ Ahora puedes:');
    print('   1. Verificar eventos en Firestore → analytics_events');
    print('   2. Esperar export a BigQuery (streaming: minutos, batch: 24h)');
    print('   3. Ejecutar queries de análisis en BigQuery');
    
  } catch (e, stackTrace) {
    print('\n❌ ERROR: $e');
    print('Stack trace: $stackTrace');
  }
}
