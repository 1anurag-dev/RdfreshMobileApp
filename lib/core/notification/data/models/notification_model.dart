import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.notifyTo,
    required super.type,
    required super.createdAt,
    super.data,
  });

  factory NotificationModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return NotificationModel(
      id: documentId,
      title: data['title'] as String? ?? '',
      message: data['message'] as String? ?? '',
      notifyTo: data['notifyTo'] as String? ?? '',
      type: data['type'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate().toIso8601String() ?? DateTime.now().toIso8601String(),
      data: data['data'] as Map<String, dynamic>?,
    );
  }

  factory NotificationModel.fromFCM(Map<String, dynamic> message) {
    final notification = message['notification'] as Map<String, dynamic>? ?? {};
    final data = message['data'] as Map<String, dynamic>? ?? {};
    
    return NotificationModel(
      id: message['messageId'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: notification['title'] as String? ?? '',
      message: notification['body'] as String? ?? '',
      notifyTo: data['notifyTo'] as String? ?? '',
      type: data['type'] as String? ?? '',
      createdAt: DateTime.now().toIso8601String(),
      data: data,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'message': message,
      'notifyTo': notifyTo,
      'type': type,
      'createdAt': Timestamp.fromMillisecondsSinceEpoch(DateTime.parse(createdAt).millisecondsSinceEpoch),
      'data': data,
    };
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      title: title,
      message: message,
      notifyTo: notifyTo,
      type: type,
      createdAt: createdAt,
      data: data,
    );
  }
}
