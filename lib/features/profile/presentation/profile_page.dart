import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentimo/main.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../../home/presentation/home_page.dart';
import '../../journal/bloc/journal_bloc.dart';
import '../../journal/presentation/new_entry_page.dart';
import 'privacy_policy_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final int _selectedIndex = 2;
  String? _userEmail;
  String? _userName;
  String? _userAvatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authRepo = context.read<AuthRepository>();
    final user = authRepo.currentUser;
    if (user != null) {
      setState(() {
        _userEmail = user.email;
        _userName = _extractNameFromEmail(user.userMetadata?['name']);
        _userAvatarUrl = user.userMetadata?['avatar_url'];
      });
    }
  }

  String _extractNameFromEmail(String email) {
    if (email.isEmpty) return 'User';
    final username = email.split('@').first;
    final parts = username.split('.');
    return parts
        .map(
          (part) => part.isNotEmpty
              ? '${part[0].toUpperCase()}${part.substring(1)}'
              : '',
        )
        .join(' ');
  }

  void _onNavTapped(int index) {
    if (index == _selectedIndex) return;

    if (index == 0) {
      // Navigate to HomePage (replace)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<JournalBloc>(),
            child: const HomePage(),
          ),
        ),
      );
    } else if (index == 1) {
      // Push NewEntryPage as modal
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<JournalBloc>(),
            child: const NewEntryPage(),
          ),
        ),
      );
    }
  }

  void _handleLogout() {
    log('🚪 [ProfilePage] Logout dialog shown');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text('Log Out', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: Color(0xFF9CA3AF)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              log('❌ [ProfilePage] Logout cancelled');
              Navigator.of(dialogContext).pop();
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.darkTextSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              log('✅ [ProfilePage] Logout confirmed');
              Navigator.of(dialogContext).pop();
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          log('✅ [ProfilePage] Logout successful, navigating to LoginPage');
          // Clear navigation stack and go to LoginPage
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const SplashScreen()),
            (route) => false,
          );
        } else if (state is AuthError) {
          log('❌ [ProfilePage] Logout error: ${state.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              (_userAvatarUrl != null)
                  ? CircleAvatar(
                      radius: 80,
                      backgroundImage: NetworkImage(_userAvatarUrl!),
                    )
                  : Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFCDB2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 80,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 50,
                                height: 2,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 50,
                                height: 2,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 50,
                                height: 2,
                                color: Colors.grey[300],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 24),
              Text(
                _userName ?? 'Loading...',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _userEmail ?? '',
                style: TextStyle(
                  color: AppTheme.darkTextSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 48),
              _buildMenuItem(
                icon: Icons.lock_outline,
                iconColor: AppTheme.brightBlue,
                title: 'Privacy Policy',
                onTap: () {
                  log('📄 [ProfilePage] Navigating to Privacy Policy');
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PrivacyPolicyPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildMenuItem(
                icon: Icons.logout,
                iconColor: Colors.red,
                title: 'Log Out',
                titleColor: Colors.red,
                iconBgColor: const Color(0xFF4B1818),
                onTap: _handleLogout,
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 1,
                width: double.infinity,
                color: AppTheme.darkTextSecondary.withValues(alpha: 0.12),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      icon: Icons.book_outlined,
                      label: 'Journal',
                      index: 0,
                      isSelected: _selectedIndex == 0,
                    ),
                    _buildNavItem(
                      icon: Icons.add_circle_outline,
                      label: 'New Entry',
                      index: 1,
                      isSelected: _selectedIndex == 1,
                    ),
                    _buildNavItem(
                      icon: Icons.person_outline,
                      label: 'Profile',
                      index: 2,
                      isSelected: _selectedIndex == 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconBgColor,
  }) {
    return Ink(
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: iconBgColor ?? const Color(0xFF1E3A5F),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: titleColor ?? Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppTheme.darkTextSecondary,
          size: 28,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _onNavTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 28,
            color: isSelected
                ? AppTheme.brightBlue
                : AppTheme.darkTextSecondary,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? AppTheme.brightBlue
                  : AppTheme.darkTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
