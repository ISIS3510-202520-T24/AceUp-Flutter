-- ============================================================================
-- BUSINESS QUESTION 3.1: QUERIES PARA ANÁLISIS DE COMPLETITUD DE SUBJECTS
-- ============================================================================
-- Fecha: Noviembre 11, 2025
-- Proyecto: AceUp Flutter App
-- Dataset: analytics_506922393
-- Tabla: analytics_events_* (cuando se cree por el export)
--
-- IMPORTANTE: Reemplaza 'aceup-app-123' con tu project ID si es diferente
-- ============================================================================

-- ----------------------------------------------------------------------------
-- QUERY 1: PORCENTAJE GLOBAL DE COMPLETITUD
-- ----------------------------------------------------------------------------
-- Propósito: Calcular el % de subjects con datos completos para GPA
-- KPI principal del dashboard
-- ----------------------------------------------------------------------------

WITH subject_events AS (
  -- Obtener todos los eventos de subjects
  SELECT 
    user_id,
    subject_id,
    subject_name,
    credits,
    event_type,
    event_timestamp,
    total_weight
  FROM `aceup-app-123.firestore_analytics.analytics_events_*`
  WHERE bq_question = '3.1'
    AND event_type IN ('subject_created', 'subject_completed_for_gpa')
),

latest_subject_state AS (
  -- Obtener el último estado de cada subject
  SELECT 
    user_id,
    subject_id,
    subject_name,
    MAX(credits) as credits,
    MAX(CASE WHEN event_type = 'subject_completed_for_gpa' THEN 1 ELSE 0 END) as is_complete
  FROM subject_events
  GROUP BY user_id, subject_id, subject_name
)

SELECT 
  COUNT(DISTINCT subject_id) as total_subjects,
  SUM(is_complete) as complete_subjects,
  COUNT(DISTINCT subject_id) - SUM(is_complete) as incomplete_subjects,
  ROUND(100.0 * SUM(is_complete) / COUNT(DISTINCT subject_id), 2) as percentage_complete_for_gpa,
  -- Desglose adicional
  SUM(CASE WHEN credits > 0 THEN 1 ELSE 0 END) as subjects_with_credits,
  SUM(CASE WHEN credits = 0 THEN 1 ELSE 0 END) as subjects_without_credits
FROM latest_subject_state;


-- ----------------------------------------------------------------------------
-- QUERY 2: SEGMENTACIÓN DE USUARIOS POR NIVEL DE COMPLETITUD
-- ----------------------------------------------------------------------------
-- Propósito: Agrupar usuarios según su % de subjects completos
-- Útil para identificar usuarios que necesitan ayuda
-- ----------------------------------------------------------------------------

WITH user_subject_stats AS (
  SELECT 
    user_id,
    COUNT(DISTINCT subject_id) as total_subjects,
    SUM(CASE WHEN event_type = 'subject_completed_for_gpa' THEN 1 ELSE 0 END) as complete_subjects
  FROM `aceup-app-123.firestore_analytics.analytics_events_*`
  WHERE bq_question = '3.1'
  GROUP BY user_id
),

user_completion_rate AS (
  SELECT 
    user_id,
    total_subjects,
    complete_subjects,
    CASE 
      WHEN total_subjects = 0 THEN 0
      ELSE ROUND(100.0 * complete_subjects / total_subjects, 2)
    END as completion_rate
  FROM user_subject_stats
),

user_segments AS (
  SELECT 
    user_id,
    total_subjects,
    complete_subjects,
    completion_rate,
    CASE 
      WHEN completion_rate = 0 THEN '0% - Sin datos completos'
      WHEN completion_rate > 0 AND completion_rate < 25 THEN '1-24% - Muy bajo'
      WHEN completion_rate >= 25 AND completion_rate < 50 THEN '25-49% - Bajo'
      WHEN completion_rate >= 50 AND completion_rate < 75 THEN '50-74% - Medio'
      WHEN completion_rate >= 75 AND completion_rate < 100 THEN '75-99% - Alto'
      WHEN completion_rate = 100 THEN '100% - Completo'
      ELSE 'Desconocido'
    END as segment
  FROM user_completion_rate
)

SELECT 
  segment,
  COUNT(user_id) as user_count,
  AVG(total_subjects) as avg_subjects_per_user,
  AVG(complete_subjects) as avg_complete_per_user,
  AVG(completion_rate) as avg_completion_rate
FROM user_segments
GROUP BY segment
ORDER BY 
  CASE segment
    WHEN '0% - Sin datos completos' THEN 1
    WHEN '1-24% - Muy bajo' THEN 2
    WHEN '25-49% - Bajo' THEN 3
    WHEN '50-74% - Medio' THEN 4
    WHEN '75-99% - Alto' THEN 5
    WHEN '100% - Completo' THEN 6
    ELSE 7
  END;


-- ----------------------------------------------------------------------------
-- QUERY 3: EVOLUCIÓN TEMPORAL DE COMPLETITUD
-- ----------------------------------------------------------------------------
-- Propósito: Ver cómo evoluciona la completitud día a día
-- Útil para gráficos de tendencia temporal
-- ----------------------------------------------------------------------------

WITH daily_snapshots AS (
  SELECT 
    DATE(event_timestamp) as date,
    COUNT(DISTINCT CASE WHEN event_type = 'subject_created' THEN subject_id END) as subjects_created,
    COUNT(DISTINCT CASE WHEN event_type = 'subject_completed_for_gpa' THEN subject_id END) as subjects_completed
  FROM `aceup-app-123.firestore_analytics.analytics_events_*`
  WHERE bq_question = '3.1'
  GROUP BY date
),

