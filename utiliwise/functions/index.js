const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendBookingNotification = functions.firestore
    .document("bookings/{bookingId}")
    .onCreate(async (snap, context) => {
      const booking = snap.data();
      const workerId = booking.workerId;

      const workerDoc = await admin.firestore()
          .collection("workers")
          .doc(workerId)
          .get();

      const fcmToken = workerDoc.data().fcmToken;

      const message = {
        notification: {
          title: "New Booking Request",
          body: "You have a new booking request",
        },
        token: fcmToken,
      };

      return admin.messaging().send(message);
    });
