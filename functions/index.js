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

  const now = new Date();
  const fiveMinutesAgo = new Date(now.getTime() - 5 * 60 * 1000);
  const db = admin.firestore();

  logger.info(`Checking for events that ended between (UTC): ${fiveMinutesAgo.toISOString()} and ${now.toISOString()}`);

  try {
    const groupsSnapshot = await db.collection("groups").get();
    logger.info(`Found ${groupsSnapshot.size} groups to process.`);

    for (const groupDoc of groupsSnapshot.docs) {
      const group = groupDoc.data();
      const groupName = group.name || "Unnamed Group";
      const memberUids = group.members || [];
      
      if (memberUids.length < 1) continue;
      logger.info(`Processing group: "${groupName}"`);

      const recentlyFreedMemberDocs = [];

      for (const memberId of memberUids) {
        const userRef = db.collection("users").doc(memberId);
        let justBecameFree = false;

        // 1. Revisar eventos personales con Timestamp
        const personalEventsSnap = await userRef.collection("events")
          .where("endTime", ">=", admin.firestore.Timestamp.fromDate(fiveMinutesAgo))
          .where("endTime", "<=", admin.firestore.Timestamp.fromDate(now))
          .get();
        
        if (!personalEventsSnap.empty) {
          logger.info(`   ✅ Member ${memberId} just finished a PERSONAL event!`);
          justBecameFree = true;
        }

        // 2. Revisar eventos académicos (exámenes y clases)
        if (!justBecameFree) {
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
              
              const classesSnap = await subjectDoc.ref.collection("classes").get();
              for (const classDoc of classesSnap.docs) {
                const classData = classDoc.data();
                const dayOfWeek = classData.dayOfWeek;
                const endTimeStr = classData.endTime;

                if (typeof dayOfWeek !== "number" || typeof endTimeStr !== "string") continue;

                const nowDayOfWeekUTC = now.getUTCDay() === 0 ? 7 : now.getUTCDay();
                
                if (nowDayOfWeekUTC === dayOfWeek) {
                  const [hour, minute] = endTimeStr.split(":").map(Number);
                  const classEndTimeTodayUTC = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate(), hour, minute));
                  
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
        }

        if (justBecameFree) {
          const userDoc = await userRef.get();
          if (userDoc.exists) {
            recentlyFreedMemberDocs.push(userDoc);
          }
        }
      }

      if (recentlyFreedMemberDocs.length > 0) {
        await notifyOnAvailabilityChange(group, recentlyFreedMemberDocs);
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
    await notifyOnScheduleUpdate(userId);
    return;
  }

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
    await notifyOnScheduleUpdate(userId);
  } else {
    logger.info(`Change detected for ${eventType} on user ${userId}, but no time fields were modified. No notification sent.`);
  }
}

async function notifyOnScheduleUpdate(userId) {
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
        // CORRECCIÓN: Usa backticks (`) para la interpolación
        const notificationBody = `${userName} has updated their calendar. Their availability may have changed.`;
        await sendNotification(groupName, uidsToNotify, notificationBody);
      }
    }
  } catch (error) {
    logger.error(`❌ CRITICAL ERROR in notifyOnScheduleUpdate for user ${userId}:`, error);
  }
}

async function notifyOnAvailabilityChange(groupData, freedMemberDocs) {
    const groupName = groupData.name || "Unnamed Group";
    const memberUids = groupData.members || [];
    const freedNames = freedMemberDocs.map(doc => doc.data().nick || "A member");
    const freedUids = freedMemberDocs.map(doc => doc.id);

    // CORRECCIÓN: Usa backticks (`) para la interpolación
    const notificationBody = `Now available: ${freedNames.join(", ")}.`;
    const uidsToNotify = memberUids.filter(uid => !freedUids.includes(uid));

    if (uidsToNotify.length > 0) {
        await sendNotification(groupName, uidsToNotify, notificationBody);
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