cumulative_stats AS (
  SELECT 
    date,
    subjects_created,
    subjects_completed,
    SUM(subjects_created) OVER (ORDER BY date) as cumulative_created,
    SUM(subjects_completed) OVER (ORDER BY date) as cumulative_completed
  FROM daily_snapshots
)

SELECT 
  date,
  subjects_created,
  subjects_completed,
  cumulative_created,
  cumulative_completed,
  CASE 
    WHEN cumulative_created = 0 THEN 0
    ELSE ROUND(100.0 * cumulative_completed / cumulative_created, 2)
  END as cumulative_completion_rate
FROM cumulative_stats
ORDER BY date DESC
LIMIT 30; -- Últimos 30 días


-- ----------------------------------------------------------------------------
-- QUERY 4: ANÁLISIS DE PROBLEMAS (SUBJECTS INCOMPLETOS)
-- ----------------------------------------------------------------------------
-- Propósito: Identificar qué subjects NO están completos y por qué
-- Útil para identificar problemas específicos
-- ----------------------------------------------------------------------------

WITH all_subjects AS (
  SELECT DISTINCT
    user_id,
    subject_id,
    subject_name,
    MAX(credits) as credits
  FROM `aceup-app-123.firestore_analytics.analytics_events_*`
  WHERE bq_question = '3.1'
    AND event_type = 'subject_created'
  GROUP BY user_id, subject_id, subject_name
),

completed_subjects AS (
  SELECT DISTINCT
    subject_id
  FROM `aceup-app-123.firestore_analytics.analytics_events_*`
  WHERE bq_question = '3.1'
    AND event_type = 'subject_completed_for_gpa'
),

weight_info AS (
  SELECT 
    subject_id,
    MAX(total_weight) as last_known_weight
  FROM `aceup-app-123.firestore_analytics.analytics_events_*`
  WHERE bq_question = '3.1'
    AND total_weight IS NOT NULL
  GROUP BY subject_id
),

incomplete_analysis AS (
  SELECT 
    a.user_id,
    a.subject_id,
    a.subject_name,
    a.credits,
    COALESCE(w.last_known_weight, 0) as total_weight,
    CASE 
      WHEN c.subject_id IS NOT NULL THEN 'Completo'
      WHEN a.credits = 0 THEN 'Sin créditos'
      WHEN COALESCE(w.last_known_weight, 0) = 0 THEN 'Sin assignments'
      WHEN COALESCE(w.last_known_weight, 0) < 100 THEN 'Peso insuficiente'
      WHEN COALESCE(w.last_known_weight, 0) > 100 THEN 'Peso excedido'
      ELSE 'Otro problema'
    END as problem_type
  FROM all_subjects a
  LEFT JOIN completed_subjects c ON a.subject_id = c.subject_id
  LEFT JOIN weight_info w ON a.subject_id = w.subject_id
)

SELECT 
  problem_type,
  COUNT(*) as subject_count,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) as percentage,
  -- Ejemplos de subjects con este problema (primeros 3)
  STRING_AGG(
    CONCAT(subject_name, ' (credits: ', CAST(credits AS STRING), ', weight: ', CAST(total_weight AS STRING), '%)'),
    ', '
    LIMIT 3
  ) as examples
FROM incomplete_analysis
GROUP BY problem_type
ORDER BY subject_count DESC;


-- ----------------------------------------------------------------------------
-- QUERY 5 (BONUS): REPORTE DETALLADO POR USUARIO
-- ----------------------------------------------------------------------------
-- Propósito: Ver el estado detallado de cada usuario
-- Útil para debugging o análisis individual
-- ----------------------------------------------------------------------------

WITH user_details AS (
  SELECT 
    user_id,
    subject_id,
    subject_name,
    MAX(credits) as credits,
    MAX(CASE WHEN event_type = 'subject_completed_for_gpa' THEN 1 ELSE 0 END) as is_complete,
    MAX(event_timestamp) as last_update
  FROM `aceup-app-123.firestore_analytics.analytics_events_*`
  WHERE bq_question = '3.1'
  GROUP BY user_id, subject_id, subject_name
)

SELECT 
  user_id,
  COUNT(*) as total_subjects,
  SUM(is_complete) as complete_subjects,
  ROUND(100.0 * SUM(is_complete) / COUNT(*), 2) as completion_rate,
  SUM(credits) as total_credits,
  -- Lista de subjects completos
  STRING_AGG(
    CASE WHEN is_complete = 1 THEN subject_name END, 
    ', '
  ) as complete_subjects_list,
  -- Lista de subjects incompletos
  STRING_AGG(
    CASE WHEN is_complete = 0 THEN subject_name END, 
    ', '
  ) as incomplete_subjects_list
FROM user_details
GROUP BY user_id
ORDER BY completion_rate DESC;


-- ============================================================================
-- NOTAS DE USO:
-- ============================================================================
-- 1. Reemplaza 'aceup-app-123' con tu project ID real
-- 2. La tabla 'analytics_events_*' usa wildcard para todas las fechas
-- 3. Todas las queries filtran por bq_question = '3.1'
-- 4. Puedes agregar filtros de fecha usando: AND DATE(event_timestamp) >= '2025-11-01'
-- 5. Para probar con datos actuales, usa: analytics_events_20251111
-- ============================================================================
