import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';
import '../../services/auth/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isEditing = false;
  bool _isSaving = false;
  
  final AuthService _authService = AuthService();
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: '(555) 123-4567'); // Mock data
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  
  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }
  
  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });
      
      try {
        // Create updated user object
        final updatedUser = User(
          id: widget.user.id,
          name: _nameController.text,
          email: _emailController.text,
          role: widget.user.role,
          avatarUrl: widget.user.avatarUrl,
        );
        
        // Update user profile
        await _authService.updateProfile(updatedUser);
        
        setState(() {
          _isEditing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColors.primary,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 32),
            _buildProfileForm(),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              widget.user.name[0].toUpperCase(),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.user.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.user.role == UserRole.admin 
                  ? AppColors.primary.withOpacity(0.1) 
                  : AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              widget.user.role == UserRole.admin ? 'Admin' : 'Staff',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: widget.user.role == UserRole.admin 
                    ? AppColors.primary 
                    : AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProfileForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Account Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: widget.user.role == UserRole.admin ? 'Admin' : 'Staff',
            decoration: const InputDecoration(
              labelText: 'Role',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            enabled: false,
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: 'Active',
            decoration: const InputDecoration(
              labelText: 'Status',
              prefixIcon: Icon(Icons.check_circle_outline),
            ),
            enabled: false,
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_isEditing) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: _isSaving ? null : _toggleEdit,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save'),
            ),
          ),
        ] else ...[
          Expanded(
            child: ElevatedButton(
              onPressed: _toggleEdit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Edit Profile'),
            ),
          ),
        ],
      ],
    );
  }
}
