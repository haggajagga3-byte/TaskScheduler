import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeHeadlineWidget extends StatelessWidget {
  final int taskCount;

  const HomeHeadlineWidget({super.key, required this.taskCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'You have ',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurface,
                  height: 1.2,
                ),
              ),
              TextSpan(
                text: '$taskCount',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: taskCount == 1 ? 'task' : 'tasks',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                  height: 1.2,
                ),
              ),
              TextSpan(
                text: ' for today',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurface,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
