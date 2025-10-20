const { onSchedule } = require("firebase-functions/v2/scheduler");
const { onDocumentWritten } = require("firebase-functions/v2/firestore");
const { logger } = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// ===================================================================
// == FUNCIÓN 1: NOTIFICAR CUANDO ALGUIEN QUEDA LIBRE (PROGRAMADA) ==
// ===================================================================
exports.notifyOnFreeMembers = onSchedule("every 5 minutes", async (event) => {
  logger.info("--- [notifyOnFreeMembers] Function Start ---");

  // Obtener hora actual del servidor (UTC)
  const nowUTC = new Date();
  
  // Convertir a hora de Bogotá (UTC-5)
  const nowBogota = new Date(nowUTC.getTime() - 5 * 60 * 60 * 1000);
  const fiveMinutesAgoBogota = new Date(nowBogota.getTime() - 5 * 60 * 1000);
  const db = admin.firestore();

  logger.info(`Current time in Bogotá (UTC-5): ${nowBogota.toISOString()}`);
  logger.info(`Checking for events that ended between (Bogotá time): ${fiveMinutesAgoBogota.toISOString()} and ${nowBogota.toISOString()}`);

  try {
    const groupsSnapshot = await db.collection("groups").get();
    logger.info(`Found ${groupsSnapshot.size} groups to process.`);

    for (const groupDoc of groupsSnapshot.docs) {
      const group = groupDoc.data();
      const groupName = group.name || "Unnamed Group";
      const memberUids = group.members || [];
      
      if (memberUids.length < 1) continue;
      logger.info(`Processing group: "${groupName}"`);


      // --- SOLO EXAMS Y CLASSES ---
      const recentlyFreedMembers = [];
      for (const memberId of memberUids) {
        const userRef = db.collection("users").doc(memberId);
        let justBecameFree = false;
        // Revisar exámenes
        const termsSnap = await userRef.collection("terms").get();
        for (const termDoc of termsSnap.docs) {
          const subjectsSnap = await termDoc.ref.collection("subjects").get();
          for (const subjectDoc of subjectsSnap.docs) {
            const examsSnap = await subjectDoc.ref.collection("exams")
              .where("endTime", ">=", admin.firestore.Timestamp.fromDate(fiveMinutesAgo))
              .where("endTime", "<=", admin.firestore.Timestamp.fromDate(now))
              .get();
            if (!examsSnap.empty) {
              logger.info(`   ✅ Member ${memberId} just finished an EXAM in subject ${subjectDoc.id}!`);
              justBecameFree = true;
              break;
            }
            // Revisar clases por día de la semana
            const classesSnap = await subjectDoc.ref.collection("classes").get();
            for (const classDoc of classesSnap.docs) {
              const classData = classDoc.data();
              const dayOfWeek = classData.dayOfWeek;
              const endTimeStr = classData.endTime;
              if (typeof dayOfWeek !== "number" || typeof endTimeStr !== "string") continue;
              
              // Obtener el día de la semana actual en UTC
              const nowDayOfWeekUTC = now.getUTCDay() === 0 ? 7 : now.getUTCDay();
              
              // Solo revisar si coincide el día de la semana
              if (nowDayOfWeekUTC === dayOfWeek) {
                const [hour, minute] = endTimeStr.split(":").map(Number);
                // Crear fecha de fin de clase para HOY en UTC
                const classEndTimeTodayUTC = new Date(Date.UTC(
                  now.getUTCFullYear(), 
                  now.getUTCMonth(), 
                  now.getUTCDate(), 
                  hour, 
                  minute
                ));
                
                logger.info(`   🔍 Checking class ${subjectDoc.data().name}: endTime=${endTimeStr} (${classEndTimeTodayUTC.toISOString()}), window=${fiveMinutesAgo.toISOString()} to ${now.toISOString()}`);
                
                // Verificar si la clase terminó en los últimos 5 minutos
                if (classEndTimeTodayUTC >= fiveMinutesAgo && classEndTimeTodayUTC <= now) {
                  logger.info(`   ✅ Member ${memberId} just finished a CLASS: ${subjectDoc.data().name}!`);
                  justBecameFree = true;
                  break;
                }
              }
            }
            if (justBecameFree) break;
          }
          if (justBecameFree) break;
        }
        if (justBecameFree) {
          const userDoc = await userRef.get();
          if (userDoc.exists) {
            const availableMinutes = await calculateAvailableTime(userRef, now);
            recentlyFreedMembers.push({
              doc: userDoc,
              availableMinutes: availableMinutes
            });
          }
        }
      }

      // --- COOLDOWN: chequear lastFreeNotifyAt ---
      if (recentlyFreedMembers.length >= 2) {
        const groupRef = db.collection("groups").doc(groupDoc.id);
        const groupData = groupDoc.data();
        let lastFreeNotifyAt = groupData.lastFreeNotifyAt;
        let canNotify = true;
        if (lastFreeNotifyAt && lastFreeNotifyAt.toDate) {
          lastFreeNotifyAt = lastFreeNotifyAt.toDate();
        }
        if (lastFreeNotifyAt instanceof Date) {
          const diffMs = now.getTime() - lastFreeNotifyAt.getTime();
          if (diffMs < 30 * 60 * 1000) { // 30 minutos
            canNotify = false;
            logger.info(`   ⏳ Skipping notification for group "${groupName}" due to cooldown (${Math.floor(diffMs/60000)} min ago)`);
          }
        }
        if (canNotify) {
          logger.info(`   🎉 ${recentlyFreedMembers.length} members are now available simultaneously!`);
          await notifyOnAvailabilityChange(group, recentlyFreedMembers, now);
          await groupRef.update({ lastFreeNotifyAt: admin.firestore.Timestamp.fromDate(now) });
        }
      } else if (recentlyFreedMembers.length === 1) {
        logger.info(`Only 1 member became free. Waiting for more members to maximize coordination.`);
      } else {
        logger.info(`No members became free in group "${groupName}" during this check.`);
      }
    }
  } catch (error) {
    logger.error("❌ CRITICAL ERROR in notifyOnFreeMembers:", error);
  }
  logger.info("--- [notifyOnFreeMembers] Function End ---");
});

