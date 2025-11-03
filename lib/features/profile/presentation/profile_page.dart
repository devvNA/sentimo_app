import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../journal/presentation/new_entry_page.dart';
import '../../home/presentation/home_page.dart';
import '../../../data/repositories/auth_repository.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final int _selectedIndex = 2;
  String? _userEmail;
  String? _userName;

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
        _userName = _extractNameFromEmail(user.email ?? '');
      });
    }
  }

  String _extractNameFromEmail(String email) {
    if (email.isEmpty) return 'User';
    final username = email.split('@').first;
    final parts = username.split('.');
    return parts
        .map((part) => part.isNotEmpty
            ? '${part[0].toUpperCase()}${part.substring(1)}'
            : '')
        .join(' ');
  }

  void _onNavTapped(int index) {
    if (index == _selectedIndex) return;

    if (index == 0) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const HomePage(),
        ),
      );
    } else if (index == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const NewEntryPage(),
        ),
      );
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text(
          'Log Out',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: Color(0xFF9CA3AF)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.darkTextSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
            child: const Text(
              'Log Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            Container(
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
              icon: Icons.person_outline,
              iconColor: AppTheme.brightBlue,
              title: 'Account Settings',
              onTap: () {
                // TODO: Navigate to account settings
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Account Settings - Coming Soon'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildMenuItem(
              icon: Icons.notifications_outlined,
              iconColor: AppTheme.brightBlue,
              title: 'Notifications',
              onTap: () {
                // TODO: Navigate to notifications
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notifications - Coming Soon'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildMenuItem(
              icon: Icons.lock_outline,
              iconColor: AppTheme.brightBlue,
              title: 'Privacy Policy',
              onTap: () {
                // TODO: Navigate to privacy policy
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Privacy Policy - Coming Soon'),
                    duration: Duration(seconds: 1),
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 8,
        ),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: iconBgColor ?? const Color(0xFF1E3A5F),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 28,
          ),
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
            color: isSelected ? AppTheme.brightBlue : AppTheme.darkTextSecondary,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppTheme.brightBlue : AppTheme.darkTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
