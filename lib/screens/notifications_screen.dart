import 'package:flutter/material.dart';
import 'package:novopharma/controllers/notification_provider.dart';
import 'package:novopharma/controllers/auth_provider.dart';
import 'package:novopharma/models/notification_model.dart';
import 'package:novopharma/models/blog_post.dart';
import 'package:novopharma/screens/badges_screen.dart';
import 'package:novopharma/screens/formation_details_screen.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Configure timeago for French
    timeago.setLocaleMessages('fr', timeago.FrMessages());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Consumer2<NotificationProvider, AuthProvider>(
            builder: (context, notificationProvider, authProvider, _) {
              if (notificationProvider.unreadCount == 0)
                return const SizedBox();

              return TextButton(
                onPressed: () {
                  final userId = authProvider.userProfile?.uid;
                  if (userId != null) {
                    notificationProvider.markAllAsRead(userId);
                  }
                },
                child: const Text(
                  'Tout marquer lu',
                  style: TextStyle(
                    color: Color(0xFF1F9BD1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer2<NotificationProvider, AuthProvider>(
        builder: (context, notificationProvider, authProvider, _) {
          if (notificationProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = notificationProvider.notifications;

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      size: 64,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune notification',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Vous serez notifié des nouvelles formations\net badges disponibles',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationCard(
                context,
                notification,
                authProvider.userProfile?.uid ?? '',
                notificationProvider,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationModel notification,
    String userId,
    NotificationProvider provider,
  ) {
    return Dismissible(
      key: Key(notification.id),
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        provider.deleteNotification(userId, notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification supprimée'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : const Color(0xFFF0F9FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead
                ? const Color(0xFFE5E7EB)
                : const Color(0xFF93C5FD),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              // Mark as read
              if (!notification.isRead) {
                await provider.markAsRead(userId, notification.id);
              }

              // Navigate based on notification type
              if (notification.type == NotificationType.newTraining) {
                // Fetch the formation from Firestore
                try {
                  final doc = await FirebaseFirestore.instance
                      .collection('blogPosts')
                      .doc(notification.resourceId)
                      .get();

                  if (doc.exists && context.mounted) {
                    final formation = BlogPost.fromFirestore(doc);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FormationDetailsScreen(formation: formation),
                      ),
                    );
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Formation introuvable'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } else if (notification.type == NotificationType.newBadge ||
                  notification.type == NotificationType.achievement) {
                // Navigate to badges screen
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BadgesScreen(),
                    ),
                  );
                }
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getNotificationColor(
                        notification.type,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getNotificationIcon(notification.type),
                      color: _getNotificationColor(notification.type),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: notification.isRead
                                      ? FontWeight.w600
                                      : FontWeight.bold,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1F9BD1),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.body,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          timeago.format(notification.createdAt, locale: 'fr'),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.newTraining:
        return Icons.school_rounded;
      case NotificationType.newBadge:
        return Icons.military_tech_rounded;
      case NotificationType.achievement:
        return Icons.emoji_events_rounded;
      case NotificationType.reminder:
        return Icons.notifications_active_rounded;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.newTraining:
        return const Color(0xFF3B82F6);
      case NotificationType.newBadge:
        return const Color(0xFFF59E0B);
      case NotificationType.achievement:
        return const Color(0xFF10B981);
      case NotificationType.reminder:
        return const Color(0xFF6366F1);
    }
  }
}
