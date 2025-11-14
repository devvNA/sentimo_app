import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'quick_checkin_modal.dart';

/// Floating action button for quick check-in
class QuickCheckInButton extends StatelessWidget {
  const QuickCheckInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showQuickCheckInModal(context),
      backgroundColor: AppTheme.brightBlue,
      icon: const Icon(Icons.add_reaction_outlined),
      label: const Text(
        'Quick Check-in',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showQuickCheckInModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const QuickCheckInModal(),
    );
  }
}
