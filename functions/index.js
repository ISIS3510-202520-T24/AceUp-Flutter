const { onSchedule } = require("firebase-functions/v2/scheduler");
const { onDocumentWritten } = require("firebase-functions/v2/firestore");
const { logger } = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// Función de ayuda para obtener la fecha actual en una zona horaria específica (ej. UTC-5)
function getNowInTimezone(offsetHours = -5) {
  const nowUtc = new Date();
  const nowInTimezone = new Date(nowUtc.getTime() + offsetHours * 60 * 60 * 1000);
  return nowInTimezone;
}

exports.notifyOnFreeMembers = onSchedule("every 5 minutes", async (event) => {
  logger.info("--- Function Start ---");

  const now = getNowInTimezone(-5);;
  const fiveMinutesAgo = new Date(now.getTime() - 5 * 60 * 1000);
  const db = admin.firestore();

  logger.info(`Checking for events that ended between: ${fiveMinutesAgo.toISOString()} and ${now.toISOString()}`);

  try {
    const groupsSnapshot = await db.collection("groups").get();
    logger.info(`Found ${groupsSnapshot.size} groups to process.`);

    for (const groupDoc of groupsSnapshot.docs) {
      const group = groupDoc.data();
      const groupName = group.name || "Unnamed Group";
      const memberUids = group.members || [];
      logger.info(`Processing group: "${groupName}" with ${memberUids.length} members.`);

      if (memberUids.length < 1) continue;

      const recentlyFreedMemberDocs = [];

      for (const memberId of memberUids) {
        logger.debug(`-> Checking member: ${memberId}`);
        const userRef = db.collection("users").doc(memberId);
        let justBecameFree = false;

        // 1. Revisar eventos personales (ruta simple)
        const personalEventsSnap = await userRef.collection("events")
          .where("endTime", ">=", admin.firestore.Timestamp.fromDate(fiveMinutesAgo))
          .where("endTime", "<=", admin.firestore.Timestamp.fromDate(now))
          .get();
        
        if (!personalEventsSnap.empty) {
          logger.info(`   ✅ Member ${memberId} just finished a PERSONAL event!`);
          justBecameFree = true;
        }

        // ===================================================================
        // == CORRECCIÓN CLAVE: Búsqueda anidada para eventos académicos ==
        // ===================================================================
        if (!justBecameFree) {
          logger.debug(`   - No personal events found. Checking academic events for ${memberId}...`);
          // 2. Revisar eventos académicos (ruta anidada)
          const termsSnap = await userRef.collection("terms").get();

          // Usamos un bucle 'for...of' para poder usar 'await' dentro y salir temprano
          for (const termDoc of termsSnap.docs) {
            const subjectsSnap = await termDoc.ref.collection("subjects").get();
            for (const subjectDoc of subjectsSnap.docs) {
              
              // Buscar en la subcolección 'exams'
              const examsSnap = await subjectDoc.ref.collection("exams")
                .where("endTime", ">=", admin.firestore.Timestamp.fromDate(fiveMinutesAgo))
                .where("endTime", "<=", admin.firestore.Timestamp.fromDate(now))
                .get();

              if (!examsSnap.empty) {
                logger.info(`   ✅ Member ${memberId} just finished an EXAM in subject ${subjectDoc.id}!`);
                justBecameFree = true;
                break; // Salir del bucle de materias
              }
            }
            if (justBecameFree) {
              break; // Salir del bucle de semestres
            }
          }
        }
        
        // La lógica para las 'classes' es más compleja y se puede añadir después si es necesario
        if (!justBecameFree) {
          logger.debug(`   - No Timestamp events found. Checking recurring classes for ${memberId}...`);
          const termsSnap = await userRef.collection("terms").get();

          for (const termDoc of termsSnap.docs) {
            const subjectsSnap = await termDoc.ref.collection("subjects").get();
            for (const subjectDoc of subjectsSnap.docs) {
              const classesSnap = await subjectDoc.ref.collection("classes").get();

              for (const classDoc of classesSnap.docs) {
                const classData = classDoc.data();
                const dayOfWeek = classData.dayOfWeek; // Es un número (ej. 1 para Lunes)
                const endTimeStr = classData.endTime; // Es un string (ej. "10:00")

                // Asegurarnos de que tenemos los datos necesarios
                if (typeof dayOfWeek !== "number" || typeof endTimeStr !== "string") continue;

                // Comprobar si el día de la semana de "ahora" coincide con el de la clase
                // Nota: en JS, getDay() es Domingo=0, Lunes=1.. Sábado=6. Firestore usa Lunes=1.. Domingo=7.
                // Hacemos un ajuste para que coincidan.
                const nowDayOfWeek = now.getDay() === 0 ? 7 : now.getDay();
                
                if (nowDayOfWeek === dayOfWeek) {
                  // Calcular la hora de fin de la clase para el día de HOY
                  const [hour, minute] = endTimeStr.split(":").map(Number);
                  const classEndTimeToday = new Date(now.getFullYear(), now.getMonth(), now.getDate(), hour, minute);

                  const classEndTimeTodayInTimezone = new Date(classEndTimeToday.getTime() - (5 * 60 * 60 * 1000));
                  
                  logger.debug(`   - Checking class: day=${dayOfWeek}, endTime=${endTimeStr}. Calculated endTime in UTC-5: ${classEndTimeToday.toLocaleString("en-US", {timeZone: "America/Bogota"})}`);

                  // Comprobar si esa hora de fin cae en nuestro rango de 5 minutos
                  if (classEndTimeToday >= fiveMinutesAgo && classEndTimeToday <= now) {
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
        }


        if (justBecameFree) {
          const userDoc = await userRef.get();
          if (userDoc.exists) {
            recentlyFreedMemberDocs.push(userDoc);
          }
        }
      }

      if (recentlyFreedMemberDocs.length > 0) {
        const freedNames = recentlyFreedMemberDocs.map(doc => doc.data().nick || "A member");
        const freedUids = recentlyFreedMemberDocs.map(doc => doc.id);

        logger.info(`   🎉 Members who just became free in "${groupName}": ${freedNames.join(", ")}`);

        const notificationTitle = `Update from ${groupName}`;
        const notificationBody = `Now available: ${freedNames.join(", ")}.`;

        // Obtener los UIDs de los miembros a notificar (todos EXCEPTO los que quedaron libres)
        const uidsToNotify = memberUids.filter(uid => !freedUids.includes(uid));
        
        if (uidsToNotify.length > 0) {
          logger.info(`   📬 Preparing to notify UIDs: ${uidsToNotify.join(", ")}`);
          const tokens = await getTokensForUids(uidsToNotify);

          if (tokens.length > 0) {
            logger.info(`   📲 Found ${tokens.length} FCM tokens. Sending notification...`);
            const message = {
              notification: { title: notificationTitle, body: notificationBody },
              tokens: tokens,
            };
            await admin.messaging().sendEachForMulticast(message);
            logger.info(`   ✅ Notification sent successfully.`);
          } else {
            logger.warn(`   ⚠️ No FCM tokens found for users to notify in group "${groupName}".`);
          }
        } else {
          logger.info(`   - No other members in the group to notify.`);
        }
      } else {
        logger.info(`No members became free in group "${groupName}" during this check.`);
      }
    }
  } catch (error) {
    logger.error("❌ CRITICAL ERROR in notifyOnFreeMembers function:", error);
  }
  logger.info("--- Function End ---");
});


// ===================================================================
// == TRIGGERS: El punto de entrada ==
// ===================================================================
exports.onUserEventChange = onDocumentWritten("users/{userId}/events/{eventId}", (event) => {
  return compareTimeFieldsAndNotify(event, "personal event", ["startTime", "endTime"]);
});

exports.onUserAssignmentChange = onDocumentWritten("users/{userId}/terms/{termId}/subjects/{subjectId}/assignments/{assignmentId}", (event) => {
  return compareTimeFieldsAndNotify(event, "assignment", ["dueTime"]);
});

exports.onUserExamChange = onDocumentWritten("users/{userId}/terms/{termId}/subjects/{subjectId}/exams/{examId}", (event) => {
  return compareTimeFieldsAndNotify(event, "exam", ["startTime", "endTime"]);
});

exports.onUserClassChange = onDocumentWritten("users/{userId}/terms/{termId}/subjects/{subjectId}/classes/{classId}", (event) => {
  return compareTimeFieldsAndNotify(event, "class", ["startTime", "endTime"]);
});

// ===================================================================
// == FUNCIÓN DE AYUDA PARA COMPARAR CAMPOS DE TIEMPO ==
// ===================================================================
async function compareTimeFieldsAndNotify(event, eventType, timeFields) {
  const userId = event.params.userId;
  const beforeSnap = event.data.before;
  const afterSnap = event.data.after;

  // Creado o borrado -> notificar
  if (!beforeSnap.exists || !afterSnap.exists) {
    logger.info(`New/deleted ${eventType} for user ${userId}. Triggering notification.`);
    await notifyGroupMembers(userId, eventType);
    return;
  }

  // Actualizado -> comparar campos
  const beforeData = beforeSnap.data();
  const afterData = afterSnap.data();
  let timeChanged = false;

  for (const field of timeFields) {
    const timeBefore = beforeData[field];
    const timeAfter = afterData[field];

    if (timeBefore === undefined || timeAfter === undefined) continue;

    if (timeBefore instanceof admin.firestore.Timestamp && timeAfter instanceof admin.firestore.Timestamp) {
      if (!timeBefore.isEqual(timeAfter)) {
        timeChanged = true;
        break;
      }
    } else if (typeof timeBefore === 'string' && typeof timeAfter === 'string') {
      if (timeBefore !== timeAfter) {
        timeChanged = true;
        break;
      }
    }
  }

  if (timeChanged) {
    logger.info(`A time field in [${timeFields.join(', ')}] changed for ${eventType} on user ${userId}. Triggering notification.`);
    await notifyGroupMembers(userId, eventType);
  } else {
    logger.info(`Change detected for ${eventType} on user ${userId}, but no time fields were modified. No notification sent.`);
  }
}

// ===================================================================
// == FUNCIÓN DE AYUDA PARA ENVIAR LAS NOTIFICACIONES ==
// ===================================================================
async function notifyGroupMembers(userId, eventTypeDescription) {
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

    for (const groupDoc of groupsSnapshot.docs) {
      const group = groupDoc.data();
      const groupName = group.name || "Unnamed Group";
      const uidsToNotify = (group.members || []).filter(memberId => memberId !== userId);

      if (uidsToNotify.length > 0) {
        logger.info(`   - Group "${groupName}": Notifying ${uidsToNotify.length} members.`);
        const tokens = await getTokensForUids(uidsToNotify);
        if (tokens.length > 0) {
          const notificationTitle = `Update from ${groupName}`;
          const notificationBody = `${userName} has updated their calendar. Their availability may have changed.`;
          const message = {
            notification: { title: notificationTitle, body: notificationBody },
            tokens: tokens,
          };
          await admin.messaging().sendEachForMulticast(message);
          logger.info(`     ✅ Notifications sent successfully for group "${groupName}".`);
        } else {
          logger.warn(`     ⚠️ No FCM tokens found for members of group "${groupName}".`);
        }
      }
    }
  } catch (error) {
    logger.error(`❌ CRITICAL ERROR in notifyGroupMembers for user ${userId}:`, error);
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