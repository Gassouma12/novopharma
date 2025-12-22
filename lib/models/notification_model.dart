import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType { newTraining, newBadge, achievement, reminder }

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final String? resourceId; // ID of the training or badge
  final String? imageUrl;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.resourceId,
    this.imageUrl,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: _parseNotificationType(data['type']),
      resourceId: data['resourceId'],
      imageUrl: data['imageUrl'],
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'type': type.name,
      'resourceId': resourceId,
      'imageUrl': imageUrl,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static NotificationType _parseNotificationType(String? type) {
    switch (type) {
      case 'newTraining':
        return NotificationType.newTraining;
      case 'newBadge':
        return NotificationType.newBadge;
      case 'achievement':
        return NotificationType.achievement;
      case 'reminder':
        return NotificationType.reminder;
      default:
        return NotificationType.reminder;
    }
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    NotificationType? type,
    String? resourceId,
    String? imageUrl,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      resourceId: resourceId ?? this.resourceId,
      imageUrl: imageUrl ?? this.imageUrl,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
