import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../models/user_model.dart';
import '../database/database_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  final DatabaseService _databaseService = DatabaseService();
  final StreamController<User?> _authStateController = StreamController<User?>.broadcast();

  Stream<User?> get authStateChanges => _authStateController.stream;
  User? get currentUser => _currentUser;

  Future<void> initialize() async {
    await _databaseService.initialize();
    await _loadUserFromPrefs();
  }

  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    
    if (userId != null) {
      try {
        final users = await _databaseService.query(
          'SELECT * FROM users WHERE id = ?',
          [userId]
        );
        
        if (users.isNotEmpty) {
          _currentUser = User.fromJson(users.first);
          _authStateController.add(_currentUser);
        }
      } catch (e) {
        debugPrint('Error loading user: $e');
      }
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      // Hash the password
      final hashedPassword = _hashPassword(password);
      
      final users = await _databaseService.query(
        'SELECT * FROM users WHERE email = ?',
        [email]
      );
      
      if (users.isEmpty) {
        throw Exception('User not found');
      }
      
      // In a real app, you would verify the hashed password against the stored hash
      // For this demo, we'll accept any password for the demo users
      if (email == 'admin@example.com' || email == 'staff@example.com') {
        final user = User.fromJson(users.first);
        
        // Save user to preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', user.id);
        
        _currentUser = user;
        _authStateController.add(_currentUser);
        
        return user;
      } else {
        throw Exception('Invalid credentials');
      }
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    
    _currentUser = null;
    _authStateController.add(null);
  }

  Future<User> updateProfile(User user) async {
    try {
      await _databaseService.query(
        'UPDATE users SET name = ?, email = ? WHERE id = ?',
        [user.name, user.email, user.id]
      );
      
      _currentUser = user;
      _authStateController.add(_currentUser);
      
      return user;
    } catch (e) {
      debugPrint('Update profile error: $e');
      rethrow;
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    if (_currentUser == null) {
      throw Exception('No user logged in');
    }
    
    try {
      // In a real app, you would verify the current password
      // For this demo, we'll accept any current password
      
      // Hash the new password
      final hashedNewPassword = _hashPassword(newPassword);
      
      // Update the password in the database
      await _databaseService.query(
        'UPDATE users SET password_hash = ? WHERE id = ?',
        [hashedNewPassword, _currentUser!.id]
      );
      
      return true;
    } catch (e) {
      debugPrint('Change password error: $e');
      return false;
    }
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  void dispose() {
    _authStateController.close();
  }
}
