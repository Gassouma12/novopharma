/* eslint-disable indent */
import * as functions from "firebase-functions/v1";
import * as admin from "firebase-admin";

// Don't initialize here - it's initialized in index.ts

/**
 * Sends a notification to all users when a new training is created
 */
export const onNewTrainingCreated = functions.firestore
    .document("blogPosts/{postId}")
    .onCreate(async (snap, context) => {
        const post = snap.data();
        const postId = context.params.postId;

        // Only send notification if it's a training post
        if (post.type !== "formation") {
            console.log(
                `Post ${postId} is not a training, ` +
                "skipping notification"
            );
            return {success: true, skipped: true};
        }

        console.log(`New training created: ${postId}`);

        try {
            // Get all users
            const usersSnapshot = await admin
                .firestore()
                .collection("users")
                .get();

            const batch = admin.firestore().batch();
            const notifications: Array<{
                token: string;
                notification: admin.messaging.Notification;
                data: { [key: string]: string };
            }> = [];

            for (const userDoc of usersSnapshot.docs) {
                const userId = userDoc.id;
                const userData = userDoc.data();
                const fcmToken = userData.fcmToken;

                // Create notification document
                const notificationRef = admin
                    .firestore()
                    .collection("users")
                    .doc(userId)
                    .collection("notifications")
                    .doc();

                batch.set(notificationRef, {
                    userId: userId,
                    title: "Nouvelle formation disponible !",
                    body:
                        post.title ||
                        "Une nouvelle formation vient d'être publiée",
                    type: "newTraining",
                    resourceId: postId,
                    imageUrl: post.imageUrl || null,
                    isRead: false,
                    createdAt: admin.firestore.FieldValue.serverTimestamp(),
                });

                // Prepare FCM message if user has a token
                if (fcmToken) {
                    notifications.push({
                        token: fcmToken,
                        notification: {
                            title: "Nouvelle formation disponible !",
                            body:
                                post.title ||
                                "Une nouvelle formation vient d'être publiée",
                        },
                        data: {
                            type: "newTraining",
                            resourceId: postId,
                            click_action: "FLUTTER_NOTIFICATION_CLICK",
                        },
                    });
                }
            }

            // Commit all notification documents
            await batch.commit();
            console.log(
                `Created ${usersSnapshot.docs.length} notification documents`
            );

            // Send FCM messages
            if (notifications.length > 0) {
                const messages = notifications.map((notif) => ({
                    token: notif.token,
                    notification: notif.notification,
                    data: notif.data,
                    android: {
                        priority: "high" as const,
                        notification: {
                            channelId: "novopharma_channel",
                            sound: "default",
                        },
                    },
                    apns: {
                        payload: {
                            aps: {
                                sound: "default",
                                badge: 1,
                            },
                        },
                    },
                }));

                const response = await admin.messaging().sendEach(messages);
                console.log(
                    `Sent ${response.successCount} FCM notifications, ` +
                    `${response.failureCount} failures`
                );
            }

            return {success: true};
        } catch (error) {
            console.error("Error sending training notifications:", error);
            return {success: false, error};
        }
    });

/**
 * Sends a notification to all users when a new badge is created
 */