// ===================================================================
// == FUNCIÓN 2: NOTIFICAR CUANDO UN HORARIO CAMBIA (TRIGGERS) ==
// ===================================================================
exports.onUserEventChange = onDocumentWritten("users/{userId}/events/{eventId}", (event) => {
  return compareTimeFieldsAndNotify(event, "personal event", ["startTime", "endTime"]);
});

exports.onUserAssignmentChange = onDocumentWritten("users/{userId}/terms/{termId}/subjects/{subjectId}/assignments/{assignmentId}", (event) => {
  return compareTimeFieldsAndNotify(event, "assignment", ["dueDate"]);
});

exports.onUserExamChange = onDocumentWritten("users/{userId}/terms/{termId}/subjects/{subjectId}/exams/{examId}", (event) => {
  return compareTimeFieldsAndNotify(event, "exam", ["startTime", "endTime"]);
});

exports.onUserClassChange = onDocumentWritten("users/{userId}/terms/{termId}/subjects/{subjectId}/classes/{classId}", (event) => {
  return compareTimeFieldsAndNotify(event, "class", ["startTime", "endTime"]);
});

// ===================================================================
// == FUNCIONES DE AYUDA REUTILIZABLES ==
// ===================================================================

async function compareTimeFieldsAndNotify(event, eventType, timeFields) {
  const userId = event.params.userId;
  const beforeSnap = event.data.before;
  const afterSnap = event.data.after;

  if (!beforeSnap.exists || !afterSnap.exists) {
    logger.info(`New/deleted ${eventType} for user ${userId}. Triggering notification.`);
      await notifyOnScheduleUpdate(userId, {
        eventType,
        eventId: event.params.classId || event.params.examId || null,
        eventDataBefore: beforeSnap.exists ? beforeSnap.data() : null,
        eventDataAfter: afterSnap.exists ? afterSnap.data() : null
      });
    return;
  }

  const beforeData = beforeSnap.data();
  const afterData = afterSnap.data();
  let timeChanged = false;

  for (const field of timeFields) {
    const timeBefore = beforeData[field];
    const timeAfter = afterData[field];

    if (timeBefore === undefined || timeAfter === undefined) continue;

    if (isSignificantTimeChange(timeBefore, timeAfter, 10)) { // 10 minutes of threshold
      timeChanged = true;
      break;
    }
  }

  if (timeChanged) {
    logger.info(`A time field in [${timeFields.join(', ')}] changed for ${eventType} on user ${userId}. Triggering notification.`);
      await notifyOnScheduleUpdate(userId, {
        eventType,
        eventId: event.params.classId || event.params.examId || null,
        eventDataBefore: beforeData,
        eventDataAfter: afterData
      });
  } else {
    logger.info(`Change detected for ${eventType} on user ${userId}, but no time fields were modified. No notification sent.`);
  }
}


