import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'utils/app_theme.dart';
import 'services/database/database_service.dart';
import 'services/auth/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database service
  final databaseService = DatabaseService();
  await databaseService.initialize();
  
  // Initialize auth service
  final authService = AuthService();
  await authService.initialize();
  
  runApp(const SuperVaultApp());
}

class SuperVaultApp extends StatelessWidget {
  const SuperVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SuperVault',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const LoginScreen(),
    );
  }
}
