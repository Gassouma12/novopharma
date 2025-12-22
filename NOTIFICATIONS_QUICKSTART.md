# Quick Start: Push Notifications

## ⚡ 5-Minute Setup

### Step 1: Deploy Cloud Functions
```bash
cd functions
npm install
firebase deploy --only functions
```

### Step 2: Android Manifest (android/app/src/main/AndroidManifest.xml)
Add inside `<application>` tag:
```xml
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="novopharma_channel" />
```

### Step 3: Test It!
1. Run: `flutter run`
2. Grant notification permissions
3. In Firebase Console, create a new document in `trainings` collection:
   ```json
   {
     "title": "Test Formation",
     "imageUrl": "https://example.com/image.jpg",
     "createdAt": <current timestamp>
   }
   ```
4. Watch notifications appear! 🎉

## 📱 Features You Get

- ✅ Bell icon with unread badge in dashboard
- ✅ Push notifications for new trainings/badges
- ✅ Swipe to delete notifications
- ✅ Tap to navigate to content
- ✅ Mark all as read button
- ✅ Real-time updates
- ✅ Automatic FCM token management

## 🧪 Testing Commands

```bash
# Check Cloud Functions logs
firebase functions:log

# Test specific function
firebase functions:shell

# View Firestore notifications
# Go to: users/{userId}/notifications in Firebase Console
```

## 🔍 Debug Checklist

**Notifications not appearing?**
1. Check console for: `[NotificationService] FCM Token: ...`
2. Verify Cloud Functions deployed: `firebase functions:list`
3. Check function logs: `firebase functions:log`
4. Ensure permissions granted in device settings

**Deep linking not working?**
1. Verify route exists in `navigation.dart`
2. Check `notification_provider.dart` → `getNavigationRoute()`
3. Test navigation manually first

## 📊 Firestore Structure

```
users/
  {userId}/
    fcmToken: "eyJhbGciOiJI..."
    fcmTokenUpdatedAt: timestamp
    notifications/
      {notificationId}/
        title: "Nouvelle formation disponible !"
        body: "Formation X est maintenant disponible"
        type: "newTraining"
        resourceId: "training123"
        imageUrl: "https://..."
        isRead: false
        createdAt: timestamp
```

## 🚀 Production Deployment

1. **iOS**: Upload APNs certificate to Firebase Console
2. **Android**: Already configured with google-services.json
3. **Functions**: `firebase deploy --only functions --project prod`
4. **Test**: Send test notifications to real devices

## 💡 Pro Tips

- Notification tokens can expire - app refreshes automatically
- Cloud Functions run on all new documents (onCreate trigger)
- Badge achievements trigger individually per user
- Notifications auto-cleanup after 30 days (add cron job)

---

**Need help?** Check `PUSH_NOTIFICATIONS_SETUP.md` for detailed instructions.
