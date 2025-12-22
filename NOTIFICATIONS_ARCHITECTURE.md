# Push Notifications Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                         FIREBASE BACKEND                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Firestore Collections:                                            │
│  ┌──────────────┐         ┌──────────────┐      ┌──────────────┐ │
│  │   trainings  │         │    badges    │      │     users    │ │
│  │   (create)   │         │   (create)   │      │  {userId}    │ │
│  └──────┬───────┘         └──────┬───────┘      └──────┬───────┘ │
│         │                        │                     │          │
│         │ onCreate               │ onCreate            │          │
│         ▼                        ▼                     │          │
│  ┌─────────────────────────────────────────┐          │          │
│  │     CLOUD FUNCTIONS (Node.js)           │          │          │
│  ├─────────────────────────────────────────┤          │          │
│  │                                         │          │          │
│  │  • onNewTrainingCreated()               │          │          │
│  │    → Notifies ALL users                 │◄─────────┼──────┐   │
│  │                                         │          │      │   │
│  │  • onNewBadgeCreated()                  │          │      │   │
│  │    → Notifies ALL users                 │          │      │   │
│  │                                         │          │      │   │
│  │  • onUserBadgeAwarded()                 │          │      │   │
│  │    → Notifies SPECIFIC user             │          │      │   │
│  │                                         │          │      │   │
│  └─────────────────┬───────────────────────┘          │      │   │
│                    │                                  │      │   │
│                    │ Batch Write                     │      │   │
│                    ▼                                  │      │   │
│         ┌──────────────────────────┐                 │      │   │
│         │  users/{userId}/         │◄────────────────┘      │   │
│         │  notifications/          │                        │   │
│         │  {notificationId}        │                        │   │
│         │  - title                 │                        │   │
│         │  - body                  │                        │   │
│         │  - type                  │                        │   │
│         │  - resourceId            │                        │   │
│         │  - isRead: false         │                        │   │
│         │  - createdAt            │                        │   │
│         └──────────┬───────────────┘                        │   │
│                    │                                        │   │
│         ┌──────────▼────────────┐                          │   │
│         │  users/{userId}       │◄─────────────────────────┘   │
│         │  - fcmToken (saved)   │                              │
│         │  - fcmTokenUpdatedAt  │                              │
│         └───────────────────────┘                              │
│                    │                                            │
└────────────────────┼────────────────────────────────────────────┘
                     │
                     │ Firebase Cloud Messaging (FCM)
                     ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      FLUTTER APP (Client)                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │              NOTIFICATION PIPELINE                           │  │
│  │                                                              │  │
│  │  1. App Start:                                              │  │
│  │     NotificationService.initialize()                        │  │
│  │     → Request permissions                                   │  │
│  │     → Get FCM token                                         │  │
│  │     → Setup listeners                                       │  │
│  │                                                              │  │
│  │  2. User Login:                                             │  │
│  │     AuthProvider._onAuthStateChanged()                      │  │
│  │     → Save FCM token to Firestore                           │  │
│  │     → NotificationProvider.initializeNotifications()        │  │
│  │                                                              │  │
│  │  3. Receive Notification:                                   │  │
│  │     ┌─────────────────────────────────────────┐            │  │
│  │     │  App State: FOREGROUND                  │            │  │
│  │     │  → FirebaseMessaging.onMessage          │            │  │
│  │     │  → Show local notification               │            │  │
│  │     │  → Update NotificationProvider           │            │  │
│  │     └─────────────────────────────────────────┘            │  │
│  │     ┌─────────────────────────────────────────┐            │  │
│  │     │  App State: BACKGROUND/TERMINATED        │            │  │
│  │     │  → System shows push notification        │            │  │
│  │     │  → FirebaseMessaging.onMessageOpenedApp  │            │  │
│  │     └─────────────────────────────────────────┘            │  │
│  │                                                              │  │
│  │  4. Real-time Stream:                                       │  │
│  │     Firestore.collection('users/{userId}/notifications')   │  │
│  │     .orderBy('createdAt', desc)                             │  │
│  │     .snapshots()                                            │  │
│  │     → Auto-updates NotificationProvider                     │  │
│  │     → Updates UI badge count                                │  │
│  │                                                              │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │                    UI COMPONENTS                             │  │
│  │                                                              │  │
│  │  DashboardHeader                                            │  │
│  │  ├─ Bell Icon                                               │  │
│  │  └─ Unread Badge (red dot)                                  │  │
│  │      │                                                       │  │
│  │      │ onTap                                                 │  │
│  │      ▼                                                       │  │
│  │  NotificationsScreen                                        │  │
│  │  ├─ ListView of notifications                               │  │
│  │  ├─ Swipe to delete                                         │  │
│  │  ├─ Tap to mark as read & navigate                          │  │
│  │  └─ "Mark all as read" button                               │  │
│  │                                                              │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │               STATE MANAGEMENT (Provider)                    │  │
│  │                                                              │  │
│  │  NotificationProvider:                                      │  │
│  │  • notifications: List<NotificationModel>                   │  │
│  │  • unreadCount: int                                         │  │
│  │  • isLoading: bool                                          │  │
│  │                                                              │  │
│  │  Methods:                                                   │  │
│  │  • initializeNotifications(userId)                          │  │
│  │  • markAsRead(userId, notificationId)                       │  │
│  │  • markAllAsRead(userId)                                    │  │
│  │  • deleteNotification(userId, notificationId)               │  │
│  │  • getNavigationRoute(notification)                         │  │
│  │                                                              │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Notification Types