function isSignificantTimeChange(timeBefore, timeAfter, thresholdMinutes = 10) {
  if (timeBefore instanceof admin.firestore.Timestamp && timeAfter instanceof admin.firestore.Timestamp) {
    const diffMs = Math.abs(timeAfter.toMillis() - timeBefore.toMillis());
    return diffMs >= thresholdMinutes * 60 * 1000;
  } else if (typeof timeBefore === 'string' && typeof timeAfter === 'string') {
    // Asume formato "HH:mm"
    const [h1, m1] = timeBefore.split(':').map(Number);
    const [h2, m2] = timeAfter.split(':').map(Number);
    const diffMinutes = Math.abs((h2 * 60 + m2) - (h1 * 60 + m1));
    return diffMinutes >= thresholdMinutes;
  }
  return false;
}

async function notifyOnScheduleUpdate(userId, eventContext = {}) {
  try {
    const userDoc = await admin.firestore().collection("users").doc(userId).get();
    if (!userDoc.exists) {
      logger.error(`User document ${userId} not found.`);
      return;
    }
    const userName = userDoc.data().nick || "A user";

    const groupsQuery = admin.firestore().collection("groups").where("members", "array-contains", userId);
    const groupsSnapshot = await groupsQuery.get();

    if (groupsSnapshot.empty) {
      logger.info(`User ${userName} is not part of any group. No notifications needed.`);
      return;
    }

    logger.info(`User ${userName} is in ${groupsSnapshot.size} groups. Preparing notifications.`);

    // --- Opción B: Notificar si el cambio crea/elimina hueco compartido ---
    // 1. Obtener disponibilidad antes y después del cambio (solo para el usuario modificado)
    //    - before: event.data.before
    //    - after: event.data.after
    //    - Solo para clases/exámenes
    // 2. Obtener disponibilidad de los demás miembros
    // 3. Calcular huecos compartidos antes y después
    // 4. Notificar si hay cambios

    // Helper para obtener bloques libres de un usuario (solo clases/exams, próximos 7 días)
    async function getFreeBlocksForUser(userId, ignoreEventId = null, ignoreEventData = null) {
      const userRef = admin.firestore().collection("users").doc(userId);
      const freeBlocks = [];
      const now = new Date();
      for (let dayOffset = 0; dayOffset < 7; dayOffset++) {
        const date = new Date(now.getTime() + dayOffset * 24 * 60 * 60 * 1000);
        const weekday = date.getUTCDay() === 0 ? 7 : date.getUTCDay();
        let busyIntervals = [];
        // Exams
        const termsSnap = await userRef.collection("terms").get();
        for (const termDoc of termsSnap.docs) {
          const subjectsSnap = await termDoc.ref.collection("subjects").get();
          for (const subjectDoc of subjectsSnap.docs) {
            const examsSnap = await subjectDoc.ref.collection("exams")
              .where("startTime", ">=", admin.firestore.Timestamp.fromDate(new Date(date.getFullYear(), date.getMonth(), date.getDate(), 0, 0)))
              .where("startTime", "<", admin.firestore.Timestamp.fromDate(new Date(date.getFullYear(), date.getMonth(), date.getDate(), 23, 59)))
              .get();
            for (const examDoc of examsSnap.docs) {
              if (ignoreEventId && examDoc.id === ignoreEventId) {
                if (ignoreEventData && ignoreEventData.startTime && ignoreEventData.endTime) {
                  busyIntervals.push({
                    start: ignoreEventData.startTime.toDate(),
                    end: ignoreEventData.endTime.toDate()
                  });
                }
                continue;
              }
              const examData = examDoc.data();
              if (examData.startTime && examData.endTime) {
                busyIntervals.push({
                  start: examData.startTime.toDate(),
                  end: examData.endTime.toDate()
                });
              }
            }
            // Clases
            const classesSnap = await subjectDoc.ref.collection("classes").where("dayOfWeek", "==", weekday).get();
            for (const classDoc of classesSnap.docs) {
              if (ignoreEventId && classDoc.id === ignoreEventId) {
                if (ignoreEventData && ignoreEventData.startTime && ignoreEventData.endTime) {
                  // Si el evento modificado tiene start/endTime
                  const startStr = ignoreEventData.startTime;
                  const endStr = ignoreEventData.endTime;
                  if (typeof startStr === "string" && typeof endStr === "string") {
                    const [sh, sm] = startStr.split(":").map(Number);
                    const [eh, em] = endStr.split(":").map(Number);
                    const start = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate(), sh, sm));
                    const end = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate(), eh, em));
                    busyIntervals.push({ start, end });
                  }
                }
                continue;
              }
              const classData = classDoc.data();
              const startStr = classData.startTime;
              const endStr = classData.endTime;
              if (typeof startStr === "string" && typeof endStr === "string") {
                const [sh, sm] = startStr.split(":").map(Number);
                const [eh, em] = endStr.split(":").map(Number);
                const start = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate(), sh, sm));
                const end = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate(), eh, em));
                busyIntervals.push({ start, end });
              }
            }
          }
        }
        // Ordenar y fusionar intervalos ocupados
        busyIntervals.sort((a, b) => a.start - b.start);
        // Fusionar intervalos solapados
        const merged = [];
        for (const interval of busyIntervals) {
          if (merged.length === 0) merged.push(interval);
          else {
            const last = merged[merged.length - 1];
            if (interval.start <= last.end) {
              last.end = new Date(Math.max(last.end, interval.end));
            } else {
              merged.push(interval);
            }
          }
        }
        // Calcular bloques libres entre 6am y 9pm
        let lastEnd = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate(), 6, 0));
        const dayEnd = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate(), 21, 0));
        for (const interval of merged) {
          if (interval.start > lastEnd) {
            freeBlocks.push({
              day: date.toISOString().slice(0, 10),
              start: lastEnd,
              end: interval.start
            });
          }
          lastEnd = new Date(Math.max(lastEnd, interval.end));
        }
        if (lastEnd < dayEnd) {
          freeBlocks.push({
            day: date.toISOString().slice(0, 10),
            start: lastEnd,
            end: dayEnd
          });
        }
      }
      return freeBlocks;
    }

    // 1. Disponibilidad antes y después del cambio para el usuario modificado
    //    - Si el evento es clase/exam, ignora el evento modificado en before/after
    //    - before: ignora el evento modificado (como si no existiera)
    //    - after: incluye el evento modificado con los nuevos datos
    //    - Para simplicity, solo para clases/exams
    //    - eventId y eventData deben venir del trigger
    //    - Solo para clases/exams

    // 2. Disponibilidad de los demás miembros
    //    - Para cada miembro, getFreeBlocksForUser

    // 3. Calcular huecos compartidos antes y después
    //    - Intersectar bloques libres de todos los miembros

    // 4. Notificar si hay cambios

    // --- Obtener eventId y eventData del trigger ---
    // Solo para clases/exams
    // eventId: event.params.classId o event.params.examId
    // eventDataBefore: event.data.before.data()
    // eventDataAfter: event.data.after.data()
    // Si no es trigger de clase/exam, usar notificación genérica

    // Usar el contexto recibido por parámetro
    let eventId = null;
    let eventDataBefore = null;
    let eventDataAfter = null;
    let isClassOrExam = false;
    if (eventContext && (eventContext.eventType === "class" || eventContext.eventType === "exam") && eventContext.eventId) {
      eventId = eventContext.eventId;
      eventDataBefore = eventContext.eventDataBefore;
      eventDataAfter = eventContext.eventDataAfter;
      isClassOrExam = true;
    }

    for (const groupDoc of groupsSnapshot.docs) {
      const group = groupDoc.data();
      const groupName = group.name || "Unnamed Group";
      const uidsToNotify = (group.members || []).filter(memberId => memberId !== userId);

      if (uidsToNotify.length > 0) {
        let notificationBody = `${userName} has updated their calendar. Their availability may have changed.`;

        if (isClassOrExam && eventId && eventDataBefore && eventDataAfter) {
          // 1. Disponibilidad antes y después del cambio para el usuario modificado
          const freeBefore = await getFreeBlocksForUser(userId, eventId, null); // before: ignora el evento modificado
          const freeAfter = await getFreeBlocksForUser(userId, null, eventDataAfter); // after: incluye el evento modificado
          // 2. Disponibilidad de los demás miembros
          const groupFreeBlocksBefore = [freeBefore];
          const groupFreeBlocksAfter = [freeAfter];
          for (const otherId of group.members) {
            if (otherId === userId) continue;
            const otherFree = await getFreeBlocksForUser(otherId);
            groupFreeBlocksBefore.push(otherFree);
            groupFreeBlocksAfter.push(otherFree);
          }
          // 3. Intersectar bloques libres
          function intersectFreeBlocks(freeBlocksList) {
            // Agrupar por día
            const byDay = {};
            for (const blocks of freeBlocksList) {
              for (const block of blocks) {
                if (!byDay[block.day]) byDay[block.day] = [];
                byDay[block.day].push(block);
              }
            }
            // Para cada día, intersectar los bloques
            const shared = [];
            for (const day in byDay) {
              // Tomar los intervalos de todos los miembros para ese día
              const intervals = byDay[day].map(b => ({ start: b.start, end: b.end }));
              // Intersección de intervalos
              let current = intervals[0];
              for (let i = 1; i < intervals.length; i++) {
                const next = intervals[i];
                const start = new Date(Math.max(current.start, next.start));
                const end = new Date(Math.min(current.end, next.end));
                if (start < end) {
                  current = { start, end };
                } else {
                  current = null;
                  break;
                }
              }
              if (current) {
                shared.push({ day, start: current.start, end: current.end });
              }
            }
            return shared;
          }
          const sharedBefore = intersectFreeBlocks(groupFreeBlocksBefore);
          const sharedAfter = intersectFreeBlocks(groupFreeBlocksAfter);
          // 4. Comparar huecos antes y después
          // Si hay huecos en sharedBefore que no están en sharedAfter, se eliminaron
          // Si hay huecos en sharedAfter que no están en sharedBefore, se crearon
          function formatBlock(block) {
            const dayNames = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"];
            const d = new Date(block.day);
            const dayName = dayNames[d.getUTCDay()];
            const start = block.start.toISOString().substr(11,5);
            const end = block.end.toISOString().substr(11,5);
            return `${dayName} ${start}-${end}`;
          }
          const beforeSet = new Set(sharedBefore.map(b => b.day+"|"+b.start+"|"+b.end));
          const afterSet = new Set(sharedAfter.map(b => b.day+"|"+b.start+"|"+b.end));
          const removed = sharedBefore.filter(b => !afterSet.has(b.day+"|"+b.start+"|"+b.end));
          const added = sharedAfter.filter(b => !beforeSet.has(b.day+"|"+b.start+"|"+b.end));
          if (removed.length > 0 || added.length > 0) {
            notificationBody = `${userName} changed their schedule.`;
            if (removed.length > 0) {
              notificationBody += ` Removed shared free block(s): ${removed.map(formatBlock).join(", ")}.`;
            }
            if (added.length > 0) {
              notificationBody += ` Added shared free block(s): ${added.map(formatBlock).join(", ")}.`;
            }
          } else {
            notificationBody = `${userName} changed their schedule, but shared free blocks remain the same.`;
          }
        }
        await sendNotification(groupName, uidsToNotify, notificationBody);
      }
    }
  } catch (error) {
    logger.error(`❌ CRITICAL ERROR in notifyOnScheduleUpdate for user ${userId}:`, error);
  }
}

