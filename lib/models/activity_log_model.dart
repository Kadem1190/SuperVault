import 'user_model.dart';

enum ActivityType { create, read, update, delete }
class ActivityLog {
  final String id;
  final String userId;
  final String userName;
  final UserRole userRole;
  final ActivityType activityType;
  final String entityType;
  final String entityId;
  final String description;
  final DateTime timestamp;

  ActivityLog({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.activityType,
    required this.entityType,
    required this.entityId,
    required this.description,
    required this.timestamp,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    ActivityType getActivityType(String typeStr) {
      switch (typeStr) {
        case 'create':
          return ActivityType.create;
        case 'read':
          return ActivityType.read;
        case 'update':
          return ActivityType.update;
        case 'delete':
          return ActivityType.delete;
        default:
          return ActivityType.read;
      }
    }

    return ActivityLog(
      id: json['id'],
      userId: json['user_id'],
      userName: json['user_name'],
      userRole: json['user_role'] == 'admin' ? UserRole.admin : UserRole.staff,
      activityType: getActivityType(json['activity_type']),
      entityType: json['entity_type'],
      entityId: json['entity_id'],
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    String getActivityTypeString(ActivityType type) {
      switch (type) {
        case ActivityType.create:
          return 'create';
        case ActivityType.read:
          return 'read';
        case ActivityType.update:
          return 'update';
        case ActivityType.delete:
          return 'delete';
      }
    }

    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_role': userRole == UserRole.admin ? 'admin' : 'staff',
      'activity_type': getActivityTypeString(activityType),
      'entity_type': entityType,
      'entity_id': entityId,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