```
┌─────────────────┬──────────────────────┬─────────────────────────────┐
│ Type            │ Triggered By         │ Sent To                     │
├─────────────────┼──────────────────────┼─────────────────────────────┤
│ newTraining     │ onCreate(trainings)  │ ALL users                   │
│ newBadge        │ onCreate(badges)     │ ALL users                   │
│ achievement     │ onCreate(userBadges) │ SPECIFIC user (badge owner) │
│ reminder        │ Manual/Scheduled     │ SPECIFIC user or ALL        │
└─────────────────┴──────────────────────┴─────────────────────────────┘
```

## Navigation Flow

```
User taps notification
        ↓
NotificationProvider.getNavigationRoute()
        ↓
    ┌───────────────────────────────┐
    │ Switch on notification.type:  │
    ├───────────────────────────────┤
    │ newTraining → /training/{id}  │
    │ newBadge    → /badges         │
    │ achievement → /badges         │
    │ reminder    → null            │
    └───────────────────────────────┘
        ↓
Navigator.pushNamed(context, route)
        ↓
User views content
```

## Data Flow Diagram

```
Admin Action (Firebase Console)
        ↓
    Create Document
        ↓
    ┌─────────────┐
    │  trainings  │ ─────┐
    │  OR         │      │
    │  badges     │      │
    └─────────────┘      │
                         │ onCreate Trigger
                         ↓
                 ┌───────────────┐
                 │ Cloud Function│
                 └───────┬───────┘
                         │
         ┌───────────────┼───────────────┐
         │               │               │
         ▼               ▼               ▼
    Create          Send FCM        Update
    Firestore       Messages        Token
    Documents       (Push)          (if needed)
         │               │               │
         └───────────────┴───────────────┘
                         │
                         ▼
                 ┌──────────────┐
                 │ User Device  │
                 └──────┬───────┘
                        │
         ┌──────────────┼──────────────┐
         │              │              │
         ▼              ▼              ▼
    Show Push      Update UI      Play Sound
    Notification   Badge Count    /Vibrate
```

## Security Model

```
Firestore Rules:
┌──────────────────────────────────────────────────────────────┐
│ match /users/{userId}/notifications/{notificationId} {      │
│   allow read: if request.auth.uid == userId;                │
│   allow write: if request.auth.uid == userId;               │
│ }                                                            │
└──────────────────────────────────────────────────────────────┘

Cloud Functions:
┌──────────────────────────────────────────────────────────────┐
│ • Run with admin privileges (bypass Firestore rules)        │
│ • Can write to any user's notification subcollection        │
│ • Can send FCM messages to any device                       │
│ • Validate data before writing                              │
└──────────────────────────────────────────────────────────────┘
```

## Performance Considerations

```
Optimization Strategy:
┌──────────────────────────────────────────────────────────────┐
│ 1. Pagination: Load 50 notifications at a time              │
│ 2. Indexing: orderBy('createdAt', descending)               │
│ 3. Caching: Provider keeps notifications in memory          │
│ 4. Batching: Cloud Functions use batch writes               │
│ 5. Streaming: Real-time updates without polling             │
│ 6. Cleanup: Auto-delete old notifications (future)          │
└──────────────────────────────────────────────────────────────┘
```

## Error Handling

```
┌─────────────────────────────────────────────────────────────┐
│ Scenario                    │ Handling                      │
├────────────────────────────┼───────────────────────────────┤
│ FCM token expired          │ Auto-refresh on app start     │
│ Permission denied          │ Show permission prompt        │
│ Network offline            │ Queue and retry when online   │
│ Cloud Function fails       │ Log error, retry logic        │
│ Invalid notification data  │ Skip and log error            │
│ Deep link route not found  │ Navigate to home screen       │
└────────────────────────────┴───────────────────────────────┘
```

## Monitoring & Debugging

```
Logs to Check:
┌──────────────────────────────────────────────────────────────┐
│ 1. Flutter Console:                                          │
│    [NotificationService] FCM Token: ...                      │
│    [NotificationService] Foreground message: ...             │
│    [AuthProvider] FCM token saved for user: ...              │
│                                                              │
│ 2. Firebase Functions Logs:                                 │
│    firebase functions:log                                    │
│    → Check onCreate triggers                                 │
│    → Verify batch writes                                     │
│    → Monitor FCM send results                                │
│                                                              │
│ 3. Firestore Console:                                       │
│    Check users/{userId}/notifications collection            │
│    Verify documents created with correct structure           │
│                                                              │
│ 4. FCM Debug:                                                │
│    Firebase Console → Cloud Messaging → Send test message    │
│    Use FCM token from app logs                               │
└──────────────────────────────────────────────────────────────┘
```
