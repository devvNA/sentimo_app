import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../bloc/bloc.dart';

/// Search bar widget with debouncing
class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _controller,
        style: const TextStyle(color: AppTheme.darkText),
        decoration: InputDecoration(
          hintText: 'Search entries...',
          hintStyle: const TextStyle(color: AppTheme.darkTextSecondary),
          prefixIcon: const Icon(
            Icons.search,
            color: AppTheme.darkTextSecondary,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: AppTheme.darkTextSecondary,
                  ),
                  onPressed: () {
                    _controller.clear();
                    context.read<SearchFilterBloc>().add(
                      const SearchTextChanged(''),
                    );
                  },
                )
              : null,
          filled: true,
          fillColor: AppTheme.darkCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          setState(() {}); // Update to show/hide clear button
          context.read<SearchFilterBloc>().add(SearchTextChanged(value));
        },
      ),
    );
  }
}
