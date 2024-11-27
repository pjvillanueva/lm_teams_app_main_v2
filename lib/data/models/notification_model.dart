import 'package:equatable/equatable.dart';
import 'package:lm_teams_app/data/models/image%20models/image_object.dart';

enum NotificationType { delete }

class Notification extends Equatable {
  const Notification({
    required this.id,
    required this.targetUsers,
    required this.isRead,
    required this.type,
    required this.data,
    required this.showWhen,
  });

  final String id;
  final List<String> targetUsers;
  final bool isRead;
  final NotificationType type;
  final NotificationData data;
  final DateTime showWhen; 

  @override
  List<Object?> get props => [id, targetUsers, isRead, type, data];
}

abstract class NotificationData {
  const NotificationData();
}

class DeleteNotificationData extends NotificationData {
  DeleteNotificationData({
    required this.table,
    required this.image,
    required this.message,
    required this.isRead,
    required this.deletedAt,
  });

  final String table;
  final ImageObject? image;
  final String message;
  final bool isRead;
  final DateTime deletedAt;
}