export const onNewBadgeCreated = functions.firestore
    .document("badges/{badgeId}")
    .onCreate(async (snap, context) => {
        const badge = snap.data();
        const badgeId = context.params.badgeId;

        console.log(`New badge created: ${badgeId}`);

        try {
            // Get all users
            const usersSnapshot = await admin
                .firestore()
                .collection("users")
                .get();

            const batch = admin.firestore().batch();
            const notifications: Array<{
                token: string;
                notification: admin.messaging.Notification;
                data: { [key: string]: string };
            }> = [];

            for (const userDoc of usersSnapshot.docs) {
                const userId = userDoc.id;
                const userData = userDoc.data();
                const fcmToken = userData.fcmToken;

                // Create notification document
                const notificationRef = admin
                    .firestore()
                    .collection("users")
                    .doc(userId)
                    .collection("notifications")
                    .doc();

                batch.set(notificationRef, {
                    userId: userId,
                    title: "Nouveau badge disponible !",
                    body: badge.name || "Un nouveau badge vient d'être lancé",
                    type: "newBadge",
                    resourceId: badgeId,
                    imageUrl: badge.imageUrl || null,
                    isRead: false,
                    createdAt: admin.firestore.FieldValue.serverTimestamp(),
                });

                // Prepare FCM message if user has a token
                if (fcmToken) {
                    notifications.push({
                        token: fcmToken,
                        notification: {
                            title: "Nouveau badge disponible !",
                            body:
                                badge.name ||
                                "Un nouveau badge vient d'être lancé",
                        },
                        data: {
                            type: "newBadge",
                            resourceId: badgeId,
                            click_action: "FLUTTER_NOTIFICATION_CLICK",
                        },
                    });
                }
            }

            // Commit all notification documents
            await batch.commit();
            console.log(
                `Created ${usersSnapshot.docs.length} notification documents`
            );

            // Send FCM messages
            if (notifications.length > 0) {
                const messages = notifications.map((notif) => ({
                    token: notif.token,
                    notification: notif.notification,
                    data: notif.data,
                    android: {
                        priority: "high" as const,
                        notification: {
                            channelId: "novopharma_channel",
                            sound: "default",
                        },
                    },
                    apns: {
                        payload: {
                            aps: {
                                sound: "default",
                                badge: 1,
                            },
                        },
                    },
                }));

                const response = await admin.messaging().sendEach(messages);
                console.log(
                    `Sent ${response.successCount} FCM notifications, ` +
                    `${response.failureCount} failures`
                );
            }

            return {success: true};
        } catch (error) {
            console.error("Error sending badge notifications:", error);
            return {success: false, error};
        }
    });

/**
 * Sends a notification to a user when they earn a badge
 */
export const onUserBadgeAwarded = functions.firestore
    .document("users/{userId}/userBadges/{badgeId}")
    .onCreate(async (snap, context) => {
        const userId = context.params.userId as string;
        const badgeId = context.params.badgeId as string;

        console.log(`User ${userId} earned badge ${badgeId}`);

        try {
            // Get badge details
            const badgeDoc = await admin
                .firestore()
                .collection("badges")
                .doc(badgeId)
                .get();
            const badge = badgeDoc.data();

            // Get user FCM token
            const userDoc = await admin
                .firestore()
                .collection("users")
                .doc(userId)
                .get();
            const userData = userDoc.data();
            const fcmToken = userData?.fcmToken;

            // Create notification document
            const notificationRef = admin
                .firestore()
                .collection("users")
                .doc(userId)
                .collection("notifications")
                .doc();

            const badgeName = badge?.name || "Nouveau badge";
            const notificationBody = `Vous avez obtenu le badge "${badgeName}"`;

            await notificationRef.set({
                userId: userId,
                title: "Félicitations ! 🎉",
                body: notificationBody,
                type: "achievement",
                resourceId: badgeId,
                imageUrl: badge?.imageUrl || null,
                isRead: false,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });

            // Send FCM notification if user has a token
            if (fcmToken) {
                await admin.messaging().send({
                    token: fcmToken,
                    notification: {
                        title: "Félicitations ! 🎉",
                        body: notificationBody,
                    },
                    data: {
                        type: "achievement",
                        resourceId: badgeId,
                        click_action: "FLUTTER_NOTIFICATION_CLICK",
                    },
                    android: {
                        priority: "high",
                        notification: {
                            channelId: "novopharma_channel",
                            sound: "default",
                        },
                    },
                    apns: {
                        payload: {
                            aps: {
                                sound: "default",
                                badge: 1,
                            },
                        },
                    },
                });
            }

            return {success: true};
        } catch (error) {
            console.error(
                "Error sending badge achievement notification:",
                error
            );
            return {success: false, error};
        }
    });
