import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/entities/quick_checkin.dart';
import '../../../../core/theme/app_theme.dart';
import '../../bloc/bloc.dart';

/// Modal for quick mood check-in
class QuickCheckInModal extends StatefulWidget {
  const QuickCheckInModal({super.key});

  @override
  State<QuickCheckInModal> createState() => _QuickCheckInModalState();
}

class _QuickCheckInModalState extends State<QuickCheckInModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _noteController = TextEditingController();

  String? _selectedEmoji;
  int? _selectedRating;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<QuickCheckInBloc, QuickCheckInState>(
      listener: (context, state) {
        if (state is QuickCheckInSuccess) {
          // Show success message and close
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Check-in saved! 🎉'),
              backgroundColor: AppTheme.mintGreen,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.of(context).pop();
        } else if (state is QuickCheckInError) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppTheme.darkBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.darkTextSecondary.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quick Check-in',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    color: AppTheme.darkTextSecondary,
                  ),
                ],
              ),
            ),

            // Tab bar
            TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.brightBlue,
              labelColor: AppTheme.white,
              unselectedLabelColor: AppTheme.darkTextSecondary,
              tabs: const [
                Tab(text: 'Emoji'),
                Tab(text: 'Rating'),
              ],
            ),

            // Tab views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildEmojiTab(), _buildRatingTab()],
              ),
            ),

            // Note input
            _buildNoteInput(),

            // Submit button
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How are you feeling?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.white,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: CheckInEmojis.all.map((emoji) {
              final isSelected = _selectedEmoji == emoji;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedEmoji = emoji;
                  });
                },
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.brightBlue.withOpacity(0.2)
                        : AppTheme.darkCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.brightBlue
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 36)),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rate your mood (1-5)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.white,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final rating = index + 1;
              final isSelected = _selectedRating == rating;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRating = rating;
                  });
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.brightBlue.withOpacity(0.2)
                        : AppTheme.darkCard,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.brightBlue
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$rating',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? AppTheme.white
                            : AppTheme.darkTextSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '😢 Low',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.darkTextSecondary,
                ),
              ),
              Text(
                'High 😄',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.darkTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoteInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add a note (optional)',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.darkTextSecondary,
                ),
              ),
              Text(
                '${_noteController.text.length}/100',
                style: TextStyle(
                  fontSize: 12,
                  color: _noteController.text.length > 100
                      ? Colors.red
                      : AppTheme.darkTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            maxLength: 100,
            maxLines: 2,
            style: const TextStyle(color: AppTheme.darkText),
            decoration: InputDecoration(
              hintText: 'What\'s on your mind?',
              hintStyle: TextStyle(color: AppTheme.darkTextSecondary),
              filled: true,
              fillColor: AppTheme.darkCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              counterText: '',
            ),
            onChanged: (value) {
              setState(() {}); // Update character count
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: BlocBuilder<QuickCheckInBloc, QuickCheckInState>(
        builder: (context, state) {
          final isSubmitting = state is QuickCheckInSubmitting;
          final canSubmit =
              (_selectedEmoji != null || _selectedRating != null) &&
              _noteController.text.length <= 100;

          return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSubmitting || !canSubmit
                  ? null
                  : () => _handleSubmit(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.brightBlue,
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: AppTheme.darkCard,
                disabledForegroundColor: AppTheme.darkTextSecondary,
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.white,
                        ),
                      ),
                    )
                  : const Text(
                      'Save Check-in',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  void _handleSubmit(BuildContext context) {
    final note = _noteController.text.trim();
    final noteToSubmit = note.isEmpty ? null : note;

    if (_tabController.index == 0 && _selectedEmoji != null) {
      // Submit emoji check-in
      context.read<QuickCheckInBloc>().add(
        SubmitEmojiCheckIn(emoji: _selectedEmoji!, note: noteToSubmit),
      );
    } else if (_tabController.index == 1 && _selectedRating != null) {
      // Submit rating check-in
      context.read<QuickCheckInBloc>().add(
        SubmitRatingCheckIn(rating: _selectedRating!, note: noteToSubmit),
      );
    }
  }
}
