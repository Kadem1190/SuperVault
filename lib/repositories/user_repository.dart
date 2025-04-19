import '../models/user_model.dart';
import '../services/database/database_service.dart';

class UserRepository {
  final DatabaseService _databaseService = DatabaseService();

  Future<List<User>> getAllUsers() async {
    final results = await _databaseService.query('SELECT * FROM users');
    return results.map((json) => User.fromJson(json)).toList();
  }

  Future<User?> getUserById(String id) async {
    final results = await _databaseService.query(
      'SELECT * FROM users WHERE id = ?',
      [id]
    );
    
    if (results.isEmpty) {
      return null;
    }
    
    return User.fromJson(results.first);
  }

  Future<User> createUser(User user) async {
    final results = await _databaseService.query(
      'INSERT INTO users (id, name, email, role, avatar_url) VALUES (?, ?, ?, ?, ?)',
      [user.id, user.name, user.email, user.role == UserRole.admin ? 'admin' : 'staff', user.avatarUrl]
    );
    
    return user;
  }

  Future<User> updateUser(User user) async {
    await _databaseService.query(
      'UPDATE users SET name = ?, email = ?, role = ?, avatar_url = ? WHERE id = ?',
      [user.name, user.email, user.role == UserRole.admin ? 'admin' : 'staff', user.avatarUrl, user.id]
    );
    
    return user;
  }

  Future<bool> deleteUser(String id) async {
    final results = await _databaseService.query(
      'DELETE FROM users WHERE id = ?',
      [id]
    );
    
    return results.isNotEmpty;
  }
}
