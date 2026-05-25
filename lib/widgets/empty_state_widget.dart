import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import './custom_icon_widget.dart';

class EmptyStateWidget extends StatelessWidget {
  final String iconName;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.iconName,
    required this.title,
    required this.subtitle,
    this.buttonLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: iconName,
                  color: theme.colorScheme.primary.withAlpha(153),
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(buttonLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
