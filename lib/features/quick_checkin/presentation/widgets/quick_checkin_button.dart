import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../data/repositories/quick_checkin_repository.dart';
import '../../../../data/repositories/streak_repository.dart';
import '../../bloc/bloc.dart';
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
      builder: (_) => BlocProvider(
        create: (context) => QuickCheckInBloc(
          checkInRepository: context.read<QuickCheckInRepository>(),
          streakRepository: context.read<StreakRepository>(),
        ),
        child: const QuickCheckInModal(),
      ),
    );
  }
}
