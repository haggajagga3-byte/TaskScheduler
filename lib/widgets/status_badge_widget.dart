import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusBadgeWidget extends StatelessWidget {
  final String label;
  final Color color;
  final double fontSize;

  const StatusBadgeWidget({
    super.key,
    required this.label,
    required this.color,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(31),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(77), width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
