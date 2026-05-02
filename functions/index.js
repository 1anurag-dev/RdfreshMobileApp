// 1. Import the Admin SDK and the Firestore v2 trigger
const admin = require("firebase-admin");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");

// 2. Initialize the Admin SDK so we can talk to FCM and Firestore
admin.initializeApp();

/**
 * LINE-BY-LINE EXPLANATION:
 * exports.sendNotification: This defines the name of your function.
 * onDocumentCreated("notifications/{id}"): This tells Firebase to wake up
 * whenever a new document is added to the "notifications" collection.
 */
exports.sendNotification = onDocumentCreated("notifications/{id}", async (event) => {
    const data = event.data.data(); // This is the data from your new notification document
    const userId = data.notifyTo;   // The user UID you want to alert

    try {
        // Find the user's FCM token from your 'users' collection
        const userDoc = await admin.firestore().collection("users").doc(userId).get();
        const fcmToken = userDoc.data()?.fcmToken;

        if (!fcmToken) {
            logger.error(`No token found for user ${userId}`);
            return;
        }

        // Construct the message payload for FCM
        const message = {
            notification: {
                title: data.title,
                body: data.message,
            },
            data: {
                orderId: data.orderId || "", // Deep link info
                type: data.type || "alert",
            },
            token: fcmToken,
        };

        // Send the push notification
        await admin.messaging().send(message);
        logger.info(`Notification sent to user: ${userId}`);
    } catch (error) {
        logger.error("Failed to send notification:", error);
    }
});