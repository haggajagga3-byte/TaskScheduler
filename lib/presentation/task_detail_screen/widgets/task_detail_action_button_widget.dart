import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/custom_icon_widget.dart';

class TaskDetailActionButtonWidget extends StatelessWidget {
  final String label;
  final String iconName;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onTap;

  const TaskDetailActionButtonWidget({
    super.key,
    required this.label,
    required this.iconName,
    required this.backgroundColor,
    required this.foregroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: foregroundColor.withAlpha(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            color: onTap == null
                ? backgroundColor.withAlpha(128)
                : backgroundColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: iconName,
                color: onTap == null
                    ? foregroundColor.withAlpha(128)
                    : foregroundColor,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: onTap == null
                      ? foregroundColor.withAlpha(128)
                      : foregroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
