const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Initialize Firebase Admin SDK (only once)
try {
  admin.initializeApp();
} catch (e) {
  console.error("Firebase Admin SDK initialization error:", e);
}

const db = admin.firestore();

/**
 * Scheduled function to transition students to alumni based on graduation year.
 * Runs daily at a specific time (e.g., 2:00 AM UTC). Adjust the schedule as needed.
 * See https://firebase.google.com/docs/functions/schedule-functions
 */
exports.transitionStudentsToAlumni = functions.pubsub
  .schedule("every day 02:00") // Runs daily at 2 AM (adjust timezone/time if needed)
  .timeZone("Etc/UTC") // Example: Use UTC timezone
  .onRun(async (context) => {
    console.log("Running scheduled function: transitionStudentsToAlumni");

    const currentYear = new Date().getFullYear();
    const graduatedUsersToUpdate = [];

    try {
      // 1. Find profiles of users expected to graduate before the current year
      const profilesSnapshot = await db
        .collection("profiles")
        .where("graduationYear", "<", currentYear)
        .get();

      if (profilesSnapshot.empty) {
        console.log("No profiles found with graduationYear before", currentYear);
        // Still need to check users collection for potential stragglers
        // return null; // Or proceed to check users collection directly
      }

      const potentiallyGraduatedUids = profilesSnapshot.docs.map(
        (doc) => doc.id,
      ); // Get UIDs from profile docs
      console.log(
        `Found ${potentiallyGraduatedUids.length} profiles potentially graduated.`,
      );

      if (potentiallyGraduatedUids.length === 0) {
         console.log("No potentially graduated UIDs found from profiles.");
         // It's possible a profile was deleted but user exists,
         // or graduationYear wasn't set. We might need a broader check
         // on the users collection if this becomes an issue.
         return null;
      }


      // 2. Query the 'users' collection to find users who are STILL 'student'
      //    among those potentially graduated. Firestore limits 'in' to 30 items per query
      //    so we might need batching if many users graduate at once.

      // Process UIDs in batches of 30 for the 'in' query limitation
      const MAX_IN_QUERY_SIZE = 30; // Firestore 'in' query limit
      for (let i = 0; i < potentiallyGraduatedUids.length; i += MAX_IN_QUERY_SIZE) {
          const uidsBatch = potentiallyGraduatedUids.slice(i, i + MAX_IN_QUERY_SIZE);

          console.log(`Checking user roles for UIDs batch: ${uidsBatch.join(", ")}`);

          const usersSnapshot = await db
            .collection("users")
            .where(admin.firestore.FieldPath.documentId(), "in", uidsBatch)
            .where("role", "==", "student") // Only find those still marked as student
            .get();

          usersSnapshot.forEach((doc) => {
            console.log(`User ${doc.id} needs role update to alumni.`);
            graduatedUsersToUpdate.push(doc.id);
          });
      }


      if (graduatedUsersToUpdate.length === 0) {
        console.log(
          "No users found with role 'student' among the potentially graduated.",
        );
        return null;
      }

      // 3. Use a batched write to update the roles efficiently
      const batch = db.batch();
      graduatedUsersToUpdate.forEach((uid) => {
        const userRef = db.collection("users").doc(uid);
        batch.update(userRef, {
          role: "alumni",
          // Optionally update the profile too (e.g., add alumniSince)
          // This requires another read or careful structuring
        });
        // Optional: Add alumniSince to profile document in the same batch
        const profileRef = db.collection("profiles").doc(uid);
        batch.set(profileRef, { alumniSince: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });

      });

      await batch.commit();
      console.log(
        `Successfully updated role to 'alumni' for ${graduatedUsersToUpdate.length} users.`,
      );
      return null;
    } catch (error) {
      console.error("Error transitioning students to alumni:", error);
      // Consider adding error reporting (e.g., to Firebase Crashlytics or logging service)
      return null;
    }
  });