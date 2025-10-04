const { onSchedule } = require("firebase-functions/v2/scheduler");
const { logger } = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.notifyOnFreeMembers = onSchedule("every 5 minutes", async (event) => {
  logger.info("--- Function Start ---");

  const now = new Date();
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