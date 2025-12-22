# Push Notifications Setup Guide for Novopharma

## Overview
This guide details the complete push notification system implementation, including Firebase Cloud Messaging (FCM), local notifications, and Cloud Functions triggers.

## Features Implemented

### 1. **Notification Types**
- `newTraining`: Triggered when new training content is published
- `newBadge`: Triggered when a new badge is launched
- `achievement`: Triggered when a user earns a badge
- `reminder`: For future reminder notifications

### 2. **Storage Structure**
```
users/{userId}/notifications/{notificationId}
  - userId: string
  - title: string
  - body: string
  - type: string (newTraining, newBadge, achievement, reminder)
  - resourceId: string (ID of training or badge)
  - imageUrl: string (optional)
  - isRead: boolean
  - createdAt: timestamp
```

### 3. **User Data Extension**
```
users/{userId}
  - fcmToken: string (device FCM token)
  - fcmTokenUpdatedAt: timestamp
```

## Setup Instructions

### Step 1: Install Dependencies

Run the following command:
```bash
flutter pub get
```

New dependencies added:
- `firebase_messaging: ^15.1.5` - FCM integration
- `flutter_local_notifications: ^18.1.0` - Local notification display
- `timeago: ^3.7.0` - Human-readable time formatting

### Step 2: Android Configuration

#### 2.1 Update `android/app/src/main/AndroidManifest.xml`

Add inside `<application>` tag:
```xml
<!-- FCM Notification Channel -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="novopharma_channel" />

<!-- FCM Icon -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_icon"
    android:resource="@drawable/ic_notification" />

<!-- FCM Color -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_color"
    android:resource="@color/notification_color" />
```

#### 2.2 Add notification icon
Place a white silhouette notification icon at:
`android/app/src/main/res/drawable/ic_notification.png`

#### 2.3 Create `android/app/src/main/res/values/colors.xml`
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="notification_color">#1F9BD1</color>
</resources>
```

#### 2.4 Update `android/app/build.gradle.kts`
Ensure minimum SDK version is 21 or higher:
```kotlin
defaultConfig {
    minSdk = 21
    targetSdk = 34
}
```

### Step 3: iOS Configuration

#### 3.1 Update `ios/Runner/Info.plist`
Add notification permissions:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

#### 3.2 Enable Push Notifications in Xcode
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target
3. Go to "Signing & Capabilities"
4. Click "+ Capability"
5. Add "Push Notifications"
6. Add "Background Modes" and enable:
   - Background fetch
   - Remote notifications

#### 3.3 Update `ios/Runner/AppDelegate.swift`
```swift
import UIKit
import Flutter
import firebase_core

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### Step 4: Firebase Console Configuration

#### 4.1 Android FCM Setup
1. Go to Firebase Console → Project Settings
2. Under "Cloud Messaging" tab
3. For Android, upload `google-services.json` (already done)
4. Note the Server Key (for testing)

#### 4.2 iOS APNs Setup
1. Go to Firebase Console → Project Settings → Cloud Messaging
2. Upload APNs Authentication Key or Certificate
3. Enter Team ID and Key ID

### Step 5: Deploy Cloud Functions

#### 5.1 Install Firebase CLI (if not already)
```bash
npm install -g firebase-tools
```

#### 5.2 Navigate to functions directory
```bash
cd functions
```

#### 5.3 Install dependencies
```bash
npm install
```

#### 5.4 Deploy functions
```bash
firebase deploy --only functions
```

This will deploy three Cloud Functions:
- `onNewTrainingCreated` - Triggers on new training
- `onNewBadgeCreated` - Triggers on new badge
- `onUserBadgeAwarded` - Triggers when user earns badge

### Step 6: Initialize Notifications on User Login

The system automatically:
1. Requests notification permissions on app start
2. Gets FCM token when user logs in
3. Saves token to user document
4. Listens to notifications in real-time
5. Updates unread badge count

This is handled in:
- `main.dart`: Initializes NotificationService
- `auth_provider.dart`: Can be extended to save FCM token on login
- `notification_provider.dart`: Manages notification state

### Step 7: Test Notifications

#### 7.1 Test with Firebase Console
1. Go to Firebase Console → Cloud Messaging
2. Click "Send test message"
3. Enter FCM token (check logs: `[NotificationService] FCM Token: ...`)
4. Send notification

#### 7.2 Test Cloud Functions
1. Create a new document in `trainings` collection
2. Check Cloud Functions logs: `firebase functions:log`
3. Verify notifications appear in `users/{userId}/notifications`

#### 7.3 Test in App
1. Log in to the app
2. Grant notification permissions
3. Create a new training or badge in Firebase
4. Notification should appear as:
   - Push notification (if app in background)
   - In-app notification (if app in foreground)
   - Unread badge on bell icon

## Usage

### Accessing Notifications Screen
Users can access notifications by:
1. Tapping the bell icon in dashboard header
2. Unread count displays as red dot
3. "Tout marquer lu" button marks all as read

### Notification Actions
- **Tap notification**: Marks as read and navigates to resource
- **Swipe to delete**: Removes notification
- **Mark all as read**: Clears all unread indicators

### Navigation Routes
- New Training → `/training/{trainingId}`
- New Badge → `/badges`
- Achievement → `/badges`

## Firestore Security Rules

Add to `firestore.rules`:
```
match /users/{userId}/notifications/{notificationId} {
  allow read: if request.auth.uid == userId;
  allow write: if request.auth.uid == userId;
}
```

## Testing Checklist

- [ ] Notification permissions requested on first launch
- [ ] FCM token saved to user document
- [ ] Push notifications received when app in background
- [ ] Local notifications displayed when app in foreground
- [ ] Notification bell shows unread count
- [ ] Tapping notification navigates to correct screen
- [ ] Marking as read updates UI immediately
- [ ] Swipe to delete removes notification
- [ ] Cloud Functions trigger on new training/badge
- [ ] All users receive notifications
- [ ] Badge achievement notification sent to specific user

## Troubleshooting

### Notifications not received
1. Check FCM token is saved: `users/{userId}.fcmToken`
2. Verify Cloud Functions deployed: `firebase functions:list`
3. Check function logs: `firebase functions:log`
4. Ensure notification permissions granted

### iOS notifications not working
1. Verify APNs certificates uploaded
2. Check Info.plist has UIBackgroundModes
3. Ensure Push Notifications capability enabled
4. Test with production APNs (not sandbox)

### Android notifications not showing
1. Verify google-services.json is correct
2. Check notification channel created
3. Ensure icon resource exists
4. Test on physical device (not just emulator)

## File Structure

```
lib/
├── models/
│   └── notification_model.dart          # Notification data model
├── services/
│   └── notification_service.dart        # FCM & local notification handling
├── controllers/
│   └── notification_provider.dart       # State management
├── screens/
│   └── notifications_screen.dart        # Notifications UI
└── main.dart                            # Service initialization

functions/
└── src/
    ├── index.ts                         # Function exports
    └── notifications.ts                 # Notification Cloud Functions
```

## Future Enhancements

1. **Scheduled Notifications**: Remind users about pending tasks
2. **Topic Subscriptions**: Group notifications by category
3. **Rich Notifications**: Images, action buttons
4. **Notification Settings**: Allow users to customize preferences
5. **Analytics**: Track notification open rates
6. **Deep Linking**: Direct navigation to specific content

## Support

For issues or questions, check:
- Firebase Console → Functions logs
- Flutter logs: `flutter logs`
- Firebase documentation: https://firebase.google.com/docs/cloud-messaging
