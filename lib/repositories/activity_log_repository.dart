import '../models/activity_log_model.dart';
import '../models/user_model.dart';
import '../services/database/database_service.dart';

class ActivityLogRepository {
  final DatabaseService _databaseService = DatabaseService();

  Future<List<ActivityLog>> getAllActivityLogs() async {
    final results = await _databaseService.query('SELECT * FROM activity_logs ORDER BY timestamp DESC');
    return results.map((json) => ActivityLog.fromJson(json)).toList();
  }

  Future<List<ActivityLog>> getActivityLogsByUser(String userId) async {
    final results = await _databaseService.query(
      'SELECT * FROM activity_logs WHERE user_id = ? ORDER BY timestamp DESC',
      [userId]
    );
    
    return results.map((json) => ActivityLog.fromJson(json)).toList();
  }

  Future<List<ActivityLog>> getActivityLogsByType(ActivityType type) async {
    String typeStr;
    switch (type) {
      case ActivityType.create:
        typeStr = 'create';
        break;
      case ActivityType.read:
        typeStr = 'read';
        break;
      case ActivityType.update:
        typeStr = 'update';
        break;
      case ActivityType.delete:
        typeStr = 'delete';
        break;
    }
    
    final results = await _databaseService.query(
      'SELECT * FROM activity_logs WHERE activity_type = ? ORDER BY timestamp DESC',
      [typeStr]
    );
    
    return results.map((json) => ActivityLog.fromJson(json)).toList();
  }

  Future<List<ActivityLog>> getActivityLogsByEntity(String entityType, String entityId) async {
    final results = await _databaseService.query(
      'SELECT * FROM activity_logs WHERE entity_type = ? AND entity_id = ? ORDER BY timestamp DESC',
      [entityType, entityId]
    );
    
    return results.map((json) => ActivityLog.fromJson(json)).toList();
  }

  Future<ActivityLog> createActivityLog({
    required String userId,
    required String userName,
    required UserRole userRole,
    required ActivityType activityType,
    required String entityType,
    required String entityId,
    required String description,
  }) async {
    final now = DateTime.now();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    
    String activityTypeStr;
    switch (activityType) {
      case ActivityType.create:
        activityTypeStr = 'create';
        break;
      case ActivityType.read:
        activityTypeStr = 'read';
        break;
      case ActivityType.update:
        activityTypeStr = 'update';
        break;
      case ActivityType.delete:
        activityTypeStr = 'delete';
        break;
    }
    
    final activityLog = ActivityLog(
      id: id,
      userId: userId,
      userName: userName,
      userRole: userRole,
      activityType: activityType,
      entityType: entityType,
      entityId: entityId,
      description: description,
      timestamp: now,
    );
    
    await _databaseService.query(
      '''
      INSERT INTO activity_logs 
      (id, user_id, user_name, user_role, activity_type, entity_type, entity_id, description, timestamp) 
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        activityLog.id,
        activityLog.userId,
        activityLog.userName,
        activityLog.userRole == UserRole.admin ? 'admin' : 'staff',
        activityTypeStr,
        activityLog.entityType,
        activityLog.entityId,
        activityLog.description,
        activityLog.timestamp.toIso8601String(),
      ]
    );
    
    return activityLog;
  }
}