// ===================================================================
// == FUNCIÓN AUXILIAR: CALCULAR TIEMPO DISPONIBLE ==
// ===================================================================
async function calculateAvailableTime(userRef, currentTime) {
  try {
    const upcomingEvents = [];
    const searchUntil = new Date(currentTime.getTime() + 4 * 60 * 60 * 1000); // Buscar en las próximas 4 horas

    // 1. Eventos personales
    const personalEventsSnap = await userRef.collection("events")
      .where("startTime", ">", admin.firestore.Timestamp.fromDate(currentTime))
      .where("startTime", "<=", admin.firestore.Timestamp.fromDate(searchUntil))
      .orderBy("startTime", "asc")
      .limit(1)
      .get();

    if (!personalEventsSnap.empty) {
      const nextEvent = personalEventsSnap.docs[0].data();
      upcomingEvents.push(nextEvent.startTime.toDate());
    }

    // 2. Exámenes próximos
    const termsSnap = await userRef.collection("terms").get();
    for (const termDoc of termsSnap.docs) {
      const subjectsSnap = await termDoc.ref.collection("subjects").get();
      for (const subjectDoc of subjectsSnap.docs) {
        const examsSnap = await subjectDoc.ref.collection("exams")
          .where("startTime", ">", admin.firestore.Timestamp.fromDate(currentTime))
          .where("startTime", "<=", admin.firestore.Timestamp.fromDate(searchUntil))
          .orderBy("startTime", "asc")
          .limit(1)
          .get();

        if (!examsSnap.empty) {
          const nextExam = examsSnap.docs[0].data();
          upcomingEvents.push(nextExam.startTime.toDate());
        }
      }
    }

    // 3. Clases próximas (hoy)
    const currentDayOfWeek = currentTime.getUTCDay() === 0 ? 7 : currentTime.getUTCDay();
    for (const termDoc of termsSnap.docs) {
      const subjectsSnap = await termDoc.ref.collection("subjects").get();
      for (const subjectDoc of subjectsSnap.docs) {
        const classesSnap = await subjectDoc.ref.collection("classes")
          .where("dayOfWeek", "==", currentDayOfWeek)
          .get();

        for (const classDoc of classesSnap.docs) {
          const classData = classDoc.data();
          const startTimeStr = classData.startTime;
          if (typeof startTimeStr === "string") {
            const [hour, minute] = startTimeStr.split(":").map(Number);
            const classStartTime = new Date(Date.UTC(
              currentTime.getUTCFullYear(),
              currentTime.getUTCMonth(),
              currentTime.getUTCDate(),
              hour,
              minute
            ));

            if (classStartTime > currentTime && classStartTime <= searchUntil) {
              upcomingEvents.push(classStartTime);
            }
          }
        }
      }
    }

    // Encontrar el evento más cercano
    if (upcomingEvents.length === 0) {
      return 240; // 4 horas si no hay eventos próximos
    }

    const nextEventTime = upcomingEvents.sort((a, b) => a - b)[0];
    const availableMinutes = Math.floor((nextEventTime - currentTime) / (1000 * 60));
    return Math.max(0, availableMinutes); // Nunca retornar negativo

  } catch (error) {
    logger.error("Error calculating available time:", error);
    return 60; // Default: 1 hora
  }
}

