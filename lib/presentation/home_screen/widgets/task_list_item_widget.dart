import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/task_model.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../theme/app_theme.dart';

class TaskListItemWidget extends StatelessWidget {
  final TaskModel task;
  final Color accentColor;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;

  const TaskListItemWidget({
    super.key,
    required this.task,
    required this.accentColor,
    required this.onTap,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = AppTheme.getCategoryColor(task.category);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: accentColor.withAlpha(20),
        highlightColor: accentColor.withAlpha(10),
        child: Container(
          decoration: BoxDecoration(
            color: task.isCompleted
                ? theme.colorScheme.surfaceContainerHighest
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: task.isCompleted
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // Colored accent bar
              Container(
                width: 4,
                height: 80,
                decoration: BoxDecoration(
                  color: task.isCompleted
                      ? theme.colorScheme.outline
                      : accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: task.isCompleted
                              ? theme.colorScheme.onSurfaceVariant
                              : theme.colorScheme.onSurface,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'access_time_rounded',
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${task.startTime} – ${task.endTime}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: categoryColor.withAlpha(26),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              task.category,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: categoryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Complete toggle
              GestureDetector(
                onTap: onToggleComplete,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.isCompleted
                          ? accentColor
                          : Colors.transparent,
                      border: Border.all(
                        color: task.isCompleted
                            ? accentColor
                            : theme.colorScheme.outline,
                        width: 2,
                      ),
                    ),
                    child: task.isCompleted
                        ? const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