async function notifyOnAvailabilityChange(groupData, freedMembers, currentTime) {
    const groupName = groupData.name || "Unnamed Group";
    const memberUids = groupData.members || [];
    const freedNames = freedMembers.map(m => m.doc.data().nick || "A member");
    const freedUids = freedMembers.map(m => m.doc.id);

    // Calcular el tiempo mínimo disponible entre todos los miembros libres
    const minAvailableTime = Math.min(...freedMembers.map(m => m.availableMinutes));
    
    // Formatear el tiempo disponible
    let timeAvailableText = "";
    if (minAvailableTime >= 120) {
      const hours = Math.floor(minAvailableTime / 60);
      timeAvailableText = `for the next ${hours}+ hours`;
    } else if (minAvailableTime >= 60) {
      timeAvailableText = `for the next hour`;
    } else {
      timeAvailableText = `for the next ${minAvailableTime} minutes`;
    }

    // Construir mensaje mejorado
    const memberCount = freedMembers.length;
    const notificationBody = `${memberCount} members (${freedNames.join(", ")}) are now available ${timeAvailableText}. Great time for a group session!`;
    
    const uidsToNotify = memberUids.filter(uid => !freedUids.includes(uid));

  if (uidsToNotify.length > 0) {
    await sendNotification(groupName, uidsToNotify, notificationBody);
    logger.info(`   📢 Notification sent: "${notificationBody}"`);
  } else {
    logger.info(`- No other members in the group to notify.`);
  }
}

async function sendNotification(groupName, uidsToNotify, notificationBody) {
  logger.info(`   📬 Preparing to notify UIDs: ${uidsToNotify.join(", ")}`);
  const tokens = await getTokensForUids(uidsToNotify);
  if (tokens.length > 0) {
    logger.info(`   📲 Found ${tokens.length} FCM tokens. Sending notification...`);
    const message = {
      notification: { title: `Update from ${groupName}`, body: notificationBody },
      tokens: tokens,
    };
    await admin.messaging().sendEachForMulticast(message);
    logger.info(`   ✅ Notification sent successfully.`);
  } else {
    logger.warn(`   ⚠️ No FCM tokens found for users to notify.`);
  }
}

async function getTokensForUids(uids) {
  if (uids.length === 0) return [];
  
  const tokens = new Set();
  const db = admin.firestore();
  
  for (const uid of uids) {
    const userDoc = await db.collection("users").doc(uid).get();
    if (userDoc.exists) {
      const fcmTokens = userDoc.data().fcmTokens || [];
      fcmTokens.forEach(token => tokens.add(token));
    }
  }
  return Array.from(tokens);
}